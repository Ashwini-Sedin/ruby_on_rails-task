require "rails_helper"

RSpec.describe Student, type: :model do
  subject { build(:student) }

  describe "Associations" do
    it { should belong_to(:teacher).class_name("User") }

    it "has one attached profile photo" do
      student = build(:student)
      expect(student.profile_photo).to be_a(ActiveStorage::Attached::One)
    end

    it "has many attached documents" do
      student = build(:student)
      expect(student.documents).to be_a(ActiveStorage::Attached::Many)
    end

    it "has one attached report card" do
      student = build(:student)
      expect(student.report_card).to be_a(ActiveStorage::Attached::One)
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:course) }
    it { should validate_presence_of(:city) }

    it do
      should validate_numericality_of(:age)
        .is_greater_than(0)
    end
  end

  describe "Scopes" do
    let!(:student1) do
      create(:student,
             name: "Ashwini",
             email: "ash@example.com",
             course: "Ruby",
             marks: 85)
    end

    let!(:student2) do
      create(:student,
             name: "Rahul",
             email: "rahul@example.com",
             course: "Rails",
             marks: 65)
    end

    let!(:student3) do
      create(:student,
             name: "Abi",
             email: "abi@example.com",
             course: "Ruby",
             marks: 30)
    end

    describe ".search" do
      it "returns matching student by name" do
        expect(Student.search("Ashwini")).to include(student1)
        expect(Student.search("Ashwini")).not_to include(student2)
      end

      it "returns matching student by email" do
        expect(Student.search("rahul")).to include(student2)
      end
    end

    describe ".by_course" do
      it "returns students of selected course" do
        expect(Student.by_course("Ruby")).to include(student1, student3)
        expect(Student.by_course("Ruby")).not_to include(student2)
      end
    end

    describe ".by_grade" do
      it "returns grade A students" do
        expect(Student.by_grade("A")).to include(student1)
      end

      it "returns grade B students" do
        expect(Student.by_grade("B")).to include(student2)
      end

      it "returns grade F students" do
        expect(Student.by_grade("F")).to include(student3)
      end
    end
  end

  describe "#result" do
    it "returns pass when marks are greater than or equal to 35" do
      student = build(:student, marks: 70)
      expect(student.result).to eq("pass")
    end

    it "returns fail when marks are less than 35" do
      student = build(:student, marks: 20)
      expect(student.result).to eq("fail")
    end

    it "returns N/A when marks are nil" do
      student = build(:student, marks: nil)
      expect(student.result).to eq("N/A")
    end
  end

  describe "#grade" do
    it "returns A" do
      expect(build(:student, marks: 90).grade).to eq("A")
    end

    it "returns B" do
      expect(build(:student, marks: 70).grade).to eq("B")
    end

    it "returns C" do
      expect(build(:student, marks: 50).grade).to eq("C")
    end

    it "returns D" do
      expect(build(:student, marks: 36).grade).to eq("D")
    end

    it "returns F" do
      expect(build(:student, marks: 20).grade).to eq("F")
    end

    it "returns N/A when marks are nil" do
      expect(build(:student, marks: nil).grade).to eq("N/A")
    end
  end
end
