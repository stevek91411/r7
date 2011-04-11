class ClassListsController < ApplicationController
 
 
     before_filter :login_required
  

  # GET /class_lists/1
  # GET /class_lists/1.xml
  def show
  
     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
  	   
  #  begin
      @list = 
           ClassList.find_all_by_school_id( params[:id], :order => "grade")
    #  rescue Exception => e    
    #  respond_to do |format|
    #    format.xml  { render :xml => errorRsp( e.message) }
    #  end
    #  return
   # end

    respond_to do |format|
      format.xml  { render :xml => @list, :dasherize => false }
    end
  end
 


# POST /addClass
  def addClass


     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
  	 
 
    @new_class = ClassList.new(params[:class_list])    
        
    if @new_class.save
         respond_to do |format|
          	format.xml { render :xml =>  @new_class, :dasherize => false }
 		end
    else
        log_DB_errors(  "class", @new_class.errors ) 
        respond_to do |format|
           format.xml { render :xml =>  log_DB_errors(  "class", @new_class.errors ) }
       end
       return
    end
  end


  # DELETE /deleteClass
  def deleteClass

     if session[:user_type] != "teacher-tx"  # basic security trap
       log_error session[:user_type] + " user type found in Teacher request to getStudentsForClass"
	   return
  	 end
  	 
    @class_list = ClassList.find(params[:id])
 
  	# check that the issuer of the request has both the class_id and ID, prevent attack   
    if @class_list.class_id != params[:class_id]
    	log_attack "Error  class_list delete " + params[:id] + " : " + params[:class_id]  + " - class_list.class_id = " + @class_list.class_id 	
      respond_to do |format|
        format.xml  { render :xml => errorRsp( "class_list delete " + params[:id] + " : " + params[:class_id]) }
        return
      end
  	end  	   
       
    @class_list.destroy

    respond_to do |format|
        format.xml  { render :xml => successRsp }
    end
  end
end
