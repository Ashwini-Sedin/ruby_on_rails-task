class Student < ApplicationRecord
  belongs_to :teacher, class_name: "User", foreign_key: :teacher_id, counter_cache: true
  has_one_attached :profile_photo
  has_many_attached :documents
  has_one_attached :report_card
  after_create :send_welcome_email
  after_commit :send_teacher_assignment_emails, on: [ :create, :update ], if: -> { saved_change_to_teacher_id? && teacher_id.present? }

  after_commit :send_marks_published_email, on: :update, if: :saved_change_to_marks?
  scope :search, ->(term) do
    escaped_term = ActiveRecord::Base.sanitize_sql_like(term)
    where(
      "name LIKE :term OR email LIKE :term",
      term: "%#{escaped_term}%"
    )
  end

  scope :by_course, ->(course) {
    where(course: course)
  }
  GRADE_RANGES={
    "A" => 80..100,
    "B" => 60...80,
    "C" => 40...60,
    "D" => 35...40,
    "F" => 0...35
}.freeze
scope :by_grade, ->(grade) do
  range = GRADE_RANGES[grade.to_s.upcase]
  range ? where(marks: range) : all
end


  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :age, numericality: { greater_than: 0 }
  validates :course, presence: true
  validates :city, presence: true
  validate :validate_profile_photo
  validate :validate_documents
  validates :marks,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100
          }
  private
 
  def send_welcome_email
    StudentMailer.welcome_email(self).deliver_later
  end 

  
  def send_teacher_assignment_emails
    StudentMailer.teacher_assigned(self).deliver_later
  end

  def send_marks_published_email
    StudentMailer.marks_published(self).deliver_later
  end

  def validate_profile_photo
    return unless profile_photo.attached?
    unless profile_photo.content_type.in?(%w[image/jpeg image/png image/jpg])
      errors.add(:profile_photo, "must be a JPEG or PNG image")
    end
    if profile_photo.blob.byte_size > 5.megabytes
      errors.add(:profile_photo, "size must be less than 5MB")

    end
  end
  def validate_documents
    return unless documents.attached?
    documents.each do |document|
      unless document.content_type.in?(%w[application/pdf image/jpeg image/png image/jpg])
        errors.add(:documents, "must be a PDF or an image (JPEG/PNG)")
      end
      if document.blob.byte_size > 10.megabytes
        errors.add(:documents, "size must be less than 10MB")
      end
    end
  end

  public

  def result
    return "N/A" if marks.blank?
    grade == "F" ? "fail" : "pass"
  end




  def grade
    return "N/A" if marks.blank?

    GRADE_RANGES.find { |_, range| range.cover?(marks) }&.first || "N/A"
  end
end
