class RedmineKeysController < ApplicationController
  before_action :set_redmine_key, only: [:show, :edit, :update, :destroy]

  # GET /redmine_keys
  # GET /redmine_keys.json
  def index
    @redmine_keys = RedmineKey.all
  end

  # GET /redmine_keys/1
  # GET /redmine_keys/1.json
  def show
  end

  # GET /redmine_keys/new
  def new
    @redmine_key = RedmineKey.new
  end

  # GET /redmine_keys/1/edit
  def edit
  end

  # POST /redmine_keys
  # POST /redmine_keys.json
  def create
    @redmine_key = RedmineKey.new(redmine_key_params)

    respond_to do |format|
      if @redmine_key.save
        format.html { redirect_to @redmine_key, notice: 'Redmine key was successfully created.' }
        format.json { render :show, status: :created, location: @redmine_key }
      else
        format.html { render :new }
        format.json { render json: @redmine_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /redmine_keys/1
  # PATCH/PUT /redmine_keys/1.json
  def update
    respond_to do |format|
      if @redmine_key.update(redmine_key_params)
        format.html { redirect_to @redmine_key, notice: 'Redmine key was successfully updated.' }
        format.json { render :show, status: :ok, location: @redmine_key }
      else
        format.html { render :edit }
        format.json { render json: @redmine_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redmine_keys/1
  # DELETE /redmine_keys/1.json
  def destroy
    @redmine_key.destroy
    respond_to do |format|
      format.html { redirect_to redmine_keys_url, notice: 'Redmine key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_redmine_key
      @redmine_key = RedmineKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def redmine_key_params
      params.require(:redmine_key).permit(
        :ticket_repository_id,
        :login_id,
        :password_digest,
        :api_key
      )
    end
end
