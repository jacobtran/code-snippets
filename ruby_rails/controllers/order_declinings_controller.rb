class OrderDecliningsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create 
    order = Order.find(params[:order_id])
    order.decline!
    send_job_declining_notice_to order.user
    redirect_to orders_path
  end

  private 

  def send_job_declining_notice_to user
    UsersMailer.delay.owner_decline_job(user)
  end

end
