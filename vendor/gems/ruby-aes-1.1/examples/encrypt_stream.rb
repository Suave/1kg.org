#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-aes'
require 'example_helper'
require 'fileutils'

class RubyAES_stream

    include RubyAES_helper

    def initialize
        setup
        puts "Using #{@kl}-#{@mode} encryption/decryption"
        file = "_ruby-aes_encrypt_stream_"

        sin = File.open(file, "w+b")
        sin.puts "The quick brown fox jumps over the lazy dog"
        sin.rewind
        sout = File.open("#{file}.aes", "w+b")
        Aes.encrypt_stream(@kl, @mode, @keys[@kl], @iv, sin, sout)
        sin.close
        sout.close

        sin = File.open("#{file}.aes", "rb")
        sout = File.open("#{file}.plain", "w+b")
        Aes.decrypt_stream(@kl, @mode, @keys[@kl], @iv, sin, sout)
        sin.close
        sout.close

        if IO.read(file) == IO.read("#{file}.plain")
            puts "The decrypted file is exactly the same as the original one"
        else
            puts "The decrypted file differs from the orginal one"
        end
        FileUtils.rm_f [ file, "#{file}.aes", "#{file}.plain" ]
    end

end
RubyAES_stream.new
