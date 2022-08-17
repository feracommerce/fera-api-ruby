module Fera
  class Media < Base
    include HasSubject
    include BelongsToCustomer
    include BelongsToProduct
    include BelongsToReview
    include BelongsToSubmission

    after_create :remove_file_param

    class << self
      def instantiate_record(record, prefix_options = {})
        new_klass = if record['type'] == 'video'
                      Video
                    else
                      Photo
                    end
        new_klass.new(record, record['id'].present?).tap do |resource|
          resource.prefix_options = prefix_options
        end
      end
    end

    def is_video?
      type.to_s == 'video'
    end
    alias_method :video?, :is_video?

    def is_photo?
      type.to_s == 'photo'
    end
    alias_method :photo?, :is_photo?

    def file=(val)
      if val.is_a?(File)
        file_name = File.basename(val.path)
        mime_type_group = type == 'video' ? 'video' : 'image'
        self.attributes['file'] = {
          'name' => File.basename(file_name),
          'data' => "data:#{ mime_type_group }/#{ file_name.split('.').last };base64,#{ Base64.encode64(val.read) }"
        }
      else
        self.attributes['file'] = val
      end
    end

    private

    def remove_file_param
      return unless self.attributes.key?('file')

      self.attributes.delete('file')
    end
  end
end
