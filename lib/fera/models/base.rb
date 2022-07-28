require_relative './collection'

module Fera
  class Base < ActiveResource::Base
    # include ActiveModel::Dirty

    attr_reader :last_response, :last_response_body, :last_response_message, :last_response_exception, :options

    self.collection_parser = ::Fera::Collection

    class << self
      def belongs_to(name, options = {})
        @belongs_tos = @belongs_tos.to_h.merge(name => options)
      end

      def belongs_tos; @belongs_tos.to_h; end

      def has_many(name, options = {})
        @has_manys = @has_manys.to_h.merge(name => options)
      end

      def has_manys; @has_manys.to_h; end

      def has_one(name, options = {})
        @has_ones = @has_ones.to_h.merge(name => options)
      end

      def has_ones; @has_ones.to_h; end

      def headers
        if _headers_defined?
          _headers
        elsif superclass != Object && superclass.headers
          superclass.headers
        else
          _headers ||= {} # rubocop:disable Lint/UnderscorePrefixedVariableName
        end
      end

      def default_params=(default_params)
        @default_params = default_params
      end

      ##
      # @override to support extra_params
      def create(attributes = {}, extra_params = {})
        self.new(attributes, false).tap { |resource| resource.create(extra_params) }
      end

      ##
      # @override to fix issue that it's not raising the error and also to support extra_params
      def create!(attributes = {}, extra_params = {})
        self.new(attributes, false).tap { |resource| resource.create!(extra_params) }
      end

      ##
      # @override to support default params
      def find_every(options)
        super(add_default_params(options))
      end

      ##
      # @override to support default params
      def find_one(options)
        super(add_default_params(options))
      end

      ##
      # @override to support default params
      def find_single(scope, options)
        options = add_default_params(options)
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)

        response = connection.get(path, headers)
        record = instantiate_record(format.decode(response.body), prefix_options)

        record.set_last_response(response)
        record
      end

      def new_element_path(prefix_options = {}, extra_params = {})
        url = "#{prefix(prefix_options)}#{collection_name}/new#{format_extension}"
        url += "?#{ extra_params.to_param }" if extra_params.present?
        url
      end

      private

      def add_default_params(options)
        if @default_params.present?
          options ||= {}
          options[:params] = options[:params].to_h.merge(@default_params)
        end

        options
      end
    end

    def initialize(attributes = nil, persisted = nil, options = {})
      @options = options.to_h

      dynamic_attributes = attributes.to_h.dup

      association_keys = self.class.has_manys.keys + self.class.has_ones.keys + self.class.belongs_tos.keys

      dynamic_attributes.except!(*(association_keys + association_keys.map(&:to_s)))

      super(dynamic_attributes, persisted)

      association_keys.each do |name, _opts|
        if attributes.key?(name.to_s) || attributes.key?(name.to_sym)
          val = attributes.to_h[name.to_s] || attributes.to_h[name.to_sym]
          self.send("#{ name }=", val) if respond_to?("#{ name }=")
        end
      end if attributes.present?
    end

    def load(attributes, *args)
      load_result = super(attributes, *args)

      attributes.each do |attr, val|
        if respond_to?("#{ attr }=".to_sym)
          self.send("#{ attr }=".to_sym, val)
        end
      end

      @clean_copy = clone_with_nil if persisted? && !options[:cloned]

      load_result
    end

    def destroy!
      destroy
    end

    def created_at=(new_created_at)
      if new_created_at.is_a?(String)
        super(Time.parse(new_created_at))
      else
        super
      end
    end

    def updated_at=(new_updated_at)
      if new_updated_at.is_a?(String)
        super(Time.parse(new_updated_at))
      else
        super
      end
    end

    def update(changed_attributes, extra_params = {}, raise = false)
      run_callbacks(:update) do
        connection.put(element_path(prefix_options, extra_params), dynamic_changed_attributes.to_json, self.class.headers).tap do |response|
          load_attributes_from_response(response)
        end

        load(changed_attributes)
      end

      true
    rescue ActiveResource::ConnectionError => e
      set_last_response(e)

      if raise
        raise(ActiveResource::ResourceInvalid.new(last_response, last_response_message.presence))
      end

      false
    end

    def update!(changed_attributes, extra_params = {})
      update(changed_attributes, extra_params, true)
    end

    def valid?(_context = nil)
      super()
    end

    ##
    # @override to add exgtra params
    def create(extra_params = {}, raise = false)
      run_callbacks :create do

        data = as_json
        (self.class.belongs_tos.merge(self.class.has_ones)).each do |name, _opts|
          next unless instance_variable_defined?(:"@#{ name }")
          nested_resource = self.send(name)
          if nested_resource.present? && !nested_resource.persisted?
            nested_resource.validate!
            data[name] = nested_resource.as_json
          end
        end

        self.class.has_manys.each do |name, _opts|
          next unless instance_variable_defined?(:"@#{ name }")
          nested_resource = self.send(name)

          next if nested_resource.nil?

          nested_resource.each do |nested_resource_instance|
            next if nested_resource_instance.persisted?

            nested_resource_instance.validate!

            data[name] ||= []
            data[name] << nested_resource_instance.as_json
          end
        end

        connection.post(collection_path(nil, extra_params), data.to_json, self.class.headers).tap do |response|
          self.id = id_from_response(response)
          load_attributes_from_response(response)
        end
      end

      true
    rescue ActiveResource::ConnectionError => e
      set_last_response(e)

      if raise
        raise(ActiveResource::ResourceInvalid.new(last_response, last_response_message.presence))
      end

      false
    end

    def create!(extra_params = {})
      create(extra_params, true)
    end

    def save(extra_params = {}, raise = false)
      run_callbacks :save do
        if new?
          create(extra_params, raise) # We'll raise the error below
        else
          # find changes
          changed_attributes = attributes.filter { |key, value| !@clean_copy.attributes.key?(key) || (@clean_copy.attributes[key] != value) || (key == self.class.primary_key) }
          changed_attributes.reject! { |k| k == 'id' }
          return false unless changed_attributes.keys.any?

          # save
          update(changed_attributes, extra_params, raise)
        end

        @clean_copy = clone_with_nil # Clear changes

        self
      end

    end

    def save!(extra_params = {})
      save(extra_params, true)
    end

    def clone_with_nil
      # Clone all attributes except the pk and any nested ARes
      cloned = Hash[attributes.reject { |k, v| k == self.class.primary_key || v.is_a?(ActiveResource::Base) }.map { |k, v| [k, v.clone] }]
      # Form the new resource - bypass initialize of resource with 'new' as that will call 'load' which
      # attempts to convert hashes into member objects and arrays into collections of objects. We want
      # the raw objects to be cloned so we bypass load by directly setting the attributes hash.
      resource = self.class.new({}, true, { cloned: true })
      resource.prefix_options = prefix_options
      resource.send :instance_variable_set, '@attributes', cloned
      resource
    end

    def clone_selected_fields(model, fields)
      fields = fields.is_a?(Array) ? fields : fields.to_s.split(',').map(&:strip)

      # find fields
      changed_attributes = HashWithIndifferentAccess.new
      changed_attributes[model.class.primary_key] = model.attributes[model.class.primary_key]
      fields.each do |key|
        if key.include?(':')
          clone_sub_fields(model, key, changed_attributes)
        elsif fields.include?(key)
          changed_attributes[key] = model.attributes[key]
        end
      end

      # create new object
      self.class.new(changed_attributes, true)
    end

    #
    # Method missing adapters to define public_*_id
    #

    def method_missing(method_name, *args, &block)
      matcher = method_name.to_s.match(/^(?!is_)([a-z_]+)\?$/) || method_name.to_s.match(/^is_([a-z_]+)\?$/)
      if matcher.present?
        attribute_name = matcher[1]
        return super if attribute_name.blank?
        attribute_name = "is_#{ attribute_name }" unless attribute_name =~ /^is_/
        return super unless known_attribute?(attribute_name.to_s)
        return !!(send(attribute_name.to_sym).presence)
      end

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      matcher = method_name.to_s.match(/^(?!is_)([a-z_]+)\?$/) || method_name.to_s.match(/^is_([a-z_]+)\?$/)
      if matcher.present?
        attribute_name = matcher[1]
        return super if attribute_name.blank?
        attribute_name = "is_#{ attribute_name }" unless attribute_name =~ /^is_/
        return true if known_attribute?(attribute_name)
      end

      super
    end

    def known_attribute?(attribute_name)
      known_attributes.map(&:to_s).include?(attribute_name.to_s)
    end

    def set_last_response(result)
      response = if result.is_a?(StandardError)
                   @last_response_exception = result
                   @last_response_exception.response
                 else
                   @last_response_exception = nil
                   result
                 end

      @last_response = response
      @last_response_body = response.body.present? ? self.class.format.decode(response.body) : nil
      @last_response_message = last_response_body.to_h['message']
    end

    protected

    def load_attributes_from_response(response)
      set_last_response(response)
      super(response)
    end

    private

    def new_has_many_associated_model(model_class, input = nil)
      model = if input.blank? || input.is_a?(Hash)
                model_class.new(input.to_h.with_indifferent_access, false)
              else
                model_class.instantiate_record(input, input.id.present?)
              end
      model.send("#{ self.class.name.demodulize.underscore }=", self)
      model
    end

    def element_path(options = nil, extra_params = {})
      self.class.element_path(to_param, options || prefix_options, extra_params)
    end

    def element_url(options = nil, extra_params = {})
      self.class.element_url(to_param, options || prefix_options, extra_params)
    end

    def new_element_path(extra_params = {})
      self.class.new_element_path(prefix_options, extra_params)
    end

    ##
    # @override
    def collection_path(options = nil, extra_params = {})
      self.class.collection_path(options || prefix_options, extra_params)
    end

    def clone_sub_fields(model, key, changed_attributes)
      sub_fields = key.split(':')
      sub_key = sub_fields.first
      values = model.attributes[sub_key]
      sub_fields = sub_fields.drop(1)
      changed_attributes[sub_key] = values.map { |value| clone_selected_fields(value, sub_fields) }
    end
  end
end
