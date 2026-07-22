class ReportCardGenerationJob
  include Sidekiq::Job

  def perform(student_id)
    student = Student.find(student_id)

    pdf_data = ReportCardService.generate(student)

    student.report_card.attach(
      io: StringIO.new(pdf_data),
      filename: "Report_card_#{student.id}.pdf",
      content_type: "application/pdf"
    )

    # Email ONLY this student
    StudentMailer.report_card(student, pdf_data).deliver_now
  end
end
