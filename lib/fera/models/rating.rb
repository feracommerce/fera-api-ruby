module Fera
  class Rating < Base
    include HasSubject
    include BelongsToProduct

    alias_attribute :value, :average
    alias_attribute :rating, :average
  end
end
