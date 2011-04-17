class AdminsController < ApplicationController
 
  before_filter :login_required
 
 
  def createSchool
 
    if session[:user_type] != "admin-mx"  # basic security trap
       log_error session[:user_type] + " user type found in  request to createSchool"
	   return
  	 end
  	 
  	 
    @user = User.new(params[:data][:user])    
    if @user.save
        self.current_user = @user
    else
        log_DB_errors(  "user", @user.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
       end
       return
    end

    @teacher = Teacher.new(params[:data][:teacher]) 
	@teacher.id = @user.id
    if !@teacher.save
        log_DB_errors(  "teacher", @teacher.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "user", @user.errors ) }
       end
       return
    end
         
   	begin
		@school = School.new(params[:data][:school])
		@school.save
	rescue Exception => exc
	   logger.error("Saving school #{exc.message}")
     	respond_to do |format|
       		format.xml { render :xml =>  errorRsp( "School name not available" ) }
       	end
       	return
	end
  
    respond_to do |format|
          format.xml { render :xml =>  @school }
    end
  end
  
  
  # GET getStudents
  def getStudents       
 
     if session[:user_type] != "admin-mx"  # basic security trap
            log_error session[:user_type] + " user type found in  request to getStudents"
	   return
  	end
  	                            
     begin
        @students = Student.find_by_sql( "select users.status, users.user_type, users.membership_expires, users.crypted_password, students.* from students, users where " + 
                                    "users.id = students.id and " +
                                    "users.status like '%#{params[:status]}%' and " +
                                    "students.#{params[:search_by_field]} like '%#{params[:value]}%'" +
                                    "  order by users.membership_expires desc limit 200" )
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

 # GET getParents
  def getParents  
  
    if session[:user_type] != "admin-mx"  # basic security trap
            log_error session[:user_type] + " user type found in  request to getParents"
	   return
	end
  	
    begin
        @parents = Parent.find_by_sql( "select parents.*, users.status, users.crypted_password from parents, users where " + 
                                    "users.id = parents.id and payment_amount  >= #{params[:fee]} and " + 
                                    "users.status like '%#{params[:status]}%' and " +
                                    "parents.#{params[:search_by_field]} like '%#{params[:value]}%'" +
                                    " order by parents.first_registered desc limit 100 " )
    rescue Exception => e  
      log_exception "Error looking for Parents", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => @parents }
    end
  end

 
  def deleteParent       

    if session[:user_type] != "admin-mx"   # basic security trap
            log_error session[:user_type] + " user type found in  request to deleteParent"
	   return
	end
	                             
    begin
        Parent.delete( params[:id] )  
        User.delete( params[:id] ) 
        
        students = Student.find_all_by_parent_id(params[:id]) 
        if (  students != nil )
          students.each do |student|
            User.delete( student.id )  
            student.destroy
        end
       end        
    rescue Exception => e  
      log_exception "Error deleting parent", e
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
       
    respond_to do |format|
      format.xml  { render :xml => successRsp( "Parents " + params[:id] + " deleted" ) }
    end
  end
 
 
 def activateParent       

	if session[:user_type] != "admin-mx"  # basic security trap
            log_error session[:user_type] + " user type found in  request to activateParent"
	   return
	end

    @parent = Parent.find(params[:id])      
    @user = User.find(params[:id])    
	                               
     															     															      
	@user.membership_expires = params[:expires]
    @user.status = "active"
	@user.save 
	
	@parent.membership_expires = params[:expires]
	     															
    if @parent.save
    
    	# now update the child users accounts
        students = Student.find_all_by_parent_id(params[:id]) 
        if (  students != nil )
          		students.each do |student|
     				user = User.find(student.id)
           	 	    user.membership_expires = params[:expires]
           	 	    @user.status = "active"
            	    user.save
        		end
        end
                                                
    	respond_to do |format|
              format.xml { render :xml => @parent }
        end  # respond_to           
        else
            respond_to do |format|
              format.xml { render :xml =>  log_DB_errors(  "parent", @parent.errors ) }
            end
        end     
	end
	
def coaxParent       

	if session[:user_type] != "admin-mx"  # basic security trap
            log_error session[:user_type] + " user type found in  request to coaxParent"
	   return
	end

    @parent = Parent.find(params[:id])      
    @user = User.find(params[:id])    
	                               
     															     															      
	@user.membership_expires = Time.now + 1.week + 1.day  # 1 weeks free trial 
	@user.save 
	
    @parent.payment_amount = params[:payment_amount]
	@parent.membership_expires = Time.now + 1.week + 1.day  # 1 weeks free trial

	     															
    if @parent.save
    
    	# now update the child users accounts
        students = Student.find_all_by_parent_id(params[:id]) 
        if (  students != nil )
          		students.each do |student|
     				user = User.find(student.id)
           	 	    user.membership_expires = @parent.membership_expires  
            	    user.save
        		end
        end
 
   		MsMailer.coax(  params[:payment_amount],  params[:full_price], @parent.membership_expires.strftime("%B %d"),
   										@parent.email, params[:greeting], 	@user.login, @user.crypted_password ).deliver
                                                
    	respond_to do |format|
              format.xml { render :xml => @parent }
        end  # respond_to           
        else
            respond_to do |format|
              format.xml { render :xml =>  log_DB_errors(  "parent", @parent.errors ) }
            end
        end     
	end
end

    



  
  
  # GET /admins/1
  # GET /admins/1.xml
  def show
  
    if session[:user_type] != "admin-mx"   # basic security trap
            log_error session[:user_type] + " user type found in  request to show"
	   return
	end
	
    @admin = Admin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  # GET /admins/new
  # GET /admins/new.xml
  def new

    MsMailer.logClientError( "ERROR", " Admin..new not available"  ).deliver
  	if true 
  		return 
  	end


    if session[:user_type] != "admin-mx"   # basic security trap
            log_error session[:user_type] + " user type found in  request to new"
	   return
	end
	
    @admin = Admin.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  # POST /admins
  # POST /admins.xml
  def create

   MsMailer.logClientError( "ERROR", " Admin.create not available"  ).deliver
  	if true 
  		return 
  	end
  	  
    if session[:user_type] != "admin-mx"   # basic security trap
            log_error session[:user_type] + " user type found in  request to new"
	   return
	end
	
    @admin = Admin.new(params[:admin])

    respond_to do |format|
      if @admin.save
        flash[:notice] = 'Admin was successfully created.'
        format.html { redirect_to(@admin) }
        format.xml  { render :xml => @admin, :status => :created, :location => @admin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
      end
    end
  end


