#!/usr/bin/env ruby

=begin
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    This script generates the constant arrays needed by ruby-aes
=end

module AesCons

    ALOG = []
    LOG = []
    j = 1
    256.times do |i|
        ALOG[i] = ALOG[i+255] = j
        LOG[j] = i
        j = (j ^ (j << 1) ^ (j & 0x80 != 0 ? 0x01b : 0)) & 0xff
    end
    LOG[1] = 0

    def self.mul(a, b)
        (a.zero? || b.zero?) ? 0 : ALOG[LOG[a] + LOG[b]]
    end

    RCON = []
    j = 1
    10.times do |i|
        RCON[i] = j << 24 & 0xff000000
        j = mul(2, j)
    end

    S = []
    Si = []
    256.times do |i|
        x = (i != 0) ? ALOG[255 - LOG[i]] : 0
        x ^= (x << 1) ^ (x << 2) ^ (x << 3) ^ (x << 4)
        x = 0x63 ^ (x ^ (x >> 8))
        S[i] = x & 0xff
        Si[x & 0xff] = i
    end

    def self.mul4(a, b)
        return 0 if (a.zero?)
        a = LOG[a & 0xFF]
        a0 = (b[0] != 0) ? ALOG[(a + LOG[b[0] & 0xff]) % 255] & 0xff : 0
        a1 = (b[1] != 0) ? ALOG[(a + LOG[b[1] & 0xff]) % 255] & 0xff : 0
        a2 = (b[2] != 0) ? ALOG[(a + LOG[b[2] & 0xff]) % 255] & 0xff : 0
        a3 = (b[3] != 0) ? ALOG[(a + LOG[b[3] & 0xff]) % 255] & 0xff : 0
        return a0 << 24 | a1 << 16 | a2 << 8 | a3
    end

    G = [
        [2, 1, 1, 3],[3, 2, 1, 1],[1, 3, 2, 1],[1, 1, 3, 2],
        [0, 0, 0, 1],[0, 0, 1, 0],[0, 1, 0, 0],[1, 0, 0, 0]
    ]
    Gi = [
        [14, 9, 13, 11], [11, 14, 9, 13], [13, 11, 14, 9],[9, 13, 11, 14],
        [0, 0, 0, 1],[0, 0, 1, 0],[0, 1, 0, 0],[1, 0, 0, 0]
    ]
    Te0, Te1, Te2, Te3 = [], [], [], []
    S0, S1, S2, S3 = [], [], [], []
    Td0, Td1, Td2, Td3 = [], [], [], []
    Si0, Si1, Si2, Si3 = [], [], [], []
    256.times do |t|
        s = S[t]
        Te0[t] = mul4(s, G[0])
        Te1[t] = mul4(s, G[1])
        Te2[t] = mul4(s, G[2])
        Te3[t] = mul4(s, G[3])
        S0[t]  = mul4(s, G[4])
        S1[t]  = mul4(s, G[5])
        S2[t]  = mul4(s, G[6])
        S3[t]  = mul4(s, G[7])
        s = Si[t]
        Td0[t] = mul4(s, Gi[0])
        Td1[t] = mul4(s, Gi[1])
        Td2[t] = mul4(s, Gi[2])
        Td3[t] = mul4(s, Gi[3])
        Si0[t] = mul4(s, Gi[4])
        Si1[t] = mul4(s, Gi[5])
        Si2[t] = mul4(s, Gi[6])
        Si3[t] = mul4(s, Gi[7])
    end

    File.open("aes_cons.h" , "w+") do |f|
        f.write <<-STOP
/*
 *  This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
 *  Written by Alex Boussinet <alex.boussinet@gmail.com>
 *
 *  aes_cons.h - AES Constant Arrays for ruby-aes
 */

#ifndef __AES_CONS__
#define __AES_CONS__

STOP
        ["RCON", "Te0", "Te1", "Te2", "Te3", "S0", "S1", "S2", "S3",
            "Td0", "Td1", "Td2", "Td3", "Si0", "Si1", "Si2", "Si3"].each do |x|
            f.write "uint    " + x + "[] = {\n"
            line = " " * 4
            module_eval(x).each do |y|
                z = "0x%08x" % y
                line << ", " if line.length > 4
                if (line.length + z.length) > 79
                    f.write line.chop + "\n"
                    line = " " * 4
                end
                line << z
            end
            f.write line unless line.length == 4
            f.write "\n};\n\n"
            end
        f.write "#endif\n"
    end

end # AesCons
