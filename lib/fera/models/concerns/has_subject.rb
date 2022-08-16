require 'active_support/concern'

module Fera
  module HasSubject
    extend ActiveSupport::Concern

    module ClassMethods
      def for_products(product_ids = nil)
        if product_ids.present?
          where(product_id: product_ids)
        else
          where(subject: :product)
        end
      end

      def for_product(product_id)
        for_products(product_id).try(:first)
      end

      def for_store
        all.where(subject: :store).try(:first)
      end
    end

    ##
    # Returns the associated product model if it was preloaded in the original request and if the object is for a product.
    # @return [::Fera::Product, NilClass]
    def product
      return nil if attributes['subject'] !~ /^product/i

      super
    end

    def for_product?
      subject.to_s == 'product'
    end

    def for_store?
      subject.to_s == 'store'
    end
  end
end
