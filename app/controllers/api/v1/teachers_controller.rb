module Api
  module V1
    class TeachersController < BaseController
      before_action :set_teacher, only: %i[show update destroy]

      def index
        teachers = User.teacher

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
        teacher = User.new(teacher_params)
        teacher.role = "teacher"

        if teacher.save
          render_teacher(teacher, :created)
        else
          render json: {
            errors: teacher.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @teacher.update(teacher_params)
          render_teacher(@teacher)
        else
          render json: {
            errors: @teacher.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @teacher.destroy
        head :no_content
      end

      private

      def set_teacher
        @teacher = User.teacher.find(params[:id])
      end

      def teacher_params
        params.permit(:name, :email, :password)
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
