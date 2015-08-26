class RedmineKeysController < ApplicationController
  # GET /redmine_keys/new
  def new
    @redmine_key = RedmineKey.new
  end
end
