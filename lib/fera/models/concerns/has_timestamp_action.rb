require 'active_support/concern'

require "pry"

module Fera
  module HasTimestampAction
    extend ActiveSupport::Concern

    module ClassMethods
      # define API actions that set a timestamp on the model
      # @example
      #   class Order < Fera::Base
      #     include HasTimestampAction
      #
      #     timestamp_action :deliver
      #   end
      #
      #   routes to `PUT /orders/1/deliver`
      #
      #   order = Order.find(1)
      #   order.deliver!(Time.now)
      #
      #   or
      #
      #   Fera::Order.deliver!(1, Time.now.utc)
      #
      # @param [Array<Symbol>] actions
      def timestamp_action(args)
        args.each do |action, attribute|
          define_method("#{ action }!") do |at = nil|
            changed_attributes = { "#{ attribute }": (at || Time.now).utc }

            put(action, changed_attributes)

            load(changed_attributes)

            true
          end

          define_singleton_method("#{ action }!") do |id, at = nil|
            find(id).send("#{ action }!", at)
          end
        end
      end
    end
  end
end
