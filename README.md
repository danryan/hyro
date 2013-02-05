# Hyro

**Hy-speed Remote Objects!** A remote HTTP/JSON resource client built with Faraday & ActiveModel, inspired by ActiveResource.

We're actively building this library to replace ActiveResource in our Rails 3 applications. A full RSpec2 test suite is keeping it sane.

  * ActiveModel provides behaviors like Validations, Dirty-tracking, Naming & much more: https://github.com/rails/rails/tree/3-2-stable/activemodel
  * Faraday provides middleware/stack-oriented HTTP connectivity: https://github.com/technoweenie/faraday
  * Hyro itself provides the structure to configure & interact with the objects representing remote resources.

### What it does do

  * define remote resources via Hyro::Base subclasses
  * pass OAuth2-style tokens via HTTP Authorization header
  * find remote resources by ID (typically the #show action)
  * find multiple resources with arbitrary query params (typically the #index action)
  * allow local attribute changes (with dirty-tracking)
  * save (with validations)
  * arbitrary non-REST actions (currently member-only)
  * provides a value transformation mechanism for non-JSON data types (Time is included)
  * support for associated/embedded objects via transforms

### What it does NOT do (yet)

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

### Override methods for unique API needs

    def member_base_url
      # return a special path for a specific remote resource (probably by ID)
    end

    def save_post_url
      # return a special path to "create" a new remote resource
    end

    def save_put_url
      # return a special path to "update" an existing resource
    end

    def to_param
      # Used by Rails #url_for to generate links in views & redirects.
      # Normally returns the string version of #id.
    end

### Use your class

#### New & then save:

    thing = Thing.new("name" => "Awesometown")
    thing.save!

Or create with one step:

    thing = Thing.create!("name" => "Awesometown")

#### Find a collection of things:

    things = Thing.find

...or use querystring params to refine the request:

    things = Thing.find( name: 'MAJ' )

Returns `[]` empty Array when nothing is found.

#### Find a thing:

    thing = Thing.find(1)

#### Call a custom action:

    thing.action("make_better")

...or call a custom action with some querystring params:

    thing.action("make_better", something: 'some value')

#### Validation errors

ActiveModel validations are supported, so `thing.errors` works like ActiveRecord's errors. The remote service must respond with the errors formatted as an attribute:

    { "thing" => {
        "name" => "Awesometown"
        "errors" => {"name" => ["can't be Awesometown"]}`
      }
    }

This format is the standard serialized format from ActiveModel::Errors.

### Embedded objects (Associations)

Hyro supports serializing and deserializing embedded objects using transforms. There is nothing magical to it; just simple instantiation of objects from JSON attributes & then serializing them back to JSON.

Modeling the remote embedded objects as simple ActiveModel::Serializer-implementations makes this really simple, like:

    class Widget
      include ActiveModel::Serialization
      attr_accessor :name
      
      def attributes
        {'name' => name}
      end
    end

#### HasOne (single object)

Thing's configuration should include the following transform:

    configure do |conf|
      conf.transforms = {
        "widget" => Thing::Transform::HasOneWidget
      }
    end

And the transform should be declared like:

    module Thing
      module Transform
        class HasOneWidget
          
          # Instantiate a Widget instance.
          #
          def self.decode(v)
            return nil if v.nil?
            Widget.new(v)
          end
          
          # Noop, because the instances natively serialize back to JSON.
          #
          def self.encode(v)
            v
          end
        end
      end
    end


#### HasMany (collection of objects)

Thing's configuration should include the following transform:

    configure do |conf|
      conf.transforms = {
        "widgets" => Thing::Transform::HasManyWidgets
      }
    end

And the transform should be declared like:

    module Thing
      module Transform
        class HasManyWidgets
          
          # Map elements into Widget instances.
          #
          def self.decode(v)
            return nil if v.nil?
            v.map do |widget|
              Widget.new(widget)
            end
          end
          
          # Noop, because the instances natively serialize back to JSON.
          #
          def self.encode(v)
            v
          end
        end
      end
    end

### URL configurations ###

The following methods may be overridden in your (Hyro::Base sub-)classes to provide specific behavior for your needs. Conventional values shown in paranthesis:

<table class="table">
  <thead>
    <tr>
      <th>Setting</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>configuration.base_path</td>
      <td>http://awesome.crowdflower.com</td>
    </tr>
    <tr>
      <td>#url\_for\_find\_by\_id</td>
      <td>http://awesome.crowdflower.com/things/1</td>
    </tr>
    <tr>
      <td>#url\_for\_find\_by\_query</td>
      <td>http://awesome.crowdflower.com/things</td>
    </tr>
    <tr>
      <td>#member\_base\_url</td>
      <td>http://awesome.crowdflower.com/things/1</td>
    </tr>
    <tr>
      <td>#action\_base\_url</td>
      <td>http://awesome.crowdflower.com/things/1/make_better</td>
    </tr>
    <tr>
      <td>#save\_put\_url</td>
      <td>http://awesome.crowdflower.com/things/1</td>
    </tr>
    <tr>
      <td>#save\_post\_url</td>
      <td>http://awesome.crowdflower.com/things</td>
    </tr>
  </tbody>
</table>

