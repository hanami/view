require 'json'

User = Struct.new(:username)

class UserXmlSerializer
  def initialize(user)
    @user = user
  end

  def serialize
    @user.to_h.map do |attr, value|
      %(<#{ attr }>#{ value }</#{ attr }>)
    end.join("\n")
  end
end

class UserLayout
  include Hanami::Layout

  def page_title(username)
    "User: #{ username }"
  end
end

module Users
  class Show
    include Hanami::View
    layout :user

    def custom
      %(<script>alert('custom')</script>)
    end

    def username
      user.username
    end

    def raw_username
      _raw user.username
    end

    def book
      _escape(locals[:book])
    end

    protected

    def protected_username
      user.username
    end

    private
    def private_username
      user.username
    end
  end

  class XmlShow < Show
    format :xml

    def render
      UserXmlSerializer.new(user).serialize
    end
  end

  class JsonShow < Show
    format :json

    def render
      _raw JSON.generate(user.to_h)
    end
  end

  class Extra
    include Hanami::View

    def username
      user.username
    end
  end
end
