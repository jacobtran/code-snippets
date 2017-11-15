class OrderPayingsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    order = Order.find(params[:order_id])
    order.pay!
    if order.user.tenant?
      deduct_from_next_month_rent order 
    else
      #process two txn, take money from owner and pay service provider
      txn1 = take_from_owner order
      txn2 = pay_service_provider order
      process_transactions txn1,txn2
    end
    redirect_to orders_path
  end

  private 

  def process_transactions txn1, txn2
    if !txn1.id.nil? || !txn2.id.nil?
      begin 
        Transactions::ProcessTransaction.new(transactions: [txn1,txn2]).process_txn
      rescue => e
        AdminMailer.delay.batch_processing_failed msg
      end
    else
      errors  = (txn1.errors.full_messages+txn2.errors.full_messages).uniq
      redirect_to orders_path, alert: "#{errors.join(",")}"
    end
  end

  def take_from_owner order
    property       = order.incident.property
    owner          = property.user
    expenses       = order.total_amount.to_f
    Transaction.create(user: owner, amount: expenses, txn_type: :debit, process_date: next_business_day)
  end

  def pay_service_provider order
    sp             = order.user
    expenses       = order.total_amount.to_f
    Transaction.create(user: sp, amount: expenses, txn_type: :credit, process_date: next_business_day)
  end

  def deduct_from_next_month_rent order
    renter               = order.user
    property             = order.incident.property
    owner                = property.user
    expenses             = order.total_amount.to_f
    property_lease       = Tenancy.active_lease(renter.id,property.id)
    transaction1         = Transaction.find_next_month_txn_for_user(renter, property_lease)
    transaction1.amount  = transaction.amount - expenses 
    transaction1.save!
    transaction2         = Transaction.find_next_month_txn_for_user(owner, property_lease)
    transaction2.amount  = transaction.amount - expenses 
    transaction2.save!
  end

  def next_business_day 
    day = Date.today
    begin
      day += 1
    end while(day.is_bc_time_off?)
    day
  end

end
