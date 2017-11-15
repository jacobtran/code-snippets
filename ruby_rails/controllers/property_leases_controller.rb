class PropertyLeasesController < ApplicationController 
  before_action :authenticate_user!
  before_action :find_tenancy

  def new 
   @property_lease = PropertyLease.new 
  end

  def create 
    @property_lease         = PropertyLease.new pl_params
    @property_lease.tenancy = @tenancy
    @property_lease.save 
    redirect_to root_path
  end

  private 

  def find_tenancy 
    @tenancy = Tenancy.find params[:tenancy_id]
  end

  def pl_params 
    params.require(:property_lease).permit(:rent_amount, :start_date, :end_date)
  end

end
