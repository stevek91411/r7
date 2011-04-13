class UsersController < ApplicationController

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
     before_filter :login_required, :only => [ :changePassword, :updateStatus, :show ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
       
 
   # GET /user/1
  # GET /user/1.xml
  def show
    @user = User.find(params[:id])
    
    # security check, the requestor has the ID and login 
    if params[:login].gsub(/ /,'') != @user.login.gsub(/ /,'')
    	log_attack "Error User show " + params[:id] + " : " + params[:login]  + " - user.login = " + @user.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "" ) }
      end
    	return
    end
    
    
    respond_to do |format|
      format.xml  { render :xml => @user }
    end
  end
  
  
  
  # POST /users
  # POST /users.xml
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
   
    @user = User.new(params[:user])    
    @user.status = "active"
    @user.membership_expires = Time.now + 1.day  
    
    if ( @user.user_type == "parent" )       
       if params[:user][:parent][:register_type] == "free"	 ||   	#  a free user
          params[:user][:parent][:register_type] == "ma"     || 	# a parent created in the Admin console
           params[:user][:parent][:register_type] == "giftC"      	# a parent using a gift cert
            @user.membership_expires = Time.now + 1.year + 1.day  
        end
          
        if params[:user][:parent][:register_type] == "trial"         
          @user.status = "trial"
          @user.membership_expires = Time.now + 1.week + 1.day  # 1 weeks free trial
        end
        if params[:user][:parent][:register_type] == "pre-enroll"         
          @user.status = "pre-enroll"
          @user.membership_expires = Time.now + 1.day # give one day incase parent pays but does not complete enrollment by returning to runRegisterSuccess
        end
    end
    
    if ( @user.user_type == "student" )
          @user.membership_expires = params[:user][:membership_expires]           
    end
       
    # for an agent, check the agent code is available
    if ( @user.user_type == "agent" )      

	    if session[:user_type] != "admin-mx" && session[:user_type] != "agent"  # basic security trap
	      return
  	    end
  	   
  	    # check the agent code is available
        @discount_code = DiscountCode.find_by_code(params[:user][:agent][:agent_code])

	    if @discount_code
          respond_to do |format|      
            format.xml  { render :xml => errorRsp( "Agent code not available" ) }
          end
          return
        end  
    end	
    
    begin        
   		if @user.save
        	self.current_user = @user
    	else
        	log_DB_errors(  "user", @user.errors ) 
        	respond_to do |format|
           		format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
       		end
       		return
    	end
   rescue Exception => exc
	    log_error_send_email( "user.create. " + @user.user_type + ". Saving user #{exc.message}")
     	respond_to do |format|
       		format.xml { render :xml =>  errorRsp( "Error, account not saved" ) }
       	end
       	return
	end
           
    # now create a agent if necessary
    if ( @user.user_type == "agent" )      
    
        @agent = Agent.new( params[:user][:agent] )
        @agent.login = @user.login       
        @agent.id = @user.id

         if  allowSendEmail  
          # notify stevek that a new agent account was created
          MsMailer.new_account( "stevek91411@yahoo.com", @agent.email,@agent.first_name, 
                                    @agent.last_name, @user.user_type, "New agent" ).deliver
         end
    
         if @agent.save
         
         	# create the discount code
          	discount_code = DiscountCode.new(  )
      		discount_code.code =  @agent.agent_code
     	 	discount_code.party_type = "agent"
      		discount_code.party_id = @agent.id
      		discount_code.party_login = @agent.login
     		discount_code.agent_membership_discount = @agent.membership_discount
      		discount_code.save()
                   
           respond_to do |format|
              format.xml { render :xml =>  @agent }
           end  # respond_to
         else
            respond_to do |format|
              format.xml { render :xml =>  log_DB_errors(  "agent", @agent.errors ) }
           end
         end    # if @agent.save
         return     
     end       # if ( user.user_type == "agent" )  
        
    # now create a student if necessary
    if ( @user.user_type == "student" )      
        @student = Student.new()
        @student.login = @user.login
        @student.email = params[:user][:student][:email]
        @email = @student.email 
        @student.first_name = params[:user][:student][:first_name]
        @student.status = "active"
        @student.last_name =params[:user][:student][:last_name]     
        @student.parent_id  = params[:user][:student][:parent_id]   
        @student.grade=params[:user][:student][:grade]
        @student.gender=params[:user][:student][:gender]
        @student.weekly_target_in_mins=params[:user][:student][:weekly_target_in_mins]
        @student.dob=params[:user][:student][:dob]
        @student.first_registered = Time.now
        @student.id = @user.id
    	@student.school_id = "0"
        
         @email =params[:user][:student][:email]
         @first_name = params[:user][:student][:first_name]
         @last_name =params[:user][:student][:last_name]
         if  allowSendEmail  && @user.login[0..4] != "PTest"
          # notify stevek that a new student account was created
          MsMailer.new_account( "stevek91411@yahoo.com", @student.email,@student.first_name, 
                                    @student.last_name, @user.user_type, "", @student.inspect.gsub( "#<", "" ) ).deliver
         end
    
         if @student.save
           respond_to do |format|
              format.xml { render :xml =>  @student }
           end  # respond_to
         else
            respond_to do |format|
              format.xml { render :xml =>  log_DB_errors(  "student", @student.errors ) }
           end
         end    # if @student.save     
     end       # if ( user.user_type == "student" )  
       
     # create a parent if necessary
     if ( @user.user_type == "parent" )         
          @parent = Parent.new()
          @parent.first_registered = Time.parse( params[:user][:parent][:first_registered] )
          @parent.email = params[:user][:parent][:email]
          @parent.first_name = params[:user][:parent][:first_name]
          @parent.last_name =params[:user][:parent][:last_name]     
          @parent.login = @user.login
          @parent.max_no_of_active_students = 2
          @parent.payment_plan = "family"
          @parent.register_type = ""
          @parent.id = @user.id
          @email =params[:user][:parent][:email]
          @first_name = params[:user][:parent][:first_name]
          @last_name =params[:user][:parent][:last_name]
          @parent.discount_code = params[:user][:parent][:discount_code]
          @parent.payment_amount = params[:user][:parent][:payment_amount]
          @parent.membership_expires = @user.membership_expires
          @parent.last_payment = params[:user][:parent][:last_payment]
           
		  if params[:user][:parent][:register_type] == "free"		#  a free user
            @parent.last_payment = ""
            @parent.payment_amount = "0"
          end
 
  		  if (  allowSendEmail && @user.login[0..4] != "PTest" )
			  # notify stevek that a new parent account was created
              MsMailer.new_account( "stevek91411@yahoo.com", @parent.email, @user.login, 
                                    @parent.last_name, @user.user_type, "-" + @parent.register_type +
                                    ", $" +  @parent.payment_amount.to_s, @parent.inspect.gsub( "#<", "" ) ).deliver 
             # notify stevek cell that a new parent account was created
             MsMailer.new_account( "8182617590@txt.att.net", @parent.email, @user.login, 
                                    @parent.last_name, @user.user_type, "-" + @parent.register_type +
                                    ", $" +  @parent.payment_amount.to_s ).deliver
      		 # send parent the welcome email
	         MsMailer.welcomeTrail(  @parent.first_name, @parent.email, @user.login, 
	                 @user.crypted_password, @parent.membership_expires.strftime("%B-%d-%Y") ).deliver # January-05-2009                                            
 
          end
                  
          if @parent.save           
            respond_to do |format|
        		format.xml  { render :xml => successRsp( "", @user.id ) } # return the user id also
            end  # respond_to
            
          else
            respond_to do |format|
              format.xml { render :xml =>  log_DB_errors(  "parent", @parent.errors ) }
            end
          end      
      end    
  end
 
 
 
 def createFamilyAccount
 	
 	# check the Parent login is available
    user = User.find_by_login( params[:family][:parent][:user][:login])
    if user
        respond_to do |format|      
    		format.xml  { render :xml => errorRsp( "Parent Username is not available" ) }
    	end
        return
    end

	# check the Student username is available
    user = User.find_by_login( params[:family][:student][:login])
    if user
        respond_to do |format|      
    		format.xml  { render :xml => errorRsp( "Student Username is not available" ) }
    	end
        return
    end
    
    # create the Parent User record
    @user = User.new(params[:family][:parent][:user])    
    @user.status = "trial"
    @user.user_type = "parent"
    @user.membership_expires = Time.now +  1.week + 1.day  # 1 weeks free trial        
    if !@user.save
        log_DB_errors(  "user", @user.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
       end
       return
    end
	# create the Parent record
	@parent = Parent.new( )
    @parent.first_registered = Time.parse( params[:family][:parent][:first_registered] )
    @parent.email = params[:family][:parent][:email]
    @parent.login = @user.login
    @parent.max_no_of_active_students = 2
    @parent.payment_plan = "family"
    @parent.register_type = params[:family][:parent][:register_type]
    @parent.id = @user.id
    @parent.discount_code = params[:family][:parent][:discount_code]
    @parent.payment_amount = params[:family][:parent][:payment_amount]
    @parent.membership_expires = @user.membership_expires
    @parent.last_payment = ""
    
    if !@parent.save           
      respond_to do |format|
         format.xml { render :xml =>  log_DB_errors(  "parent", @parent.errors ) }
      end      
    end          
        
    # now create a student User and Student record
    @user = User.new(params[:family][:student])    
    @user.status = "active"
    @user.user_type = "student"
    @user.membership_expires = Time.now +  1.week + 1.day  # 1 weeks free trial        
    if !@user.save
        log_DB_errors(  "user", @user.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
       end
       return
    end
    
	# create the Student record    
    @student = Student.new()
    @student.login = @user.login
    @student.email = @parent.email
    @student.first_name = params[:family][:student][:first_name]
    @student.status = "active"
    @student.school_id = "0"
    @student.last_name =params[:family][:student][:last_name]     
    @student.parent_id  = @parent.id   
    @student.grade=params[:family][:student][:grade]
    @student.weekly_target_in_mins=params[:family][:student][:weekly_target_in_mins]
    @student.first_registered = Time.now
    @student.id = @user.id
    
    if @student.save
       respond_to do |format|
         format.xml  { render :xml => successRsp( "", "" ) } 
       end  # respond_to
     else
        respond_to do |format|
          format.xml { render :xml =>  log_DB_errors(  "student", @student.errors ) }
        end
    end    # if @student.save     
       
    if (  allowSendEmail  )
	      # notify stevek that a new parent account was created
          MsMailer.new_account( "stevek91411@yahoo.com", @parent.email, @parent.login, 
                                    @parent.last_name, "Parent + Student ", " $" +  @parent.payment_amount.to_s,  
                                    @parent.inspect.gsub( "#<", "" ), @student.inspect.gsub( "#<", "" ) ).deliver 
           # notify stevek cell that a new parent account was created
          MsMailer.new_account( "8182617590@txt.att.net", @parent.email, @parent.login, 
                                    @parent.last_name, "Parent + Student ", " $" +  @parent.payment_amount.to_s ).deliver 
      	  # send parent the welcome email
	      MsMailer.welcomeTrailFamily(  @parent.first_name, @parent.email, params[:family][:parent][:user][:login], 
	                params[:family][:parent][:user][:password], params[:family][:student][:login], 
	                params[:family][:student][:password], @parent.membership_expires.strftime("%B-%d-%Y") ).deliver # January-05-2009                                            
 
     end      
 end
 
 
 
  # POST /students
  # POST /students.xml
  def changePassword
    @user = User.find(params[:user][:id])

   respond_to do |format|
      if @user.update_attributes(params[:user])
        format.xml  { render :xml => successRsp }
      else
        format.xml  { render :xml => errorRsp( @user.errors.to_s ) }
      end
    end
  end
  
 # PUT /updateStatus
 # PUT /updateStatus
  def updateStatus
    begin    
      @user = User.find(params[:id])
      @user.status = params[:status]
    
      if @user.user_type == "parent"      	
        students = Student.find_all_by_parent_id(params[:id]) 
        if (  students != nil )
          students.each do |student|
            student.status = params[:status]  
            student.save
        end
      end
    end
    rescue Exception => e  
      log_exception "Error changing a student status", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end

        
    respond_to do |format|
       if !@user.save
        format.xml  { render :xml => errorRsp( @user.errors.to_s ) }
       else
        format.xml  { render :xml => successRsp }
      end
    end
  end
  
end

 
