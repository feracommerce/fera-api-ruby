require 'active_support/concern'

module Fera
  module HasManyReviews
    extend ActiveSupport::Concern

    included do
      has_many :reviews, class_name: "Fera::Review"
    end

    def reviews=(new_reviews)
      @reviews = new_reviews.to_a.map do |model|
        if model.is_a?(Review)
          model
        else
          model_id = model.try(:with_indifferent_access).try(:[], :id)
          Review.new(model, model_id.present?)
        end
      end
    end

    def reviews(query = {})
      if @reviews && query.blank?
        @reviews.to_a
      else
        Review.where(query.merge("#{ self.class.name.demodulize.underscore }_id" => id))
      end
    end
  end
end
