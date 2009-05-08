require 'test/unit'
require File.dirname(__FILE__) + '/../lib/ruby-aes'

require 'fileutils'

unless defined? KEY_LENGTH
  KEY_LENGTH = [128,192,256].freeze
  MODES = ['ECB','CBC','OFB','CFB'].freeze
end

def random_fill(n, buffer)
    n.times do
        buffer << rand(256).chr
    end
end

