class TenanciesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner_only

  def new
    @tenancy    = Tenancy.new
    #@tenants    = User.where("invitation_token IS NOT NULL")
    @tenants    = User.where(guest: true)
    @properties = current_user.properties
    @tenancy.property_leases.build
  end

  def create
    @tenancy    = Tenancy.new tenancy_params
    # byebug
    if @tenancy.save
      redirect_to properties_path
    else
      #TODO temp solution
      @tenants    = User.where(guest: true)
      @properties = current_user.properties 
      render :new
    end
  end

  private

  def authorize_owner_only
    redirect_to root_path unless current_user.owner? || current_user.property_manager?
  end

  def tenancy_params
    params.require(:tenancy).permit(:user_id,
                                    :property_id,
                                    :property_leases_attributes => [:id,
                                                                    :tenancy_id,
                                                                    :start_date,
                                                                    :end_date,
                                                                    :rent_amount]
                                    )
  end

end
