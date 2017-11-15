class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:edit]

  def new
    @user      = User.new
    #TODO review
    if current_user.owner?
      @user_type = UserType.where("title ILIKE ?", UserType.tenant).first.id
      @properties = current_user.properties
    elsif current_user.property_manager?
      @user_type = UserType.where("title ILIKE ?", UserType.tenant).first.id
      @properties = current_user.managed_properties
    elsif current_user.admin?
      @user_type = UserType.where("title ILIKE ? OR title ILIKE ?",
                                  UserType.owner,
                                  UserType.property_manager).first.id
      @properties = Property.all
    end
  end

  #admin invites owner/pm
  #owner/pm invites tenant
  def create
    user = User.find_by_email params[:user][:email]
    if user.blank?
      @user = User.create(user_params.merge(guest: true, invitation_token: generate_token))
      link_to_property @user, params[:user][:property_id] unless params[:user][:property_id].blank?
      UsersMailer.delay.invite_new_user current_user, @user
    end
    redirect_to properties_path
  end

  def edit
    @user  = User.find_by_invitation_token(params[:id])
    if @user.blank? #or token expired
      return
    else
      @user.guest = false
      @user.save(validate: false)
      @user.subscribe! if @user.owner? #TODO check
      session[:user_id] = @user.id
      redirect_to edit_user_path(@user)
    end
  end

  private

  def link_to_property (user,property_id)
    if user.tenant?
      Tenancy.create    user_id: user.id, property_id: property_id
    elsif user.owner?
      Ownership.create  user_id: user.id, property_id: property_id
    elsif user.property_manager?
      Management.create user_id: user.id, property_id: property_id
    elsif user.service_provider?
      Servicing.create  user_id: user.id, property_id: property_id
    end
  end

  def generate_token
    SecureRandom.hex+DateTime.now.strftime("%Y%m%d%H%M%S")
  end

  def user_params
    params.require(:user).permit(:first_name,
                                 :last_name,
                                 :email,
                                 :email_confirmation,
                                 :user_type_id)
  end

end
