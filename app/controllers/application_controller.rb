class ApplicationController < ActionController::Base
  helper_method :has_admin?

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :include_gon
  before_filter :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

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

  private
  def include_gon
    gon.controller = params[:controller]
    gon.action     = params[:action]
  end

  def has_admin?
    current_user.login_id == "admin"
  end
end
