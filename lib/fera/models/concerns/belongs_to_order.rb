require 'active_support/concern'

module Fera
  module BelongsToOrder
    extend ActiveSupport::Concern

    included do
      belongs_to :order, class_name: "Fera::Order"
    end

    def order=(order)
      order_id = if order.is_a?(Order)
                     order.id
                   else
                     order.try(:with_indifferent_access).try(:[], :id)
                   end
      external_order_id = if order.is_a?(Order)
                              order.external_id
                            else
                              order.try(:with_indifferent_access).try(:[], :external_id)
                            end
      @order = if order.is_a?(Order)
                   order
                 else
                   Order.new(order, order_id.present?)
                 end
      self.attributes['order_id'] = order_id
      self.attributes['external_order_id'] = external_order_id
      self.attributes.delete('order')
    end

    def order_id=(new_id)
      return if order_id == new_id

      if new_id.nil?
        reset_order_instance_assoc
      else
        self.attributes['order_id'] = new_id
      end
    end

    def external_order_id=(new_id)
      return if external_order_id == new_id

      if new_id.nil?
        reset_order_instance_assoc
      else
        self.attributes['external_order_id'] = new_id
      end
    end

    def order
      if @order.present?
        @order
      else
        load_order
      end
    end

    def reload
      reset_order_instance_assoc
      super
    end

    private

    def reset_order_instance_assoc
      remove_instance_variable(:@order)
      self.attributes['order_id'] = nil
      self.attributes['external_order_id'] = nil
    end

    def load_order
      if attributes.key?('order') && attributes['order'].present?
        Order.new(attributes['order'], true)
      elsif attributes.key?('order_id') && order_id.present?
        Order.find(order_id)
      elsif attributes.key?('external_order_id') && external_order_id.present?
        Order.find(external_order_id)
      else
        nil
      end
    end

  end
end
