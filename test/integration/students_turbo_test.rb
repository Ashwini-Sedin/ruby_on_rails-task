require "test_helper"

class StudentsTurboTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @student = students(:one)
    sign_in @user
  end

  test "GET /students with search returns Turbo Frame students_table" do
    get students_path(search: @student.name)
    assert_response :success
    assert_select "turbo-frame#students_table" do
      assert_select "td", text: @student.name
    end
  end

  test "POST /students with turbo_stream appends student and clears form" do
    assert_difference "Student.count", 1 do
      post students_path, params: {
        student: {
          name: "Charlie Brown",
          email: "charlie@example.com",
          age: 21,
          course: "Ruby",
          city: "Chicago",
          marks: 78
        }
      }, as: :turbo_stream
    end
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type

    # Verify turbo-stream tags in response
    assert_match /turbo-stream action="append" target="students"/, response.body
    assert_match /turbo-stream action="update" target="new_student_form"/, response.body
    assert_match /turbo-stream action="update" target="student_count"/, response.body
  end

  test "GET /students/:id/edit returns inline turbo frame" do
    get edit_student_path(@student), headers: { "Turbo-Frame" => dom_id(@student) }
    assert_response :success
    assert_select "turbo-frame##{dom_id(@student)}" do
      assert_select "form"
      assert_select "a", text: "Cancel"
    end
  end

  test "GET /students/:id (Cancel) returns student partial" do
    get student_path(@student), headers: { "Turbo-Frame" => dom_id(@student) }
    assert_response :success
    assert_select "turbo-frame##{dom_id(@student)}" do
      assert_select "td", text: @student.name
    end
  end
end
