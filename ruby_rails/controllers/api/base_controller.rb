class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  def authorize
    head :unauthorized unless api_user.present?
  end

  def authorize_tenant_only
    head :unauthorized unless api_user.present? && api_user.tenant?
  end

  def authorize_admin_only
    head :unauthorized unless api_user.present? && api_user.admin?
  end

  def api_user
    User.find_by_api_key(request.headers["HTTP_API_KEY"])
  end

end
