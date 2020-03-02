class Interceptor
  # Attempt 1 - trying to replace original class with a fake
  #
  # Interceptor.for(Klass1, Klass2)
  #     -> replace the original classes wrappers
  #
  # object = klass.new
  #     -> returns a fake class that handles the original klass intenally
  #
  # object.some_method
  #     -> method missing will intercept the call and call the original method
  #
  # klass.some_static_method
  #     -> method missing will intercept the call and call the original method
  #
  # module MethodInterceptor
  #   def method_missing(methId)
  #     puts "#{@_original_obj.class.to_s}\tstart\t#{methId}"
  #     @_original_obj.send(methId)
  #     puts "#{@_original_obj.class.to_s}\tend\t#{methId}"
  #   end
  # end

  # module Wrapper
  #   def initializer(klass)
  #     Object.const_get(klass).prepend(MethodInterceptor)
  #   end
  # end

  # def self.for(klasses)
  #   klasses.each do |klass|
  #   end
  # end



  # Attempt 2 - Useing Tracepoint
  #
  # https://devdocs.io/ruby~2.6/tracepoint

  # TODO: parent isn't needed, is just a way to handle stack navigation easier
  CallStack = Struct.new(:parent, :children, :key) do
    def as_json(*)
      { key: key }
        .merge(children.empty? ? {} : { children: children.map { |i| i.as_json } })
    end
  end

  @@storage = {
    # id => tracer
  }

  def self.get(id)
    @@storage[id]
  end

  attr_reader :tracer, :id, :calls_root

  def initialize(klasses)
    @id = SecureRandom.uuid
    @klasses = klasses
    @calls_root = []
    @calls_current = CallStack.new(nil, [], nil)
    @tracer = TracePoint.new(:call, :return, &method(:tracer_handler))
    @@storage[@id] = self
    # clanup the storage a bit
    @@storage.delete[@@storage.first.first] if @@storage.size > 20
  end

  # TracePoint handler
  #
  # Handles methods calls and returns, building a callStack
  def tracer_handler(tp)
    return unless @klasses.any? {|klass| tp.defined_class <= klass }

    case tp.event
    when :call
      key = :"#{tp.defined_class}/#{tp.method_id}"
      unless @calls_current.key
        @calls_root.push(@calls_current)
        @calls_current.key = key
        return
      end

      calls_next = CallStack.new(@calls_current, [], key)
      puts "#{calls_next.key} - #{calls_next.parent.key}"

      @calls_current.children.push(calls_next)
      @calls_current = calls_next

    when :return
      @calls_current = @calls_current.parent || CallStack.new(nil, [], nil)
    end
  end
end

