require 'active_support/concern'

module Fera
  module BelongsToCustomer
    extend ActiveSupport::Concern

    included do
      belongs_to :customer, class_name: "Fera::Customer"
    end

    def customer=(customer)
      if customer.is_a?(Customer)
        @customer = customer
        self.attributes['customer_id'] = customer.id
        self.attributes['external_customer_id'] = customer.try(:external_id)
        self.attributes.delete('customer')
      elsif customer.is_a?(Hash)
        customer_id = customer.with_indifferent_access[:id]

        if customer.with_indifferent_access.key?(:id) # Hash
          if customer_id =~ /^fcus_/
            self.attributes['customer_id'] = customer_id
          else
            self.attributes['external_customer_id'] = customer_id
          end
        end

        if customer.with_indifferent_access.key?(:external_id) # Hash
          self.attributes['external_customer_id'] = customer.with_indifferent_access[:external_id]
        end

        @customer = Customer.new(customer, customer_id.present?)
        self.attributes.delete('customer')
      end


      @customer
    end

    def customer_id=(new_id)
      if @customer.present?
        @customer.id = new_id
      end

      self.attributes['customer_id'] = new_id
    end

    def external_customer_id=(new_external_id)
      if @customer.present?
        @customer.external_id = new_external_id
      end

      self.attributes['external_customer_id'] = new_external_id
    end

    def customer
      if @customer.present?
        @customer
      elsif attributes.key?('customer') && attributes['customer'].present?
        Customer.new(attributes['customer'], true)
      elsif attributes.key?('customer_id') && customer_id.present?
        Customer.find(customer_id)
      elsif attributes.key?('external_customer_id') && external_customer_id.present?
        Customer.find(external_customer_id)
      else
        nil
      end
    end
  end
end
