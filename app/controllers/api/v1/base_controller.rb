module Api
  module V1
    class BaseController < ApplicationController
       protect_from_forgery with: :null_session
      
      before_action :authenticate_user!
      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: {
          errors: [e.message]
        }, status: :not_found
      end
    end
  end
end
