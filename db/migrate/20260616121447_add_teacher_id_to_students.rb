class AddTeacherIdToStudents < ActiveRecord::Migration[8.1]
  def change
    add_column :students, :teacher_id, :integer
    add_foreign_key :students, :teacher
  end
end
