describe Hyro::Base do
  let(:klass) do
    class TestSubclass < Hyro::Base
      model_attribute :id, :name
    end
    TestSubclass.instance_variable_set(:@configuration, nil)
    TestSubclass.instance_variable_set(:@connection, nil)
    TestSubclass
  end
  
  describe ".configure" do
    it "should be configurable" do
      root_name = "widget"
      root_name_plural = "widgets"
      base_url = "http://localtest.host"
      base_path = "/widgets"
      auth_type = "Bearer"
      auth_token = "SEKRET"
      klass.configure do |conf|
        conf.root_name = root_name
        conf.root_name_plural = root_name_plural
        conf.base_url = base_url
        conf.base_path = base_path
        conf.auth_type = auth_type
        conf.auth_token = auth_token
      end
      klass.configuration.root_name.should == root_name
      klass.configuration.root_name_plural.should == root_name_plural
      klass.configuration.base_url.should == base_url
      klass.configuration.base_path.should == base_path
      klass.configuration.auth_type.should == auth_type
      klass.configuration.auth_token.should == auth_token
    end
  end
  
  describe ".new_connection" do
    it "should be noisy about missing base URL" do
      lambda { klass.new_connection }.should raise_error(Hyro::Misconfigured)
    end
    
    it "should return a Faraday connection" do
      klass.configure do |conf|
        conf.root_name = "widget"
        conf.root_name_plural = "widgets"
        conf.base_url = "http://localtest.host"
        conf.base_path = "/widgets"
        conf.auth_type = "Bearer"
        conf.auth_token = "SEKRET"
      end
      conn = klass.new_connection
      conn.should be_kind_of(Faraday::Connection)
    end
  end
  
  describe "instance" do
    before(:each) do
      klass.configure do |conf|
        conf.root_name = "widget"
        conf.root_name_plural = "widgets"
        conf.base_url = "http://localtest.host"
        conf.base_path = "/widgets"
        conf.auth_type = "Bearer"
        conf.auth_token = "SEKRET"
      end
    end
    
    describe "#initialize" do
      it "should return populated instance" do
        inst = klass.new( "id" => 1, "name" => "Uno")
        inst.id.should == 1
        inst.name.should == "Uno"
      end
      
      it "should raise on unexpected attributes" do
        lambda { TestSubclass.new( :id => 100, :name => "Neverknown", :welp => "bolth") }.should 
          raise_error(Hyro::UnknownAttribute)
      end
    end
  end
end
