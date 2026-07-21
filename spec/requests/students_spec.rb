
require "rails_helper"

RSpec.describe "Students", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:teacher) { create(:user, role: "teacher") }
  let!(:student) { create(:student, teacher: teacher) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "returns success" do
      get students_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "shows a student" do
      get student_path(student)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "returns success" do
      get new_student_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "returns success" do
      get edit_student_path(student)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        student: {
          name: "Ashwini",
          email: "ashwini@test.com",
          age: 22,
          course: "Ruby",
          city: "Chennai",
          marks: 90,
          teacher_id: teacher.id
        }
      }
    end

    it "creates a student" do
      expect {
        post students_path, params: valid_params
      }.to change(Student, :count).by(1)
    end
  end

  describe "PATCH /update" do
    it "updates the student" do
      patch student_path(student),
            params: {
              student: {
                name: "Updated Name"
              }
            }

      expect(student.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /destroy" do
    it "deletes the student" do
      expect {
        delete student_path(student)
      }.to change(Student, :count).by(-1)
    end
  end

  describe "POST /generate_report_card" do
    it "queues the report card job" do
      expect {
        post generate_report_card_student_path(student)
      }.to change(ReportCardGenerationJob.jobs, :size).by(1)
    end
  end

  describe "POST /send_all_report_cards" do
    it "queues the send all reports job" do
      expect {
        post send_all_report_cards_students_path
      }.to change(SendAllReportCardsJob.jobs, :size).by(1)
    end
  end

  describe "POST /create with invalid params" do
    it "does not create an invalid student" do
      expect {
        post students_path,
             params: {
               student: {
                 name: "",
                 email: ""
               }
             }
      }.not_to change(Student, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
