class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  # before_action :allow_admin_only
  before_action :find_attachment, only: [:show, :edit, :update, :destroy]

  def index
    @attachments = Attachment.all
  end

  def show
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new attachment_params
    if @attachment.save
      redirect_to @attachment
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @attachment.update attachment_params
      redirect_to @attachment
    else
      render :edit
    end
  end

  def destroy
    @attachment.destroy
    redirect_to attachments_path
  end

  private

  def allow_admin_only
    redirect_to root_url unless current_user.admin?
  end

  def find_attachment
    @attachment = Attachment.find params[:id]
  end

  def attachment_params
    params.require(:attachment).permit(:image_link)
  end

end
