module Fera
  class Review < Base
    include HasMedia
    include HasSubject
    include BelongsToCustomer
    include BelongsToProduct
    include BelongsToSubmission

    def only_rating?
      body.blank? && heading.blank?
    end
    alias_method :rating_only?, :only_rating?

    def stars
      (('★' * rating) + ('☆' * (5 - rating))).chars.join(" ")
    end
  end
end
