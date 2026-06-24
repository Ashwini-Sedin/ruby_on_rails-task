class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(exception)
    respond_to do |format|
      format.html { raise exception }
      format.json { render json: { errors: [ exception.message ] }, status: :not_found }
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
