require 'openssl'

module Polydata

  class Key
    KeyBits = 2048 # msg bytes 245 # FIXME use this in key gen
    KeyGenDays = 730
    
    def self.encrypt(keystr, msg)
      rsa_key = OpenSSL::PKey::RSA.new(keystr)
      raise( RuntimeError, "Message too large to encrypt.") if msg.size > 245 # FIXME use KeyBits math # "2048 bit key which gives 256 - 11 = 245 bytes"
      if rsa_key.private?
        rsa_key.private_encrypt(msg.to_s) # large msg is sloooow
      else
        rsa_key.public_encrypt(msg.to_s) # large msg is sloooow
      end
    end

    def self.decrypt(keystr, crypt)
      rsa_key = OpenSSL::PKey::RSA.new(keystr)
      if rsa_key.private?
        rsa_key.private_decrypt(crypt)
      elsif rsa_key.public?
        rsa_key.public_decrypt(crypt)
      else
        raise RuntimeError, "Bad key."
      end
    end
=begin
these are not used in polydata but I hesitate to trash them ...
    def self.sign(private_keystr, msg) # only works with private keys
      private_key = OpenSSL::PKey::RSA.new(private_keystr)
      raise(RuntimeError, "Only private keys can sign.") unless private_key.private?
      dig = OpenSSL::Digest::SHA1.new
      private_key.sign(dig, msg)
    end
    
    def self.verify(keystr, signed, unsigned)
      key = OpenSSL::PKey::RSA.new(keystr)
      dig = OpenSSL::Digest::SHA1.new
      key.verify(dig, signed, unsigned)
    end
=end
    def self.generate_pair(tmp_path)
  #    pri = `openssl genrsa 1024`
  #    pub = `openssl req -new -utf8 -batch -pubkey -x509 -nodes -sha1 -days #{KeyGenDays} -key #{tmp_path}.pri` # pri key needs to be in a file which makes this awkward
  # FIXME there are cleaner ways to get the PEM values
      public_data = `openssl req -new -batch -x509 -pubkey -nodes -days #{KeyGenDays} -keyout #{tmp_path}.pri`
      # public_data contains a certificate request
      ix0 = public_data.index('-----BEGIN PUBLIC KEY-----')
      ix1 = public_data.index('-----END PUBLIC KEY-----') + 24 # -----END PUBLIC KEY----- is 24 chars
      private_key = ''
      File.new( "#{tmp_path}.pri", 'r' ).read(nil, private_key)
      keys = { 
        :private_key => private_key,
        :public_key => public_data[ix0, (ix1 - ix0)] 
        }
      `rm #{tmp_path}.pri` # FIXME data on file, even briefly, is a security hole?
      keys
    end
    
  end # /class Key

end # /module Polydata
