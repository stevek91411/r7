class SessionsController < ApplicationController

  skip_before_filter :login_required
  
  

  # GET /session/new.xml
  # render new.rhtml
  #def new
  #end

  # GET /session/new        #checkForExistingSession
  def new    

    respond_to do |format|
        if ( self.current_user == nil )
          format.xml { render :xml => errorRsp( "NoSession" ) }
      else           
           format.xml { render :xml => self.current_user.to_xml }
        end
    end
  end

 # GET getFotdFile      
  def getFotdFile    

    fileName = Dir.pwd + params[:fact_file]
    
    data = ''
  	f = File.open(fileName, "r") 
  	
    while (line = f.gets)
		data += line
	end
	f.close
	
    respond_to do |format|
        format.xml { render :xml => data }
    end
  end
  
  
  # POST /resendActivationCode
  # resend resendActivationCode
  def resendActivationCode
     #send_welcome_email    
     respond_to do |format|    
        format.xml  { render :xml => successRsp }
      end
  end  
 
  # POST /contactUs
  #  contactUs
  # parms are :contactType,  :msg - the user typed in message, 
  # email - will be blank for a logged in users, :source_program - Login, ParentAdmin etc
  def contactUs
   
     respond_to do |format|    
        format.xml  { render :xml => successRsp }
    end
    
    
     # get the values to acknowledge the email to the user, 
     user_email =  params[:email]  
     first_name = params[:first_name]
     last_name = params[:last_name]
     login = params[:login]
     
   
     if  allowSendEmail  

         Mymailer.deliver_contactUsConfimationToUser( user_email, first_name, 
                               last_name,  
                               params[:contactType], params[:msg], params[:source_program] )
                               
        # forward to mathspert support
        Mymailer.deliver_contactUsFowardToSupport( user_email, first_name, 
                               last_name,   login,
                               params[:contactType], params[:msg], params[:source_program] )
     
        # forward to stevek91411 support
        Mymailer.deliver_contactUsFowardStevek91411( user_email, first_name, 
                               last_name, login,
                               params[:contactType], params[:msg], params[:source_program] )
    end
  end
  
  # POST /logClientError
  #  logClientError
  def logClientError
   
     respond_to do |format|    
        format.xml  { render :xml => successRsp }
    end
      
    if  allowSendEmail  
       Mymailer.deliver_logClientError(  params[:request][:msgSubject],  params[:request][:msgContent] )
    end 
  end
  
 

  # POST activateAccount
  # activiate the parent  account
  def activateAccount
     @user = User.find(params[:id])

    if ( params[:activationCode] == self.current_user.salt[0..3] )
        @user.status = "active"


        respond_to do |format|
          if @user.save
            format.xml  { render :xml => successRsp }
          else
            format.xml  { render :xml => errorRsp( @user.errors.to_s ) }
          end
      end
   else
         respond_to do |format|
            format.xml  { render :xml => errorRsp( "Invalid Activation Code" ) }
          end
      end    
  end  
  
  
  # POST /session
  # POST /session.xml
  def create 
        
    if params[:login].index( "projectMDemo" ) != nil
      # just email that someone has used the demo
      if  allowSendEmail 
         Mymailer.deliver_infoToStevek91411(  params[:login] + " login, grade " + params[:grade], "" )
      end
      respond_to do |format|    
        format.xml { render :text => "ok" }
      end
      return
    end
    

    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?

	  session[:user_type] = self.current_user.user_type
	  session[:session_user_id] = self.current_user.id.to_s
	  
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      if  allowSendEmail  &&  params[:login] != "admin-mx" && params[:login][0..4] != "PTest"
       # Mymailer.deliver_infoToStevek91411(  "login for " + self.current_user.user_type + " : " + params[:login], "" )
      end
      respond_to do |format|    
        format.xml { render :xml => self.current_user.to_xml }
      end
     else
      #render :action => 'new'
      respond_to do |format|
        format.xml { render :text => "badlogin" }
      end
    end
  end  
 

  # DELETE /session
  # DELETE /session.xml
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    respond_to do |format|
        format.xml { render :text => "ok" }
    end
  end

  # POST activateParentAccount
  # activiate the parent  account following successful registration
 def activateParentAccount
	@user = User.find_by_login(params[:username])   
	@parent = Parent.find(@user.id) 
	
	if params[:payment_amount] != "10"
    	@user.membership_expires =  Time.now + 1.year + 1.day
    else
    	@user.membership_expires =  Time.now + 3.month + 1.day		# the  3 month summer sepcial
    end
      	  	
    @user.status = "active"     
         
    if !@user.save        
        log_DB_errors(  "user", @user.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
        end
         return
    end
       
    @parent.last_payment = Time.parse( params[:client_date])
    @parent.membership_expires = @user.membership_expires     
    @parent.payment_amount = params[:payment_amount]
    
    respond_to do |format|
    	if @parent.save
           
            # now update the child users accounts
        	students = Student.find_all_by_parent_id(@parent.id) 
        	if (  students != nil )
          		students.each do |student|
     				user = User.find(student.id)
           	 	    user.membership_expires = @parent.membership_expires  
            	    user.save
        		end
        	end
                    
            format.xml  { render :xml => successRsp }
             
            if  @parent.discount_code != nil && @parent.discount_code.length > 0 
          		# a agent discount code was provided , create a commision record
          		begin
	          	    agent = Agent.find_by_agent_code( @parent.discount_code  )
	          	    
			 	    if agent == nil 
			  	    	respond_to do |format|
			    	  		format.xml  { render :xml => errorRsp( "Agent not found for discount_code '" + @parent.discount_code + "'" ) }
			 				log_error ( "Creating parent commision. Agent not found for discount_code '" + @parent.discount_code +  "', parent ID: " + @parent.id.to_s )
			    		end
			    	  	return
			    	end 
			    	
	          	  	@commisions = Agcommision.new(  )
	      			@commisions.commision_type = "parent"
	  				@commisions.party_id = @parent.id                 
	  				@commisions.party_login = @user.login                 
	  				@commisions.party_name = @parent.first_name + " " + @parent.last_name                 
	    			@commisions.party_status ="firstMonth"
	      			@commisions.party_payment_date = Time.now
	      			@commisions.superagent_id = agent.superagent_id
	      			@commisions.parent_first_month_expires = Time.now + 30.days
	      			@commisions.party_payment_amount_cents = @parent.payment_amount * 100
	      			@commisions.parent_membership_expires = @user.membership_expires
	     			@commisions.agent_name = agent.first_name + " " + agent.last_name
	     		 	@commisions.agent_id = agent.id  
	     		 	@commisions.agent_login = agent.login 
	     		 	@commisions.agent_payment_method = agent.payment_method      		 	
	      			@commisions.commision_percentage = agent.parent_commision_percentage 
	      			@commisions.commision_cents = ( @commisions.commision_percentage.to_i * @parent.payment_amount.to_i )
	           		@commisions.save
           			           
	            rescue Exception => e  
	              log_exception "Error creation agcommision", e
	            end
	        end
          
            if  allowSendEmail  
                 
                # notify stevek that a  parent account was paid
                Mymailer.deliver_new_account( "stevek91411@yahoo.com", @parent.email,@parent.first_name, 
                                    @parent.last_name, @user.user_type, ", paid $" + @parent.payment_amount.to_s )

             	# notify stevek cell that a new parent account was created
                Mymailer.deliver_new_account( "8182617590@txt.att.net", @parent.email,@parent.first_name, 
                                    @parent.last_name, @user.user_type, ", paid $" + @parent.payment_amount.to_s )        

	      		# send parent the welcome email
	         	Mymailer.deliver_welcome( @parent.first_name, @parent.email, @user.login, 
	                 @user.crypted_password, @parent.membership_expires.strftime("%B-%d-%Y") ) # January-05-2009                                            
           end
       else
            format.xml { render :xml =>  log_DB_errors(  "parent", @parent.errors ) }
       end
    end       
end  
 
  # POST forgottenPassword
  # activiate the parent  account following successful registration
  def forgottenPassword 
    
    # note - need to return the parent and user accounts
    begin      
       @users_parents = User.find_by_sql( "SELECT users.* FROM users, parents where users.id = parents.id and parents.email = '#{params[:email]}' " )
      rescue Exception => e  
        log_exception "Error looking for Parent Users email = #{params[:email]}", e
        respond_to do |format|
          format.xml  { render :xml => errorRsp( "Cound not find email address") }
        end
        return
    end

    begin
     @users_students = User.find_by_sql( "SELECT users.* FROM users, students where users.id = students.id and students.email = '#{params[:email]}' " )

      rescue Exception => e  
        log_exception "Error looking for Student Users email = #{params[:email]}", e
        respond_to do |format|
          format.xml  { render :xml => errorRsp( "Cound not find email address") }
        end
        return
    end
    
    @all_users = @users_parents + @users_students
    
    if @all_users.size == 0
      log_message " no users"
        respond_to do |format|
          format.xml  { render :xml => rspWithStatus( "INVALID EMAIL", "No users found for the email address") }
        end       
    else
      respond_to do |format|
        format.xml  { render :xml => successRsp }
      end
      
     if  allowSendEmail  
       Mymailer.deliver_forgotten_password(  params[:email], "guest",  @all_users )
    end
    
    end
  end   
  
# GET /getAllStudentLoginData
  # GET /getAllStudentLoginData
  def getAllStudentLoginData
   
    # load all student login data, topic_activity_summaries, student_assignments, weekly_activity_summaries
    
    if  params[:today] != "" 
    	createInitialWeeklyActivitySummary params[:today]
    end
    
    begin
      @topic_activity_summaries = 
           TopicActivitySummary.find_all_by_student_id_and_grade(params[:id], params[:grade])
           
      @student_assignments = StudentAssignments.find_all_by_student_id(params[:id],  :order => "due ASC",
	        				:conditions => ["due >= ?", Time.now - 3.day ] )

 	  @weekly_activity_summaries = 
          WeeklyActivitySummary.find_all_by_student_id(params[:id], :order=> 'start_of_week' )
          	        				
      rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    
  
	        				
	data = Array.new
	data[0] = Array.new		# add a dummy first ebtry, otherwise the fierst item is not correct, leave it, don't know why	
	data[1] = @student_assignments
	data[2] = @topic_activity_summaries
	data[3] = @weekly_activity_summaries

    respond_to do |format|
      format.xml  { render :xml => data }
    end
  end
  
 
  def createInitialWeeklyActivitySummary today
  
    	# for a student logging in for the first time  create the initial weekly summary
       
       	# the client provides todays date to avoid timezone errors
       	clientDate = Time.parse( today)
       	week = clientDate.strftime("%U").to_i        # the current week, 1 - 51
       	year = clientDate.strftime("%y").to_i        # this year
                 
      	# determine first day of week   ( sunday )            
      	day_of_week = clientDate.strftime("%w")        # 0 - 6   
      	start_of_week = clientDate - day_of_week.to_i.days
  
      	# check if a WeeklyActivitySummary already exists for this week, if not create one
      	begin
        	 weekly_activity_summary = 
            	WeeklyActivitySummary.find_by_student_id_and_week_and_year(params[:id], week, year )
      	rescue Exception => e  
        	log_exception "Error looking for WeeklyActivitySummary :student_id = #{params[:id]}", e
        	respond_to do |format|
          		format.xml  { render :xml => errorRsp( e.message) }
        	end
        	return
      	end
      
      	if weekly_activity_summary == nil 
          # no record found, create a new one
          weekly_activity_summary = WeeklyActivitySummary.new do |t|
             t.student_id = params[:id]     
             t.week =  week 
             t.year =  year
             t.start_of_week = start_of_week
        end 
         
        # now save the record
        if !weekly_activity_summary.save
             log_message "Not saved #{weekly_activity_summary}"
              respond_to do |format|
                  format.xml  { render :xml => errorRsp( weekly_activity_summary.errors.to_s ) }
              end
              return
        end       
    end
  end
  
end


