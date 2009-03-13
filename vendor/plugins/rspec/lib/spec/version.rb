module Spec
  module VERSION
    unless defined? MAJOR
      MAJOR  = 1
      MINOR  = 1
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/version.rb
      TINY   = 8

      STRING = [MAJOR, MINOR, TINY].join('.')

      SUMMARY = "rspec #{STRING}"
=======
      TINY   = 4

      STRING = [MAJOR, MINOR, TINY].join('.')

      SUMMARY = "rspec version #{STRING}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/version.rb
    end
  end
end