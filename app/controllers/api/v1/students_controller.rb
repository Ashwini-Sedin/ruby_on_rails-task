module Api
  module V1
    class StudentsController < BaseController
      before_action :set_student, only: [ :show, :update, :destroy ]

      def index
        students = Student.all
        if params[:name].present?
          search= ActiveRecord::Base.sanitize_sql_like(params[:name])
          students = students.where(
            "name LIKE ?",
            "%#{search}%"
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
        student = Student.new(student_params)

        if student.save
          render json: student_json(student),
                 status: :created
        else
          render_validation_errors(student)
        end
      end

      def update
        if @student.update(student_params)
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
          :teacher_id
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
          teacher_id: student.teacher_id
        }
      end
    end
  end
end
