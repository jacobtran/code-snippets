class IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_property, only: [:new,:create]
  before_action :authorize_service_provider, only: [:index]
  before_action :find_incident, only: [:show,:edit,:update]

  def index
    user_type = current_user.user_type_fmt
    if    user_type == UserType.tenant
      @incidents = current_user.reported_incidents.page params[:page]
    elsif user_type == UserType.owner
      @incidents = current_user.properties.map(&:incidents).flatten.page params[:page]
    elsif user_type == UserType.service_provider
      @incidents = Incident.service_providers_incidents(current_user).page params[:page]
    elsif current_user.admin?
      @incidents = Incident.all.page params[:page]
    end
  end

  def new
    @incident = Incident.new
    #@incident.availabilities.build
    @incident.attachments.build
    @incident.property = @property
  end

  def create
    @incident = Incident.new incident_params
    @incident.property = @property
    @incident.user     = current_user
    if @incident.save
      redirect_to incident_path(@incident)
    else
      render :new
    end
  end

  def show
    @incident.restore! if @incident.orders.empty? #redundant check against bad data
    @order    = Order.new
  end

  def edit
  end

  def update
    if @incident.update(incident_params)
      redirect_to incident_path(@incident), notice: "Updated Incident info!"
    else
      render :edit
    end
  end

  private

  def authorize_service_provider
    redirect_to root_url unless current_user.user_type_fmt == UserType.service_provider
  end

  def find_incident
    @incident = Incident.find(params[:id])
  end

  def find_property
    @property = Property.find(params[:property_id])
  end

  def incident_params
    params.require(:incident).permit(:title,
                                     :description,
                                     :incident_date,
                                     :provider_type_id,
                                     :attachments_attributes => [:id,:incident_id,:image_link])
  end

end
