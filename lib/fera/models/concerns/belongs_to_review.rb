require 'active_support/concern'

module Fera
  module BelongsToReview
    extend ActiveSupport::Concern

    included do
      belongs_to :review, class_name: "Fera::Review"
    end

    def review=(review)
      review_id = if review.is_a?(Review)
                        review.id
                      else
                        review.try(:with_indifferent_access).try(:[], :id)
                      end
      @review = if review.is_a?(Review)
                      review
                    else
                      Review.new(review, review_id.present?)
                    end
      self.attributes['review_id'] = review_id
      self.attributes.delete('review')
      @review
    end

    def review
      if @review.present?
        @review
      elsif attributes.key?('review') && attributes['review'].present?
        Review.new(attributes['review'], true)
      elsif attributes.key?('review_id') && review_id.present?
        Review.find(review_id)
      else
        nil
      end
    end

  end
end
