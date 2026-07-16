class User < ApplicationRecord
  scope :teacher, -> { where(role: "teacher") }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :students, foreign_key: :teacher_id, dependent: :destroy
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def admin?
    role == "admin"
  end

  def teacher?
    role == "teacher"
  end
end
