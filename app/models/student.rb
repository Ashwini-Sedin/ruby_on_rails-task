class Student < ApplicationRecord
  belongs_to :teacher, class_name: "User", foreign_key: :teacher_id, counter_cache: true

  scope :search, ->(term) {
    where(
      "name LIKE :search OR email LIKE :search",
      search: "%#{term}%"
    )
  }

  scope :by_course, ->(course) {
    where(course: course)
  }

  scope :by_grade, ->(grade) {
    case grade.to_s.upcase
    when "A"
      where("marks >= 80")
    when "B"
      where("marks >= 60 AND marks < 80")
    when "C"
      where("marks >= 40 AND marks < 60")
    when "D"
      where("marks >= 35 AND marks < 40")
    when "F"
      where("marks < 35")
    else
      all
    end
  }

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

  def grade
    return "N/A" unless marks.present?
    if marks >= 80
      "A"
    elsif marks >= 60
      "B"
    elsif marks >= 40
      "C"
    elsif marks >= 35
      "D"
    else
      "F"
    end
  end
end
