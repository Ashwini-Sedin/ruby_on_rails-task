
class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy remove_profile_photo remove_document download_report_card]

  def index
    @students =
      if current_user.admin?
        Student.all
      else
        current_user.students
      end

    @students = @students.search(params[:search]) if params[:search].present?
    @students = @students.by_course(params[:course]) if params[:course].present?
    respond_to do |format|
      format.html
      format.turbo_stream
   end 
      
  end

  def show
  end

  def new
    @student = Student.new
  end


  def create
    teacher_id = student_params[:teacher_id].presence || current_user.id
    result = StudentRegistrationService.call(
      student_params.merge(teacher_id: teacher_id)
    )

    if result[:success]
      @student = result[:student]

      ProfilePhotoService.upload(@student, params[:student][:profile_photo])
      StudentDocumentService.upload(@student, params[:student][:documents])
      flash.now[:notice] = "Student created successfully."
      respond_to do |format|
        format.turbo_stream  
        format.html { redirect_to students_path, notice: "Student created successfully."}
      end
    else
      @student = Student.new(student_params)
      @student.errors.add(:base, result[:errors].join(", "))
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end


  def update
    if @student.update(student_params.except(:profile_photo, :documents))
      ProfilePhotoService.upload(@student, params[:student][:profile_photo])
      StudentDocumentService.upload(@student, params[:student][:documents])
     
      flash.now[:notice] = "Student updated successfully."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to students_path, notice: "Student updated successfully." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    flash.now[:notice] = "Student deleted successfully"
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to students_path, notice: "Student deleted successfully" }
    end
  end
  def remove_profile_photo
    ProfilePhotoService.delete(@student)
    redirect_to edit_student_path(@student),
                notice: "Profile photo deleted successfully."
  end

  def remove_document
    StudentDocumentService.delete(@student, params[:attachment_id])
    redirect_to edit_student_path(@student),
                notice: "Document deleted successfully."
  end

  def download_report_card
    pdf_data = ReportCardService.generate(@student)
    StudentMailer.report_card(@student, pdf_data).deliver_now
    send_data pdf_data,
              filename: "ReportCard.pdf",
              type: "application/pdf",
              disposition: "attachment"
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
