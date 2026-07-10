
class StudentMailer < ApplicationMailer
  default from: "kannanash31@gmail.com"

  def welcome_email(student)
    @student = student
    @teacher = student.teacher

    mail(
      to: @student.email,
      subject: "Welcome to ABC Academy"
    )
  end

  def teacher_assigned(student)
    @student = student
    @teacher = student.teacher

    mail(
      to: @student.email,
      subject: "Teacher Assigned"
    )
  end


  def marks_published(student)
    @student = student

    mail(
      to: @student.email,
      subject: "Your Marks have been Published"
    )
  end

  def report_card(student, pdf_data = nil)
  @student = student

  if pdf_data.present?
    attachments["ReportCard.pdf"] = pdf_data
  elsif student.report_card.attached?
    attachments["ReportCard.pdf"] = student.report_card.download
  end

  mail(
    to: student.email,
    subject: "Your Report Card"
  )
end
end
