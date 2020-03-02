class WelcomeController < ApplicationController
  def index
    @user = UserDecorator.new(User.new)
  end

  def get_stack
    render json: Interceptor.get(params[:id]).calls_root
  end
end
