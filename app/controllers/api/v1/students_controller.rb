module Api
  module V1
    class StudentsController < BaseController
      before_action :set_student, only: [ :show, :update, :destroy ]

      def index
        students=
         if current_user.admin?
          Student.all
         else
           current_user.students
         end

        students = students.where(teacher_id: params[:teacher_id]) if params[:teacher_id].present?
        search_term = params[:name].presence || params[:search].presence
        if search_term.present?
          term = ActiveRecord::Base.sanitize_sql_like(search_term.to_s.strip)
          students = students.where(
            "LOWER(name) LIKE LOWER(:term) OR LOWER(email) LIKE LOWER(:term)",
            term: "%#{term}%"
          )
        end

        students = students.by_grade(params[:grade]) if params[:grade].present?
        students = students.by_course(params[:course]) if params[:course].present?

        render json: students.map { |student| student_json(student) }
      end

      def show
        render json: student_json(@student)
      end

      def create
        teacher_id = params[:teacher_id].presence || student_params[:teacher_id]
        student = Student.new(student_params.except(:profile_photo, :documents).merge(teacher_id: teacher_id))

        if student.save
          if params[:student].present?
            ProfilePhotoService.upload(student, params[:student][:profile_photo]) if params[:student][:profile_photo].present?
            StudentDocumentService.upload(student, params[:student][:documents]) if params[:student][:documents].present?
          end

          render json: student_json(student),
                 status: :created
        else
          render_validation_errors(student)
        end
      end

      def update
        if @student.update(student_params.except(:profile_photo, :documents))
          if params[:student].present?
            ProfilePhotoService.upload(@student, params[:student][:profile_photo]) if params[:student][:profile_photo].present?
            StudentDocumentService.upload(@student, params[:student][:documents]) if params[:student][:documents].present?
          end

          render json: student_json(@student)
        else
          render_validation_errors(@student)
        end
      end

      def destroy
        @student.destroy
        head :no_content
      end

      private

      def set_student
        @student = Student.find(params[:id])
      end

      private

      def render_validation_errors(record)
         render json: {
         errors: record.errors.full_messages
         }, status: :unprocessable_entity
      end

      def student_params
        params.require(:student).permit(
          :name,
          :email,
          :age,
          :course,
          :city,
          :marks,
          :teacher_id,
          :profile_photo,
          { documents: [] }
        )
      end
      def student_json(student)
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
          documents: student.documents.map do |doc|
            {
              id: doc.id,
              blob_id: doc.blob_id,
              filename: doc.filename.to_s,
              content_type: doc.content_type,
              byte_size: doc.byte_size,
              url: Rails.application.routes.url_helpers.rails_blob_url(doc, only_path: true)
            }
          end,
          teacher: student.teacher ? {
            id: student.teacher.id,
            name: student.teacher.name,
            email: student.teacher.email
          } : nil
        }
      end
    end
  end
end


      