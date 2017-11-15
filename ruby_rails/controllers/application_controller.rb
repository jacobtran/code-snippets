class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_user!
    redirect_to new_session_path, notice: "Please sign in" unless user_signed_in?
  end

  #http://stackoverflow.com/questions/9613438/argumenterror-in-activeadmindevisesessionscontrollercreate
  #activeadmin uses sign_in, so change to sign_in_ for custom sign in function
  def sign_in_(user)
    session[:user_id] = user.id
  end

  def user_signed_in?
    session[:user_id].present?
  end
  helper_method :user_signed_in?

  def current_user
    begin
      @current_user ||=  User.find(session[:user_id]) if user_signed_in?
    rescue Exception => e
     @current_user = nil 
     session[:user_id] = nil
    end
  end
  helper_method :current_user

  def set_language(language_id)
    I18n.locale = language_id
    redirect_to current_page
  end
end
