class DashboardController < ApplicationController
  def index
    if current_user.admin?
       @total_students=Student.count
       @total_teachers= User.where(role: "teacher").count
       @students_per_teacher = User.where(role: "teacher")
                                .includes(:students)
    else
      students = current_user.students

       @total_students = students.count

      course_counts = students.group(:course).count

      @ruby_students  = course_counts["Ruby"]  || 0
      @rails_students = course_counts["Rails"] || 0
      @react_students = course_counts["React"] || 0
      @java_students  = course_counts["Java"]  || 0
    end
  end
end
