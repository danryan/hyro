module Hyro
  module Transform
    class Time
      
      def self.decode(v)
        return nil if v.nil?
        ::DateTime.strptime(v, "%Y-%m-%dT%H:%M:%SZ").to_time
      end
      
      def self.encode(v)
        return nil if v.nil?
        v.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
      
    end
  end
end