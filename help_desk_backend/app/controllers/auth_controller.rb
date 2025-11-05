class AuthController < ApplicationController
  before_action :set_user, only: [:login, :me]
  def register
    @user = User.new(user_params)
    if @user.save
      render json: {
        user:@user,
        message:"User registered successfully"
      },status: :created
    else
      render json:{errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(username: params[:username])
    if user && user.password == params[:password]
      user.update(last_active_at: Time.current)
      render json:{message:"Login successful", user: user}, status: :ok
    else
      render json:{error:"Invalid username or password"}, status: :unauthorized
    end
  end

  def logout
    render json:{message:"Logged out successfully"}, status: :ok
  end

  def refresh
    render json:{message:"Session refreshed"}, status: :ok
  end

  def me
    user = User.find_by(id: params[:id]) # For testing; later replace with session/JWT lookup
    if user
      render json: user, status: :ok
    else
      render json:{error:"User not found"}, status: :not_found
    end
  end

  private
  def set_user
    @user = User.find_by(username: params[:username])
  end

  def user_params
    params.require(:user).permit(:username, :password)
  end


end
