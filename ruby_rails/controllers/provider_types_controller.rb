class ProviderTypesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :find_provider_type, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:show, :edit, :update]

  def index
    @provider_types = ProviderType.all
  end

  def new
    @provider_type = ProviderType.new
  end

  def create
    @provider_type = ProviderType.new user_params
    if @provider_type.save
      redirect_to provider_types_path
    else
      render :new
    end
  end

  def edit
    # @provider_type = @property.property_profile
  end

  def update
    if @provider_type.update(user_params)
      redirect_to provider_type_path(@provider_type), notice: "Updated Provider Type info!"
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @provider_type.destroy
    redirect_to provider_types_path
  end

  def user_params
    params.require(:provider_type).permit([:id,:title])
  end

  def find_provider_type
    @provider_type = ProviderType.find(params[:id])
  end

  def authorize_user
    if !current_user.admin?
      redirect_to root_url, alert: "access denied" unless can? :view, @provider_type
    end
  end

end
