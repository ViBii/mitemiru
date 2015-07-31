class CompController < ApplicationController
  def index
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.xAxis(:categories => ["開発者A", "開発者B", "開発者C", "開発者D", "開発者E"])
      f.series(:name => "実装ステップ", :yAxis => 0, :data => [14119, 5068, 4985, 3339, 2656])
      f.series(:name => "主体性", :yAxis => 1, :data => [310, 127, 1340, 81, 65])

      f.yAxis [
        {:title => {:text => "実装ステップ", :margin => 70} },
        {:title => {:text => "主体性"}, :opposite => true},
      ]

      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart({:defaultSeriesType=>"column"})
    end
  end
end
