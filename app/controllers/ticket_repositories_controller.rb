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
    @ticket_repository = TicketRepository.new
    redirect_to '/ticket_repositories/new', notice: 'Ticket repository\'s successfully registered.' 
  end
end
