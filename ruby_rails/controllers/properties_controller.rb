class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :find_property, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:show, :edit, :update]
  before_action :authorize_admin_only, only: [:destroy]

  def index
    user_type = current_user.user_type_fmt
    if    user_type == UserType.owner # || user_type == UserType.property_manager
      @properties = current_user.properties
    elsif user_type == UserType.tenant
      @properties = current_user.rentals
    elsif user_type == UserType.service_provider
      @properties = current_user.serviced_properties
    elsif current_user.admin?
      @properties = Property.all.order('updated_at DESC').page params[:page]
    end
  end

  def new
    @property = Property.new
    @property.build_property_profile
    @property.ownerships.build
    @property.tenancies.build
  end

  def create
    @property = Property.new property_params
    if @property.save
      link_to_owner @property, current_user if current_user.owner?
      redirect_to properties_path
    else
      render :new
    end
  end


  def show
    @incidents = @property.incidents.order('updated_at DESC').page params[:page]
  end

  def edit
  end

  def update
    if @property.update(property_params)
      redirect_to properties_path, notice: "Updated Property info!"
    else
      render :edit
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path
  end

  private

  def link_to_owner p, u
    Ownership.create user: u, property: p
  end

  def authorize_admin_only
    redirect_to root_url unless current_user.admin?
  end

  def property_params
    params.require(:property).permit(:property_profile_attributes => [:unit,
                                                                      :address,
                                                                      :city,
                                                                      :province,
                                                                      :order_threshold,
                                                                      :id,
                                                                      :property_id],
                                    :ownerships_attributes => [:id, :user_id, :property_id],
                                    :tenancies_attributes => [:id, :user_id, :property_id])
  end

  def find_property
    @property = Property.find(params[:id])
  end

  def authorize_user
    if !current_user.admin?
      redirect_to root_url, alert: "access denied" unless can? :view, @property
    end
  end
end
