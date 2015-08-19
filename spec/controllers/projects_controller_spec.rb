require 'rails_helper'
RSpec.describe ProjectsController, type: :controller do
=begin
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProjectsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all projects as @projects" do
      project = Project.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:projects)).to eq([project])
    end
  end

  describe "GET #show" do
    it "assigns the requested project as @project" do
      project = Project.create! valid_attributes
      get :show, {:id => project.to_param}, valid_session
      expect(assigns(:project)).to eq(project)
    end
  end

  describe "GET #new" do
    it "assigns a new project as @project" do
      get :new, {}, valid_session
      expect(assigns(:project)).to be_a_new(Project)
    end
  end

  describe "GET #edit" do
    it "assigns the requested project as @project" do
      project = Project.create! valid_attributes
      get :edit, {:id => project.to_param}, valid_session
      expect(assigns(:project)).to eq(project)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, {:project => valid_attributes}, valid_session
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, {:project => valid_attributes}, valid_session
        expect(assigns(:project)).to be_a(Project)
        expect(assigns(:project)).to be_persisted
      end

      it "redirects to the created project" do
        post :create, {:project => valid_attributes}, valid_session
        expect(response).to redirect_to(Project.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        post :create, {:project => invalid_attributes}, valid_session
        expect(assigns(:project)).to be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        post :create, {:project => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested project" do
        project = Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => new_attributes}, valid_session
        project.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested project as @project" do
        project = Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        expect(assigns(:project)).to eq(project)
      end

      it "redirects to the project" do
        project = Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        expect(response).to redirect_to(project)
      end
    end

    context "with invalid params" do
      it "assigns the project as @project" do
        project = Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => invalid_attributes}, valid_session
        expect(assigns(:project)).to eq(project)
      end

      it "re-renders the 'edit' template" do
        project = Project.create! valid_attributes
        put :update, {:id => project.to_param, :project => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested project" do
      project = Project.create! valid_attributes
      expect {
        delete :destroy, {:id => project.to_param}, valid_session
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      project = Project.create! valid_attributes
      delete :destroy, {:id => project.to_param}, valid_session
      expect(response).to redirect_to(projects_url)
    end
  end
=end
end
