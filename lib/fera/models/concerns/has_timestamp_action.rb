require 'active_support/concern'

module Fera
  module HasTimestampAction
    extend ActiveSupport::Concern

    module ClassMethods
      # define API actions that set a timestamp on the model
      # @example
      #   class Order < Fera::Base
      #     include HasTimestampAction
      #
      #     timestamp_action deliver: :delivered
      #   end
      #
      #   routes to `PUT /orders/1/deliver`
      #
      #   order = Order.find(1)
      #   order.delivered? # => false
      #   order.deliver!(Time.now)
      #   order.delivered? # => true
      #   order.delivered_at # => 2018-01-01 00:00:00 UTC
      #
      #   or
      #
      #   Fera::Order.deliver!(1, Time.now.utc)
      #
      # @param [Array<Symbol>] actions
      def timestamp_action(args)
        args.each do |action, state|
          define_method("#{ action }!") do |at = nil|
            changed_attributes = { "#{ state }_at": (at || Time.now).utc }

            put(action, changed_attributes)

            load(changed_attributes)

            true
          end

          define_method("#{ state }?") do
            send("#{ state }_at?")
          end

          define_singleton_method("#{ action }!") do |id, at = nil|
            find(id).send("#{ action }!", at)
          end
        end
      end
    end
  end
end
