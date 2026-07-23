require "rails_helper"

RSpec.describe ReportCardGenerationJob, type: :job do
  let(:teacher) { create(:user, role: "teacher") }
  let(:student) { create(:student, teacher: teacher) }

  let(:pdf_data) { "%PDF Fake PDF Content" }

  before do
    allow(ReportCardService).to receive(:generate).and_return(pdf_data)
    allow(StudentMailer).to receive_message_chain(:report_card, :deliver_now)
  end

  describe "#perform" do
    it "generates the report card" do
      described_class.new.perform(student.id)

      expect(ReportCardService).to have_received(:generate).with(student)
    end

    it "attaches the PDF to the student" do
      described_class.new.perform(student.id)

      expect(student.reload.report_card).to be_attached
    end

    it "sends the report card email" do
      described_class.new.perform(student.id)

      expect(StudentMailer).to have_received(:report_card).with(student, pdf_data)
    end

    it "raises an error for an invalid student" do
      expect {
        described_class.new.perform(-1)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
