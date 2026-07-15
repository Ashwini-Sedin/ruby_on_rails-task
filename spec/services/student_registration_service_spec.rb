require "rails_helper"

RSpec.describe StudentRegistrationService do
  let(:teacher) { create(:user, role: "teacher") }

  let(:valid_params) do
    {
      name: "Ashwini",
      email: "ashwini@test.com",
      age: 22,
      course: "Ruby",
      city: "Chennai",
      marks: 90,
      teacher_id: teacher.id
    }
  end

  describe ".call" do
    it "creates a student successfully" do
      result = described_class.call(valid_params)

      expect(result[:success]).to eq(true)
      expect(result[:student]).to be_persisted
    end

    it "fails with invalid params" do
      result = described_class.call(valid_params.merge(name: ""))

      expect(result[:success]).to eq(false)
    end
  end
end