require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:teacher) { create(:user, role: "teacher") }

  before do
    sign_in admin
  end

  describe "GET /users" do
    it "returns success" do
      get users_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users?role=teacher" do
    it "shows only teachers" do
      get users_path, params: { role: "teacher" }

      expect(response).to have_http_status(:ok)
    end
  end
end


describe "when user is not admin" do
  let(:teacher) { create(:user, role: "teacher") }

  before do
    sign_in teacher
  end

  it "redirects to root" do
    get users_path

    expect(response).to redirect_to(root_path)
  end
end