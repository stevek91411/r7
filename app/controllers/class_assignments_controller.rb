class ClassAssignmentsController < ApplicationController

  # GET /classassignments/0.xml		# id is the school id
  def show
 
     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
  	  
    begin
    
      if ( params[:due] != "all"  )
      	@class_assignments = ClassAssignments.find_all_by_school_id_and_assignment_class_id(params[:school_id], params[:class_id],
       	  :conditions => ["due >= ?", params[:due] ], :order => "due DESC" )   	  
      else   
	    @class_assignments = ClassAssignments.find_all_by_school_id_and_assignment_class_id(params[:id],  
	        								params[:class_id], :limit =>  params[:limit], :order => "due DESC" )
	  end
 
    rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
     
    respond_to do |format|
      format.xml  { render :xml => @class_assignments }
    end
  end



  # POST /class_assignments
  # POST /class_assignments.xml
  def create

	if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	end
  
    @class_assignment = ClassAssignments.new(params[:all][:class_assignment])

    if !@class_assignment.save
	    respond_to do |format|
  			format.xml { render :xml =>  log_DB_errors(  "class_assignment", @class_assignment.errors ) }
  			return
      	end
    end
 
    
    # create student_assignment records for each student in the class
    students = Student.find_all_by_school_id_and_class_id(@class_assignment.school_id, @class_assignment.assignment_class_id )
	if (  students != nil )
    	students.each do |student|
          
       		@student_assignment = StudentAssignments.new()
   			@student_assignment.student_login = student.login
      		@student_assignment.student_id = student.id   
       		@student_assignment.student_full_name = student.first_name + " " + student.last_name   
      		@student_assignment.assigned_by = @class_assignment.assignment_class_id
      		@student_assignment.assignment_id = @class_assignment.assignment_id  
      		@student_assignment.worksheet_name = @class_assignment.worksheet_name  
      		@student_assignment.assignment_grade = @class_assignment.assignment_grade
      		@student_assignment.school_id = @class_assignment.school_id
     		@student_assignment.assigned_on = @class_assignment.assigned_on
     		@student_assignment.assigned_by = @class_assignment.assigned_by
     		@student_assignment.assignment_class_id = @class_assignment.assignment_class_id   		
     		@student_assignment.due = @class_assignment.due
      		@student_assignment.status = @class_assignment.status
       		@student_assignment.data = params[:all][:student_assignment_data]
       		@student_assignment.class_assignment_id =  @class_assignment.id
       		
       		begin     		     		
            	@student_assignment.save
            rescue Exception => e  
      			log_exception "Error saving a studentAssignment", e
      			respond_to do |format|
        			format.xml  { render :xml => errorRsp( "Error saving a studentAssignment " + e.message) }
        			return
      			end
      		end
        end    
  	end
  
   	respond_to do |format|
        format.xml  { render :xml => successRsp }
   	end
    	
end



  # PUT /class_assignments/1
  # PUT /class_assignments/1.xml
  def update
    @class_assignments = ClassAssignments.find(params[:id])

    respond_to do |format|
      if @class_assignments.update_attributes(params[:class_assignments])
        flash[:notice] = 'ClassAssignments was successfully updated.'
        format.html { redirect_to(@class_assignments) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @class_assignments.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /class_assignments/1
  # DELETE /class_assignments/1.xml
  def destroy
    @class_assignments = ClassAssignments.find(params[:id])
    @class_assignments.destroy
    StudentAssignments.delete_all(["class_assignment_id = ? ", params[:id] ] )   # delete the corresponding student assignments      
    

    respond_to do |format|
      format.html { redirect_to(class_assignments_url) }
      format.xml  { head :ok }
    end
  end
end
