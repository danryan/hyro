# Hyro

Hy-speed Remote Objects!

A remote HTTP/JSON resource client built with Faraday & ActiveModel, inspired by ActiveResource.

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
        
        # REST endpoint. SSL is a good thing! (required)
        conf.base_url = "https://awesome-app.com"
        conf.base_path = "/v1/things"
        
        # HTTP "Authorization" header (required)
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

    