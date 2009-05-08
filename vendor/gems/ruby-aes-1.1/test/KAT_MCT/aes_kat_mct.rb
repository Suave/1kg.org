#!/usr/bin/env ruby

=begin
 This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
 Written by Alex Boussinet <alex.boussinet@gmail.com>

 KAT Tests and MCT tests according to katmct.pdf file.
 <http://csrc.nist.gov/encryption/aes/katmct/katmct.htm>
 See rijndael-vals.zip
=end

require File.dirname(__FILE__) + '/../test_helper.rb'

def cbc_decrypt_mct(output)
  output.write <<EOT

=========================

FILENAME: "cbc_d_m.txt"

Cipher Block Chaining (CBC) Mode - DECRYPTION
Monte Carlo Test

Algorithm Name: Rijndael

==========

EOT
  [128, 192, 256].each { |kl|
    output.write "KEYSIZE=#{kl}\n\n"
    key = "0" * (kl/4)
    ct = iv = "0" * 32
    opt = pt = nil
    400.times { |i|
      output.write "I=#{i}\nKEY=#{key}\nIV=#{iv}\nCT=#{ct}\n"
      10000.times { |j|
	opt = pt
	pt = Aes.decrypt_block(kl, 'ECB', key, iv,
				[ct].pack("H*")).unpack("H*")[0]
	pt = "%032X" % (pt.hex ^ iv.hex)
	iv = ct
	ct = pt
      }
      case kl
      when 128
	npt = pt
      when 192, 256
	x = -(kl/4-32)
	npt = opt[x..-1] + pt
      end
      key = "%0#{kl/4}X" % (key.hex ^ npt.hex)
      output.write "PT=#{pt}\n\n"
    }
    output.write "=========================\n\n"
  }
end

def cbc_encrypt_mct(output)
  output.write <<EOT

=========================

FILENAME: "cbc_e_m.txt"

Cipher Block Chaining (CBC) Mode - ENCRYPTION
Monte Carlo Test

Algorithm Name: Rijndael

==========

EOT
  [128, 192, 256].each { |kl|
    output.write "KEYSIZE=#{kl}\n\n"
    key = "0" * (kl/4)
    pt = iv = "0" * 32
    oct = ct = nil
    400.times { |i|
      output.write "I=#{i}\nKEY=#{key}\nIV=#{iv}\nPT=#{pt}\n"
      10000.times { |j|
	oct = ct
	pt = "%032X" % (pt.hex ^ iv.hex)
	ct = Aes.encrypt_block(kl, 'ECB', key, iv,
				[pt].pack("H*")).unpack("H*")[0]
	if j == 0 then pt = iv else pt = oct end
	iv = ct
      }
      case kl
      when 128
	nct = ct
      when 192, 256
	x = -(kl/4-32)
	nct = oct[x..-1] + ct
      end
      key = "%0#{kl/4}X" % (key.hex ^ nct.hex)
      output.write "CT=#{ct}\n\n"
    }
    output.write "=========================\n\n"
  }
end

def ecb_decrypt_mct(output)
  output.write <<EOT

=========================

FILENAME: "ecb_d_m.txt"

Electronic Codebook (ECB) Mode - DECRYPTION
Monte Carlo Test

Algorithm Name: Rijndael

=========================

EOT
  [128, 192, 256].each { |kl|
    output.write "KEYSIZE=#{kl}\n\n"
    key = "0" * (kl/4)
    ct = "0" * 32
    opt = pt = nil
    400.times { |i|
      output.write "I=#{i}\nKEY=#{key}\nCT=#{ct}\n"
      10000.times { |j|
	opt = pt
	pt = Aes.decrypt_block(kl, 'ECB', key, nil,
				[ct].pack("H*")).unpack("H*")[0]
	ct = pt
      }
      case kl
      when 128
	npt = pt
      when 192, 256
	x = -(kl/4-32)
	npt = opt[x..-1] + pt
      end
      key = "%0#{kl/4}X" % (key.hex ^ npt.hex)
      ct = pt
      output.write "PT=#{pt}\n\n"
    }
    output.write "=========================\n\n"
  }
end

def ecb_encrypt_mct(output)
  output.write <<EOT

=========================

FILENAME: "ecb_e_m.txt"

Electronic Codebook (ECB) Mode - ENCRYPTION
Monte Carlo Test

Algorithm Name: Rijndael

=========================

EOT
  [128, 192, 256].each { |kl|
    output.write "KEYSIZE=#{kl}\n\n"
    key = "0" * (kl/4)
    pt = "0" * 32
    oct = ct = nil
    400.times { |i|
      output.write "I=#{i}\nKEY=#{key}\nPT=#{pt}\n"
      10000.times { |j|
	oct = ct
	ct = Aes.encrypt_block(kl, 'ECB', key, nil,
				[pt].pack("H*")).unpack("H*")[0]
	pt = ct
      }
      case kl
      when 128
	nct = ct
      when 192, 256
	x = -(kl/4-32)
	nct = oct[x..-1] + ct
      end
      key = "%0#{kl/4}X" % (key.hex ^ nct.hex)
      pt = ct
      output.write "CT=#{ct}\n\n"
    }
    output.write "=========================\n\n"
  }
end

def ecb_iv(output)
  output.write <<EOT

=========================

FILENAME: "ecb_iv.txt"

Electronic Codebook (ECB) Mode
Intermediate Value Known Answer Tests

Algorithm Name: Rijndael

==========

EOT
  if (AesAlg.respond_to? :c_extension)
      @output.write <<EOT
Not Implemented

==========

EOT
  else
      $output = output
      AesAlg.class_eval do
          alias :encrypt_block_original :_encrypt_block
          alias :decrypt_original_block :_decrypt_block
          def _encrypt_block
              addRoundKey 0
              1.upto(@nr) { |n|
                  subBytes
                  shiftRows
                  mixColumns unless n == @nr
                  addRoundKey n
                  $output.puts "CT#{n}=#{@state.unpack("H*")[0]}" unless (@nr-n).zero?
              }
              @state
          end
          def _decrypt_block
              addRoundKey @nr
              (@nr-1).downto(0) { |n|
                  ishiftRows
                  isubBytes
                  $output.puts "PT#{@nr-n}=#{@state.unpack("H*")[0]}" unless n.zero?
                  addRoundKey n
                  imixColumns unless n == 0
              }
              @state
          end
      end
      [128, 192, 256].each { |kl|
          output.write "KEYSIZE=#{kl}\n"
          key = ""
          (kl/8).times do |n| key << n.chr end
          output.write "KEY=#{key.unpack("H*")[0]}\n\n"
          output.write "Intermediate Ciphertext Values (Encryption)\n\n"
          pt = ""
          16.times do |n| pt << n.chr end
          output.write "PT=#{pt.unpack("H*")[0]}\n"
          ct = Aes.encrypt_block(kl, 'ECB', key, nil, pt)
          output.write "CT=#{ct.unpack("H*")[0]}\n\n"

          output.write "Intermediate Ciphertext Values (Decryption)\n\n"
          output.write "CT=#{ct.unpack("H*")[0]}\n"
          npt = Aes.decrypt_block(kl, 'ECB', key, nil, ct)
          output.write "PT=#{npt.unpack("H*")[0]}\n\n"

          output.write "==========\n\n"
      }
      AesAlg.class_eval do
          alias :_block_encrypt :encrypt_block_original
          alias :_block_decrypt :decrypt_block_original
      end
  end
end

def ecb_tbl(output)
  output.write <<EOT

=========================

FILENAME: "ecb_tbl.txt"

Electronic Codebook (ECB) Mode
Tables Known Answer Tests

Algorithm Name: Rijndael
Tables tested: S, Si, LOG, ALOG, RCON, Te0-4 Td0-4

==========

EOT
  [128, 192, 256].each { |kl|
    output.write "KEYSIZE=#{kl}\n\n"
    File.open("table.#{kl}", "r") { |f|
      begin
	1.upto(64) { |i|
	  key, *pt = f.readline.split(" ")
	  pt = pt.join
	  ct = Aes.encrypt_block(kl, 'ECB', key, nil, [pt].pack("H*"))
	  output.write "I=#{i}\nKEY=#{key}\nPT=#{pt}\nCT=#{ct.unpack("H*")[0]}\n\n"
	}
	65.upto(128) { |i|
	  key, *ct = f.readline.split(" ")
	  ct = ct.join
	  pt = Aes.encrypt_block(kl, 'ECB', key, nil, [ct].pack("H*"))
	  output.write "I=#{i}\nKEY=#{key}\nPT=#{pt.unpack("H*")[0]}\nCT=#{ct}\n\n"
	}
      rescue
	raise "Bad Table File"
      end
    }
    output.write "==========\n\n"
  }
end

def ecb_vt(output)
  output.write <<EOT

=========================

FILENAME: "ecb_vt.txt"

Electronic Codebook (ECB) Mode
Variable Text Known Answer Tests

Algorithm Name: Rijndael

==========

EOT
  [128, 192, 256].each { |kl|
    key = "0" * (kl/4)
    output.write "KEYSIZE=#{kl}\n\nKEY=#{key}\n\n"
    (127).downto(0) { |b|
      i = 128 - b
      pt = "%032X" % (1 << b)
      ct = Aes.encrypt_block(kl, 'ECB', key, nil, [pt].pack("H*"))
      output.write "I=#{i}\nPT=#{pt}\nCT=#{ct.unpack("H*")[0]}\n\n"
    }
    output.write "==========\n\n"
  }
end

def ecb_vk(output)
  pt = "00000000000000000000000000000000"
  output.write <<EOT

=========================

FILENAME: "ecb_vk.txt"

Electronic Codebook (ECB) Mode
Variable Key Known Answer Tests

Algorithm Name: Rijndael

==========
EOT
  [128, 192, 256].each { |kl|
    output.write "KEYSIZE=#{kl}\n\nPT=#{pt}\n\n"
    (kl-1).downto(0) { |b|
      i = kl - b
      key = "%0#{kl/4}X" % (1 << b)
      ct = Aes.encrypt_block(kl, 'ECB', key, nil, [pt].pack("H*"))
      output.write "I=#{i}\nKEY=#{key}\nCT=#{ct.unpack("H*")[0]}\n\n"
    }
    output.write "==========\n\n"
  }
end

def kat_tests
  puts "Writing ecb_vk.txt..."
  File.open("ecb_vk.txt") { |f| ecb_vk f }
  puts "Writing ecb_vt.txt..."
  File.open("ecb_vt.txt") { |f| ecb_vt f }
  puts "Writing ecb_tbl.txt..."
  File.open("ecb_tbl.txt") { |f| ecb_tbl f }
  puts "Writing ecb_iv.txt..."
  File.open("ecb_iv.txt") { |f| ecb_iv f }
end

def mct_tests
  puts "Writing ecb_e_m.txt..."
  File.open("ecb_e_m.txt") { |f| ecb_encrypt_mct f }
  puts "Writing ecb_d_m.txt..."
  File.open("ecb_d_m.txt") { |f| ecb_decrypt_mct f }
  puts "Writing cbc_e_m.txt..."
  File.open("cbc_e_m.txt") { |f| cbc_encrypt_mct f }
  puts "Writing cbc_d_m.txt..."
  File.open("cbc_d_m.txt") { |f| cbc_decrypt_mct f }
end

if __FILE__ == $0
  puts "Performing KAT Tests..."
  kat_tests
  puts "Performing MCT Tests... VERY time consuming !"
  mct_tests
end
