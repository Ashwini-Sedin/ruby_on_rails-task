class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_teacher!, only: [ :show, :edit, :update, :destroy ]
  def index
    @students =
      if current_user.admin?
        Student.all
      else
        current_user.students
      end
    if params[:search].present?
      @students = @students.where(
        "name LIKE ? OR email LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    end

    if params[:course].present?
      @students = @students.where(course: params[:course])
    end
  end

  def show
  end

  def new
    @student = Student.new
  end

 def create
  @student = Student.new(student_params)
  @student.user_id = current_user.id

  if current_user.teacher?
    @student.teacher_id = current_user.id
  end

  if @student.save
    redirect_to students_path, notice: "Student created successfully"
  else
    render :new
  end
end

  def edit
  end

  def update
    if @student.update(student_params)
      redirect_to students_path
    else
      render :edit
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def authorize_teacher!
    return if current_user.admin?
    unless @student.teacher == current_user
      redirect_to students_path, alert: "Access Denied"
    end
  end

  def student_params
  permitted = [ :name, :email, :age, :course, :city, :marks ]


  permitted << :teacher_id if current_user.admin?

  params.require(:student).permit(permitted)
end
end
