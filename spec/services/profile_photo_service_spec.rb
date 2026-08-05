require "rails_helper"

RSpec.describe ProfilePhotoService do
  let(:student) { create(:student) }

  let(:file) do
    fixture_file_upload(
      Rails.root.join("spec/fixtures/files/profile.jpg"),
      "image/jpeg"
    )
  end

  describe ".upload" do
    it "attaches profile photo" do
      described_class.upload(student, file)

      expect(student.profile_photo).to be_attached
    end

    it "does not attach photo when file is nil" do
      described_class.upload(student, nil)

      expect(student.profile_photo).not_to be_attached
    end

    it "replaces existing profile photo" do
      student.profile_photo.attach(file)

      described_class.upload(student, file)

      expect(student.profile_photo).to be_attached
    end
  end

  describe ".delete" do
    it "deletes profile photo" do
      student.profile_photo.attach(file)

      described_class.delete(student)

      expect(student.profile_photo).not_to be_attached
    end

    it "does nothing when photo is not attached" do
      expect {
        described_class.delete(student)
      }.not_to raise_error
    end
  end
end
