class ApplicationController < ActionController::Base
  helper_method :has_admin?

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :include_gon
  before_filter :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  # ハンドリング
  if Rails.env == 'production'
    rescue_from Exception, with: :error500
    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :error404
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up){|u|
      u.permit(:login_id, :password, :password_confirmation)
    }
    devise_parameter_sanitizer.for(:sign_in){|u|
      u.permit(:login_id, :password, :remember_me)
    }
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def error404(e)
    render 'error404', status: 404, formats: [:html]
  end

  def error500(e)
    logger.error [e, *e.backtrace].join("\n")
    render 'error500', status: 500, formats: [:html]
  end

  private
  def include_gon
    gon.controller = params[:controller]
    gon.action     = params[:action]
  end

  def has_admin?
    current_user.login_id == "admin"
  end
end
