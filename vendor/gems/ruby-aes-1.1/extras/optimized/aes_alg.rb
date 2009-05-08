=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    ruby-aes (optimized version)
    Based on "Normal" code
    Adapted from the Rijndael Specifications (dfips-AES.pdf)
=end

require 'ruby-aes/aes_cons'
require 'ruby-aes/aes_shared'

class AesAlg
    include AesCons
    include AesShared

    def mixColumns
        t = ""
        4.times do |j| i = j*4
            t << (G2X[@state[i]] ^ G3X[@state[i+1]] ^ @state[i+2] ^ @state[i+3])
            t << (@state[i] ^ G2X[@state[i+1]] ^ G3X[@state[i+2]] ^ @state[i+3])
            t << (@state[i] ^ @state[i+1] ^ G2X[@state[i+2]] ^ G3X[@state[i+3]])
            t << (G3X[@state[i]] ^ @state[i+1] ^ @state[i+2] ^ G2X[@state[i+3]])
        end
        @state = t
    end
    protected :mixColumns

    def imixColumns
        t = ""
        4.times do |j| i = j*4
            t << (GEX[@state[i]] ^ GBX[@state[i+1]] ^ GDX[@state[i+2]] ^ G9X[@state[i+3]])
            t << (G9X[@state[i]] ^ GEX[@state[i+1]] ^ GBX[@state[i+2]] ^ GDX[@state[i+3]])
            t << (GDX[@state[i]] ^ G9X[@state[i+1]] ^ GEX[@state[i+2]] ^ GBX[@state[i+3]])
            t << (GBX[@state[i]] ^ GDX[@state[i+1]] ^ G9X[@state[i+2]] ^ GEX[@state[i+3]])
        end
        @state = t
    end
    protected :imixColumns

    # Combine -- shiftRows, subBytes -- as one method
    def subShiftRows
        @state[0], @state[4], @state[8], @state[12] = 
            S_BOX[@state[0]], S_BOX[@state[4]], S_BOX[@state[8]], S_BOX[@state[12]]
        @state[1], @state[5], @state[9], @state[13] = 
            S_BOX[@state[5]], S_BOX[@state[9]], S_BOX[@state[13]], S_BOX[@state[1]]
        @state[2], @state[6], @state[10], @state[14] = 
            S_BOX[@state[10]], S_BOX[@state[14]], S_BOX[@state[2]], S_BOX[@state[6]]
        @state[3], @state[7], @state[11], @state[15] = 
            S_BOX[@state[15]], S_BOX[@state[3]], S_BOX[@state[7]], S_BOX[@state[11]]
    end
    protected :subShiftRows

    # Combine -- shiftRows, subBytes, addRoundkey -- as one method
    def lastEncryptRound
        i = 16*@nr
        @state[0], @state[4], @state[8], @state[12] = 
            S_BOX[@state[0]] ^ @w[i], S_BOX[@state[4]] ^ @w[i+4],
            S_BOX[@state[8]] ^ @w[i+8], S_BOX[@state[12]] ^ @w[i+12]
        @state[1], @state[5], @state[9], @state[13] = 
            S_BOX[@state[5]] ^ @w[i+1], S_BOX[@state[9]] ^ @w[i+5],
            S_BOX[@state[13]] ^ @w[i+9], S_BOX[@state[1]] ^ @w[i+13]
        @state[2], @state[6], @state[10], @state[14] = 
            S_BOX[@state[10]] ^ @w[i+2], S_BOX[@state[14]] ^ @w[i+6],
            S_BOX[@state[2]] ^ @w[i+10], S_BOX[@state[6]] ^ @w[i+14]
        @state[3], @state[7], @state[11], @state[15] = 
            S_BOX[@state[15]] ^ @w[i+3], S_BOX[@state[3]] ^ @w[i+7],
            S_BOX[@state[7]] ^ @w[i+11], S_BOX[@state[11]] ^ @w[i+15]
    end
    protected :lastEncryptRound

    # Combine -- ishiftRows, isubBytes, addRoundkey -- as one method
    def decryptSubRound(n)
        i = 16*n
        @state[0], @state[4], @state[8], @state[12] = 
            IS_BOX[@state[0]] ^ @w[i], IS_BOX[@state[4]] ^ @w[i+4],
            IS_BOX[@state[8]] ^ @w[i+8], IS_BOX[@state[12]] ^ @w[i+12]
        @state[1], @state[5], @state[9], @state[13] = 
            IS_BOX[@state[13]] ^ @w[i+1], IS_BOX[@state[1]] ^ @w[i+5],
            IS_BOX[@state[5]] ^ @w[i+9], IS_BOX[@state[9]] ^ @w[i+13]
        @state[2], @state[6], @state[10], @state[14] = 
            IS_BOX[@state[10]] ^ @w[i+2], IS_BOX[@state[14]] ^ @w[i+6],
            IS_BOX[@state[2]] ^ @w[i+10], IS_BOX[@state[6]] ^ @w[i+14]
        @state[3], @state[7], @state[11], @state[15] = 
            IS_BOX[@state[7]] ^ @w[i+3], IS_BOX[@state[11]] ^ @w[i+7],
            IS_BOX[@state[15]] ^ @w[i+11], IS_BOX[@state[3]] ^@w[i+15]
    end
    protected :decryptSubRound

    def addRoundKey(n)
        j = n*16
        16.times do |i|
            @state[i] ^= @w[i+j]
        end
    end
    protected :addRoundKey

    def key_expansion(key)
        0.upto(@nk*4-1) do
            |i| @w[i] = key[i]
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
        1.upto(@nr-1) do |n|
            subShiftRows
            mixColumns
            addRoundKey n
        end
        lastEncryptRound
        @state
    end
    protected :_encrypt_block

    def _decrypt_block
        addRoundKey @nr
        (@nr-1).downto(1) do |n|
            decryptSubRound n
            imixColumns
        end
        decryptSubRound 0 
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
