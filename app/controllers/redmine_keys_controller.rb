class RedmineKeysController < ApplicationController
  def new
    @redmine_key = RedmineKey.new
  end

  def create
    redirect_to '/redmine_keys/new'
  end
end
