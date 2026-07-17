class DashboardController < ApplicationController
  def index
    if current_user.admin?
      load_admin_dashboard
    else
      load_teacher_dashboard
    end
  end

  private

  def load_admin_dashboard
    @total_students = Student.count
    @total_teachers = User.teacher.count
    @teachers = User.teacher
  end

  def load_teacher_dashboard
    students = current_user.students
    @total_students = students.count
    @course_counts = students.group(:course).count
  end
end
