var create_commit_graph = function(all_commit,own_commit,developer_name){
    var commit_count = [all_commit, own_commit];
    var developer_name = ['その他', developer_name];
    var color = ['#b1d7e8', '#006ab3'];

    // 取得データの一覧
    // developers: 開発者のリスト
    // commit_count: 各開発者のコミット数

    // 取得データサンプル(連携後に消去)
    var developers = ['DeveloperA', 'DeveloperB', 'DeveloperC', 'DeveloperD', '玄葉      条士郎'];
    var commit_count = [38, 55, 103, 11, 82];

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
      // イベントの所要時間
      var event_time = 800;

      // 棒の描画エリア
      var bar_start_x = 100;

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
     
      // グラフタイトルの表示
      svg.select('.chart_area')
        .append('text')
        .transition()
        .duration(event_time)
        .each('start', function() {
          d3.select(this)
            .attr({
              'class': 'chart_title',
              'x': bar_start_x-50,
              'y': bar_max_height/2,
              'font-family': 'sans-serif',
              'font-size': '20px',
              'text-anchor': 'middle',
              'dominant-baseline': 'middle',
              'writing-mode': 'tb',
              'fill': '#777777',
              'opacity': 0
            })
            .text('コミット数');
        })
        .attr({
          'opacity': 1
        });

      var line = d3.svg.line()
                   .x(function(d) {
                     return d[0];
                   })
                   .y(function(d) {
                     return d[1];
                   });


      // 平均軸の表示
      svg.select('.chart_area')
        .append('path')
        .transition()
        .duration(event_time)
        .each('start', function() {
          d3.select(this)
            .attr({
              'class': 'xaxis',
              'd': line([[bar_start_x-20, bar_max_height-yScale(getCommitAvarage())], [bar_start_x-20+developers.length*60, bar_max_height-yScale(getCommitAvarage())]]),
              'stroke': '#aaaaaa',
              'stroke-width': 1,
              'stroke-dasharray': 10,
              'opacity': 0
            });
        })
        .attr({
          'opacity': 1
        });

      // 棒の表示 
      svg.select('.chart_area')
        .selectAll('.bar')
        .data(commit_count)
        .enter()
        .append('rect')
        .attr('class', '.bar')
        .attr({
          'width': 40,
          'height': 0,
          'x': function(d, i) {
            return bar_start_x+i*60;
          },
          'y': bar_max_height,
          'fill': base_color,
          'opacity': 1
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr({
          'height': function(d, i) {
            return yScale(d);
          },
          'y': function(d, i) {
            return bar_max_height-yScale(d);
          }
        });
        /*
        .transition()
        .delay(event_time)
        .duration(event_time)
        .each('start', function() {
          svg.select('.chart_area')
            .selectAll('.bar')
            .data(commit_count)
            .attr({
              'width': 40,
              'height': 100,
              'x': function(d, i) {
                return i*60;
              },
              'y': 100,
              'fill': 'blue',
              'opacity': 0
            })
        })
        .attr({
          'opacity': 1
        }); */

      // y軸の表示
      svg.select('.chart_area')
         .append('path')
         .transition()
         .duration(event_time)
         .each('start', function() {
           d3.select(this)
             .attr({
               'class': 'yaxis',
               'd': line([[bar_start_x-20, bar_max_height], [bar_start_x-20, 0]]),
               'stroke': '#aaaaaa',
               'stroke-width': 1,
               'opacity': 0
             });
         })
         .attr({
           'opacity': 1
         });

       // x軸の表示
       svg.select('.chart_area')
         .append('path')
         .transition()
         .duration(event_time)
         .each('start', function() {
           d3.select(this)
             .attr({
               'class': 'xaxis',
               'd': line([[bar_start_x-20, bar_max_height], [bar_start_x-20+developers.length*60, bar_max_height]]),
               'stroke': '#aaaaaa',
               'stroke-width': 1,
               'opacity': 0
             });
         })
         .attr({
           'opacity': 1
         });
    };

    /*************/
    /* Utilities */
    /*************/
    
    // コミット数の平均値
    function getCommitAvarage() {
      var avg = 0;

      for (var i=0; i<commit_count.length; i++) {
        avg += commit_count[i];
      }

      avg = avg/commit_count.length;
      return avg.toFixed(1);
    }
    
};
