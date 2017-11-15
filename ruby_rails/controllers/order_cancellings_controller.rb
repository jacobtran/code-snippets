class OrderCancellingsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create 
    order = Order.find(params[:order_id])
    order.cancel! order.incident
    send_job_cancellation_notice_to current_user
    redirect_to orders_path
  end

  private 

  def send_job_cancellation_notice_to user
    UsersMailer.delay.sp_cancel_job(user)
  end

end
