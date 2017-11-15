class ReportingsController < ApplicationController 
  before_action :authenticate_user!

  #TODO in progress
  def index 
    txn_id = 1
    service       = Reportings::GetReport.new(txn_id: txn_id)
    if service.call 
      redirect_to root_path, notice: "Reporting Success"
    else
      redirect_to root_path, alert: "Reporting Failed"
    end
  end

end
