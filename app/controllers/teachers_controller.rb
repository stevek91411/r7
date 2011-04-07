class TeachersController < ApplicationController
     before_filter :login_required
 
 # GET getStudentsForClass
  def getStudentsForClass 
 
      if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	  end
  	
  	 # check that the issuer of the request has both the username and ID, prevent attack
     teacher = Teacher.find(params[:id]) 
     if params[:school_id].gsub(/ /,'') != teacher.school_id.gsub(/ /,'')
    	log_attack "Error getStudentsForClass " + params[:id] + " : " + params[:school_id]  + " - teacher.school_id = " + teacher.school_id 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "Security error, Mathspert contact support" ) }
      end
    	return
     end
    	  
      begin
        @students = Student.find_by_sql( "select students.*, users.status, users.crypted_password from students, users where " + 
                                    "users.id = students.id  and " +
                                    "users.status = '#{params[:status]}' and " +
                                    "students.class_id  = '#{params[:class_id]}' and " +
                                     "students.school_id  = '#{params[:school_id]}'" +
                                    " order by users.login desc limit 100 " )
    rescue Exception => e  
      log_exception "Error looking for Students", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => @students }
    end
  end
    
 # GET getTeachers
  def getTeachers 
 
      if session[:user_type] != "teacher-tx"  && session[:user_type] != "admin-mx" # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getTeachers"
	   return
  	  end
	  
      begin
        @teachers = Teacher.find_by_sql( "select teachers.*, users.status, users.crypted_password from teachers, users where " + 
                                    "users.id = teachers.id  and users.status != 'deleted' and " +
                                    "teachers.id != '#{params[:exclude_teacher_id]}' and "   +  # don't return the teacher making the query 
                                    "teachers.school_id = '#{params[:school_id]}' "   +                            
                                    " order by users.login desc " )
    rescue Exception => e  
      log_exception "Error looking for Teachers", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => @teachers }
    end
  end
    
    
       
# GET getWeeklyActivityForClass
 def getWeeklyActivityForClass 
 
      if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	  end

 	 # the client provides todays date to avoid timezone errors
      clientDate = Time.parse( params[:today]) - Integer(params[:week_offset]).week
      year = clientDate.strftime("%y").to_i        # this year
      week = clientDate.strftime("%U").to_i        # the current week, 1 - 51
      	  
      begin
        @summaries = WeeklyActivitySummary.find_by_sql( "select weekly_activity_summaries.*, students.*  from students, weekly_activity_summaries where " + 
 									"weekly_activity_summaries.student_id = students.id and " +
                                    "students.school_id = '#{params[:school_id]}'  and " +
                                    "students.class_id = '#{params[:class_id]}'  and " +
                                    "students.status = 'active' and " +
                                    "weekly_activity_summaries.week =  '#{week}' and " +
                                    "weekly_activity_summaries.year =  '#{year}' "  )
    rescue Exception => e  
      log_exception "Error , TeacherController, looking for weekly_activity_summaries", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => @summaries }
    end
  end
  
  
  
 # POST /addTeacher
  def addTeacher
    
    if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	end
  	    
    @user = User.new(params[:user])    
    @user.status = "active"
    @user.user_type = "teacher-tx"
    @user.membership_expires = Time.now + 5.year  # teachers for schools expire if school membership expires  
        
    if !@user.save
        log_DB_errors(  "user", @user.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
       end
       return
    end
     
            
    @teacher = Teacher.new()
    @teacher.login = @user.login
    @teacher.email = params[:user][:teacher][:email]
    @email = @teacher.email
    @teacher.first_name = params[:user][:teacher][:first_name]
    @teacher.last_name =params[:user][:teacher][:last_name]     
    @teacher.telephone_cell =params[:user][:teacher][:telephone_cell]  
    @teacher.telephone_home =params[:user][:teacher][:telephone_home]       
    @teacher.class_id =params[:user][:teacher][:class_id]     
    @teacher.school_id =params[:user][:teacher][:school_id]     
    @teacher.admin=params[:user][:teacher][:admin]
    @teacher.first_registered = Time.now
    @teacher.id = @user.id
    @teacher.membership_expires = @user.membership_expires 
        
     if  allowSendEmail  
      # notify stevek that a new teacher account was created
      log_message "xx= " + @teacher.inspect.gsub( "#<", "" )
   	   Mymailer.deliver_new_school_account(  "teacher", @teacher.school_id, "", @teacher.inspect.gsub( "#<", "" ) )
                           
      if params[:user][:send_welcome_email] == "true"
     	Mymailer.deliver_teacher_welcome( @teacher.first_name, @teacher.email, @user.login, @user.crypted_password  )
      end
                                
                                
     end
    
     if @teacher.save
       respond_to do |format|
          format.xml { render :xml =>  @teacher }
       end  # respond_to
     else
        respond_to do |format|
          format.xml { render :xml =>  log_DB_errors(  "teacher", @teacher.errors ) }
       end
     end    # if @teacher.save     
         
  end
 

    
  # POST /addStudentForSchool
  def addStudentForSchool

     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
     
    user = User.new(params[:user])    
    user.status = "active"
    user.membership_expires = Time.now + 5.year  # students for schools expire id school membership expires  
        
    if !user.save
        log_DB_errors(  "user", user.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", user.errors ) }
       end
       return
    end
           
 
  	# add an inital WeeklyActivitySummary
    clientDate = Time.parse( params[:user][:today])
 	week = clientDate.strftime("%U").to_i        # the current week, 1 - 51
    year = clientDate.strftime("%y").to_i        # this year
                 
    # determine first day of week   ( sunday )            
    day_of_week = clientDate.strftime("%w")        # 0 - 6   
    start_of_week = clientDate - day_of_week.to_i.days
  
      
    # create a first activity summary
    @weekly_activity_summary = WeeklyActivitySummary.new do |t|
             t.student_id = user.id     
             t.week =  week 
             t.year =  year
             t.start_of_week = start_of_week
    end 
         
    # now save the record
    if !@weekly_activity_summary.save
         log_message "Not saved #{@weekly_activity_summary}"
          respond_to do |format|
                  format.xml  { render :xml => errorRsp( @weekly_activity_summary.errors.to_s ) }
          end
          return
     end       
            
    @student = Student.new()
    @student.login = user.login
    @student.email = params[:user][:student][:email]
    @email = @student.email
    @student.first_name = params[:user][:student][:first_name]
    @student.status = "active"
    @student.last_name =params[:user][:student][:last_name]     
    @student.class_id =params[:user][:student][:class_id]     
    @student.school_id =params[:user][:student][:school_id]     
    @student.parent_id  = 0		# a school student   
    @student.grade=params[:user][:student][:grade]
    @student.weekly_target_in_mins=params[:user][:student][:weekly_target_in_mins]
    @student.first_registered = Time.now
    @student.id = user.id
        
     @email =params[:user][:student][:email]
     @first_name = params[:user][:student][:first_name]
     @last_name =params[:user][:student][:last_name]
     if  allowSendEmail  
      # notify stevek that a new student account was created
   	   Mymailer.deliver_new_school_account(  "student", @student.school_id, @student.grade, @student.inspect.gsub( "#<", "" ) )
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
         
  end
 
 

  # GET /teachers/1
  # GET /teachers/1.xml
  def show

     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
  	 
  	 # check that the issuer of the request has both the username and ID, prevent attack
    user = User.find(params[:id]) 
    if params[:login].gsub(/ /,'') != user.login.gsub(/ /,'')
    	log_attack "Error showing teacher " + params[:id] + " : " + params[:login]  + " - user.login = " + user.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "Security error, Mathspert contact support" ) }
      end

    	return
    end
    
    
  	 
    @teacher = Teacher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher }
    end
  end


  # GET /teachers/1/edit
  def edit
    @teacher = Teacher.find(params[:id])
  end

  # POST /teachers
  # POST /teachers.xml
  def create
  
     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
  	 
    @teacher = Teacher.new(params[:teacher])

    respond_to do |format|
      if @teacher.save
        format.xml  { render :xml => @teacher, :status => :created, :location => @teacher }
      else
        format.xml  { render :xml => @teacher.errors, :status => :unprocessable_entity }
      end
    end
  end

 # PUT /teachers/1
  # PUT /deleteTeacher/1.xml
  def deleteTeacher
 
    if session[:user_type] != "teacher-tx"   # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to updateTeacher"
	   return
  	end
 
 	# check that the issuer of the request has both the username and ID, prevent attack
    user = User.find(params[:id]) 
    if params[:login].gsub(/ /,'') != user.login.gsub(/ /,'')
    	log_attack "Error deleting teacher " + params[:id] + " : " + params[:login]  + " - user.login = " + user.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "ATTACK: Error deleting teacher " + params[:id] + " : " + params[:login]) }
      end

    	return
    end
    
    
  	begin
        User.delete( params[:id] )  
        Teacher.delete( params[:id] )  
    rescue Exception => e  
      log_exception "Error deleting teacher", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    	
    respond_to do |format|
        format.xml  { render :xml => successRsp }
      end
  end
  
  
  # PUT /teachers/1
  # PUT /teachers/1.xml
  def updateTeacher
 
   if session[:user_type] != "teacher-tx"   # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to updateTeacher"
	   return
  	end
 
    @teacher = Teacher.find(params[:teacher][:id])

 	# check that the issuer of the request has both the username and ID, prevent attack
    if params[:teacher][:login].gsub(/ /,'') != @teacher.login.gsub(/ /,'')
    	log_attack "Error student teacher " + params[:teacher][:id] + " : " + params[:teacher][:login]  + " - @teacher.login = " + @teacher.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "ATTACK: Error deleting student " + params[:teacher][:id] + " : " + params[:teacher][:login]) }
      end

    	return
    end
    
    
    respond_to do |format|
      if @teacher.update_attributes(params[:teacher])
        format.xml  { render :xml => successRsp }
      else
        format.xml  { render :xml => errorRsp( @teacher.errors.to_s ) }
      end
    end
  end


  # PUT /deleteStudent/1.xml
  def deleteStudent
 
    if session[:user_type] != "teacher-tx"   # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to updateTeacher"
	   return
  	end
 
 	# check that the issuer of the request has both the username and ID, prevent attack
    user = User.find(params[:id]) 
    if params[:login].gsub(/ /,'') != user.login.gsub(/ /,'')
    	log_attack "Error student teacher " + params[:id] + " : " + params[:login]  + " - user.login = " + user.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "ATTACK: Error deleting student " + params[:id] + " : " + params[:login]) }
      end

    	return
    end
     
 
  	begin
        User.delete( params[:id] )  
        Student.delete( params[:id] )  
        StudentAssignments.delete_all(["student_id = ? ", params[:id] ] )       
        
    rescue Exception => e  
      log_exception "Error deleting Student", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    	
    respond_to do |format|
        format.xml  { render :xml => successRsp }
      end
  end
  
  
end
