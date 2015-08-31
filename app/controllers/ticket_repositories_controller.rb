class TicketRepositoriesController < ApplicationController
  def index
    @ticket_repository = TicketRepository.all
  end
  
  # GET /ticket_repositories/new
  def new
    @ticket_repository = TicketRepository.new
  end

  # POST /ticket_repositories/new
  def create
    @ticket_repository = TicketRepository.new(ticket_repository_params)
    if @ticket_repository.save
      redirect_to '/ticket_repositories/new', notice: 'Ticket repository\'s successfully registered.'
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
