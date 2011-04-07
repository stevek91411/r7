class TopicsController < ApplicationController
   
   before_filter :login_required
   
   
  # GET /topics
  # GET /topics.xml
  def index
    @topics = Topic.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
  end

  # POST /topics
  # POST /topics.xml
  # create a new Topic record
  def create
    
     begin
        @topic = Topic.new(params[ "topic" ])    
     rescue Exception => e    
        respond_to do |format|
          format.xml  { render :xml => errorRsp( e.message) }
        end
      return
    end
    
       
    logger.info  log_hash "Topic", @topic.attributes
    
     # noting fatal happened with the 'new'
    respond_to do |format|
      begin 
        if @topic.save
          format.xml  { render :xml => successRsp }
        else
          format.xml  { render :xml => errorRsp( @topic.errors.to_xml ) }
        end
      rescue Exception => e    
        format.xml  { render :xml => errorRsp( "xx-" + e.message ) }
      end
    end
  end

  
  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to(@topic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(topics_url) }
      format.xml  { head :ok }
    end
  end
end
