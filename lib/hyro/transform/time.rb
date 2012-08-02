module Hyro
  module Transform
    class Time
      
      def self.decode(v)
        ::DateTime.strptime(v, "%Y-%m-%dT%H:%M:%SZ").to_time
      end
      
      def self.encode(v)
        v.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
      
    end
  end
end