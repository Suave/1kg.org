#!/usr/bin/env ruby

module RubyAES_helper

    KEY_LENGTH = [128,192,256].freeze
    MODES = ['ECB','CBC','OFB','CFB'].freeze

    def random_fill(n, buffer)
        n.times do
            buffer << rand(256).chr
        end
    end

    def setup
        @keys = {}
        KEY_LENGTH.each do |kl|
            @keys[kl] = ""
            random_fill(kl/8, @keys[kl])
        end

        @iv = ""; random_fill(16, @iv)
        @pt = ""; random_fill(64, @pt)
        @kl = KEY_LENGTH[(rand * KEY_LENGTH.length).to_i]
        @mode = MODES[(rand * MODES.length).to_i]
    end

end
