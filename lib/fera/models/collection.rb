require 'active_resource/collection'

module Fera
  class Collection < ActiveResource::Collection
    attr_reader :result_count, :total_count, :page, :total_pages, :page_size, :offset, :limit

    def initialize(parsed = {})
      super(parsed['data'])
      @result_count = parsed['result_count']
      @total_count = parsed['total_count']

      @using_pagination = parsed.key?('page')

      if @using_pagination
        @page = parsed['page']
        @total_pages = parsed['total_pages']
        @page_size = parsed['page_size']
      else
        @offset = parsed['offset']
        @limit = parsed['limit']
      end
    end

    def using_pagination?; @using_pagination; end
  end
end
