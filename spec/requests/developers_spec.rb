require 'rails_helper'

RSpec.describe "Developers", type: :request do
  describe "GET /developers" do
    it "works! (now write some real specs)" do
      get developers_path
      expect(response).to have_http_status(200)
    end
  end
end
