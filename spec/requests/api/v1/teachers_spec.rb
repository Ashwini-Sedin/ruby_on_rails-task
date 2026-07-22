require "rails_helper"

RSpec.describe "API::V1::Teachers", type: :request do
  let!(:teacher) do
    create(
      :user,
      role: "teacher",
      name: "John",
      email: "john@test.com"
    )
  end

  before do
    sign_in teacher
  end

  describe "GET /index" do
    it "returns all teachers" do
      get api_v1_teachers_path

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.first["name"]).to eq("John")
    end
  end

  describe "GET /show" do
    it "returns the teacher" do
      get api_v1_teacher_path(teacher)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["name"]).to eq("John")
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        name: "Ashwini",
        email: "ashwini@test.com",
        password: "password123"
      }
    end

    it "creates a teacher" do
      expect {
        post api_v1_teachers_path,
             params: valid_params
      }.to change(User.teacher, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)

      expect(json["name"]).to eq("Ashwini")
    end

    it "does not create an invalid teacher" do
      post api_v1_teachers_path,
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
    it "updates the teacher" do
      patch api_v1_teacher_path(teacher),
            params: {
              name: "Updated Teacher"
            }

      expect(response).to have_http_status(:ok)

      expect(teacher.reload.name).to eq("Updated Teacher")
    end
  end

  describe "DELETE /destroy" do
    it "deletes the teacher" do
      expect {
        delete api_v1_teacher_path(teacher)
      }.to change(User.teacher, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "GET /index with subject filter" do
    let!(:student) do
      create(:student, teacher: teacher, course: "Ruby")
    end

    it "returns teachers by subject" do
      get api_v1_teachers_path,
          params: { subject: "Ruby" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.size).to eq(1)
      expect(json.first["subject"]).to eq("Ruby")
    end
  end
end
