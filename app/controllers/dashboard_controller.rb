class DashboardController < ApplicationController
  def index
    if current_user.admin?
       @total_students=Student.count
       @total_teachers= User.teacher.count
       @students_per_teacher = User.teacher

    else
      students = current_user.students

      @total_students = students.count

      @course_counts = students.group(:course).count
    end
  end
end
