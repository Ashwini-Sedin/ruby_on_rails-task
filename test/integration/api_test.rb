require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  setup do
    # Clear database between tests
    Student.destroy_all
    User.destroy_all

    # Create default teacher for tests
    @teacher1 = User.create!(
      name: "John Doe",
      email: "john.doe@example.com",
      password: "password123",
      role: "teacher"
    )

    # Create default student under teacher1
    @student1 = Student.create!(
      name: "Alice Smith",
      email: "alice@example.com",
      age: 20,
      course: "Mathematics",
      city: "New York",
      marks: 85,
      teacher: @teacher1
    )
  end

  # Helper to perform login and get JWT token in Authorization header
  def auth_headers(user)
    post user_session_path(format: :json), params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
    token = response.headers["Authorization"]
    { "Authorization" => token }
  end

  # ================= TEACHERS API TESTS =================

  test "GET /teachers.json should return all teachers with valid JWT" do
    get api_v1_teachers_path(format: :json), headers: auth_headers(@teacher1)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
    assert_equal @teacher1.id, json_response[0]["id"]
    assert_equal "John Doe", json_response[0]["name"]
    assert_equal "Mathematics", json_response[0]["subject"]
  end

  test "GET /teachers.json without JWT should return 401 Unauthorized" do
    get api_v1_teachers_path(format: :json)
    assert_response :unauthorized
  end

  test "GET /teachers/:id.json should return teacher details with students" do
    get api_v1_teacher_path(@teacher1, format: :json), headers: auth_headers(@teacher1)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @teacher1.id, json_response["id"]
    assert_equal "John Doe", json_response["name"]
    assert_equal "Mathematics", json_response["subject"]
    assert_equal 1, json_response["students"].size
    assert_equal @student1.id, json_response["students"][0]["id"]
    assert_equal "Alice Smith", json_response["students"][0]["name"]
  end

  test "POST /teachers.json should create a teacher" do
    assert_difference "User.count", 1 do
      post api_v1_teachers_path(format: :json), params: {
        name: "Professor Xavier",
        email: "xavier@example.com",
        password: "telepathicpass"
      }, headers: auth_headers(@teacher1)
    end
    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Professor Xavier", json_response["name"]
    assert_equal "Mathematics", json_response["subject"]
  end

  test "PUT /teachers/:id.json should update teacher details" do
    put api_v1_teacher_path(@teacher1, format: :json), params: {
      name: "Johnathan Doe"
    }, headers: auth_headers(@teacher1)
    assert_response :ok

    json_response = JSON.parse(response.body)
    assert_equal "Johnathan Doe", json_response["name"]
    assert_equal "Johnathan Doe", @teacher1.reload.name
  end

  test "DELETE /teachers/:id.json should delete a teacher" do
    assert_difference "User.count", -1 do
      delete api_v1_teacher_path(@teacher1, format: :json), headers: auth_headers(@teacher1)
    end
    assert_response :no_content
  end

  # ================= STUDENTS API TESTS =================

  test "GET /students.json should return all students" do
    get api_v1_students_path(format: :json), headers: auth_headers(@teacher1)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
    assert_equal @student1.id, json_response[0]["id"]
    assert_equal "Alice Smith", json_response[0]["name"]
    assert_equal "A", json_response[0]["grade"]
  end

  test "GET /students/:id.json should return student details" do
    get api_v1_student_path(@student1, format: :json), headers: auth_headers(@teacher1)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @student1.id, json_response["id"]
    assert_equal "Alice Smith", json_response["name"]
    assert_equal "A", json_response["grade"]
    assert_equal @teacher1.id, json_response["teacher_id"]
  end

  test "POST /students.json should create a student" do
    assert_difference "Student.count", 1 do
      post api_v1_students_path(format: :json), params: {
        name: "Bob Jones",
        email: "bob@example.com",
        age: 22,
        course: "Science",
        city: "Boston",
        marks: 75,
        teacher_id: @teacher1.id
      }, headers: auth_headers(@teacher1)
    end
    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Bob Jones", json_response["name"]
    assert_equal "B", json_response["grade"]
  end

  test "PUT /students/:id.json should update student details" do
    put api_v1_student_path(@student1, format: :json), params: {
      marks: 55
    }, headers: auth_headers(@teacher1)
    assert_response :ok

    json_response = JSON.parse(response.body)
    assert_equal 55, json_response["marks"]
    assert_equal "C", json_response["grade"]
  end

  test "DELETE /students/:id.json should delete a student" do
    assert_difference "Student.count", -1 do
      delete api_v1_student_path(@student1, format: :json), headers: auth_headers(@teacher1)
    end
    assert_response :no_content
  end

  # ================= ASSOCIATION API TESTS =================

  test "GET /teachers/:teacher_id/students.json should return students of teacher" do
    get api_v1_teacher_students_path(@teacher1, format: :json), headers: auth_headers(@teacher1)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
    assert_equal @student1.id, json_response[0]["id"]
  end

  test "POST /teachers/:teacher_id/students.json should create student under teacher" do
    assert_difference "Student.count", 1 do
      post api_v1_teacher_students_path(@teacher1, format: :json), params: {
        name: "Charlie Brown",
        email: "charlie@example.com",
        age: 18,
        course: "History",
        city: "Chicago",
        marks: 38
      }, headers: auth_headers(@teacher1)
    end
    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Charlie Brown", json_response["name"]
    assert_equal "D", json_response["grade"]
    assert_equal @teacher1.id, json_response["teacher_id"]
    assert_equal @teacher1.id, Student.last.teacher_id
  end

  # ================= FILTERING TESTS =================

  test "GET /students?name=abc should search students by name" do
    Student.create!(
      name: "Bob Jones",
      email: "bob@example.com",
      age: 22,
      course: "Science",
      city: "Boston",
      marks: 75,
      teacher: @teacher1
    )

    get api_v1_students_path(name: "Alice", format: :json), headers: auth_headers(@teacher1)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
    assert_equal "Alice Smith", json_response[0]["name"]
  end

  test "GET /students?grade=A should filter students by grade" do
    Student.create!(
      name: "Failing Student",
      email: "fail@example.com",
      age: 22,
      course: "Science",
      city: "Boston",
      marks: 30,
      teacher: @teacher1
    )

    get api_v1_students_path(grade: "A", format: :json), headers: auth_headers(@teacher1)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
    assert_equal "Alice Smith", json_response[0]["name"]
  end

  test "GET /teachers?subject=Math should filter teachers by subject" do
    teacher2 = User.create!(
      name: "Science Teacher",
      email: "science@example.com",
      password: "password123",
      role: "teacher"
    )
    Student.create!(
      name: "Bob Jones",
      email: "bob@example.com",
      age: 22,
      course: "Science",
      city: "Boston",
      marks: 75,
      teacher: teacher2
    )

    get api_v1_teachers_path(subject: "Math", format: :json), headers: auth_headers(@teacher1)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.size
    assert_equal "John Doe", json_response[0]["name"]
  end

  # ================= NEGATIVE SCENARIOS =================

  test "GET /teachers/:id.json with invalid ID should return 404" do
    get api_v1_teacher_path(id: 99999, format: :json), headers: auth_headers(@teacher1)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert json_response["errors"].any?
  end

  test "POST /teachers.json with missing fields should return 422" do
    post api_v1_teachers_path(format: :json), params: {
      name: ""
    }, headers: auth_headers(@teacher1)
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert json_response["errors"].any?
  end

  test "POST /students.json with invalid teacher assignment should return 422" do
    post api_v1_students_path(format: :json), params: {
      name: "Bob Jones",
      email: "bob@example.com",
      age: 22,
      course: "Science",
      city: "Boston",
      marks: 75,
      teacher_id: 99999
    }, headers: auth_headers(@teacher1)
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert json_response["errors"].any?
  end
end
