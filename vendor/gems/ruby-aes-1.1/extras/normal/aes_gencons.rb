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
        RCON[i] = p; p = mul(2, p)
    end

    S_BOX = []
    IS_BOX = []
    256.times do |i|
        x = (i != 0) ? ALOG[255 - LOG[i]] : 0
        x ^= (x<<1)^(x<<2)^(x<<3)^(x<<4)
        x = 0x63^(x^(x>>8))
        S_BOX[i] = x & 0xff
        IS_BOX[x&0xff] = i
    end

    G2X, G3X, G9X, GBX, GDX, GEX = [],[],[],[],[],[]

    256.times do |i|
        G2X[i] = mul(2,  i)
        G3X[i] = mul(3,  i)
        G9X[i] = mul(9,  i)
        GBX[i] = mul(11, i)
        GDX[i] = mul(13, i)
        GEX[i] = mul(14, i)
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

        ["RCON", "S_BOX", "IS_BOX", "G2X", "G3X",
            "G9X", "GBX", "GDX", "GEX"].each do |x|
            f.write "    " + x + " = [\n"
            line = " " * 8
            module_eval(x).each do |y|
                z = "0x%02x" % y
                line << ", " if line.length > 8
                if (line.length + z.length) > 79
                    f.write line.chop + "\n"
                    line = " " * 8
                end
                line << z
            end
            f.write line unless line.length == 8
            f.write "\n    ]\n\n"
        end
        f.write "end # AesCons\n"
    end

end # AesCons

