#!/usr/bin/env ruby

=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    This script generates the constant arrays needed by ruby-aes
=end

module AesCons

    ALOG = []
    LOG = []
    p = 1
    256.times do |i|
        ALOG[i] = ALOG[i+255] = p
        LOG[p] = i
        p = (p ^ (p << 1) ^ (p & 0x80 != 0 ? 0x01b : 0)) & 0xff
    end
    LOG[1] = 0

    def self.mul(a, b)
        (a.zero? || b.zero?) ? 0 : ALOG[LOG[a] + LOG[b]]
    end

    RCON = []
    p = 1
    30.times do |i|
        RCON[i] = p << 24 & 0xff000000
        p = mul(2, p)
    end

    S = []
    Si = []
    256.times do |i|
        x = (i != 0) ? ALOG[255 - LOG[i]] : 0
        x ^= (x<<1)^(x<<2)^(x<<3)^(x<<4)
        x = 0x63^(x^(x>>8))
        S[i] = x & 0xff
        Si[x&0xff] = i
    end

    def self.mul4(a, b)
        return 0 if (a == 0)
        a = LOG[a & 0xFF]
        a0 = (b[0] != 0) ? ALOG[(a + LOG[b[0] & 0xff]) % 255] & 0xff : 0
        a1 = (b[1] != 0) ? ALOG[(a + LOG[b[1] & 0xff]) % 255] & 0xff : 0
        a2 = (b[2] != 0) ? ALOG[(a + LOG[b[2] & 0xff]) % 255] & 0xff : 0
        a3 = (b[3] != 0) ? ALOG[(a + LOG[b[3] & 0xff]) % 255] & 0xff : 0
        return a0 << 24 | a1 << 16 | a2 << 8 | a3
    end

    G = [
        [2, 1, 1, 3],[3, 2, 1, 1],[1, 3, 2, 1],[1, 1, 3, 2],
        [1, 1, 1, 1]
    ]
    Gi = [
        [14, 9, 13, 11], [11, 14, 9, 13], [13, 11, 14, 9],
        [9, 13, 11, 14],[1, 1, 1, 1]
    ]
    Te0, Te1, Te2, Te3, Te4 = [], [], [], [], []
    Td0, Td1, Td2, Td3, Td4 = [], [], [], [], []
    256.times do |t|
        s = S[t]
        Te0[t] = mul4(s, G[0])
        Te1[t] = mul4(s, G[1])
        Te2[t] = mul4(s, G[2])
        Te3[t] = mul4(s, G[3])
        Te4[t] = mul4(s, G[4])
        s = Si[t]
        Td0[t] = mul4(s, Gi[0])
        Td1[t] = mul4(s, Gi[1])
        Td2[t] = mul4(s, Gi[2])
        Td3[t] = mul4(s, Gi[3])
        Td4[t] = mul4(s, Gi[4])
    end

    File.open("aes_cons.rb" , "w+") do |f|
        f.write <<-STOP
=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    aes_cons.rb - AES Constant Arrays for ruby-aes
=end

module AesCons

STOP

        ["RCON", "Te0", "Te1", "Te2", "Te3", "Te4",
            "Td0", "Td1", "Td2", "Td3", "Td4"].each do |x|
            f.write "    " + x + " = [\n"
            line = " " * 8
            module_eval(x).each do |y|
                z = "0x%08x" % y
                line << ", " if line.length > 8
                if (line.length + z.length) > 79
                    f.write line.chop + "\n"
                    line = " " * 8
                end
                line << z
            end
            f.write line unless line.length == 8
            f.write "\n]\n\n"
            end
        f.write "end # AesCons\n"
    end

end # module
