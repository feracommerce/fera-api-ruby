module Fera
  class Order < Base
    include BelongsToCustomer
    include HasTimestampAction

    timestamp_action pay: :paid_at, deliver: :delivered_at, fulfill: :fulfilled_at
  end
end
