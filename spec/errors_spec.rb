describe Hyro::Errors do
  let!(:klass) do
    class TestSubclass < Hyro::Base
      model_attribute :id, :name
    end
    TestSubclass.instance_variable_set(:@configuration, nil)
    TestSubclass.instance_variable_set(:@connection, nil)
    TestSubclass.configure do |conf|
      conf.root_name = "widget"
      conf.root_name_plural = "widgets"
      conf.base_url = "http://localtest.host"
      conf.base_path = "/widgets"
      conf.auth_type = "Bearer"
      conf.auth_token = "SEKRET"
    end
    TestSubclass
  end
  
  def test_for_error(code, exception)
    stub_request(:get, "http://localtest.host/widgets/100").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(:status => code, :body => '', :headers => {})
    
    lambda { TestSubclass.find!(100) }.should raise_error(exception)
  end
  
  it "raises not found" do  
    test_for_error(404, Hyro::ResourceNotFound)
  end
  
  it "raises not authorized" do  
    test_for_error(401, Hyro::NotAuthorized)
  end
  
  it "raises permission denied" do  
    test_for_error(403, Hyro::PermissionDenied)
  end
  
  it "raises redirected" do  
    test_for_error(302, Hyro::Redirected)
  end
  
  it "raises request error" do  
    test_for_error(400, Hyro::RequestError)
  end
  
  it "raises server error" do  
    test_for_error(500, Hyro::ServerError)
  end
end
