class AddTeacherIdToStudents < ActiveRecord::Migration[8.1]
  def change
     add_reference :students, :teacher, foreign_key: { to_table: :users }
  end
end
