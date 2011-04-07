class StudentAssignmentsController < ApplicationController

  before_filter :login_required


  # GET /student_assignments/1
  # GET /student_assignments/1.xml		# id is the student ID
  def show
 
 
    begin
    
      if ( params[:due] != "all" && params[:due] != "allFuture" && params[:due] != "student")
      	@student_assignments = StudentAssignments.find_all_by_student_id(params[:id],  :conditions => ["due >= ?", params[:due] ], :order => "due DESC" )
      else
	     if ( params[:due] == "allFuture" )
	      	@student_assignments = StudentAssignments.find_all_by_student_id(params[:id], :limit =>  params[:limit], :order => "due DESC", 
	      						:conditions => ["due >= ?", params[:today] ] )      
	     end
	     
	      if ( params[:due] == "all" )
	        @student_assignments = StudentAssignments.find_all_by_student_id(params[:id],  :limit =>  params[:limit], :order => "due DESC" )
	      end
	  
	      if ( params[:due] == "student" )
	        @student_assignments = StudentAssignments.find_all_by_student_id(params[:id],  :limit =>  params[:limit], :order => "due ASC",
	        				:conditions => ["due >= ?", Time.now - 2.day ])
	      end
	      
	   end
 
    rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
        log_message "failed"
      end
      return
    end
     
    respond_to do |format|
      format.xml  { render :xml => @student_assignments }
    end
  end


  # GET /getStudentsForClassAssignment
  def getStudentsForClassAssignment	# get all StudentAssignments for specified class assignment ID
 
     if session[:user_type] != "teacher-tx"  && session[:user_type] != "parent" # basic security trap
       log_error session[:user_type] + " user type found in  request to getStudentsForClass"
	   return
  	 end
  	  
    begin
      @student_assignments = StudentAssignments.find_all_by_class_assignment_id(params[:class_assignment_id])
 
    rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
        log_message "failed"
      end
      return
    end
     
    respond_to do |format|
      format.xml  { render :xml => @student_assignments }
    end
  end
  
  # POST /student_assignments
  # POST /student_assignments.xml
  def create
 
     if session[:user_type] != "teacher-tx"   && session[:user_type] != "parent" # basic security trap
       log_error session[:user_type] + " user type found in  request to getStudentsForClass"
	   return
  	 end
  	 
    @student_assignment = StudentAssignments.new(params[:student_assignment])

    respond_to do |format|
      if @student_assignment.save
        	format.xml  { render :xml => successRsp( "", "" ) } 
      else
             format.xml { render :xml =>  log_DB_errors(  "student_assignment", @student_assignment.errors ) }
      end
    end
  end


  # PUT /student_assignments/1
  # PUT /student_assignments/1.xml
  def update    
    
    respond_to do |format|
      if StudentAssignments.update(params[:id], :data => params[:data] )
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @student_assignments.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /student_assignments/1
  # DELETE /student_assignments/1.xml
  def destroy
    @student_assignments = StudentAssignments.find(params[:id])
    @student_assignments.destroy

    respond_to do |format|
      format.xml  { head :ok }
    end
  end
end
