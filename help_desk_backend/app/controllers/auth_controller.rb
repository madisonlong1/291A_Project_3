class AuthController < ApplicationController
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'dev_key'

  def register
    user = User.new(username: params[:username], password: params[:password])
    if user.save
      token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, SECRET_KEY, 'HS256')
      render json: {
        user: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at },
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      user.update(last_active_at: Time.current)
      token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, SECRET_KEY, 'HS256')
      render json: {
        user: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at },
        token: token
      }, status: :ok
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  def logout
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  def refresh
    token = request.headers['Authorization']&.split(' ')&.last
    begin
      payload = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
      user = User.find(payload['user_id'])
      new_token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, SECRET_KEY, 'HS256')
      render json: {
        user: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at },
        token: new_token
      }, status: :ok
    rescue
      render json: { error: 'No session found' }, status: :unauthorized
    end
  end

  def me
    token = request.headers['Authorization']&.split(' ')&.last
    begin
      payload = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
      user = User.find(payload['user_id'])
      render json: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at }, status: :ok
    rescue
      render json: { error: 'No session found' }, status: :unauthorized
    end
  end
end
