class TestingController < ApplicationController 
  before_action :authenticate_user!
  before_action :authorize_user

  def index 
    redirect_to root_url
  end

  private 

  def authorize_user
   redirect_to user_omniauth_authorize_path(:google_oauth2) unless (current_user.token && 
                                                                    current_user.uid && 
                                                                    current_user.token_expires_at &&
                                                                    current_user.token_expires_at > Time.now)
  end

end
