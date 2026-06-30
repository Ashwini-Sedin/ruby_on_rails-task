class AddTeacherIdToStudents < ActiveRecord::Migration[8.1]
  def change
    add_column :students, :teacher_id, :integer
    add_index :students, :teacher_id
  end
end
