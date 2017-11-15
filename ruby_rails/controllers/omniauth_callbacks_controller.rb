class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
      access_token  = request.env["omniauth.auth"]
      data          = access_token.info
      @user         = User.where(:email => data["email"]).first
      if @user
        #todo review, temp
        @user.update_column :provider, access_token.provider 
        @user.update_column :uid, access_token.uid 
        @user.update_column :token, access_token.credentials.token 
        @user.update_column :token_expires_at, Time.at(access_token.credentials.expires_at) 
        sign_in_and_redirect @user, :event => :authentication
      else
        redirect_to root_path
      end
  end
end
