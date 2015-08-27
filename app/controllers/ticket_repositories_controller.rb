class TicketRepositoriesController < ApplicationController
  # GET /ticket_repositories/new
  def new
    @ticket_repository = TicketRepository.new
  end

  # POST /ticket_repositories/new
  def index
    @ticket_repository = TicketRepository.new
    redirect_to '/ticket_repositories/new'
  end
end
