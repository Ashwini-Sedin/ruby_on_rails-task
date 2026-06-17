class TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  def index
     @teachers = User.where(role: "teacher").includes(:students)
  end


  private

  def require_admin!
    redirect_to root_path, alert: "Access Denied" unless current_user.admin?
  end
end
