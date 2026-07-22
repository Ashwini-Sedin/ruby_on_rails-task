require "rails_helper"

RSpec.describe SendAllReportCardsJob, type: :job do
  let(:teacher) { create(:user, role: "teacher") }

  let!(:student1) { create(:student, teacher: teacher) }
  let!(:student2) { create(:student, teacher: teacher) }

  before do
    allow(ReportCardGenerationJob).to receive(:perform_async)
  end

  describe "#perform" do
    it "queues report card generation for given student ids" do
      described_class.new.perform([ student1.id, student2.id ])

      expect(ReportCardGenerationJob).to have_received(:perform_async).with(student1.id)
      expect(ReportCardGenerationJob).to have_received(:perform_async).with(student2.id)
    end

    it "queues report card generation for all students when no ids are given" do
      described_class.new.perform

      expect(ReportCardGenerationJob).to have_received(:perform_async).with(student1.id)
      expect(ReportCardGenerationJob).to have_received(:perform_async).with(student2.id)
    end
  end
end
