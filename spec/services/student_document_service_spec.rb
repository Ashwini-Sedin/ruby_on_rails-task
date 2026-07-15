require "rails_helper"

RSpec.describe StudentDocumentService do
  let(:student) { create(:student) }

  let(:file) do
    fixture_file_upload(
      Rails.root.join("spec/fixtures/files/sample.pdf"),
      "application/pdf"
    )
  end

  describe ".upload" do
    it "attaches documents" do
      described_class.upload(student, [file])

      expect(student.documents).to be_attached
      expect(student.documents.count).to eq(1)
    end
  end
  describe ".delete" do
   it "deletes a document" do
    student.documents.attach(file)

    document_id = student.documents.first.id

    described_class.delete(student, document_id)

    student.reload

    expect(student.documents).not_to be_attached
  end
end
  
end