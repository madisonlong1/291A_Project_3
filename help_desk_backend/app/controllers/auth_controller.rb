class AuthController < ApplicationController
  def register
    user = User.new(username: params[:username], password: params[:password])
    if user.save
      session[:user_id] = user.id
      token = JwtService.encode(user)
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
      session[:user_id] = user.id
      token = JwtService.encode(user)
      render json: {
        user: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at },
        token: token
      }, status: :ok
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  def logout
    reset_session
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  def refresh
    # Require valid session (JWT token alone is not enough)
    unless session[:user_id]
      return render json: { error: 'No session found' }, status: :unauthorized
    end
    
    user = User.find(session[:user_id])
    new_token = JwtService.encode(user)
    render json: {
      user: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at },
      token: new_token
    }, status: :ok
  end

  def me
    # Try JWT token first
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      decoded = JwtService.decode(token)
      return render json: { error: 'No session found' }, status: :unauthorized if decoded.nil?
      
      user = User.find(decoded[:user_id])
      render json: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at }, status: :ok
    elsif session[:user_id]
      # Fall back to session
      user = User.find(session[:user_id])
      render json: { id: user.id, username: user.username, created_at: user.created_at, last_active_at: user.last_active_at }, status: :ok
    else
      render json: { error: 'No session found' }, status: :unauthorized
    end
  end
end
