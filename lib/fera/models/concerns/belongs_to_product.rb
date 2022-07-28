require 'active_support/concern'

module Fera
  module BelongsToProduct
    extend ActiveSupport::Concern

    included do
      belongs_to :product, class_name: "Fera::Product"
    end

    def product=(product)
      product_id = if product.is_a?(Product)
                    product.id
                  else
                    product.try(:with_indifferent_access).try(:[], :id)
                  end
      external_product_id = if product.is_a?(Product)
                     product.external_id
                   else
                     product.try(:with_indifferent_access).try(:[], :external_id)
                   end
      @product = if product.is_a?(Product)
                      product
                    else
                      Product.new(product, product_id.present?)
                    end
      self.attributes['product_id'] = product_id
      self.attributes['external_product_id'] = external_product_id
      self.attributes.delete('product')
      @product
    end

    def product
      if @product.present?
        @product
      elsif attributes.key?('product') && attributes['product'].present?
        Product.new(attributes['product'], true)
      elsif attributes.key?('product_id') && product_id.present?
        Product.find(product_id)
      elsif attributes.key?('external_product_id') && external_product_id.present?
        Product.find(external_product_id)
      else
        nil
      end
    end

  end
end
