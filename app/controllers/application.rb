# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require_dependency 'user'
require_dependency 'role'
require_dependency 'static_permission'
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include AuthenticatedSystem
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '390e1d6248716377e77ed7518595a99e'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def rescue_action(exception)
    exception.is_a?(ActiveRecord::RecordInvalid) ? render_invalid_record(exception.record) : super
  end
  
  def render_invalid_record(record)
    @invalid_record = record 
    respond_to do |format| 
      format.html do 
        render :action => (record.new_record? ? 'new' : 'edit') 
      end 
      format.js do 
        render :update do |page| 
          page.alert @invalid_record.errors.full_messages.join("\n") 
        end 
      end 
    end 
  end
end
