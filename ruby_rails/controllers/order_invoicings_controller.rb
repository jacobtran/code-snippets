class OrderInvoicingsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    order                 = Order.find(params[:order_id])
    attachment            = Attachment.new attachment_params
    attachment.attachable = order

    if attachment.save
      order.invoice! order.incident
      redirect_to orders_path
    else
      flash[:alert] = "Sorry, file not uploaded."
      @order = order
      render '/orders/show'
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:image_link)
  end

end
