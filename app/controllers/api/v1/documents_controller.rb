# app/controllers/api/v1/documents_controller.rb
module Api
  module V1
    class DocumentsController < BaseController
      before_action :set_student
      before_action :set_document, only: [ :show, :destroy, :download ]

      # GET /api/v1/students/:student_id/documents
      def index
        documents = @student.documents.map { |doc| document_json(doc) }
        render json: {
          message: "Documents fetched successfully",
          documents: documents
        }, status: :ok
      end

      # GET /api/v1/students/:student_id/documents/:id
      def show
        render json: {
          message: "Document fetched successfully",
          document: document_json(@document)
        }, status: :ok
      end

      # GET /api/v1/students/:student_id/documents/:id/download
      def download
        send_data @document.download,
                  filename: @document.filename.to_s,
                  type: @document.content_type,
                  disposition: "attachment"
      end

      # POST /api/v1/students/:student_id/documents
      def create
        files = params[:documents] || params[:file]

        if files.present?
          StudentDocumentService.upload(@student, files)

          if @student.errors.none?
            documents = @student.documents.map { |doc| document_json(doc) }
            render json: {
              message: "Documents uploaded successfully",
              documents: documents
            }, status: :created
          else
            render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { errors: [ "No document files provided for upload" ] }, status: :bad_request
        end
      end

      # DELETE /api/v1/students/:student_id/documents/:id
      def destroy
        StudentDocumentService.delete(@student, @document.id)
        render json: {
          message: "Document deleted successfully"
        }, status: :ok
      end

      private

      def set_student
        @student = Student.find(params[:student_id])
      end

      def set_document
        @document = @student.documents.find_by(id: params[:id]) || @student.documents.find_by(blob_id: params[:id])
        return if @document.present?

        render json: {
          errors: [ "Document with ID #{params[:id]} not found for this student" ]
        }, status: :not_found
      end

      def document_json(document)
        {
          id: document.id,
          blob_id: document.blob_id,
          filename: document.filename.to_s,
          content_type: document.content_type,
          byte_size: document.byte_size,
          created_at: document.created_at,
          url: Rails.application.routes.url_helpers.rails_blob_url(document, only_path: true)
        }
      end
    end
  end
end
