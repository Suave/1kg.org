=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    This version is derived from the Optimised ANSI C code
    Authors of C version:
        Vincent Rijmen <vincent.rijmen@esat.kuleuven.ac.be>
        Antoon Bosselaers <antoon.bosselaers@esat.kuleuven.ac.be>
        Paulo Barreto <paulo.barreto@terra.com.br>
=end

require 'ruby-aes/aes_cons'
require 'ruby-aes/aes_shared'

class AesAlg
    include AesCons
    include AesShared

    def encryption_key_schedule(key)
        i = 0
        @rk = []
        @rk[0] = key[0] << 24 | key[1] << 16 | key[2] << 8 | key[3]
        @rk[1] = key[4] << 24 | key[5] << 16 | key[6] << 8 | key[7]
        @rk[2] = key[8] << 24 | key[9] << 16 | key[10] << 8 | key[11]
        @rk[3] = key[12] << 24 | key[13] << 16 | key[14] << 8 | key[15]
        if @kl == 128
            j = 0
            loop { temp  = @rk[3+j]
                @rk[4+j] = @rk[0+j] ^
                (Te4[(temp >> 16) & 0xff] & 0xff000000) ^
                (Te4[(temp >>  8) & 0xff] & 0x00ff0000) ^
                (Te4[(temp      ) & 0xff] & 0x0000ff00) ^
                (Te4[(temp >> 24)       ] & 0x000000ff) ^ RCON[i]
                @rk[5+j] = @rk[1+j] ^ @rk[4+j]
                @rk[6+j] = @rk[2+j] ^ @rk[5+j]
                @rk[7+j] = @rk[3+j] ^ @rk[6+j]
                i += 1
                return if (i == 10)
                j += 4
            }
        end
        @rk[4] = key[16] << 24 | key[17] << 16 | key[18] << 8 | key[19]
        @rk[5] = key[20] << 24 | key[21] << 16 | key[22] << 8 | key[23]
        if (@kl == 192)
            j = 0
            loop { temp = @rk[ 5+j]
                @rk[ 6+j] = @rk[ 0+j] ^
                (Te4[(temp >> 16) & 0xff] & 0xff000000) ^
                (Te4[(temp >>  8) & 0xff] & 0x00ff0000) ^
                (Te4[(temp      ) & 0xff] & 0x0000ff00) ^
                (Te4[(temp >> 24)       ] & 0x000000ff) ^ RCON[i]
                @rk[ 7+j] = @rk[ 1+j] ^ @rk[ 6+j]
                @rk[ 8+j] = @rk[ 2+j] ^ @rk[ 7+j]
                @rk[ 9+j] = @rk[ 3+j] ^ @rk[ 8+j]
                i += 1
                return if (i == 8)
                @rk[10+j] = @rk[ 4+j] ^ @rk[ 9+j]
                @rk[11+j] = @rk[ 5+j] ^ @rk[10+j]
                j += 6
            }
        end
        @rk[6] = key[24] << 24 | key[25] << 16 | key[26] << 8 | key[27]
        @rk[7] = key[28] << 24 | key[29] << 16 | key[30] << 8 | key[31]
        if (@kl == 256)
            j = 0
            loop { temp = @rk[ 7+j]
                @rk[ 8+j] = @rk[ 0+j] ^
                (Te4[(temp >> 16) & 0xff] & 0xff000000) ^
                (Te4[(temp >>  8) & 0xff] & 0x00ff0000) ^
                (Te4[(temp      ) & 0xff] & 0x0000ff00) ^
                (Te4[(temp >> 24)       ] & 0x000000ff) ^ RCON[i]
                @rk[ 9+j] = @rk[ 1+j] ^ @rk[ 8+j]
                @rk[10+j] = @rk[ 2+j] ^ @rk[ 9+j]
                @rk[11+j] = @rk[ 3+j] ^ @rk[10+j]
                i += 1
                return if (i == 7)
                temp = @rk[11+j]
                @rk[12+j] = @rk[ 4+j] ^
                (Te4[(temp >> 24)       ] & 0xff000000) ^
                (Te4[(temp >> 16) & 0xff] & 0x00ff0000) ^
                (Te4[(temp >>  8) & 0xff] & 0x0000ff00) ^
                (Te4[(temp      ) & 0xff] & 0x000000ff)
                @rk[13+j] = @rk[ 5+j] ^ @rk[12+j]
                @rk[14+j] = @rk[ 6+j] ^ @rk[13+j]
                @rk[15+j] = @rk[ 7+j] ^ @rk[14+j]
                j += 8
            }
        end
    end
    protected :encryption_key_schedule

    def decryption_key_schedule(key)
        # expand the cipher key:
        encryption_key_schedule(key)
        @ek = @rk.dup
        # invert the order of the round keys:
        j = 4 * @nr
        i = 0
        loop { break if i >= j
            temp = @rk[i]
            @rk[i] = @rk[j]
            @rk[j] = temp
            temp = @rk[i + 1]
            @rk[i + 1] = @rk[j + 1]
            @rk[j + 1] = temp
            temp = @rk[i + 2]
            @rk[i + 2] = @rk[j + 2]
            @rk[j + 2] = temp
            temp = @rk[i + 3]
            @rk[i + 3] = @rk[j + 3]
            @rk[j + 3] = temp
            i += 4
            j -= 4
        }
        # apply the inverse MixColumn transform
        # to all round keys but the first and the last:
        j = 0
        1.upto(@nr-1) { |i| j += 4
            @rk[0+j] =
                Td0[Te4[(@rk[0+j] >> 24)       ] & 0xff] ^
            Td1[Te4[(@rk[0+j] >> 16) & 0xff] & 0xff] ^
            Td2[Te4[(@rk[0+j] >>  8) & 0xff] & 0xff] ^
            Td3[Te4[(@rk[0+j]      ) & 0xff] & 0xff]
            @rk[1+j] =
                Td0[Te4[(@rk[1+j] >> 24)       ] & 0xff] ^
            Td1[Te4[(@rk[1+j] >> 16) & 0xff] & 0xff] ^
            Td2[Te4[(@rk[1+j] >>  8) & 0xff] & 0xff] ^
            Td3[Te4[(@rk[1+j]      ) & 0xff] & 0xff]
            @rk[2+j] =
                Td0[Te4[(@rk[2+j] >> 24)       ] & 0xff] ^
            Td1[Te4[(@rk[2+j] >> 16) & 0xff] & 0xff] ^
            Td2[Te4[(@rk[2+j] >>  8) & 0xff] & 0xff] ^
            Td3[Te4[(@rk[2+j]      ) & 0xff] & 0xff]
            @rk[3+j] =
                Td0[Te4[(@rk[3+j] >> 24)       ] & 0xff] ^
            Td1[Te4[(@rk[3+j] >> 16) & 0xff] & 0xff] ^
            Td2[Te4[(@rk[3+j] >>  8) & 0xff] & 0xff] ^
            Td3[Te4[(@rk[3+j]      ) & 0xff] & 0xff]
        }
    end
    protected :decryption_key_schedule

    def _encrypt_block(pt)
        t0 = t1 = t2 = t3 = nil
        # map byte array block to cipher state and add initial round key:
        s0 = (pt[ 0] << 24 | pt[ 1] << 16 | pt[ 2] << 8 | pt[ 3]) ^ @ek[0]
        s1 = (pt[ 4] << 24 | pt[ 5] << 16 | pt[ 6] << 8 | pt[ 7]) ^ @ek[1]
        s2 = (pt[ 8] << 24 | pt[ 9] << 16 | pt[10] << 8 | pt[11]) ^ @ek[2]
        s3 = (pt[12] << 24 | pt[13] << 16 | pt[14] << 8 | pt[15]) ^ @ek[3]
        r = @nr >> 1
        j = 0
        loop {
            t0 = Te0[(s0 >> 24)       ] ^ Te1[(s1 >> 16) & 0xff] ^
            Te2[(s2 >>  8) & 0xff] ^ Te3[(s3      ) & 0xff] ^ @ek[4+j]
            t1 = Te0[(s1 >> 24)       ] ^ Te1[(s2 >> 16) & 0xff] ^
            Te2[(s3 >>  8) & 0xff] ^ Te3[(s0      ) & 0xff] ^ @ek[5+j]
            t2 = Te0[(s2 >> 24)       ] ^ Te1[(s3 >> 16) & 0xff] ^
            Te2[(s0 >>  8) & 0xff] ^ Te3[(s1      ) & 0xff] ^ @ek[6+j]
            t3 = Te0[(s3 >> 24)       ] ^ Te1[(s0 >> 16) & 0xff] ^
            Te2[(s1 >>  8) & 0xff] ^ Te3[(s2      ) & 0xff] ^ @ek[7+j]
            j += 8
            r -= 1
            break if r == 0
            s0 = Te0[(t0 >> 24)       ] ^ Te1[(t1 >> 16) & 0xff] ^
            Te2[(t2 >>  8) & 0xff] ^ Te3[(t3      ) & 0xff] ^ @ek[0+j]
            s1 = Te0[(t1 >> 24)       ] ^ Te1[(t2 >> 16) & 0xff] ^
            Te2[(t3 >>  8) & 0xff] ^ Te3[(t0      ) & 0xff] ^ @ek[1+j]
            s2 = Te0[(t2 >> 24)       ] ^ Te1[(t3 >> 16) & 0xff] ^
            Te2[(t0 >>  8) & 0xff] ^ Te3[(t1      ) & 0xff] ^ @ek[2+j]
            s3 = Te0[(t3 >> 24)       ] ^ Te1[(t0 >> 16) & 0xff] ^
            Te2[(t1 >>  8) & 0xff] ^ Te3[(t2      ) & 0xff] ^ @ek[3+j]
        }
        # apply last round and map cipher state to byte array block:
        s0 = (Te4[(t0>>24)] & 0xff000000) ^ (Te4[(t1>>16)&0xff]&0x00ff0000) ^
        (Te4[(t2>>8)&0xff]&0x0000ff00) ^ (Te4[(t3)&0xff]&0x000000ff) ^ @ek[0+j]
        s1 = (Te4[(t1>>24)]&0xff000000) ^ (Te4[(t2>>16)&0xff]&0x00ff0000) ^
        (Te4[(t3>>8)&0xff]&0x0000ff00) ^ (Te4[(t0)&0xff]&0x000000ff) ^ @ek[1+j]
        s2 = (Te4[(t2>>24)]&0xff000000) ^ (Te4[(t3>>16)&0xff]&0x00ff0000) ^
        (Te4[(t0>>8)&0xff]&0x0000ff00) ^ (Te4[(t1)&0xff]&0x000000ff) ^ @ek[2+j]
        s3 = (Te4[(t3>>24)]&0xff000000) ^ (Te4[(t0>>16)&0xff]&0x00ff0000) ^
        (Te4[(t1>>8)&0xff]&0x0000ff00) ^ (Te4[(t2)&0xff]&0x000000ff) ^ @ek[3+j]
        [("%08x%08x%08x%08x" % [s0, s1, s2, s3])].pack("H*")
    end
    protected :_encrypt_block

    def _decrypt_block(ct)
        t0 = t1 = t2 = t3 = nil
        # map byte array block to cipher state and add initial round key:
        s0 = (ct[ 0] << 24 | ct[ 1] << 16 | ct[ 2] << 8 | ct[ 3]) ^ @rk[0]
        s1 = (ct[ 4] << 24 | ct[ 5] << 16 | ct[ 6] << 8 | ct[ 7]) ^ @rk[1]
        s2 = (ct[ 8] << 24 | ct[ 9] << 16 | ct[10] << 8 | ct[11]) ^ @rk[2]
        s3 = (ct[12] << 24 | ct[13] << 16 | ct[14] << 8 | ct[15]) ^ @rk[3]
        r = @nr >> 1
        j = 0
        loop {
            t0 = Td0[(s0 >> 24)       ] ^ Td1[(s3 >> 16) & 0xff] ^
            Td2[(s2 >>  8) & 0xff] ^ Td3[(s1         ) & 0xff] ^ @rk[4+j]
            t1 = Td0[(s1 >> 24)       ] ^ Td1[(s0 >> 16) & 0xff] ^
            Td2[(s3 >>  8) & 0xff] ^ Td3[(s2         ) & 0xff] ^ @rk[5+j]
            t2 = Td0[(s2 >> 24)       ] ^ Td1[(s1 >> 16) & 0xff] ^
            Td2[(s0 >>  8) & 0xff] ^ Td3[(s3         ) & 0xff] ^ @rk[6+j]
            t3 = Td0[(s3 >> 24)       ] ^ Td1[(s2 >> 16) & 0xff] ^
            Td2[(s1 >>  8) & 0xff] ^ Td3[(s0         ) & 0xff] ^ @rk[7+j]
            j += 8
            r -= 1
            break if r == 0
            s0 = Td0[(t0 >> 24)       ] ^ Td1[(t3 >> 16) & 0xff] ^
            Td2[(t2 >>  8) & 0xff] ^ Td3[(t1      ) & 0xff] ^ @rk[0+j]
            s1 = Td0[(t1 >> 24)       ] ^ Td1[(t0 >> 16) & 0xff] ^
            Td2[(t3 >>  8) & 0xff] ^ Td3[(t2      ) & 0xff] ^ @rk[1+j]
            s2 = Td0[(t2 >> 24)       ] ^ Td1[(t1 >> 16) & 0xff] ^
            Td2[(t0 >>  8) & 0xff] ^ Td3[(t3      ) & 0xff] ^ @rk[2+j]
            s3 = Td0[(t3 >> 24)       ] ^ Td1[(t2 >> 16) & 0xff] ^
            Td2[(t1 >>  8) & 0xff] ^ Td3[(t0      ) & 0xff] ^ @rk[3+j]
        }
        # apply last round and map cipher state to byte array block:
        s0 = (Td4[(t0>>24)]&0xff000000) ^ (Td4[(t3>>16)&0xff]&0x00ff0000) ^
        (Td4[(t2>>8)&0xff]&0x0000ff00) ^ (Td4[(t1)&0xff]&0x000000ff) ^ @rk[0+j]
        s1 = (Td4[(t1>>24)]&0xff000000) ^ (Td4[(t0>>16)&0xff]&0x00ff0000) ^
        (Td4[(t3>>8)&0xff]&0x0000ff00) ^ (Td4[(t2)&0xff]&0x000000ff) ^ @rk[1+j]
        s2 = (Td4[(t2>>24)]&0xff000000) ^ (Td4[(t1>>16)&0xff]&0x00ff0000) ^
        (Td4[(t0>>8)&0xff]&0x0000ff00) ^ (Td4[(t3)&0xff]&0x000000ff) ^ @rk[2+j]
        s3 = (Td4[(t3>>24)]&0xff000000) ^ (Td4[(t2>>16)&0xff]&0x00ff0000) ^
        (Td4[(t1>>8)&0xff]&0x0000ff00) ^ (Td4[(t0)&0xff]&0x000000ff) ^ @rk[3+j]
        [("%08x%08x%08x%08x" % [s0, s1, s2, s3])].pack("H*")
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
        case @mode
        when 'ECB'
            _encrypt_block(block)
        when 'CBC'
            @iv = _encrypt_block(xor(block, @iv))
        when 'OFB'
            @iv = _encrypt_block(@iv)
            xor(@iv, block)
        when 'CFB'
            @iv = xor(_encrypt_block(@iv), block)
        end
    end

    def decrypt_block(block)
        case @mode
        when 'ECB'
            _decrypt_block(block)
        when 'CBC'
            o = xor(_decrypt_block(block), @iv)
            @iv = block
            o
        when 'OFB'
            @iv = _encrypt_block(@iv)
            xor(@iv, block)
        when 'CFB'
            o = xor(_encrypt_block(@iv), block)
            @iv = block
            o
        end
    end

    def init(key_length, mode, key, iv = nil)
        @nb = 4
        @ek = []
        @rk = []
        @state = nil
        @iv = "\000" * 16
        @iv = iv if iv
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
        @kl = key_length
        case mode
        when 'ECB', 'CBC', 'OFB', 'CFB'
            @mode = mode
        else
            raise 'Bad AES mode'
        end
        decryption_key_schedule(key)
    end

    def initialize(key_length, mode, key, iv = nil)
        init(key_length, mode, key, iv)
    end

end # AesAlg
