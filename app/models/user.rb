class User < ApplicationRecord
  enum :role, { 
    admin: "admin",
    teacher: "teacher",
    student: "student"
   }
  scope :by_subject, ->(subj) do
    search = ActiveRecord::Base.sanitize_sql_like(subj)
    joins(:students)
     .where("students.course LIKE ?", "%#{search}%").distinct
  end
  

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
  
  def subject
    students.distinct.pick(:course) || "Mathematics"
  end
end
