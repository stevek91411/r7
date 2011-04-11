class TopicActivitySummariesController < ApplicationController
  
    before_filter :login_required
  

  # GET /topic_activity_summaries/1
  # GET /topic_activity_summaries/1.xml
  def show
    
    begin
      @topic_activity_summaries = 
           TopicActivitySummary.find_all_by_student_id_and_grade(params[:id], params[:grade])
      rescue Exception => e    
      respond_to do |format|
        format.xml  { render :xml => errorRsp( e.message) }
      end
      return
    end
	        
    respond_to do |format|
      format.xml  { render :xml => @topic_activity_summaries.to_xml(:dasherize => false) }
    end
  end


 
  
end
