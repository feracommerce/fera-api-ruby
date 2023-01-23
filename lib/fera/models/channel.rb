require_rel "./concerns/has_many_reviews"

module Fera
  class Channel < Base
    include HasManyReviews

    self.collection_name = "/reviews/channels"
  end
end
