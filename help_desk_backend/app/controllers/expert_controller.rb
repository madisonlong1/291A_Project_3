class ExpertController < ApplicationController
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'dev_key'

  # GET /expert/profile
  def profile
    current_user = extract_user_from_token
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

    expert_profile = ExpertProfile.find_by(user_id: current_user.id)
    return render json: { error: 'Expert profile not found' }, status: :not_found unless expert_profile

    render json: {
      id: expert_profile.id.to_s,
      userId: expert_profile.user_id.to_s,
      bio: expert_profile.bio,
      knowledgeBaseLinks: expert_profile.knowledge_base_links || [],
      createdAt: expert_profile.created_at.iso8601,
      updatedAt: expert_profile.updated_at.iso8601
    }, status: :ok
  end

  # PUT /expert/profile
  def update_profile
    current_user = extract_user_from_token
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

    expert_profile = ExpertProfile.find_by(user_id: current_user.id)
    return render json: { error: 'Expert profile not found' }, status: :not_found unless expert_profile

    if expert_profile.update(bio: params[:bio], knowledge_base_links: params[:knowledgeBaseLinks])
      render json: {
        id: expert_profile.id.to_s,
        userId: expert_profile.user_id.to_s,
        bio: expert_profile.bio,
        knowledgeBaseLinks: expert_profile.knowledge_base_links || [],
        createdAt: expert_profile.created_at.iso8601,
        updatedAt: expert_profile.updated_at.iso8601
      }, status: :ok
    else
      render json: { errors: expert_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def queue
  end

  def claim
  end

  def unclaim
  end

  def assignments_history
  end

  private

  def extract_user_from_token
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token

    begin
      payload = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
      User.find(payload['user_id'])
    rescue
      nil
    end
  end
end
