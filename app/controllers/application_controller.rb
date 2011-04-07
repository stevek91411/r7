class ApplicationController < ActionController::Base
  #protect_from_forgery
   helper :all # include all helpers, all the time
  include AuthenticatedSystem
  #before_filter :login_required
  
  $:.push("/whatever")


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '975c2fe3ae7364c463ef35fc6e2f88e6'
  
  @success_update = "<success/>"
  
    def logParams expandThisKey = "" 
    s = "Params = \n" 
    params.each {|key, value| 
    
            if key.to_s.eql? expandThisKey 
              s += log_hash expandThisKey, value
            else 
              s += "    #{key} => #{value}\n"
            end }
    return s
  end
  
  def log_hash hashName, theHash 
    s = "    " + hashName + "\n"  
    theHash.each {|key, value| s += "      #{key} => #{value}\n"}
    return s
  end
  
  def log_DB_errors recordName, saveErrors
    logger.error  recordName + " not saved\n" +  log_hash( "errors", saveErrors )
     s = "<rsp><status>FAIL</status><errors>" 
    saveErrors.each {|key, value| 
              s += "<#{key}>#{value}</#{key}>\n"
            }
     s +=  "</errors></rsp>"
    return   s
  end
  
  def allowSendEmail
    # if testing locally, stop emails by putting  file named 'sendNoEmail' in the directory
    return !FileTest.exist?('C:\stephen\ruby\instantrails\rails_apps\projectM\sendNoEmail')  
  end
  
  def log_exception msg, e=""
    logger.error  msg + " -- " +  e.to_s
  end
  
  def log_message msg
    logger.error msg
  end

  def log_error_send_email msg
    logger.error "**ERROR** " + msg
    
    if  allowSendEmail  
       Mymailer.deliver_logClientError(  "Fatal error",  msg )
    end
    
  end
  
  
  def log_error msg
    logger.error "**ERROR** " + msg
  end

 def log_attack msg
    logger.error "**ATTACK** " + msg
    if  allowSendEmail  
       Mymailer.deliver_logClientError(  "Fatal error",  "**ATTACK** " + msg  )
    end

  end
   
   
  def errorRsp msg=""    
   msg = "<rsp><status>FAIL</status><error>#{msg.sub(/[<>]/, '-')}</error></rsp>"
  end  

  def rspWithStatus status, msg=""
   msg = "<rsp><status>#{status}</status><error>#{msg.sub(/[<>]/, '-')}</error></rsp>"
  end   
  
   def successRsp msg="", id=""
    msg = "<rsp><status>OK</status><msg>#{msg}</msg><id>#{id}</id></rsp>"
    logger.error   msg
  end 
 
end
  
  

  
  module ActiveSupport #:nodoc:
		module CoreExtensions #:nodoc:
			module Hash #:nodoc:
				module Conversions
				# We force :dasherize to be false, since we never want
				# it true. Thanks very much to the reader on the
				# flexiblerails Google Group who suggested this better
				# approach.
				#unless method_defined? :old_to_xml
				#	alias_method :old_to_xml, :to_xml
				#	def to_xml(options = {})
				#		options.merge!(:dasherize => false)
				#		old_to_xml(options)
				#	end
				#end
			end
		end
	
			module Array #:nodoc:
				module Conversions
					# We force :dasherize to be false, since we never want
					# it to be true.
					#unless method_defined? :old_to_xml
					#	alias_method :old_to_xml, :to_xml
					#	def to_xml(options = {})
					#		options.merge!(:dasherize => false)
					#		old_to_xml(options)
					#	end
					#end
				end
			end
		end
	end
	module ActiveRecord #:nodoc:
	module Serialization
		# We force :dasherize to be false, since we never want it to
		# be true.
		#unless method_defined? :old_to_xml
		#	alias_method :old_to_xml, :to_xml
		#	def to_xml(options = {})
		#		options.merge!(:dasherize => false)
		#		old_to_xml(options)
		#	end
		#end
	end
end
