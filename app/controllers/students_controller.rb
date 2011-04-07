class StudentsController < ApplicationController
  
   before_filter :login_required
  
  # GET /students
  # GET /students.xml
  # get all the Active and Inactive Students for a specified parent
  def index
    
    parent_user = User.find( params[:parent_id] )

	# check that the issuer of the request has both the username and ID of the parent, prevent attack
    if params[:parent_login].gsub(/ /,'') != parent_user.login.gsub(/ /,'')
    	log_attack "Student index() for parent " + params[:parent_id] + " : " + params[:parent_login]  + " - parent_user.login = " + parent_user.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "Security error") }
      end
    	return
    end
    
        
    if params[:parent_id] != nil
       @students = Student.find_all_by_parent_id(params[:parent_id], 
           :conditions => { :status => [ "active" ] } )
    end
    
    
    if params[:admin_list] != nil
       @students = Student.find_all_by_status( [ "active", "suspended" ] )
    end
    
    respond_to do |format|
      format.xml  { render :xml => @students }
    end
  end

  # GET /students/1
  # GET /students/1.xml
  # get a single student record
  def show
  

    begin
      @students = Student.find(params[:id])    
      
       	# check that the issuer of the request has both the username and ID, prevent attack
    	if params[:login].gsub(/ /,'') != @students.login.gsub(/ /,'')
    		log_attack "Student show " + params[:id] + " : " + params[:login]  + " - students.login = " + @students.login 	
      		respond_to do |format|
        		format.xml  { render :xml => errorRsp( "Security error, contact support" ) }
     		 end
    		return
    	end  
      rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
    
    respond_to do |format|
      format.xml  { render :xml => @students }
    end
  end

  

  # PUT /students/1
  # PUT /students/1.xml
  def update
    @student = Student.find(params[:student][:id])

 	# check that the issuer of the request has both the username and ID, prevent attack
    if params[:student][:login].gsub(/ /,'') != @student.login.gsub(/ /,'')
    	log_attack "Student update " + params[:student][:id] + " : " + params[:student][:login]  + " - student.login = " + @student.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "ATTACK: Error student update " + params[:student][:id] + " : " + params[:student][:login]) }
      end
    	return
    end
    
    
    respond_to do |format|
      if @student.update_attributes(params[:student])
        format.xml  { render :xml => successRsp }
      else
        log_DB_errors(  "student", @student.errors ) 
        format.xml  { render :xml => errorRsp( @student.errors.to_s ) }
      end
    end
  end


 # PUT /updateStatus
  def updateStatus
    
    # the status value is present in both the user and student record, need to update in both places
    @student = Student.find(params[:id])
    
    
    # check that the issuer of the request has both the username and ID, prevent attack
    if params[:login].gsub(/ /,'') != @student.login.gsub(/ /,'')
    	log_attack "Student updateStatus " + params[:id] + " : " + params[:login]  + " - student.login = " + @student.login 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "ATTACK: Error student updateStatus " + params[:id] + " : " + params[:login]) }
      end
    	return
    end
    
    
    @student.status = params[:status]
    @user = User.find(params[:id])
    @user.status = params[:status]
    
    respond_to do |format|

       if !@user.save
        format.xml  { render :xml => errorRsp( @user.errors.to_s ) }
      end
      
      if @student.save
        format.xml  { render :xml => successRsp }
      else
        format.xml  { render :xml => errorRsp( @student.errors.to_s ) }
      end
    end
  end

  
end
