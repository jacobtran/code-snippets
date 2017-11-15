class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :find_user, only: [:edit, :update, :show, :destroy]
  before_action :authorize_user, only: [:edit, :update, :show]
  before_action :authorize_admin_only, only: [:index, :destroy]

  def index
    @users = User.all
    @owners            = User.owners
    @tenants           = User.tenants
    @service_providers = User.service_providers
    # @property_managers = User.property_managers
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      send_welcome_email_to @user
      sign_in_(@user)
      if @user.owner? || @user.tenant?
        @user.subscribe! if @user.owner? #TODO check
        redirect_to new_user_payment_profile_path(@user)
      else
        redirect_to root_url
      end
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @user.update(user_params)
      if @user.invitation_token.present?
        redirect_to new_user_payment_profile_path(@user), notice: "Updated User info!"
      else
        redirect_to user_path(@user), notice: "Updated User info!"
      end
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

  def send_welcome_email_to user
    UsersMailer.delay.welcome_new_user(user)
  end

  def authorize_user
    redirect_to root_url unless can? :manage, @user
  end

  def authorize_admin_only
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    #@user = current_user
    #@user  = User.find(params[:id])
    @user  = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name,
                                 :last_name,
                                 :email,
                                 :email_confirmation,
                                 :password,
                                 :password_confirmation,
                                 :user_type_id,
                                 :provider_type_id,
                                 :business_name,
                                 :address,
                                 :phone_number)
  end

end
