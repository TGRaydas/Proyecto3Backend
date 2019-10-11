# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    user = User.find_by_email(params[:username])
    token = params[:token]
    #user.update(token: token)
    if user.valid_password?(params[:password])
      users_with_same_token = User.where(token: token)
      users_with_same_token.each do |user|
        user.update(token: nil)
      end
      user.update(token: token)
      sign_in user
      render json:{state: "success", userid: user.id}
      return
    end
    render json:{state: "invalid"}
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
