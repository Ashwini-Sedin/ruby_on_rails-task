class TeacherMailer < ApplicationMailer
 default from: "kannanash31@gmail.com"

 def new_student(student)
    set_variables(student)
    return unless @teacher

  mail(
    to: @teacher.email,
    subject: "New Student Assigned")
 end

 def documents_uploaded(student)
    set_variables(student)
    return unless @teacher

    mail(
      to: @teacher.email,
      subject: "#{@student.name} Uploaded New Documents"
    )
  end

  private

  def set_variables(student)
    @student = student
    @teacher = student.teacher
  end
end
