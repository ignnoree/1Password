require 'openssl'
require 'sqlite3'

db=SQLite3::Database.new('passwords.db')

db.execute("CREATE TABLE IF NOT EXISTS passwords (id INTEGER PRIMARY KEY,service_name TEXT,password_hash TEXT)")

class String
    def encrypt(key)
        cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
        cipher.key = key
        s = cipher.update(self) + cipher.final
    
        s.unpack('H*')[0].upcase
      end
    
    def decrypt(key)
        cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').decrypt
        cipher.key = key
        s = [self].pack("H*").unpack("C*").pack("c*")
    
        cipher.update(s) + cipher.final
      end
    end




def generate_password(length)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w[! @ # $ % ^ & *]
    Array.new(length) { chars.sample }.join
 end


key="some random key here " 


while true
    puts '1.Add password, 2.Get password, 3.exit' 
    input1=gets.chomp
    if input1=='1'
        puts 'Enter service name:'
        service_name=gets.chomp

        password=generate_password(12)
        puts "Generated password: #{password}"
        encpass=password.encrypt(key)
        puts "Encrypted password: #{encpass}"
        db.execute("INSERT INTO passwords (service_name,password_hash) VALUES (?,?)",[service_name , encpass])
    elsif input1=='2'
        puts 'Enter service name:'
        service_name=gets.chomp
        decrypted_password=db.get_first_value("SELECT password_hash FROM passwords WHERE service_name=?",service_name)

        if decrypted_password.nil?
            puts 'Password not found for the service name entered try again or add password for the service name entered ' 
        else
            puts "Decrypted Password: #{decrypted_password.decrypt(key)}"
        end
    
    elsif input1=='3'
        break
    end
end
        

