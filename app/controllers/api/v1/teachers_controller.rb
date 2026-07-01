module Api
  module V1
    class TeachersController < BaseController
      before_action :set_teacher, only: %i[show update destroy]
  
      def index
        teachers = User.teacher.includes(:students)

        teachers = teachers.by_subject(params[:subject]) if params[:subject].present?

        render json: teachers.map { |teacher|
          {
            id: teacher.id,
            name: teacher.name,
            subject: teacher.subject
          }
        }
      end

      def show
        render_teacher(@teacher)
      end

      def create
        teacher = User.new(teacher_params.merge(role :teacher))
  
        if teacher.save
          render_teacher(teacher, :created)
        else
          render_validation_errors(teacher)
        end
      end

      def update
        if @teacher.update(teacher_params)
          render_teacher(@teacher)
        else
          render_validation_errors(@teacher)
        end
      end

      def destroy
        @teacher.destroy
        head :no_content
      end

      private

      def set_teacher
        @teacher = User.teacher.includes(:students).find(params[:id])
      end

      def render_validation_errors(record)
        render json: {
        errors: record.errors.full_messages
        }, status: :unprocessable_entity
      end

      def teacher_params
        params.require(:teacher).permit(
          :name, :email, :password)
      end

      def render_teacher(teacher, status = :ok)
        render json: {
          id: teacher.id,
          name: teacher.name,
          subject: teacher.subject,
          students: teacher.students.map do |student|
            {
              id: student.id,
              name: student.name
            }
          end
        }, status: status
      end
    end
  end
end
