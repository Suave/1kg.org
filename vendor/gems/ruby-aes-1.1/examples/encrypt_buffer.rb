#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-aes'
require 'example_helper'

class RubyAES_buffer

    include RubyAES_helper

    def initialize
        setup
        puts "Using #{@kl}-#{@mode} encryption/decryption"
        pt = "The quick brown fox jumps over the lazy dog"
        puts "Plaintext is: '#{pt}'"
        puts "(a buffer will be padded so that its length will be a multiple of 16)"
        ct = Aes.encrypt_buffer(@kl, @mode, @keys[@kl], @iv, pt)
        puts "Ciphertext (unpacked) is: #{ct.unpack("H*").first}"
        npt = Aes.decrypt_buffer(@kl, @mode, @keys[@kl], @iv, ct)
        puts "Decrypted ciphertext is: '#{npt}'"
        puts "(should be: '#{pt}')"
    end

end
RubyAES_buffer.new
