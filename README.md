# Hyro

**Hy-speed Remote Objects!** A remote HTTP/JSON resource client built with Faraday & ActiveModel, inspired by ActiveResource.

We're actively building this library to replace ActiveResource in our Rails 3 applications. A full RSpec2 test suite is keeping it sane.

  * ActiveModel provides behaviors like Validations, Dirty-tracking, Naming & much more: https://github.com/rails/rails/tree/3-2-stable/activemodel
  * Faraday provides middleware/stack-oriented HTTP connectivity: https://github.com/technoweenie/faraday
  * Hyro itself provides the structure to configure & interact with the objects representing remote resources.

### What it does do

  * define remote resources via Hyro::Base subclasses
  * pass OAuth2-style tokens via HTTP Authorization header
  * find remote resources by ID
  * allow local attribute changes (with dirty-tracking)
  * save (with validations)
  * arbitrary non-REST actions (currently member-only)
  * provides a value transformation mechanism for non-JSON data types (Time is included)

### What it does NOT do (yet)

  * ActiveRecord-style associations; an Association transformation & proxy is needed
  * find multiple resources in one call or support arbitrary queries
  * document or test how the remote service API should work

## Installation

Add this line to your application's Gemfile:

    gem 'hyro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hyro

## Usage

### Define your class.

    class Thing < Hyro::Base
    
      # Declare attributes of the remote model.
      #
      # These will be accessible on the instance 
      # via getter `name` & setter `name=` methods.
      #
      model_attribute :id, :name, :created_at, :updated_at
      
      configure do |conf|
        
        # JSON root element name (required)
        conf.root_name = "thing"
        conf.root_name_plural = "things"
        
        # REST endpoint. (required)
        conf.base_url = "https://awesome-app.com"
        conf.base_path = "/v1/things"
        
        # HTTP "Authorization" header
        conf.auth_type = "Bearer"
        conf.auth_token = "S3KR3T"
        
        # JSON only handles a few primative types.
        # Register transformers to coerce others.
        conf.transforms = {
          "created_at" => Hyro::Transform::Time,
          "updated_at" => Hyro::Transform::Time
        }
        
        # Add support for non-CRUD actions.
        conf.actions = {
          "member" => {
            "copy" => "post",
            "make_better" => "put"
          }
        }
      end
    end

### Use your class

New & then save:

    thing = Thing.new("name" => "Awesometown")
    thing.save!

Or create with one step:

    thing = Thing.create!("name" => "Awesometown")

Find a thing:

    thing = Thing.find(1)

Call a custom action:

    thing.action("make_better")

ActiveModel validations are supported, so `thing.errors` works like ActiveRecord's errors. The remote service must respond with the errors formatted as an attribute `"errors" => {"name" => ["can't be blank", "can't be Mars (haha)"]}`.

    