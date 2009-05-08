=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    It contains the code shared by all the implementations
=end

module AesShared
    def encrypt_blocks(buffer)
        raise "Bad block length" unless (buffer.length % 16).zero?
        ct = ""
        block = ""
        buffer.each_byte do |char|
            block << char
            if block.length == 16
                ct << encrypt_block(block)
                block = ""
            end
        end
        ct
    end

    def decrypt_blocks(buffer)
        raise "Bad block length" unless (buffer.length % 16).zero?
        pt = ""
        block = ""
        buffer.each_byte do |char|
            block << char
            if block.length == 16
                pt << decrypt_block(block)
                block = ""
            end
        end
        pt
    end

    def encrypt_buffer(buffer)
        ct = ""
        block = ""
        buffer.each_byte do |char|
            block << char
            if block.length == 16
                ct << encrypt_block(block)
                block = ""
            end
        end
        c = "\000"
        if (m = 16 - block.length % 16) != 16
            c = m.chr
            ct << encrypt_block(block << c * m)
        end
        ct << c
    end

    def decrypt_buffer(buffer)
        pt = ""
        block = ""
        buffer.each_byte do |char|
            block << char
            if block.length == 16
                pt << decrypt_block(block)
                block = ""
            end
        end
        if block.length != 1
            raise 'Bad Block Padding'
        elsif (c = block[-1]).zero?
            pt
        else
            if block * c == pt[-c..-1]
                pt[0..-c-1]
            else
                raise "Bad Block Padding"
            end
        end
    end
end
