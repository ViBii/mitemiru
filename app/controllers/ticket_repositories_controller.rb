class TicketRepositoriesController < ApplicationController
  before_action :set_ticket_repository, only: [:show, :edit, :update, :destroy]
  def index
    @ticket_repositories = TicketRepository.all
  end

  # GET /ticket_repositories/new
  def new
    @ticket_repositories = TicketRepository.new
    @ticket_info = TicketRepository.all
  end

  # POST /ticket_repositories/new
  def create
    @ticket_repositories = TicketRepository.new(ticket_repository_params)
    if @ticket_repositories.save
      redirect_to '/redmine_keys/new', notice: 'Ticket repository URL is successfully registered.'
    else
      redirect_to '/ticket_repositories/new', status: 'Failed to register.'
    end
  end

  def edit
  end

  def show
  end

  def destroy
    @ticket_repository.destroy
    respond_to do |format|
      format.html { redirect_to developers_url, notice: 'ticket_repository was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ticket_repository
    @ticket_repository = TicketRepository.find(params[:id])
  end

  def ticket_repository_params
    params.require(:ticket_repository).permit(
      :url
    )
  end
end
