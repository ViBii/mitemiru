class PortfolioController < ApplicationController
  def index
  end

  def tracker_viewer
    @tracker_info = Hash.new

    @tracker_info[:category] = ['bug', 'feature', 'test']
    gon.tracker_category = @tracker_info[:category]

    @tracker_info[:ticket_num] = [20, 8, 13]
    gon.ticket_num = @tracker_info[:ticket_num]

    @tracker_info[:ticket_num_all] = 0
    for n in @tracker_info[:ticket_num] do
      @tracker_info[:ticket_num_all] += n;
    end

    gon.ticket_num_all = @tracker_info[:ticket_num_all]

    @tracker_info[:developer] = '玄葉 条士郎'
  end
end
