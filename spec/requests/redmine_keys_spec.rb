require 'rails_helper'

RSpec.describe "RedmineKeys", type: :request do
  describe "GET /redmine_keys" do
    it "works! (now write some real specs)" do
      get redmine_keys_path
      expect(response).to have_http_status(200)
    end
  end
end
