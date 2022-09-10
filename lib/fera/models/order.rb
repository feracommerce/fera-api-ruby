module Fera
  class Order < Base
    include BelongsToCustomer
    include HasTimestampAction

    timestamp_action pay: :paid, deliver: :delivered, fulfill: :fulfilled
  end
end
