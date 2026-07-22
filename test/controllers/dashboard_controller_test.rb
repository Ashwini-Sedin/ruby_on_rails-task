require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Dashboard User",
      email: "dashboard.user@example.com",
      password: "password123",
      role: "teacher"
    )
  end

  test "should get index when authenticated" do
    sign_in @user
    get dashboard_index_url
    assert_response :success
  end
end
