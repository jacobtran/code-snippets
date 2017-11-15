class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_incident

  def create
    expense          = Expense.new expense_params
    expense.user     = current_user
    expense.incident = @incident
    expense.save
    redirect_to incident_path(@incident)
  end

  def destroy
    expense = Expense.find params[:id]
    expense.destroy  if can? :manage, Expense
    redirect_to incident_path(@incident)
  end

  private

  def expense_params
    params.require(:expense).permit(:attachment_attributes => [:id, :expense_id, :image_link] )
  end

  def find_incident
    @incident = Incident.find params[:incident_id]
  end

end
