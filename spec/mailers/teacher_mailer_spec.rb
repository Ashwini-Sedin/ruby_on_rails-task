require "rails_helper"

RSpec.describe TeacherMailer, type: :mailer do
  let(:teacher) { create(:user, role: "teacher") }
  let(:student) { create(:student, teacher: teacher) }

  describe "#new_student" do
    let(:mail) { described_class.new_student(student) }

    it "sends to the teacher email" do
      expect(mail.to).to eq([ teacher.email ])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("New Student Assigned")
    end

    it "contains the student name" do
      expect(mail.body.encoded).to include(student.name)
    end
  end

  describe "#documents_uploaded" do
    let(:mail) { described_class.documents_uploaded(student) }

    it "sends to the teacher email" do
      expect(mail.to).to eq([ teacher.email ])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("#{student.name} Uploaded New Documents")
    end

    it "contains the student name" do
      expect(mail.body.encoded).to include(student.name)
    end
  end
end
