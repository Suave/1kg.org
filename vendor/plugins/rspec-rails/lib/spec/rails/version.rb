module Spec
  module Rails
    module VERSION #:nodoc:
      unless defined? MAJOR
        MAJOR  = 1
        MINOR  = 1
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/version.rb
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/version.rb
        TINY   = 8

        STRING = [MAJOR, MINOR, TINY].join('.')

        SUMMARY = "rspec-rails #{STRING}"
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/version.rb
        TINY   = 4

        STRING = [MAJOR, MINOR, TINY].join('.')

        SUMMARY = "rspec-rails version #{STRING}"
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/version.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/version.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/version.rb
      end
    end
  end
end