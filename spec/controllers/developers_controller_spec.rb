require 'rails_helper'
RSpec.describe DevelopersController, type: :controller do
=begin
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DevelopersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all developers as @developers" do
      developer = Developer.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:developers)).to eq([developer])
    end
  end

  describe "GET #show" do
    it "assigns the requested developer as @developer" do
      developer = Developer.create! valid_attributes
      get :show, {:id => developer.to_param}, valid_session
      expect(assigns(:developer)).to eq(developer)
    end
  end

  describe "GET #new" do
    it "assigns a new developer as @developer" do
      get :new, {}, valid_session
      expect(assigns(:developer)).to be_a_new(Developer)
    end
  end

  describe "GET #edit" do
    it "assigns the requested developer as @developer" do
      developer = Developer.create! valid_attributes
      get :edit, {:id => developer.to_param}, valid_session
      expect(assigns(:developer)).to eq(developer)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Developer" do
        expect {
          post :create, {:developer => valid_attributes}, valid_session
        }.to change(Developer, :count).by(1)
      end

      it "assigns a newly created developer as @developer" do
        post :create, {:developer => valid_attributes}, valid_session
        expect(assigns(:developer)).to be_a(Developer)
        expect(assigns(:developer)).to be_persisted
      end

      it "redirects to the created developer" do
        post :create, {:developer => valid_attributes}, valid_session
        expect(response).to redirect_to(Developer.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved developer as @developer" do
        post :create, {:developer => invalid_attributes}, valid_session
        expect(assigns(:developer)).to be_a_new(Developer)
      end

      it "re-renders the 'new' template" do
        post :create, {:developer => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested developer" do
        developer = Developer.create! valid_attributes
        put :update, {:id => developer.to_param, :developer => new_attributes}, valid_session
        developer.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested developer as @developer" do
        developer = Developer.create! valid_attributes
        put :update, {:id => developer.to_param, :developer => valid_attributes}, valid_session
        expect(assigns(:developer)).to eq(developer)
      end

      it "redirects to the developer" do
        developer = Developer.create! valid_attributes
        put :update, {:id => developer.to_param, :developer => valid_attributes}, valid_session
        expect(response).to redirect_to(developer)
      end
    end

    context "with invalid params" do
      it "assigns the developer as @developer" do
        developer = Developer.create! valid_attributes
        put :update, {:id => developer.to_param, :developer => invalid_attributes}, valid_session
        expect(assigns(:developer)).to eq(developer)
      end

      it "re-renders the 'edit' template" do
        developer = Developer.create! valid_attributes
        put :update, {:id => developer.to_param, :developer => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested developer" do
      developer = Developer.create! valid_attributes
      expect {
        delete :destroy, {:id => developer.to_param}, valid_session
      }.to change(Developer, :count).by(-1)
    end

    it "redirects to the developers list" do
      developer = Developer.create! valid_attributes
      delete :destroy, {:id => developer.to_param}, valid_session
      expect(response).to redirect_to(developers_url)
    end
  end
=end
end
