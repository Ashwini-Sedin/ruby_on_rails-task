class ProfilePhotoService
  def self.upload(student, file)
    return unless file.present?

    student.profile_photo.purge if student.profile_photo.attached?

    student.profile_photo.attach(file)
  end

  def self.delete(student)
    student.profile_photo.purge if student.profile_photo.attached?
  end
end
