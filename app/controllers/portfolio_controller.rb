class PortfolioController < ApplicationController
  def index
  end

  def ticket_digestion
    @tracker_info = Hash.new

    @tracker_info[:category] = ['Bug', 'Feature', 'Test']
    gon.tracker = @tracker_info[:category]

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
