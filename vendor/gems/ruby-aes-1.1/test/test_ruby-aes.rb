require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubyAES < Test::Unit::TestCase

  def setup
      @keys = {}
      KEY_LENGTH.each do |kl|
          @keys[kl] = ""
          random_fill(kl/8, @keys[kl])
      end

      @iv = ""
      random_fill(16, @iv)
      @pt = ""
      random_fill(64, @pt)
      @kl = KEY_LENGTH[(rand * KEY_LENGTH.length).to_i]
      @mode = MODES[(rand * MODES.length).to_i]
  end

  def test_modes_and_key_lengths
      pt = @pt[0...16]
      MODES.each do |mode|
          KEY_LENGTH.each do |kl|
              ct = Aes.encrypt_block(kl, mode, @keys[kl], @iv, pt)
              npt = Aes.decrypt_block(kl, mode, @keys[kl], @iv, ct)
              assert_equal(pt, npt, "Error in encryption/decryption (#{kl}-#{mode})")
          end
      end
  end

  def test_encrypt_decrypt_stream
      file = "_ruby-aes_test_encrypt_stream_"
      sin = File.open(file, "w+b")
      random_fill(4242, sin)
      sin.close

      sin = File.open(file, "rb")
      sout = File.open("#{file}.aes", "w+b")
      Aes.encrypt_stream(@kl, @mode, @keys[@kl], @iv, sin, sout)
      sin.close
      sout.close

      sin = File.open("#{file}.aes", "rb")
      sout = File.open("#{file}.plain", "w+b")
      Aes.decrypt_stream(@kl, @mode, @keys[@kl], @iv, sin, sout)
      sin.close
      sout.close

      pt, npt = IO.read(file), IO.read("#{file}.plain")

      assert_equal pt, npt, "Error in encrypt_decrypt_stream"
  ensure
      FileUtils.rm_f [ file, "#{file}.aes", "#{file}.plain" ]
  end

  def test_encrypt_decrypt_buffer
      MODES.each do |mode|
          KEY_LENGTH.each do |kl|
            ct = Aes.encrypt_buffer(kl, mode, @keys[kl], @iv, @pt)
            npt = Aes.decrypt_buffer(kl, mode, @keys[kl], @iv, ct)
            assert_equal(@pt, npt, "Error in encrypt_decrypt_buffer")
          end
      end
      pt = ""
      42.times do
          pt << random_fill(1, pt)
          ct = Aes.encrypt_buffer(@kl, @mode, @keys[@kl], @iv, pt)
          npt = Aes.decrypt_buffer(@kl, @mode, @keys[@kl], @iv, ct)
          assert_equal(pt, npt, "Error in encrypt_decrypt_buffer")
      end
  end

  def test_check_key_length
      assert_raise(RuntimeError) do
          Aes.check_kl(42)
      end
      KEY_LENGTH.each do |kl|
          assert_nothing_raised do
              Aes.check_kl(kl)
          end
      end
  end

  def test_check_iv
      assert_raise(RuntimeError) do
          Aes.check_iv(@iv.unpack('H*'))
      end
      assert_nothing_raised do
          Aes.check_iv(@iv)
      end
  end

  def test_check_key
      assert_raise(RuntimeError) do
          Aes.check_key(@keys[128], 64)
      end # bad key length
      assert_raise(RuntimeError) do
          Aes.check_key('123', 128)
      end # bad key string
      assert_raise(RuntimeError) do
          Aes.check_key(nil, 256)
      end # bad key string
      assert_raise(RuntimeError) do
          Aes.check_key(@keys[128].unpack('H*'), 128)
      end # bad key string
      assert_nothing_raised do
          Aes.check_key(@keys[@kl], @kl)
      end
  end

  def test_check_mode
      assert_raise(RuntimeError) do
          Aes.check_mode('ABC')
      end
      MODES.each do |mode|
          assert_nothing_raised do
              Aes.check_mode(mode)
          end
      end
  end

  def test_truth
      assert true
  end

end
