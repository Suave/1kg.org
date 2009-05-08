#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-aes'
require 'example_helper'

class RubyAES_block

    include RubyAES_helper

    def initialize
        setup
        pt = "0123467890ABCDEF"
        puts "Using #{@kl}-#{@mode} encryption/decryption"
        puts "Plaintext is: #{pt} (a block should be 16 octets)"
        ct = Aes.encrypt_block(@kl, @mode, @keys[@kl], @iv, pt)
        puts "Ciphertext (unpacked) is: #{ct.unpack("H*").first}"
        npt = Aes.decrypt_block(@kl, @mode, @keys[@kl], @iv, ct)
        puts "Decrypted ciphertext is: #{npt} (should be: #{pt})"
    end

end
RubyAES_block.new
