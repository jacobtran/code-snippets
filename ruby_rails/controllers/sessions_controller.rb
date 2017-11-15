class SessionsController < ApplicationController

  def index
    I18n.locale = params[:language]
    @contact = Contact.new
  end

  def new
  end

  def create
    # render json: params
    user = User.find_by_email params[:email]
    if user && user.authenticate(params[:password])
      # the sign_in method is defined in application controller
      sign_in_(user)

      if user.admin?
        # redirect_to users_path
        redirect_to properties_path
      else
        user_type = user.user_type_fmt

        if user_type == UserType.owner
          @properties = user.properties
          redirect_to properties_path
        elsif user_type == UserType.tenant
          # @property = user.rentals.first ? redirect_to property_path(@property.property_profile.id) : redirect_to root_path
          @property = user.rentals.first
          if @property
            redirect_to property_path(@property)
          else
            redirect_to root_path
          end
        elsif user_type == UserType.service_provider
          redirect_to incidents_path
        else
          redirect_to root_path
        end
      end
    else
      flash[:alert] = "Sorry, wrong email or password."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully."
  end

end
