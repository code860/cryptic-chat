module ConnectionManager
  extend ConnectionManager::KeyPassConnection
  extend ConnectionManager::SidekiqConnection
  class << self
    Connections = Struct.new(:key_pass_connection, :sidekiq_connection_client, :sidekiq_connection_server)
    attr_accessor :connections
    def connect!
      key_pass_connection = self.key_pass_connection
      sidekiq_connection_server = self.sidekiq_connection_server
      sidekiq_connection_client = self.sidekiq_connection_client
      @connections ||= Connections.new(key_pass_connection, sidekiq_connection_client, sidekiq_connection_server)
    end
    def disconnect!
      @connections.each{|conn| conn.disconnect}
    end
  end
end
