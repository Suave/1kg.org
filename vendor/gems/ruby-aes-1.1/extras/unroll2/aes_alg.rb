=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    This version is derived from the Optimised ANSI C code
    Authors of C version:
        Vincent Rijmen <vincent.rijmen@esat.kuleuven.ac.be>
        Antoon Bosselaers <antoon.bosselaers@esat.kuleuven.ac.be>
        Paulo Barreto <paulo.barreto@terra.com.br>

    Table look up improvements
=end

require 'ruby-aes/aes_cons'
require 'ruby-aes/aes_shared'

class AesAlg
    include AesCons
    include AesShared

    def encryption_key_schedule(key)
        i = 0
        @ek = []
        @ek[0] = key[0] << 24 | key[1] << 16 | key[2] << 8 | key[3]
        @ek[1] = key[4] << 24 | key[5] << 16 | key[6] << 8 | key[7]
        @ek[2] = key[8] << 24 | key[9] << 16 | key[10] << 8 | key[11]
        @ek[3] = key[12] << 24 | key[13] << 16 | key[14] << 8 | key[15]
        if @kl == 128
            j = 0
            loop do
                temp  = @ek[3+j]
                @ek[4+j] = @ek[0+j] ^
                (S3[(temp >> 16) & 0xff]) ^
                (S2[(temp >>  8) & 0xff]) ^
                (S1[(temp) & 0xff]) ^
                (S0[(temp >> 24)]) ^ RCON[i]
                @ek[5+j] = @ek[1+j] ^ @ek[4+j]
                @ek[6+j] = @ek[2+j] ^ @ek[5+j]
                @ek[7+j] = @ek[3+j] ^ @ek[6+j]
                i += 1
                return if (i == 10)
                j += 4
            end
        end
        @ek[4] = key[16] << 24 | key[17] << 16 | key[18] << 8 | key[19]
        @ek[5] = key[20] << 24 | key[21] << 16 | key[22] << 8 | key[23]
        if (@kl == 192)
            j = 0
            loop do
                temp = @ek[ 5+j]
                @ek[ 6+j] = @ek[ 0+j] ^
                (S3[(temp >> 16) & 0xff]) ^
                (S2[(temp >>  8) & 0xff]) ^
                (S1[(temp) & 0xff]) ^
                (S0[(temp >> 24)]) ^ RCON[i]
                @ek[ 7+j] = @ek[ 1+j] ^ @ek[ 6+j]
                @ek[ 8+j] = @ek[ 2+j] ^ @ek[ 7+j]
                @ek[ 9+j] = @ek[ 3+j] ^ @ek[ 8+j]
                i += 1
                return if (i == 8)
                @ek[10+j] = @ek[ 4+j] ^ @ek[ 9+j]
                @ek[11+j] = @ek[ 5+j] ^ @ek[10+j]
                j += 6
            end
        end
        @ek[6] = key[24] << 24 | key[25] << 16 | key[26] << 8 | key[27]
        @ek[7] = key[28] << 24 | key[29] << 16 | key[30] << 8 | key[31]
        if (@kl == 256)
            j = 0
            loop do
                temp = @ek[ 7+j]
                @ek[ 8+j] = @ek[ 0+j] ^
                (S3[(temp >> 16) & 0xff]) ^
                (S2[(temp >>  8) & 0xff]) ^
                (S1[(temp) & 0xff]) ^
                (S0[(temp >> 24)]) ^ RCON[i]
                @ek[ 9+j] = @ek[ 1+j] ^ @ek[ 8+j]
                @ek[10+j] = @ek[ 2+j] ^ @ek[ 9+j]
                @ek[11+j] = @ek[ 3+j] ^ @ek[10+j]
                i += 1
                return if (i == 7)
                temp = @ek[11+j]
                @ek[12+j] = @ek[ 4+j] ^
                (S3[(temp >> 24)]) ^
                (S2[(temp >> 16) & 0xff]) ^
                (S1[(temp >>  8) & 0xff]) ^
                (S0[(temp) & 0xff])
                @ek[13+j] = @ek[ 5+j] ^ @ek[12+j]
                @ek[14+j] = @ek[ 6+j] ^ @ek[13+j]
                @ek[15+j] = @ek[ 7+j] ^ @ek[14+j]
                j += 8
            end
        end
    end
    protected :encryption_key_schedule

    def decryption_key_schedule(key)
        # expand the cipher key:
        encryption_key_schedule(key)
        @dk = @ek.dup
        # invert the order of the round keys:
        j = 4 * @nr
        i = 0
        loop do
            break if i >= j
            temp = @dk[i]
            @dk[i] = @dk[j]
            @dk[j] = temp
            temp = @dk[i + 1]
            @dk[i + 1] = @dk[j + 1]
            @dk[j + 1] = temp
            temp = @dk[i + 2]
            @dk[i + 2] = @dk[j + 2]
            @dk[j + 2] = temp
            temp = @dk[i + 3]
            @dk[i + 3] = @dk[j + 3]
            @dk[j + 3] = temp
            i += 4
            j -= 4
        end
        # apply the inverse MixColumn transform
        # to all round keys but the first and the last:
        j = 0
        1.upto(@nr-1) do |i|
            j += 4
            w0= @dk[j]
            w1 = @dk[j+1]
            w2 = @dk[j+2]
            w3 = @dk[j+3]
            @dk[0+j] =
                Td0[S0[(w0 >> 24)] ]^
            Td1[S0[(w0 >> 16) & 0xff] ] ^
            Td2[S0[(w0 >>  8) & 0xff] ] ^
            Td3[S0[(w0) & 0xff] ]
            @dk[1+j] =
                Td0[S0[(w1 >> 24)] ] ^
            Td1[S0[(w1 >> 16) & 0xff] ] ^
            Td2[S0[(w1 >>  8) & 0xff] ] ^
            Td3[S0[(w1) & 0xff] ]
            @dk[2+j] =
                Td0[S0[(w2 >> 24)] ] ^
            Td1[S0[(w2 >> 16) & 0xff] ] ^
            Td2[S0[(w2 >>  8) & 0xff] ] ^
            Td3[S0[(w2) & 0xff] ]
            @dk[3+j] =
                Td0[S0[(w3 >> 24)] ] ^
            Td1[S0[(w3 >> 16) & 0xff] ] ^
            Td2[S0[(w3 >>  8) & 0xff] ] ^
            Td3[S0[(w3) & 0xff] ]
        end
    end
    protected :decryption_key_schedule

    def _encrypt_block(pt)
        #
        # map byte array block to cipher state and add initial round key:
        #
        s0 = (pt[ 0] << 24 | pt[ 1] << 16 | pt[ 2] << 8 | pt[ 3]) ^ @ek[0]
        s1 = (pt[ 4] << 24 | pt[ 5] << 16 | pt[ 6] << 8 | pt[ 7]) ^ @ek[1]
        s2 = (pt[ 8] << 24 | pt[ 9] << 16 | pt[10] << 8 | pt[11]) ^ @ek[2]
        s3 = (pt[12] << 24 | pt[13] << 16 | pt[14] << 8 | pt[15]) ^ @ek[3]
        # round 1:
        t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[ 4]
        t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[ 5]
        t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[ 6]
        t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[ 7]
        # round 2:
        s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ @ek[ 8]
        s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ @ek[ 9]
        s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ @ek[10]
        s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ @ek[11]
        # round 3:
        t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[12]
        t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[13]
        t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[14]
        t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[15]
        # round 4:
        s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ @ek[16]
        s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ @ek[17]
        s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ @ek[18]
        s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ @ek[19]
        # round 5:
        t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[20]
        t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[21]
        t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[22]
        t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[23]
        # round 6:
        s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ @ek[24]
        s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ @ek[25]
        s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ @ek[26]
        s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ @ek[27]
        # round 7:
        t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[28]
        t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[29]
        t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[30]
        t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[31]
        # round 8:
        s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ @ek[32]
        s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ @ek[33]
        s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ @ek[34]
        s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ @ek[35]
        # round 9:
        t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[36]
        t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[37]
        t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[38]
        t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[39]
        if (@nr > 10)
            # round 10:
            s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
            Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ @ek[40]
            s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
            Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ @ek[41]
            s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
            Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ @ek[42]
            s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
            Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ @ek[43]
            # round 11:
            t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
            Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[44]
            t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
            Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[45]
            t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
            Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[46]
            t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
            Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[47]
            if (@nr > 12)
                # round 12:
                s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
                Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ @ek[48]
                s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
                Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ @ek[49]
                s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
                Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ @ek[50]
                s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
                Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ @ek[51]
                # round 13:
                t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
                Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ @ek[52]
                t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
                Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ @ek[53]
                t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
                Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ @ek[54]
                t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
                Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ @ek[55]
            end
        end
        j = @nr << 2
        #
        # apply last round and map cipher state to byte array block:
        #
        s0 =
            (S3[(t0 >> 24)]) ^
        (S2[(t1 >> 16) & 0xff]) ^
        (S1[(t2 >>  8) & 0xff]) ^
        (S0[(t3) & 0xff]) ^ @ek[0+j]
        s1 =
            (S3[(t1 >> 24)]) ^
        (S2[(t2 >> 16) & 0xff]) ^
        (S1[(t3 >>  8) & 0xff]) ^
        (S0[(t0) & 0xff]) ^ @ek[1+j]
        s2 =
            (S3[(t2 >> 24)]) ^
        (S2[(t3 >> 16) & 0xff]) ^
        (S1[(t0 >>  8) & 0xff]) ^
        (S0[(t1) & 0xff]) ^ @ek[2+j]
        s3 =
            (S3[(t3 >> 24)]) ^
        (S2[(t0 >> 16) & 0xff]) ^
        (S1[(t1 >>  8) & 0xff]) ^
        (S0[(t2) & 0xff]) ^ @ek[3+j]
        [("%08x%08x%08x%08x" % [s0, s1, s2, s3])].pack("H*")
    end
    protected :_encrypt_block

    def _decrypt_block(ct)
        #
        # map byte array block to cipher state and add initial round key:
        #
        s0 = (ct[ 0] << 24 | ct[ 1] << 16 | ct[ 2] << 8 | ct[ 3]) ^ @dk[0]
        s1 = (ct[ 4] << 24 | ct[ 5] << 16 | ct[ 6] << 8 | ct[ 7]) ^ @dk[1]
        s2 = (ct[ 8] << 24 | ct[ 9] << 16 | ct[10] << 8 | ct[11]) ^ @dk[2]
        s3 = (ct[12] << 24 | ct[13] << 16 | ct[14] << 8 | ct[15]) ^ @dk[3]
        # round 1:
        t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[ 4]
        t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[ 5]
        t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[ 6]
        t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[ 7]
        # round 2:
        s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ @dk[ 8]
        s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ @dk[ 9]
        s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ @dk[10]
        s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ @dk[11]
        # round 3:
        t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[12]
        t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[13]
        t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[14]
        t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[15]
        # round 4:
        s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ @dk[16]
        s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ @dk[17]
        s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ @dk[18]
        s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ @dk[19]
        # round 5:
        t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[20]
        t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[21]
        t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[22]
        t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[23]
        # round 6:
        s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ @dk[24]
        s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ @dk[25]
        s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ @dk[26]
        s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ @dk[27]
        # round 7:
        t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[28]
        t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[29]
        t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[30]
        t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[31]
        # round 8:
        s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ @dk[32]
        s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ @dk[33]
        s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ @dk[34]
        s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ @dk[35]
        # round 9:
        t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[36]
        t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[37]
        t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[38]
        t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[39]
        if (@nr > 10)
            # round 10:
            s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
            Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ @dk[40]
            s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
            Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ @dk[41]
            s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
            Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ @dk[42]
            s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
            Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ @dk[43]
            # round 11:
            t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
            Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[44]
            t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
            Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[45]
            t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
            Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[46]
            t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
            Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[47]
            if (@nr > 12)
                # round 12:
                s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
                Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ @dk[48]
                s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
                Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ @dk[49]
                s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
                Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ @dk[50]
                s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
                Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ @dk[51]
                # round 13:
                t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
                Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ @dk[52]
                t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
                Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ @dk[53]
                t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
                Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ @dk[54]
                t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
                Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ @dk[55]
            end
        end
        j = @nr << 2
        #
        # apply last round and map cipher state to byte array block:
        #
        s0 =
            (Si3[(t0 >> 24)]) ^
        (Si2[(t3 >> 16) & 0xff]) ^
        (Si1[(t2 >>  8) & 0xff]) ^
        (Si0[(t1) & 0xff]) ^ @dk[0+j]
        s1 =
            (Si3[(t1 >> 24)]) ^
        (Si2[(t0 >> 16) & 0xff]) ^
        (Si1[(t3 >>  8) & 0xff]) ^
        (Si0[(t2) & 0xff]) ^ @dk[1+j]
        s2 =
            (Si3[(t2 >> 24)]) ^
        (Si2[(t1 >> 16) & 0xff]) ^
        (Si1[(t0 >>  8) & 0xff]) ^
        (Si0[(t3) & 0xff]) ^ @dk[2+j]
        s3 =
            (Si3[(t3 >> 24)]) ^
        (Si2[(t2 >> 16) & 0xff]) ^
        (Si1[(t1 >>  8) & 0xff]) ^
        (Si0[(t0) & 0xff]) ^ @dk[3+j]
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
        @dk = []
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
