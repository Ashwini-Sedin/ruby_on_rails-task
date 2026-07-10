class SendAllReportCardsJob
  include Sidekiq::Job

  def perform(student_ids = nil)
    students = student_ids ? Student.where(id: student_ids) : Student.all
    students.find_each do |student|
      ReportCardGenerationJob.perform_async(student.id)
    end
  end
end