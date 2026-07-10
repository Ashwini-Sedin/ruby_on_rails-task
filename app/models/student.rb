class Student < ApplicationRecord
  belongs_to :teacher, class_name: "User", foreign_key: :teacher_id, counter_cache: true
  has_one_attached :profile_photo
  has_many_attached :documents
  has_one_attached :report_card
  after_create :send_welcome_email
  after_commit :send_teacher_assignment_emails, on: [ :create, :update ], if: -> { saved_change_to_teacher_id? && teacher_id.present? }
  after_commit :send_marks_published_email, on: :update, if: :saved_change_to_marks?
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
  validate :validate_profile_photo
  validate :validate_documents
  private

  def validate_profile_photo
    return unless profile_photo.attached?
    unless profile_photo.content_type.in?(%w[image/jpeg image/png image/jpg])
      errors.add(:profile_photo, "must be a JPEG or PNG image")
    end
    if profile_photo.blob.byte_size > 5.megabytes
      errors.add(:profile_photo, "size must be less than 5MB")

    end
  end

  def send_welcome_email
    StudentMailer.welcome_email(self).deliver_later
  end

  def send_teacher_assignment_emails
    StudentMailer.teacher_assigned(self).deliver_later
    TeacherMailer.new_student(self).deliver_later
  end

  def send_marks_published_email
    StudentMailer.marks_published(self).deliver_later if marks.present?
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
