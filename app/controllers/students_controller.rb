
class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  def index
    @students =
      if current_user.admin?
        Student.all
      else
        current_user.students
      end

    @students = @students.search(params[:search]) if params[:search].present?
    @students = @students.by_course(params[:course]) if params[:course].present?
   
  end

  def show; end

  def new
    @student = Student.new
  end

  def create
    student_attributes=
       if current_user.admin?
         student_params
       else
         student_params.merge(teacher_id: current_user.id)
       end  
    result = StudentRegistrationService.call(
      student_attributes)

    if @student.save
      redirect_to students_path, notice: "Student created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Student updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student deleted successfully"
  end

  private

  def set_student
    @student =
      if current_user.admin?
        Student.find(params[:id])
      else
        current_user.students.find(params[:id])
      end
  end

  def student_params
    permitted = [ :name, :email, :age, :course, :city, :marks, :profile_photo, { documents: [] } ]
    permitted << :teacher_id if current_user.admin?

    params.require(:student).permit(permitted)
  end
end
