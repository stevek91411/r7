class SchoolsController < ApplicationController

  before_filter :login_required

  # GET /schools
  # GET /schools.xml
  def index
  
     if session[:user_type] != "admin-mx"  # basic security trap
       log_error session[:user_type] + " user type found in  request to index"
	   return
  	 end
  	 
  	 @schools = School.find_by_sql( "select * from schools where " +                              
                                    "schools.status like '%#{params[:status]}%'" +                                   
                                    "  order by schools.membership_expires desc limit 50" )
   
   		# get the syudetn in each school
      @schools.each { |i| 
      	i.enrolled_students =   Student.count(:conditions => "school_id  = '#{i.school_id}'").to_s  	     		
      }
      
                                     
    respond_to do |format|
      format.xml  { render :xml => @schools }
    end
  end

  # GET /schools/schoolId.xml
  def show
  
     if session[:user_type] != "admin-mx"  && session[:user_type] != "teacher-tx"# basic security trap
       log_error session[:user_type] + " user type found in  request to show"
	   return
  	 end
  	 
    @school = School.find_by_school_id(params[:id])

     if @school == nil
       log_error "School " + params[:id] + " not found"
	   return
  	 end
  	 
    respond_to do |format|
      format.xml  { render :xml => @school }
    end
  end





  # POST /schools
  # POST /schools.xml
  def create
  
     if session[:user_type] != "admin-mx"  # basic security trap
       log_error session[:user_type] + " user type found in  request to createSchool"
	   return
  	 end
  	 
    @school = School.new(params[:school])

    respond_to do |format|
      if @school.save
        flash[:notice] = 'School was successfully created.'
        format.html { redirect_to(@school) }
        format.xml  { render :xml => @school, :status => :created, :location => @school }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schools/1
  # PUT /schools/updateSchool
  def updateSchool
  
     if session[:user_type] != "admin-mx" &&  session[:user_type] != "teacher-tx" # basic security trap
       log_error session[:user_type] + " user type found in  request to updateSchool"
	   return
  	 end
  	 
    @school = School.find(params[:school][:id])

    respond_to do |format|
      if @school.update_attributes(params[:school])
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
  end

 
end
