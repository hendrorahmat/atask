module Authenticated
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    helper_method :current_user
    helper_method :user_signed_in?
  end

  def current_user
    if session[:current_user_id]
      @current_user ||= User.find_by(id: session[:current_user_id])
    end
  end

  def authenticate_user!
    raise ApiExceptions::UnauthorizedError.new if current_user.blank?
  end

  def user_signed_in?
    current_user.present?
  end
end