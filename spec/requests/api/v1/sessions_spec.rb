
require "rails_helper"

RSpec.describe "API::V1::Sessions", type: :request do
  let!(:user) do
    create(
      :user,
      email: "teacher@test.com",
      password: "password123",
      role: "teacher"
    )
  end

  describe "POST /api/v1/login" do
    it "logs in with valid credentials" do
      post api_v1_login_path,
           params: {
             user: {
               email: user.email,
               password: "password123"
             }
           },
           as: :json

      expect(response).to have_http_status(:created)
      expect(response.headers["Authorization"]).to be_present
    end

    it "returns unauthorized for invalid credentials" do
      post api_v1_login_path,
           params: {
             user: {
               email: user.email,
               password: "wrongpassword"
             }
           },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
