require "rails_helper"

RSpec.describe RedmineKeysController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/redmine_keys").to route_to("redmine_keys#index")
    end

    it "routes to #new" do
      expect(:get => "/redmine_keys/new").to route_to("redmine_keys#new")
    end

    it "routes to #show" do
      expect(:get => "/redmine_keys/1").to route_to("redmine_keys#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/redmine_keys/1/edit").to route_to("redmine_keys#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/redmine_keys").to route_to("redmine_keys#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/redmine_keys/1").to route_to("redmine_keys#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/redmine_keys/1").to route_to("redmine_keys#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/redmine_keys/1").to route_to("redmine_keys#destroy", :id => "1")
    end

  end
end
