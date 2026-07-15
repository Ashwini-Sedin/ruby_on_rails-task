require "rails_helper"

RSpec.describe "API::V1::Students", type: :request do
  let(:teacher) { create(:user, role: "teacher") }

  let!(:student) do
    create(
      :student,
      teacher: teacher,
      name: "Ashwini",
      course: "Ruby",
      marks: 90
    )
  end

  before do
    sign_in teacher
  end

  describe "GET /index" do
    it "returns all students" do
      get api_v1_students_path

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.size).to eq(1)
      expect(json.first["name"]).to eq("Ashwini")
    end

    it "filters students by name" do
      get api_v1_students_path, params: { name: "Ash" }

      json = JSON.parse(response.body)

      expect(json.first["name"]).to eq("Ashwini")
    end

    it "filters students by course" do
      get api_v1_students_path, params: { course: "Ruby" }

      json = JSON.parse(response.body)

      expect(json.first["course"]).to eq("Ruby")
    end

    it "filters students by grade" do
      get api_v1_students_path, params: { grade: "A" }

      json = JSON.parse(response.body)

      expect(json.first["grade"]).to eq("A")
    end
  end

  describe "GET /show" do
    it "returns the student" do
      get api_v1_student_path(student)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["id"]).to eq(student.id)
      expect(json["name"]).to eq(student.name)
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        name: "Kannan",
        email: "kannan@test.com",
        age: 21,
        course: "Rails",
        city: "Chennai",
        marks: 88,
        teacher_id: teacher.id
      }
    end

    it "creates a student" do
      expect {
        post api_v1_students_path, params: valid_params
      }.to change(Student, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)

      expect(json["name"]).to eq("Kannan")
    end

    it "returns errors for invalid params" do
      post api_v1_students_path,
           params: {
             name: "",
             email: ""
           }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)

      expect(json["errors"]).to be_present
    end
  end

  describe "PATCH /update" do
    it "updates the student" do
      patch api_v1_student_path(student),
            params: {
              name: "Updated Name"
            }

      expect(response).to have_http_status(:ok)

      expect(student.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /destroy" do
    it "deletes the student" do
      expect {
        delete api_v1_student_path(student)
      }.to change(Student, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end