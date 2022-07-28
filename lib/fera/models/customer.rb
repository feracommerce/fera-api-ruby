module Fera
  class Customer < Base
    include HasManyReviews
    include HasMedia
    include HasManyOrders
    include HasManySubmissions
  end
end
