class Student < ApplicationRecord
 belongs_to :teacher, class_name: "User"
 validates :name, presence: true
 validates :email, presence: true, uniqueness: true
 validates :age, numericality: { greater_than: 0 }
 validates :course, presence: true
 validates :city, presence: true

 def result
  return "pass" if marks.present? && marks >= 35
  return "fail" if marks.present?
  "N/A"
 end
end
