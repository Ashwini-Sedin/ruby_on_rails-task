
class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  def index
    if request.path_parameters[:teacher_id]
      @teacher = User.teacher.find(request.path_parameters[:teacher_id])
      @students = @teacher.students
    else
      if request.format.json?
        @students = Student.all  
      else
        @students =
          if current_user.admin?
            Student.all
          else
            current_user.students
          end
      end   
    end

    if params[:name].present?
      @students = @students.where("name LIKE ?", "%#{params[:name]}%")
    elsif params[:search].present?
      @students = @students.search(params[:search])
    end

    if params[:grade].present?
      @students = @students.by_grade(params[:grade])
    end

    if params[:course].present?
      @students = @students.by_course(params[:course])
    end

    respond_to do |format|
      format.html
      format.json do
        render json: @students.map { |student| student_json_structure(student) }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: student_json_structure(@student) }
    end
  end

  def new
    @student = Student.new
  end

  def create
    if request.path_parameters[:teacher_id]
      @teacher = User.teacher.find(request.path_parameters[:teacher_id])
      @student = @teacher.students.build(student_params)
    else
      @student = Student.new(student_params)
      unless request.format.json?
        @student.teacher_id = current_user.id unless current_user.admin?
      end
    end

    respond_to do |format|
      if @student.save
        format.html do
          redirect_to students_path,
                      notice: "Student created successfully"
        end

        format.json do
          render json: student_json_structure(@student), status: :created
        end
      else
        format.html do
          render :new, status: :unprocessable_entity
        end

        format.json do
          render json: {
            errors: @student.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html do
          redirect_to students_path,
                      notice: "Student updated successfully"
        end

        format.json do
          render json: student_json_structure(@student), status: :ok
        end
      else
        format.html do
          render :edit, status: :unprocessable_entity
        end

        format.json do
          render json: {
            errors: @student.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @student.destroy

    respond_to do |format|
      format.html do
        redirect_to students_path,
                    notice: "Student deleted successfully"
      end

      format.json do
        head :no_content
      end
    end
  end

  private

  def set_student
    @student =
      if request.format.json?
        Student.find(params[:id])
      elsif current_user.admin?
        Student.find(params[:id])
      else
        current_user.students.find(params[:id])
      end
  end

  def student_json_structure(student)
    {
      id: student.id,
      name: student.name,
      email: student.email,
      age: student.age,
      course: student.course,
      city: student.city,
      marks: student.marks,
      grade: student.grade,
      teacher_id: student.teacher_id,
      created_at: student.created_at,
      updated_at: student.updated_at
    }
  end

  def student_params
    permitted = %i[name email age course city marks teacher_id]
    if params[:student].present?
      params.require(:student).permit(permitted)
    else
      params.permit(permitted)
    end
  end
end