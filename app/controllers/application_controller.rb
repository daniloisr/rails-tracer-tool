class ApplicationController < ActionController::Base
  around_action :intercept

  def intercept
    params[:intercept] = ['Base', 'BaseDecorator']
    klasses = Array(params[:intercept]).map(&Object.method(:const_get))
    if klasses.empty?
      yield
      return
    end

    @interceptor = Interceptor.new(klasses)
    @interceptor.tracer.enable do
      yield
    end
  end
end
