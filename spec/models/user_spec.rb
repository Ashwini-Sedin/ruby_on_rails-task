require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "Associations" do
    it { should have_many(:students).with_foreign_key(:teacher_id).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe "Scopes" do
    let!(:teacher) { create(:user, role: "teacher") }
    let!(:admin) { create(:user, role: "admin") }

    it "returns only teachers" do
      expect(User.teacher).to include(teacher)
      expect(User.teacher).not_to include(admin)
    end

    it "returns teachers by subject" do
      create(:student, teacher: teacher, course: "Ruby")

      expect(User.by_subject("Ruby")).to include(teacher)
    end
  end

  describe "#admin?" do
    it "returns true for admin" do
      user = build(:user, role: "admin")

      expect(user.admin?).to eq(true)
    end

    it "returns false for teacher" do
      user = build(:user, role: "teacher")

      expect(user.admin?).to eq(false)
    end
  end

  describe "#teacher?" do
    it "returns true for teacher" do
      user = build(:user, role: "teacher")

      expect(user.teacher?).to eq(true)
    end

    it "returns false for admin" do
      user = build(:user, role: "admin")

      expect(user.teacher?).to eq(false)
    end
  end

  describe "#subject" do
    it "returns the student's course" do
      teacher = create(:user, role: "teacher")
      create(:student, teacher: teacher, course: "Rails")

      expect(teacher.subject).to eq("Rails")
    end

    it "returns Mathematics when teacher has no students" do
      teacher = create(:user, role: "teacher")

      expect(teacher.subject).to eq("Mathematics")
    end
  end
end
