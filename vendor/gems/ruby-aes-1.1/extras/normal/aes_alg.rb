=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    ruby-aes (non-optimized version)
    Adapted from the Rijndael Specifications (dfips-AES.pdf)
=end

require 'ruby-aes/aes_cons'
require 'ruby-aes/aes_shared'

class AesAlg
    include AesCons
    include AesShared

    def subBytes
        i = 0
        @state.each_byte do |b|
            @state[i] = S_BOX[b]
            i+=1
        end
    end
    protected :subBytes

    def isubBytes
        i = 0
        @state.each_byte do |b|
            @state[i] = IS_BOX[b]
            i+=1
        end
    end
    protected :isubBytes

    def shiftRows
        @state[1], @state[5], @state[9], @state[13] =
            @state[5], @state[9], @state[13], @state[1]
        @state[2], @state[6], @state[10], @state[14] =
            @state[10], @state[14], @state[2], @state[6]
        @state[3], @state[7], @state[11], @state[15] =
            @state[15], @state[3], @state[7], @state[11]
    end
    protected :shiftRows

    def ishiftRows
        @state[1], @state[5], @state[9], @state[13] =
            @state[13], @state[1], @state[5], @state[9]
        @state[2], @state[6], @state[10], @state[14] =
            @state[10], @state[14], @state[2], @state[6]
        @state[3], @state[7], @state[11], @state[15] =
            @state[7], @state[11], @state[15], @state[3]
    end
    protected :ishiftRows

    def mixColumns
        t = "\000" * 16
        4.times do |c|
            t[c*4] = G2X.at(@state[c*4]) ^ G3X.at(@state[1+c*4]) ^
            @state[2+c*4] ^ @state[3+c*4]
            t[1+c*4] = @state[c*4] ^ G2X.at(@state[1+c*4]) ^
            G3X.at(@state[2+c*4]) ^ @state[3+c*4]
            t[2+c*4] = @state[c*4] ^ @state[1+c*4] ^
            G2X.at(@state[2+c*4]) ^ G3X.at(@state[3+c*4])
            t[3+c*4] = G3X.at(@state[c*4]) ^ @state[1+c*4] ^
            @state[2+c*4] ^ G2X.at(@state[3+c*4])
        end
        @state = t
    end
    protected :mixColumns

    def imixColumns
        t = "\000" * 16
        4.times do |c|
            t[c*4] = GEX.at(@state[c*4]) ^ GBX.at(@state[1+c*4]) ^
            GDX.at(@state[2+c*4]) ^ G9X.at(@state[3+c*4])
            t[1+c*4] = G9X.at(@state[c*4]) ^ GEX.at(@state[1+c*4]) ^
            GBX.at(@state[2+c*4]) ^ GDX.at(@state[3+c*4])
            t[2+c*4] = GDX.at(@state[c*4]) ^ G9X.at(@state[1+c*4]) ^
            GEX.at(@state[2+c*4]) ^ GBX.at(@state[3+c*4])
            t[3+c*4] = GBX.at(@state[c*4]) ^ GDX.at(@state[1+c*4]) ^
            G9X.at(@state[2+c*4]) ^ GEX.at(@state[3+c*4])
        end
        @state = t
    end
    protected :imixColumns

    def addRoundKey(n)
        j = n*16
        16.times do |i|
            @state[i] ^= @w[i+j]
        end
    end
    protected :addRoundKey

    def key_expansion(key)
        0.upto(@nk*4-1) do |i|
            @w[i] = key[i]
        end
        @nk.upto(@nb*(@nr+1)-1) do |i|
            j = i*4
            k = j-(@nk*4)
            t0, t1, t2, t3 = @w[j-4], @w[j-3], @w[j-2], @w[j-1]
            if (i % @nk == 0)
                t0, t1, t2, t3 =
                    S_BOX[t1] ^ RCON[i/@nk - 1], S_BOX[t2], S_BOX[t3], S_BOX[t0]
            elsif (@nk > 6) && (i % @nk == 4)
                t0, t1, t2, t3 = S_BOX[t0], S_BOX[t1], S_BOX[t2], S_BOX[t3]
            end
            @w[j], @w[j+1], @w[j+2], @w[j+3] =
                @w[k] ^ t0, @w[k+1] ^ t1, @w[k+2] ^ t2, @w[k+3] ^ t3
        end
    end
    protected :key_expansion

    def _encrypt_block
        addRoundKey 0
        1.upto(@nr) do |n|
            subBytes
            shiftRows
            mixColumns unless n == @nr
            addRoundKey n
        end
        @state
    end
    protected :_encrypt_block

    def _decrypt_block
        addRoundKey @nr
        (@nr-1).downto(0) do |n|
            ishiftRows
            isubBytes
            addRoundKey n
            imixColumns unless n == 0
        end
        @state
    end
    protected :_decrypt_block

    def xor(a,b)
        c = ""
        16.times do |i|
            c << (a[i] ^ b[i]).chr
        end
        c
    end
    protected :xor

    def encrypt_block(block)
        @state = block.dup
        case @mode
        when 'ECB'
            _encrypt_block
        when 'CBC'
            @state = xor(block, @iv)
            @iv = _encrypt_block
        when 'OFB'
            @state = @iv.dup
            @iv = _encrypt_block
            xor(@iv, block)
        when 'CFB'
            @state = @iv.dup
            @iv = xor(_encrypt_block, block)
        end
    end

    def decrypt_block(block)
        @state = block.dup
        case @mode
        when 'ECB'
            _decrypt_block
        when 'CBC'
            o = xor(_decrypt_block, @iv)
            @iv = block
            o
        when 'OFB'
            @state = @iv.dup
            @iv = _encrypt_block
            xor(@iv, block)
        when 'CFB'
            @state = @iv.dup
            o = xor(_encrypt_block, block)
            @iv = block
            o
        end
    end

    def init(key_length, mode, key, iv = nil)
        @iv = "\000" * 16
        @iv = iv if iv
        @nb = 4
        @nk = 4
        @nr = 10
        @mode = 'ECB'
        @state = nil
        @w = []
        case key_length
        when 128
            @nk = 4
            @nr = 10
        when 192
            @nk = 6
            @nr = 12
        when 256
            @nk = 8
            @nr = 14
        else
            raise 'Bad Key length'
        end
        case mode
        when 'ECB', 'CBC', 'OFB', 'CFB'
            @mode = mode
        else
            raise 'Bad AES mode'
        end
        key_expansion key
    end

    def initialize(key_length, mode, key, iv = nil)
        init(key_length, mode, key, iv)
    end

end # class aes
