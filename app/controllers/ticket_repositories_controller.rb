class TicketRepositoriesController < ApplicationController
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

  def ticket_repository_params
    params.require(:ticket_repository).permit(
      :url
    )
  end
end
