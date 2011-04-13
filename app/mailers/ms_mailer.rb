class MsMailer < ActionMailer::Base
  default :from => "support@mathspert.com",   :reply_to => "support@mathspert.com"

  def welcome(name, email, login, password, membership_expires )
    @name  = name
    @email = email 
    @login = login 
    @password = password 
    @membership_expires = membership_expires 
    mail( :to => email, :subject   => "Welcome to Mathspert", :content_type => "text/html" )

  end

   def teacher_welcome( name, email, login, password )
    @login = login 
    @password = password 
    mail( :to => email, :subject   =>"Welcome to Mathspert", :content_type => "text/html" )
  end
  
  def welcomeTrail(name, email, login, password, membership_expires )
    @name  = name
    @email = email 
    @login = login 
    @password = password 
    @membership_expires = membership_expires 
    mail( :to => email, :subject   =>"Welcome to Mathspert", :content_type => "text/html" )
  end
 
 def welcomeTrailFamily(name, email, login, password, student_login, student_password, membership_expires )
    @name  = name
    @email = email 
    @login = login 
    @password = password 
    @student_login = student_login 
    @student_password = student_password 
     @membership_expires = membership_expires 
    mail( :to => email, :subject   =>"Welcome to Mathspert", :content_type => "text/html" )
  end
    
   def welcomeByCheque(name, email, login, password, membership_expires, payment_amount )
    @name  = name
    @email = email 
    @login = login 
    @password = password 
    @membership_expires = membership_expires 
    @payment_amount = payment_amount 
     mail( :to => email, :subject   =>"Welcome to Mathspert", :content_type => "text/html" )
 end

  def new_account(  to_email, account_email, first_name, surname, user_type, payment_str, the_user="no user object", the_user2="no user2 object" )
    @account_email = account_email 
    @first_name = first_name  
    @surname = surname 
    @user_type = user_type 
    @the_user = the_user  
    @the_user2 = the_user2  
     mail( :to => to_email, :subject   =>":NewAccount: " + user_type +  payment_str, :content_type => "text/html" )

end

  def new_school_account(  acc_type, school_id, grade, the_user )
 
    @the_user = the_user 
  #  @acc_type = acc_type 
    mail( :to => "stevek91411@yahoo.com", :subject   =>":NSA:" + acc_type + " - "  + school_id +  ", grade " + grade, :content_type => "text/html" )

end


  def giftCert(  to_email, name,  activiation_code, status, message )
    @content_type = "text/html" 
    @name = name 
    @activiation_code = activiation_code  
    @status = status 
    @message = message  
    mail( :to => to_email, :subject   =>message, :content_type => "text/html" )
end

 def forgotten_password(  to_email, first_name, users  )
    @sent_on      = Time.now
    @content_type = "text/html" 
    @first_name = first_name  
    @users = users 
    mail( :to => to_email, :subject   =>"Forgotten Usernames & Passwords", :content_type => "text/html" )
end


  def contactUsConfimationToUser(  user_email, first_name, last_name, contactType, msg, source_program )
    @first_name = first_name  
    @last_name = last_name 
    @contactType = contactType  
    @msg = msg  
    @source_program = source_program  
    mail( :to => user_email, :subject   =>"Received your request", :content_type => "text/html" )
  end

  def contactUsFowardToSupport(  user_email, first_name, last_name, login, contactType, msg, source_program )
    @first_name = first_name  
    @last_name = last_name  
    @contactType = contactType  
    @msg = msg  
    @login = login  
    @source_program = source_program  
    mail( :to => "support@mathspert.com", :subject => "Your request", :content_type => "text/html" ) 

  end

  def contactUsFowardStevek91411(  user_email, first_name, last_name, login, contactType, msg, source_program )
    @first_name = first_name  
    @last_name = last_name 
    @user_email = user_email 
    @contactType = contactType  
    @msg = msg  
    @login = login  
    @source_program = source_program  
    mail( :to => "stevek91411@yahoo.com", :subject   =>":support:" + user_email, :content_type => "text/html" )
  end
 
  def infoToStevek91411(  msgSubject, msgContent )
    @msgContent = msgContent   
     mail( :to => "stevek91411@yahoo.com", :subject   =>":info: " +msgSubject, :content_type => "text/html" )
 end
  
  def logClientError(  msgSubject, msgContent )
    @msgContent = msgContent   
    mail( :to => "stevek91411@yahoo.com", :subject   =>":error: " +msgSubject, :content_type => "text/html" )
  end
  
  def coax(  payment_amount, full_price, expires_date, parent_email, greeting, user_name, password )
    @payment_amount = payment_amount 
    @greeting = greeting
    @user_name = user_name
    @password = password
    @full_price = full_price
    @expires_date = expires_date
    mail( :to => parent_email, :subject   => "Mathspert special offer.", :content_type => "text/html" )
    
  end
  
  
  
  
end
