
class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_teacher, only: [:show, :update, :destroy]

  def index
    @users =
      if request.format.json? || params[:controller] == "teachers"
        User.teacher
      else
        case params[:role]
        when "teacher"
          User.teacher
        when "student"
          User.student
        else
          User.all
        end
      end

    if request.format.json? && params[:subject].present?
      @users = @users.by_subject(params[:subject])
    end

    respond_to do |format|
      format.html
      format.json do
        render json: @users.map { |teacher|
          {
            id: teacher.id,
            name: teacher.name,
            subject: teacher.subject
          }
        }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render_teacher(@teacher, status: :ok) }
    end
  end

  def create
    @teacher = User.new(user_params)
    @teacher.role = "teacher"

    respond_to do |format|
      if @teacher.save
        format.html { redirect_to teachers_path, notice: "Teacher created successfully" }
        format.json { render_teacher(@teacher, status: :created) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: {
            errors: @teacher.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @teacher.update(user_params)
        format.html { redirect_to teachers_path, notice: "Teacher updated successfully" }
        format.json { render_teacher(@teacher, status: :ok) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: {
            errors: @teacher.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @teacher.destroy
    respond_to do |format|
      format.html { redirect_to teachers_path, notice: "Teacher deleted successfully" }
      format.json { head :no_content }
    end
  end

  private

  def set_teacher
    @teacher = User.teacher.find(params[:id])
  end

  def render_teacher(teacher, status: :ok)
    render json: {
      id: teacher.id,
      name: teacher.name,
      subject: teacher.subject,
      students: teacher.students.map { |student| { id: student.id, name: student.name } }
    }, status: status
  end

  def user_params
    if params[:user].present?
      params.require(:user).permit(:name, :email, :password)
    else
      params.permit(:name, :email, :password)
    end
  end

  def require_admin!
    return if request.format.json?
    redirect_to root_path, alert: "Access Denied" unless current_user.admin?
  end
end