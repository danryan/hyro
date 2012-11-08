module Hyro
  module Transform
    class JSON
      
      def self.decode(v)
        return nil if v.nil?
        ::JSON.load(v)
      end
      
      def self.encode(v)
        return nil if v.nil?
        ::JSON.dump(v)
      end      
    end
  end
end
