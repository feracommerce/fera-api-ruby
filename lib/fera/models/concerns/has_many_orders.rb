require 'active_support/concern'

module Fera
  module HasManyOrders
    extend ActiveSupport::Concern

    included do
      has_many :orders, class_name: "Fera::Order"
    end

    def orders=(new_orders)
      @orders = new_orders.to_a.map do |model|
        if model.is_a?(Order)
          model
        else
          model_id = model.try(:with_indifferent_access).try(:[], :id)
          Order.new(model, model_id.present?)
        end
      end
    end

    def photos(query = {})
      if @orders && query.blank?
        @orders.to_a
      else
        Order.where(query.merge("#{ self.class.name.demodulize.underscore }_id" => id))
      end
    end
  end
end
