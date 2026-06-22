class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @users =
      case params[:role]
      when "teacher"
        User.teacher
      when "student"
        User.student
      else
        User.all
      end
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Access Denied" unless current_user.admin?
  end
end
