class Mymailer < ActionMailer::Base
  
    def welcome(name, email, login, password, membership_expires )
    @recipients   = "#{email}"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Welcome to Mathspert"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:name]  = name
    body[:email] = email 
    body[:login] = login 
    body[:password] = password 
    body[:membership_expires] = membership_expires 

  end

   def teacher_welcome( name, email, login, password )
    @recipients   = "#{email}"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Welcome to Mathspert"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:login] = login 
    body[:password] = password 
  end
  
  def welcomeTrail(name, email, login, password, membership_expires )
    @recipients   = "#{email}"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Welcome to Mathspert"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:name]  = name
    body[:email] = email 
    body[:login] = login 
    body[:password] = password 
    body[:membership_expires] = membership_expires 
  end
 
 def welcomeTrailFamily(name, email, login, password, student_login, student_password, membership_expires )
    @recipients   = "#{email}"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Welcome to Mathspert"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:name]  = name
    body[:email] = email 
    body[:login] = login 
    body[:password] = password 
    body[:student_login] = student_login 
    body[:student_password] = student_password 
     body[:membership_expires] = membership_expires 
  end
    
   def welcomeByCheque(name, email, login, password, membership_expires, payment_amount )
    @recipients   = "#{email}"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Welcome to Mathspert"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:name]  = name
    body[:email] = email 
    body[:login] = login 
    body[:password] = password 
    body[:membership_expires] = membership_expires 
    body[:payment_amount] = payment_amount 
  end

  def new_account(  to_email, account_email, first_name, surname, user_type, payment_str, the_user="no user object", the_user2="no user2 object" )
    @recipients   = to_email
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = ":NewAccount: " + user_type +  payment_str
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:account_email] = account_email 
    body[:first_name] = first_name  
    body[:surname] = surname 
    body[:user_type] = user_type 
    body[:the_user] = the_user  
    body[:the_user2] = the_user2  
 
end

  def new_school_account(  acc_type, school_id, grade, the_user )
 
    @recipients   = "stevek91411@yahoo.com"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = ":NSA:" + acc_type + " - "  + school_id +  ", grade " + grade
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:the_user] = the_user 
  #  body[:acc_type] = acc_type 

end


  def giftCert(  to_email, name,  activiation_code, status, message )
    @recipients   = to_email
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = message
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:name] = name 
    body[:activiation_code] = activiation_code  
    body[:status] = status 
    body[:message] = message  
end

 def forgotten_password(  to_email, first_name, users  )
    @recipients   = to_email
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Forgotten Usernames & Passwords"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:first_name] = first_name  
    body[:users] = users 
end


  def contactUsConfimationToUser(  user_email, first_name, last_name, contactType, msg, source_program )
    @recipients   = user_email
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Received your request"
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:first_name] = first_name  
    body[:last_name] = last_name 
    body[:contactType] = contactType  
    body[:msg] = msg  
    body[:source_program] = source_program  
  end

  def contactUsFowardToSupport(  user_email, first_name, last_name, login, contactType, msg, source_program )
    @recipients   = ["support@mathspert.com"]
    @from         = user_email
    headers         "Reply-to" => user_email
    @subject      = "Your request" 
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:first_name] = first_name  
    body[:last_name] = last_name  
    body[:contactType] = contactType  
    body[:msg] = msg  
    body[:login] = login  
    body[:source_program] = source_program  

  end

  def contactUsFowardStevek91411(  user_email, first_name, last_name, login, contactType, msg, source_program )
    @recipients   = "stevek91411@yahoo.com"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = ":support:" + user_email
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:first_name] = first_name  
    body[:last_name] = last_name 
    body[:user_email] = user_email 
    body[:contactType] = contactType  
    body[:msg] = msg  
    body[:login] = login  
    body[:source_program] = source_program  
  end
 
  def infoToStevek91411(  msgSubject, msgContent )
    @recipients   = "stevek91411@yahoo.com"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = ":info: " +msgSubject
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:msgContent] = msgContent   
  end
  
  def logClientError(  msgSubject, msgContent )
    @recipients   = "stevek91411@yahoo.com"
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = ":error: " +msgSubject
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:msgContent] = msgContent   
  end
  
  def coax(  payment_amount, full_price, expires_date, parent_email, greeting, user_name, password )
    @recipients   = parent_email
    @from         = "support@mathspert.com"
    headers         "Reply-to" => "support@mathspert.com"
    @subject      = "Mathspert special offer."
    @sent_on      = Time.now
    @content_type = "text/html" 
    body[:payment_amount] = payment_amount 
    body[:greeting] = greeting
    body[:user_name] = user_name
    body[:password] = password
    body[:full_price] = full_price
    body[:expires_date] = expires_date
     
  end
  
  
end
