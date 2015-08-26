require 'rails_helper'

RSpec.describe RedmineController, type: :controller do

  describe "GET #registeration" do
    it "returns http success" do
      get :registeration
      expect(response).to have_http_status(:success)
    end
  end

end
