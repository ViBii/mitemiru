
class DatasamplesController < ApplicationController
  include Statsample
  def index
    a = Shorthand.rnorm(10000,50,10)
    g = Graph::Histogram.new(a,bins:20)
    @datasample = Hash.new
    render :text => g.summary
  end
end
