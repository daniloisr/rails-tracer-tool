class UserDecorator < BaseDecorator
  def full_name
    object.first_name + ' ' + object.last_name
  end
end


