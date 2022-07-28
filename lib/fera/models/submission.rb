module Fera
  class Submission < Base
    include HasMedia
    include HasManyReviews
    include BelongsToCustomer
    include BelongsToOrder

    schema do
      string 'id'
      string 'external_customer_id'
      string 'customer_id'

      boolean 'is_test'

      timestamp 'created_at'
      timestamp 'updated_at'
    end
  end
end
