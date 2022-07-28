require 'active_support/concern'

module Fera
  module HasManySubmissions
    extend ActiveSupport::Concern

    included do
      has_many :submission, class_name: "Fera::Submission"
    end

    def submissions=(new_submissions)
      @submissions = new_submissions.to_a.map do |model|
        if model.is_a?(Submission)
          model
        else
          model_id = model.try(:with_indifferent_access).try(:[], :id)
          Submission.new(model, model_id.present?)
        end
      end
    end

    def submissions(query = {})
      if @submissions && query.blank?
        @submissions.to_a
      else
        Submission.where(query.merge("#{ self.class.name.demodulize.underscore }_id" => id))
      end
    end
  end
end
