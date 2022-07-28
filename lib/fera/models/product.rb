module Fera
  class Product < Base
    include HasManyReviews
    include HasMedia

    alias_attribute :rating, :average_rating

    def self.ratings(query = {})
      ProductRating.where(query)
    end
  end
end
