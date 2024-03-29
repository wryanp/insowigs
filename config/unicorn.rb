worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Rails.logger.debug "server: #{server.to_s}, worker: #{worker.to_s}"
  Signal.trap 'TERM' do
    Rails.logger.info 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Rails.logger.debug "server: #{server.to_s}, worker: #{worker.to_s}"
  Signal.trap 'TERM' do
    Rails.logger.info 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
