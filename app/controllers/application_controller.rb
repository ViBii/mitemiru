class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :include_gon

  private
  def include_gon
    gon.controller = params[:controller]
    gon.action     = params[:action]
  end
end
