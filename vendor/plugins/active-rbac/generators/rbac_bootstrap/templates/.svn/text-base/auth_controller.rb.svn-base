# AuthController provides common authentication related features:
#
# * logging users in and out
# * allowing users to create a new password when they lost it
# * allowing users to register with the system
#
# The controller makes some assumptions on your other controllers and on your
# models:
#
# * You are using acts_as_current_user_container in a super class of 
#   AuthController (required for login/logout)
# * Your User class provides the class method "find_by_credentials" which
#   accepts the login name and the password of a user and returns the User
#   object corresponding to the user. Must return nil if the credentials
#   are invalid (required for login).
class AuthController < ApplicationController
  # On GET, this action displays a form the user can use to log in.
  #
  # On POST, this action tries to authenticate the client with the given 
  # credentials
  #
  # You can pass the parameter ":return_to" to this action for a location to
  # return to if the user could log in with the given credentials.
  # The parameter can be passed in the request parameters or in the session 
  # (session taking priority over request parameter). The action will redirect
  # there if the user clicks no.
  #
  # This value is directly passed to redirect_to so you can either specify a
  # Hash or a string. The string you pass in must start with a "/" and thus be
  # relative to the server root for security reasons. If you violate this, then
  # the user will be redirected to "/".
  #
  # === Interpred Parameters
  #
  # return_to::Where to return to after successful login.
  # user[login]::Login name of the user to find. Will be passed into
  #              User#find_by_credentials as the first parameter.
  # user[password]::Password of the user to find. Will be passed into
  #              User#find_by_credentials as the second parameter.
  #
  # === Flash Entries
  #
  # Sets "flash[:success]" if the login was successful.
  def login
    @return_to = return_to_from_session_or_params(:return_to)
    
    return unless request.post? # Render form on GET et al

    # -- POST request handling -----

    user = User.find_by_credentials(params[:user][:login], params[:user][:password])
    
    if user.nil? then
      # login failed
      @login_failed = true
      @user_login = params[:user][:login]

      render
    else
      # login successful 
      self.current_user = user
      
      flash[:success] = 'You are now logged in.'
      
      redirect_to @return_to
    end
  end

  # On GET, this action displays a form to confirm that he really wants to log
  # out.
  #
  # On POST, this action logs out the user by setting the current user to nil.
  # This will make current_user return an anonymous instance.
  #
  # All other request types will behave like GET requests.
  #
  # You can pass the parameter ":return_to_logout" (or ":return_to_nologout") to
  # this action for a location to return to if the user clicks yes (or no).
  # The parameter can be passed in the request parameters or in the session 
  # (session taking priority over request parameter). The action will redirect
  # there if the user clicks no.
  #
  # This value is directly passed to redirect_to so you can either specify a
  # Hash or a string. The string you pass in must start with a "/" and thus be
  # relative to the server root for security reasons. If you violate this, then
  # the user will be redirected to "/".
  #
  # Redirects to HTTP server root ("/") if no value is specified.
  #
  # The user is considered to having clicked "yes" iff "submit_yes" or 
  # "submit_yes.x" are set.
  #
  # === Interpreted Parameters
  #
  # return_to_logout::Redirection target on logout (see above).
  # return_to_nologout::Redirection target on no logout (see above).
  # submit_yes::Must be set when the user is to be logged out.
  # submit_yes.x::Must be set when the user is to be logged out.
  #
  # === Flash Entries
  #
  # Sets "flash[:success]" if the logout was successful.
  def logout
    return unless request.post? # render on GET et al
    
    # -- POST request handling -----
    
    if params[:submit_yes].nil? and params['submit_yes.x'].nil? then
      # user clicked no
      redirect_to return_to_from_session_or_params(:return_to_nologout)
    else
      # user clicked yes
      self.current_user = nil

      redirect_to return_to_from_session_or_params(:return_to_nologout)
    end
  end

  
  protected
  
    # Returns the given entry from session or request params. The session value
    # takes precendence over the request parameter value if it is not nil.
    #
    # If the entry is a string and does not start with a slash ("/") or both 
    # entries are nil then "/" is returned.
    #
    # === Example
    #
    #   redirect_to return_to_from_sesion_or_params(:return_to)
    def return_to_from_session_or_params(key)
      value = session[key]
      value = params[key] if value.nil?

      value = '/' if value.nil? or (value.kind_of?(String) and value[0] != '/')
      
      return value
    end
end
