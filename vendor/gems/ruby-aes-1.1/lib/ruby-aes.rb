=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

==Valid modes are:
    * ECB (Electronic Code Book)
    * CBC (Cipher Block Chaining)
    * OFB (Output Feedback)
    * CFB (Cipher Feedback)

==Valid key length:
    * 128 bits
    * 192 bits
    * 256 bits

==API calls:
    Default key_length: 128
    Default mode: 'ECB'
    Default IV: 16 null chars ("00" * 16 in hex format)
    Default key: 16 null chars ("00" * 16 in hex format)
    Default input text: "PLAINTEXT"

    Aes.check_key(key_string, key_length)
    Aes.check_iv(iv_string)
    Aes.check_kl(key_length)
    Aes.check_mode(mode)
    Aes.init(key_length, mode, key, iv)
    Aes.encrypt_block(key_length, mode, key, iv, block) # no padding
    Aes.decrypt_block(key_length, mode, key, iv, block) # no padding
    Aes.encrypt_buffer(key_length, mode, key, iv, block) # padding
    Aes.decrypt_buffer(key_length, mode, key, iv, block) # padding
    Aes.encrypt_stream(key_length, mode, key, iv, sin, sout)
    Aes.decrypt_stream(key_length, mode, key, iv, sin, sout)
    Aes.bs() # block size for read operations (stream)
    Aes.bs=(bs)
=end

module Aes

    require 'ruby-aes/aes_alg'

    @@aes = nil
    @@bs = 4096

    def Aes.bs(); return @@bs end
    def Aes.bs=(bs); @@bs = bs.to_i; @@bs==0 ? 4096 : @@bs = @@bs - @@bs%16 end

    def Aes.check_key(key_string, kl = 128)
        kl = Aes.check_kl(kl)
        k = key_string ? key_string.length : 0
        raise "Bad key string or bad key length" if (k != kl/8) && (k != kl/4)
        hex = (key_string =~ /[a-f0-9A-F]{#{k}}/) == 0 && (k == kl/4)
        bin = ! hex
        if ! (([32, 48, 64].include?(k) && hex) ||
           ([16, 24, 32].include?(k) && bin))
            raise "Bad key string"
        end
        hex ? [key_string].pack("H*") : key_string
    end

    def Aes.check_iv(iv_string)
        k = iv_string.length
        hex = (iv_string =~ /[a-f0-9A-F]{#{k}}/) == 0
        bin = ! hex
        if k == 32 && hex
            return [iv_string].pack("H*")
        elsif k == 16 && bin
            return iv_string
        else
            raise "Bad IV string"
        end
    end

    def Aes.check_mode (mode)
        case mode
        when 'ECB', 'CBC', 'OFB', 'CFB'
        else raise "Bad cipher mode"
        end
        mode
    end

    def Aes.check_kl(key_length)
        case key_length
        when 128, 192, 256
        else raise "Bad key length"
        end
        key_length
    end

    def Aes.init(keyl, mode, key, iv)
        unless @@aes
            @@aes = AesAlg.new(Aes.check_kl(keyl), Aes.check_mode(mode),
                               Aes.check_key(key, keyl), iv ? Aes.check_iv(iv) : nil)
        else
            @@aes.init(Aes.check_kl(keyl), Aes.check_mode(mode),
                       Aes.check_key(key, keyl), iv ? Aes.check_iv(iv) : nil)
        end
    end

    def Aes.encrypt_block(keyl, mode, key, iv, block = "DEFAULT PLAINTXT")
        raise "Bad Block size" if block.length < 16 || block.length > 16
        Aes.init(keyl, mode, key, iv)
        @@aes.encrypt_block(block)
    end

    def Aes.decrypt_block(keyl, mode, key, iv, block = "DEFAULT PLAINTXT")
        Aes.init(keyl, mode, key, iv)
        @@aes.decrypt_block(block)
    end

    def Aes.encrypt_buffer(keyl, mode, key, iv, buffer = "PLAINTEXT")
        Aes.init(keyl, mode, key, iv)
        @@aes.encrypt_buffer(buffer)
    end

    def Aes.decrypt_buffer(keyl, mode, key, iv, buffer = "DEFAULT PLAINTXT")
        raise "Bad Block size" if buffer.length < 16
        Aes.init(keyl, mode, key, iv)
        @@aes.decrypt_buffer(buffer)
    end

    def Aes.encrypt_stream(keyl, mode, key, iv, sin = STDIN, sout = STDOUT)
        Aes.init(keyl, mode, key, iv)
        case sout
        when String, Array, IO
        else
            raise "Bad output stream (String, Array, IO)"
        end
        case sin
        when String
            sout << @@aes.encrypt_buffer(sin)
        when IO
            while buf = sin.read(@@bs)
              if buf.length == @@bs
                sout << @@aes.encrypt_blocks(buf)
              else
                sout << @@aes.encrypt_buffer(buf)
              end
            end
        else
            raise "Bad input stream (String, IO)"
        end
    end

    def Aes.decrypt_stream(keyl, mode, key, iv, sin = STDIN, sout = STDOUT)
        Aes.init(keyl, mode, key, iv)
        case sout
        when String, Array, IO
        else
            raise "Bad output stream (String, Array, IO)"
        end
        case sin
        when String
            sout << @@aes.decrypt_buffer(sin)
        when IO
            while buf = sin.read(@@bs)#+1)
              if buf.length == @@bs
                sout << @@aes.decrypt_blocks(buf)
              else
                sout << @@aes.decrypt_buffer(buf)
              end
            end
        else
            raise "Bad input stream (String, IO)"
        end
    end

end # end Aes
