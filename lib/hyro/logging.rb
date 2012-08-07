module Hyro
  
  # Simple hook to write Faraday instrumentation data into the Rails log.
  #
  module Logging
    
    if Kernel.const_defined?(:Rails) && 
      Kernel.const_defined?(:ActiveSupport) && ActiveSupport.const_defined?(:Notifications)
      
      ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
        url = env[:url]
        http_method = env[:method].to_s.upcase
        duration = ((end_time - start_time) * 1000)
        Rails.logger.info 'Hyro %s %s (%.1fms)' % [http_method, url.to_s, duration]
      end
    end
    
  end
end
