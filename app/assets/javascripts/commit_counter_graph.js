var create_commit_graph = function(all_commit,own_commit,developer_name){
    var commit_count = [all_commit, own_commit];
    var developer_name = ['その他', developer_name];
    var color = ['#b1d7e8', '#006ab3'];

    // 取得データの一覧
    // developers: 開発者のリスト
    // commit_count: 各開発者のコミット数

    // 取得データサンプル(連携後に消去)
    var developers = ['DeveloperA', 'DeveloperB', 'DeveloperC', 'DeveloperD', '玄葉      条士郎'];
    var commit_count = [38, 56, 103, 11, 82];

    // グラフの色
    var base_color = '#4f81bd';
    var faint_color = '#749ccb';

    // SVG領域の設定
    var width = 960;
    var height = 640;
    var margin = {top: 50, right: 100, bottom: 0, left: 100};

    // SVG領域の描画
    var svg = d3.select('body')
          .append('svg')
          .attr({
            'class': 'commit_counter_graph',
            'width': width,
            'height': height
          });

    /**************/
    /* 描画の実行 */
    /**************/
    drawBarChart();
    
    /******************/
    /* 棒グラフの描画 */
    /******************/
    function drawBarChart() {
      // 棒の最大の高さ
      var bar_max_height = 300;

      // グラフエリアの設定
      svg.append('g')
        .attr({
          'class': 'chart_area',
          'transform': 'translate('+(margin.left)+', '+(margin.top)+')'
        });

      // グラフスケールの調整
      var yScale = d3.scale.linear()
                     .domain([0, d3.max(commit_count)])
                     .range([0, bar_max_height])
                     .nice();
     
     var line = d3.svg.line()
                  .x(function(d) {
                    return d[0];
                  })
                  .y(function(d) {
                    return d[1];
                  });

      svg.select('.chart_area')
        .append('path')
        .transition()
        .duration(1000)
        .each('start', function() {
          d3.select(this)
            .attr({
              'class': 'yaxis',
              'd': line([[100,bar_max_height], [100, 0]]),
              'stroke': '#aaaaaa',
              'stroke-width': 1,
              'opacity': 0
            });
        })
        .attr({
          'opacity': 1
        });

      svg.select('.chart_area')
        .append('path')
        .transition()
        .duration(1000)
        .each('start', function() {
          d3.select(this)
            .attr({
              'class': 'xaxis',
              'd': line([[100,bar_max_height], [100+developers.length*60, bar_max_height]]),
              'stroke': '#aaaaaa',
              'stroke-width': 1,
              'opacity': 0
            });
        })
        .attr({
          'opacity': 1
        });

    };
};
