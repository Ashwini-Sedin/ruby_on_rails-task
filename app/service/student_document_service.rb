class StudentDocumentService
  def self.upload(student, files)
    return unless files.present?

    student.documents.attach(files)
    if student.teacher.present?
      TeacherMailer.documents_uploaded(student).deliver_later
    end
  end

  def self.delete(student, document_id)
    document = student.documents.find(document_id)
    document.purge
  end
end
