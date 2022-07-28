require 'active_support/concern'

module Fera
  module BelongsToSubmission
    extend ActiveSupport::Concern

    included do
      belongs_to :submission, class_name: "Fera::Submission"
    end

    def submission=(submission)
      submission_id = if submission.is_a?(Submission)
                        submission.id
                      else
                        submission.try(:with_indifferent_access).try(:[], :id)
                      end
      @submission = if submission.is_a?(Submission)
                      submission
                    else
                      Submission.new(submission, submission_id.present?)
                    end
      self.attributes['submission_id'] = submission_id
      self.attributes.delete('submission')
    end

    def submission
      if @submission.present?
        @submission
      elsif attributes.key?('submission') && attributes['submission'].present?
        Submission.new(attributes['submission'], true)
      elsif attributes.key?('submission_id') && submission_id.present?
        Submission.find(submission_id)
      else
        nil
      end
    end
  end
end
