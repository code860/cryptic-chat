if defined?(POOLED_CONNECTIONS)
  Sidekiq.configure_client do |config|
    config.redis = POOLED_CONNECTIONS.sidekiq_connection_client.conn_pool
  end

  Sidekiq.configure_server do |config|
    config.redis = POOLED_CONNECTIONS.sidekiq_connection_server.conn_pool
  end
end
