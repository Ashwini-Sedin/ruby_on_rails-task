require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      name: "Admin User",
      email: "admin@example.com",
      password: "password123",
      role: "admin"
    )
  end

  test "should get index when logged in as admin" do
    sign_in @admin
    get users_index_url
    assert_response :success
  end
end
