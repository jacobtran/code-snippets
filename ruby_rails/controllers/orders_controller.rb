class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_concerned_parties, only: [:index, :create, :destroy]
  before_action :find_incident, except: [:index, :show, :destroy]
  before_action :check_order_lock, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]

  def index
    if current_user.admin?
      @orders = Order.all.order("id DESC").page params[:page]
    elsif current_user.user_type_fmt == UserType.service_provider
      @orders =  current_user.orders.order("id DESC").page params[:page]
    elsif current_user.user_type_fmt == UserType.owner
      @orders = Kaminari.paginate_array(get_user_orders(current_user)).page params[:page]
    end
  end

  def create
    @order          = Order.new order_params
    @order.incident = @incident
    @order.user     = current_user
    if @order.save
      send_job_acceptance_email_to current_user
      send_calender_invite_to [@incident.user]
    end
    redirect_to order_path(@order)
  end

  def show
    @order = Order.find(params[:id])
    redirect_to orders_path unless can? :view, @order
  end

  def destroy
    order = Order.find(params[:id])
    order.destroy
    redirect_to orders_path
  end

  private

  def send_job_acceptance_email_to user
    UsersMailer.delay.sp_new_job(user)
  end

  def send_calender_invite_to receivers
      #TODO enter start and end time
      begin
        if current_user.token.present?
          invite = Calender::SendInvite.new(sender: current_user,
                                            start_time: Time.new(2016,10,10), #placeholder
                                            end_time: Time.new(2016,10,11),  #placeholder
                                            invitees: receivers)
          invite.call
        end
      rescue => e
        puts e.message
      end
  end

#  def check_google_login
#    redirect_to user_omniauth_authorize_path(:google_oauth2) unless (current_user.token.present? &&
#                                                                     current_user.uid.present? &&
#                                                                     current_user.token_expires_at.present? &&
#                                                                     current_user.token_expires_at > Time.zone.now)
#
#  end

  def check_order_lock
    ords = @incident.orders
    redirect_to orders_path unless (ords.empty? || ords.inject(true) {|state,ord| state && ord.declined?})
  end

  def get_user_orders(user)
    user.properties.map{|p| p.incidents.map{|i| i.orders}}.flatten.sort_by(&:id).reverse
  end

  def authorize_concerned_parties
    redirect_to root_url if current_user.user_type_fmt == UserType.tenant
  end

  def find_incident
    @incident = Incident.find(params[:incident_id])
  end

  def order_params
    params.require(:order).permit(:comment,
                                  :order_items_attributes    => [:id,:order_id, :amount, :description], 
                                  :availabilities_attributes => [:id,:incident_id,:availability_date,:availability_date_end,:selected],
                                  :attachments_attributes    => [:id,:order_id, :image_link])
  end

end
