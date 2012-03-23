require 'test/unit' 
require "polydata.rb"
require 'net/https'
require 'uri'

class KeyTest < Test::Unit::TestCase
  def test_one
    # test generate_pair, signing and verifying
    tmp_path = "/tmp/#{OpenSSL::Digest::MD5.hexdigest( rand(Time.new.to_i).to_s ).upcase}" # FIXME make this configurable/portable
    client_keys = Polydata::Key.generate_pair(tmp_path)
  
    msg = Polydata.get_secs_now
    msg_encrypted = Polydata::Key.encrypt(client_keys[:private_key], msg)
    msg_decrypted = Polydata::Key.decrypt(client_keys[:public_key], msg_encrypted)
    if msg.to_s == msg_decrypted.to_s
      STDOUT.puts("Client to Server authentication code passed.")
      if Polydata.check_timestamp(msg_decrypted.to_i)
        STDOUT.puts("Timestamp passed.")
      else
        raise(RuntimeError, "Timestamp failed.")
      end
    else
      raise(RuntimeError, "Client to Server authentication code failed.")
    end
    
    polydata_request = Polydata::Request.decode('@llli*sys/(+polydata)/(+supporter/role)/($get)/(@!72CD.A072.157E.A9C6!0000.0000.3B9B.1FF6!0000.0000.3B9A.CA01)/(+supporter=@!72CD.A072.157E.A9C6!0000.0000.3B9A.CA17)')
    auth = Polydata.get_auth_token(client_keys[:private_key])
    if Polydata.verify_auth_token(client_keys[:public_key], auth)
      STDOUT.puts("Auth token passed.")
      STDOUT.puts("pub key #{client_keys[:public_key]}")
    else
      raise(RuntimeError, "Auth token invalid.")
    end
  end # / def test_one

  def test_two
    tmp_path = "/tmp/#{OpenSSL::Digest::MD5.hexdigest( rand(Time.new.to_i).to_s ).upcase}" # FIXME make this configurable/portable
    client_keys = Polydata::Key.generate_pair(tmp_path)
    
    auth_timestamp = Polydata.get_auth_token(client_keys[:private_key])
    assert( Polydata.verify_auth_token(client_keys[:public_key], auth_timestamp ) )
  end # / def test_two

  def test_signing
    puts "Signing is not part of the polydata process"
    return
    # test generate_pair, signing and verifying
    tmp_path = "/tmp/#{OpenSSL::Digest::MD5.hexdigest( rand(Time.new.to_i).to_s ).upcase}" # FIXME make this configurable/portable
    client_keys = Polydata::Key.generate_pair(tmp_path)
    puts 'client_keys'
    puts client_keys.inspect
  
    timestamp = Polydata.get_secs_now
    puts 'timestamp'
    puts timestamp.inspect
    sign_timestamp = Polydata::Key.sign(client_keys[:private_key], timestamp.to_s)
    puts 'sign_timestamp'
    puts sign_timestamp.inspect
    
    if Polydata::Key.verify(client_keys[:public_key], sign_timestamp, timestamp.to_s)
      STDOUT.puts("Client to Server signed token passed.")
      if Polydata.check_timestamp(timestamp.to_i)
        STDOUT.puts("Timestamp passed.")
      else
        raise(RuntimeError, "Timestamp failed.")
      end
    else
      raise(RuntimeError, "Client to Server authentication code failed.")
    end
  end # / def test_three
end 


