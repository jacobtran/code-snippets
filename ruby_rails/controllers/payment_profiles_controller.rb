class PaymentProfilesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :find_user

  def new
    @payment_profile = PaymentProfile.new
    render 'payment_profiles/pad_agreement_form.html.erb'
  end

  def create
    ops = "N"
    service = PaymentProfiles::CreatePaymentProfile.new(params: payment_profile_params, ops: ops, user: @user)
    if service.call
      @payment_profile  = service.payment_profile
      redirect_to @user, notice: "Payment Profile Created"
    else
      @user 	       = find_user
      @payment_profile = service.payment_profile
      flash[:alert] = "Failed to create payment profile: #{@payment_profile.errors.full_messages}"
      render 'payment_profiles/pad_agreement_form.html.erb'
    end
  end

  def edit
    ops = "M"
  end

  def show
    ops = "Q"
  end


  private

  def find_user
    @user = User.friendly.find params[:user_id]
  end

  def payment_profile_params
    payment_profile_params = params.require(:payment_profile).permit(:profile_type,
                                                                     :account_holder,
                                                                     :billing_address,
                                                                     :billing_city,
                                                                     :billing_province,
                                                                     :billing_postal_code,
                                                                     :billing_phone_number,
                                                                     :institution_number,
                                                                     :branch_number,
                                                                     :account_number,
                                                                     :attachments_attributes => [:id,:payment_profile_id,:image_link])
  end

end
