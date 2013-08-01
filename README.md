# Lotus::View

A View pattern framework

## Installation

Add this line to your application's Gemfile:

    gem 'lotus-view'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotus-view

## Usage

Lotus::View is a thin layer for MVC web frameworks and works beautifully with [Lotus](https://lotusrb.org/lotus) and [Lotus::Controller](https://lotusrb.org/controller).
It's designed with performances and testability in mind.

### Views

    module Articles
      class Show
        include Lotus::View

        def title
          @title ||= article.title.upcase
        end
      end

      class JsonShow < Show
        format :json

        def title
          super.downcase
        end
      end
    end

    Articles::Index.render { format: :html }, { article: article } # => renders `articles/show.html.erb`
    Articles::Index.render { format: :json }, { article: article } # => renders `articles/show.json.erb`
    Articles::Index.render { format: :xml  }, { article: article } # => returns `nil`

    # or..

    template = Lotus::View::Template.new('path/to/template')
    Articles::Index.new(template, article: article).render # => renders `template`

It works with all the template engines supported by [Tilt]() and it's up to the developer to install that libraries.
It works with any format, without the need to register them.
These two features ensure virtually zero dependencies and developer freedom.

### Thread safety

`Lotus::View` is thread safe, but it's loading isn't. For this reason it exposes a mechanism to preload everything, ensure to invoke it as last thing before your application starts.

    Mutex.new.synchronize do
      Lotus::View.load!
    end

After this operation, all the class variables are frozen, in order to prevent accidental modifications at the run time.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
