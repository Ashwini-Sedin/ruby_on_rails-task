class PopulateStudentsCountInUsers < ActiveRecord::Migration[8.1]
  def up
    User.find_each do |user|
      User.reset_counters(user.id, :students)
    end
  end

  def down
  end
end
