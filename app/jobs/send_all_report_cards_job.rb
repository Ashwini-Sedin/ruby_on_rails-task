class SendAllReportCardsJob
  include Sidekiq::Job

  def perform
    Student.find_each do |student|
      next unless student.report_card.attached?

      StudentMailer.report_card(student).deliver_now
    end
  end
end
