class DashboardController < ApplicationController
  def index
    @total_students=Student.count
    @ruby_students=Student.where(course: "Ruby").count
    @rails_students=Student.where(course: "Rails").count
    @react_students=Student.where(course: "React").count
    @java_students=Student.where(course: "Java").count
  end
end
