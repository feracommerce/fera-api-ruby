module Fera
  class Store < Base
    include ActiveResource::Singleton

    self.singleton_name = :store

    def self.current(options = {})
      find(options)
    end
  end
end
