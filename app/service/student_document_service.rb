class StudentDocumentService
  def self.upload(student, files)
    return unless files.present?

    student.documents.attach(files)
  end

  def self.delete(student, document_id)
    document = student.documents.find(document_id)
    document.purge
  end
end
