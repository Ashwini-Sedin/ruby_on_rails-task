class StudentRegistrationService
  def self.call(params)
    profile_photo = params.delete(:profile_photo)
    documents = params.delete(:documents)

    student = Student.new(params)

    if student.save
      ProfilePhotoService.upload(student, profile_photo) if profile_photo.present?
      StudentDocumentService.upload(student, documents) if documents.present?

      {
        success: true,
        student: student
      }
    else
      {
        success: false,
        errors: student.errors.full_messages
      }
    end
  end
end
