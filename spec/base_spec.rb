require 'hyro'

describe Hyro::Base do
  let(:klass) do
    class TestSubclass < Hyro::Base
    end
    TestSubclass.instance_variable_set(:@configuration, nil)
    TestSubclass
  end
  
  describe ".configure" do
    it "should be configurable" do
      base_url = "http://localtest.host"
      base_path = "/widgets"
      authorization = "Bearer SEKRET"
      klass.configure do |conf|
        conf.base_url = base_url
        conf.base_path = base_path
        conf.authorization = authorization
      end
      klass.configuration.base_url.should == base_url
      klass.configuration.base_path.should == base_path
      klass.configuration.authorization.should == authorization
    end
  end
  
  describe ".new_connection" do
    it "should be noisy about missing base URL" do
      lambda { klass.new_connection }.should raise_error(Hyro::Misconfigured)
    end
    
    it "should return a Faraday connection" do
      klass.configure do |conf|
        conf.base_url = "http://localtest.host"
        conf.base_path = "/widgets"
        conf.authorization = "Bearer SEKRET"
      end
      conn = klass.new_connection
      conn.should be_kind_of(Faraday::Connection)
    end
  end
end
