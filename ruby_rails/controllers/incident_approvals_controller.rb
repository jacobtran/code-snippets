  class IncidentApprovalsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    incident    = Incident.find(params[:incident_id])
    incident.approve!
    redirect_to properties_path
  end

end
