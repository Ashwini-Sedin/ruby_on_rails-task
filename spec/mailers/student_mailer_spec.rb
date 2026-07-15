require "rails_helper"

RSpec.describe StudentMailer, type: :mailer do
  let(:teacher) { create(:user, role: "teacher") }
  let(:student) { create(:student, teacher: teacher) }

  describe "#welcome_email" do
    let(:mail) { described_class.welcome_email(student) }

    it "sends to the student email" do
      expect(mail.to).to eq([student.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Welcome to ABC Academy")
    end

    it "contains the student name" do
      expect(mail.body.encoded).to include(student.name)
    end
  end

  describe "#teacher_assigned" do
    let(:mail) { described_class.teacher_assigned(student) }

    it "sends to the student email" do
      expect(mail.to).to eq([student.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Teacher Assigned")
    end

    it "contains the teacher name" do
      expect(mail.body.encoded).to include(teacher.name)
    end
  end

  describe "#marks_published" do
    let(:mail) { described_class.marks_published(student) }

    it "sends to the student email" do
      expect(mail.to).to eq([student.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your Marks have been Published")
    end

    it "contains the student marks" do
      expect(mail.body.encoded).to include(student.marks.to_s)
    end
  end

  describe "#report_card" do
    let(:pdf_data) { "Dummy PDF Content" }
    let(:mail) { described_class.report_card(student, pdf_data) }

    it "sends to the student email" do
      expect(mail.to).to eq([student.email])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your Report Card")
    end

    it "attaches the report card" do
      expect(mail.attachments.count).to eq(1)
      expect(mail.attachments.first.filename).to eq("ReportCard.pdf")
    end
  end
end