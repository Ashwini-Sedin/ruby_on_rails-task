class RemoveUserIdFromStudents < ActiveRecord::Migration[8.1]
  def change
    remove_column :students, :user_id, :integer
  end
end
