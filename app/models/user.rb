class User < ApplicationRecord
  scope :teacher, -> { where(role: "teacher") }
  scope :by_subject, ->(subj) {
    joins(:students).where("students.course LIKE ?", "%#{subj}%").distinct
  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
       :registerable,
       :recoverable,
       :rememberable,
       :validatable,
       :jwt_authenticatable,
       jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :students, foreign_key: :teacher_id, dependent: :destroy
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def admin?
    role == "admin"
  end

  def teacher?
    role == "teacher"
  end

  def subject
    students.pluck(:course).uniq.first || "Mathematics"
  end
end
