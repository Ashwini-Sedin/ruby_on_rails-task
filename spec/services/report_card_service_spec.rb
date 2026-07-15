require "rails_helper"

RSpec.describe ReportCardService do
  let(:teacher) { create(:user, role: "teacher") }
  let(:student) { create(:student, teacher: teacher) }

  describe ".generate" do
    it "returns PDF data" do
      pdf = described_class.generate(student)

      expect(pdf).to be_present
      expect(pdf).to be_a(String)
    end
  end
end