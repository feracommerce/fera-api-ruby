require 'active_support/concern'

module Fera
  module HasMedia
    extend ActiveSupport::Concern

    included do
      has_many :media, class_name: "Fera::Media"
      has_many :videos, class_name: "Fera::Video"
      has_many :photos, class_name: "Fera::Photo"
    end

    def media=(inputs)
      @media = inputs.to_a.map do |input|
        self.new_media(input)
      end
    end

    def add_media(input)
      new_model = self.new_media(input)
      if @media.nil?
        @media = [new_model]
      else
        @media << new_model
      end
    end

    def new_media(input = nil)
      model_class = [Photo, Video].include?(input.class) ? input.class : Media
      new_has_many_associated_model(model_class, input)
    end

    def media(query = {})
      if @media && query.blank?
        @media.to_a
      else
        Media.where(query.merge("#{ self.class.name.demodulize.underscore }_id" => id))
      end
    end

    def photos=(inputs)
      @photos = inputs.to_a.map do |input|
        new_has_many_associated_model(Photo, input)
      end
    end

    def add_photo(input)
      new_model = self.new_photo(input)
      if @photos.nil?
        @photos = [new_model]
      else
        @photos << new_model
      end
    end

    def new_photo(input = nil)
      new_has_many_associated_model(Photo, input)
    end

    def photos(query = {})
      if @photos && query.blank?
        @photos.to_a
      else
        Photo.where(query.merge("#{ self.class.name.demodulize.underscore }_id" => id))
      end
    end

    def videos=(inputs)
      @videos = inputs.to_a.map do |input|
        self.new_video(input)
      end
    end

    def add_video(input)
      new_model = self.new_video(input)
      if @videos.nil?
        @videos = [new_model]
      else
        @videos << new_model
      end
    end

    def new_video(input = nil)
      new_has_many_associated_model(Video, input)
    end

    def videos(query = {})
      if @videos && query.blank?
        @videos.to_a
      else
        Video.where(query.merge("#{ self.class.name.demodulize.underscore }_id" => id))
      end
    end
  end
end
