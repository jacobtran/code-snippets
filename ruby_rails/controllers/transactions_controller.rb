class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_property_lease

  def create
    if params[:transaction][:txn_type].to_sym == Transaction.debit_sym #TODO
      @user       = @property_lease.tenant
    else
      @user       = @property_lease.landlord
    end
    service       = Transactions::CreateTransaction.new(params:           transaction_params,
                                                        property_lease:   @property_lease,
                                                        do_send_batch:    params[:do_send_batch],
                                                        user:             @user)
    if service.call
      #transaction  = service.transaction
      #Reports::BeanstreamTxnStatus.new(transaction: transaction).call
      redirect_to :back, notice: "Transaction made"
    else
      redirect_to :back, notice: "Transaction failed"
    end
  end

  def update
    @transaction  = Transaction.find params[:id]
    service       = Transactions::UpdateTransaction.new(transaction:      @transaction,
                                                        params:           transaction_params,
                                                        do_send_batch:    params[:do_send_batch])
    if service.call 
      redirect_to :back, notice: "Update transaction success"
    else
      redirect_to :back, notice: "Update transaction failed"
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:amount,:txn_type,:process_date)
  end

  def find_property_lease
    @property_lease = PropertyLease.find params[:property_lease_id]
  end

end
