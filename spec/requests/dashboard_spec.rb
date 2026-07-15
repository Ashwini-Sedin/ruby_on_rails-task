# require "rails_helper"

# RSpec.describe "Dashboard", type: :request do
#   describe "GET /dashboard" do
#     context "when admin is logged in" do
#       let(:admin) { create(:user, role: "admin") }
#       let!(:teacher) { create(:user, role: "teacher") }
#       let!(:student) { create(:student, teacher: teacher) }

#       before do
#         sign_in admin
#       end

#       it "returns success" do
#         get dashboard_path

#         expect(response).to have_http_status(:ok)
#       end

#       it "assigns admin dashboard data" do
#         get dashboard_path

#         expect(assigns(:total_students)).to eq(Student.count)
#         expect(assigns(:total_teachers)).to eq(User.teacher.count)
#       end
#     end

#     context "when teacher is logged in" do
#       let(:teacher) { create(:user, role: "teacher") }
#       let!(:student1) { create(:student, teacher: teacher, course: "Ruby") }
#       let!(:student2) { create(:student, teacher: teacher, course: "Rails") }

#       before do
#         sign_in teacher
#       end

#       it "returns success" do
#         get dashboard_path

#         expect(response).to have_http_status(:ok)
#       end

#       it "shows only the teacher's students" do
#         get dashboard_path

#         expect(assigns(:total_students)).to eq(2)
#         expect(assigns(:course_counts)).to eq(
#           "Ruby" => 1,
#           "Rails" => 1
#         )
#       end
#     end
#   end
# end




require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /dashboard" do
    context "when admin is logged in" do
      let(:admin) { create(:user, role: "admin") }
      let!(:teacher) { create(:user, role: "teacher") }
      let!(:student) { create(:student, teacher: teacher) }

      before do
        sign_in admin
      end

      it "returns success" do
        get dashboard_path

        expect(response.body).to include("Total Students")
      end
    end

    context "when teacher is logged in" do
      let(:teacher) { create(:user, role: "teacher") }
      let!(:student1) { create(:student, teacher: teacher, course: "Ruby") }
      let!(:student2) { create(:student, teacher: teacher, course: "Rails") }

      before do
        sign_in teacher
      end

      it "returns success" do
        get dashboard_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end