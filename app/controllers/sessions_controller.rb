# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      session[:current_user_id] = user.id
      render json: { message: 'Logged in successfully' }
    else
      render json: { message: 'Invalid credentials', detail: "Username and password couldn't be found!", status_code: 401 }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: 'Logged out successfully' }
  end
end
