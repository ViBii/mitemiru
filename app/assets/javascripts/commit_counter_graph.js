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

    // イベントの所要時間
    var event_time = 800;

    // 棒の描画エリア
    var bar_start_x = 100;

    // 棒の最大の高さ
    var bar_max_height = 300;

    /**************/
    /* 描画の実行 */
    /**************/
    drawBarChart();
    sortBarChart(); 
    /******************/
    /* 棒グラフの描画 */
    /******************/
    function drawBarChart() {
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
              'd': line([[bar_start_x-20, bar_max_height-yScale(getCommitAvarage())], [bar_start_x-20+developers.length*60+20, bar_max_height-yScale(getCommitAvarage())]]),
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
        .attr('class', 'bar')
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

      // 各コミット数の表示
      svg.select('.chart_area')
        .selectAll('.bar_figure')
        .data(commit_count)
        .enter()
        .append('text')
        .attr('class', 'bar_figure')
        .text(function(d) {
          return d;
        })
        .attr({
          'x': function(d, i) {
            return bar_start_x+i*60+20;
          },
          'y': function(d, i) {
            return bar_max_height-yScale(d)-15;
          },
          'font-family': 'sans-serif',
          'font-size': '15px',
          'text-anchor': 'middle',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 0
        })
        .transition()
        .delay(2*event_time)
        .duration(event_time)
        .attr({
          'opacity': 1
        });

      // 開発者名の表示
      svg.select('.chart_area')
        .selectAll('.developer_label')
        .data(developers)
        .enter()
        .append('text')
        .attr('class', 'developer_label')
        .text(function(d) {
          return d;
        })
        .attr({
          'x': function(d, i) {
            return bar_start_x+i*60+20;
          },
          'y': function(d, i) {
            return bar_max_height+10;
          },
          'font-family': 'sans-serif',
          'font-size': '15px',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'writing-mode': 'tb',
          'fill': '#777777',
          'opacity': 0
        })
        .transition()
        .delay(event_time)
        .duration(event_time)
        .attr({
          'opacity': 1
        });

      
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
               'd': line([[bar_start_x-20, bar_max_height], [bar_start_x-20+developers.length*60+20, bar_max_height]]),
               'stroke': '#aaaaaa',
               'stroke-width': 1,
               'opacity': 0
             });
         })
         .attr({
           'opacity': 1
         });
    };

    //
    // 棒グラフのソート 
    //
    function sortBarChart() {
      var button_base_color = ['#4f81bd', '#c0504d'];
      var button_pale_color = ['#99b6d9', '#db9a98'];
      var button_radius = [10, 8];
      var order = ['開発者の登録順', 'コミット数順'];
      var in_order = 0;

      // ソート済みデータの準備
      var swp_commit_count = [];
      var sort_commit_count = [];
      var swp_developers = [];
      var sort_developers = [];
      for (var i=0; i<commit_count.length; i++) {
        swp_commit_count.push(commit_count[i]);
        sort_commit_count.push(commit_count[i]);
        swp_developers.push(developers[i]);
      }

      // コミット数のソート
      sort_commit_count.sort(function(a, b) {
        if (a<b) return -1;
        if (a>b) return 1;
        return 0;
      });

      // 開発者名のソート
      for (var i=0; i<developers.length; i++) {
        for (var j=0; j<developers.length; j++) {
          if (sort_commit_count[i] == swp_commit_count[j]) {
            sort_developers.push(swp_developers[j]);
            swp_commit_count.splice(j,1);
            swp_developers.splice(j,1);
            break;
          }
        }
      }

      // ソート結果の表示
      console.log(commit_count);
      console.log(developers);
      console.log(sort_commit_count);
      console.log(sort_developers);

      // ソートグループの作成
      svg.select('.chart_area')
        .append('g')
        .attr('class', 'sort')
        .attr('transform', 'translate('+(bar_start_x-20+developers.length*60+20)+', '+0+')');

      // テキストの表示
      svg.select('.chart_area')
        .select('.sort')
        .append('text')
        .attr('class', 'function_name')
        .text('Sort')
        .attr({
          'x': 20,
          'y': 0,
          'font-family': 'sans-serif',
          'font-size': '20px',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 0
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr({
          'opacity': 1
        });

      // ボタンの追加
      svg.select('.chart_area')
        .select('.sort')
        .selectAll('.button')
        .data(button_radius)
        .enter()
        .append('circle')
        .attr('class', 'button')
        .attr({
          'cx': 20,
          'cy': 30,
          'r': 0,
          'fill': function(d, i) {
            if (i == 0) {
              return button_pale_color[0];
            } else if (i == 1) {
              return button_base_color[0];
            }
          },
          'opacity': 0
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr({
          'r': function(d, i) {
            return button_radius[i];
          },
          'opacity': 1
        });
      
      // ボタンのマウスイベント
      svg.select('.chart_area')
        .select('.sort')
        .selectAll('.button')
        .on('mouseover', function() {
          svg.select('.chart_area')
            .select('.sort')
            .selectAll('.button')
            .data(button_radius)
            .attr('fill', function(d, i) {
              if (i == 0) {
                return button_pale_color[1];
              } else if (i == 1) {
                return button_base_color[1];
              }
            });
        })
        .on('mouseout', function() {
          svg.select('.chart_area')
            .select('.sort')
            .selectAll('.button')
            .data(button_radius)
            .attr('fill', function(d, i) {
              if (i == 0) {
                return button_pale_color[0];
              } else if (i == 1) {
                return button_base_color[0];
              }
            });
        })
        .on('click', function() {
          in_order = (in_order+1)%order.length;
          svg.select('.chart_area')
            .select('.sort')
            .select('.sort_name')
            .text(order[in_order]);

          /* 開発者の登録順 */
          if (in_order == 0) {
            // 開発者ラベルのソート
            svg.select('.chart_area')
              .selectAll('.developer_label')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d, i) {
                return bar_start_x+i*60+20;
              });

            // 棒グラフのソート
            svg.select('.chart_area')
              .selectAll('.bar')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d, i) {
                return bar_start_x+i*60;
              });

            // コミット数のソート
            svg.select('.chart_area')
              .selectAll('.bar_figure')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d, i) {
                return bar_start_x+i*60+20;
              });

          }
          /* コミット数順 */
          else if (in_order == 1) {
            // 開発者ラベルのソート
            svg.select('.chart_area')
              .selectAll('.developer_label')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d) {
                for (var j=0; j<developers.length; j++) {
                  if (d == sort_developers[j]) {
                    return bar_start_x+(developers.length-1-j)*60+20;
                  }
                }
              });

            // 棒グラフのソート
            svg.select('.chart_area')
              .selectAll('.bar')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d) {
                for (var j=0; j<developers.length; j++) {
                  if (d == sort_developers[j]) {
                    return bar_start_x+(developers.length-1-j)*60;
                  }
                }
              });

            // コミット数のソート
            svg.select('.chart_area')
              .selectAll('.bar_figure')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d) {
                for (var j=0; j<developers.length; j++) {
                  if (d == sort_developers[j]) {
                    return bar_start_x+(developers.length-1-j)*60+20;
                  }
                }
              });
          }
        });

      // ソート順の表示
      svg.select('.chart_area')
        .select('.sort')
        .append('text')
        .attr('class', 'sort_name')
        .text(order[in_order])
        .attr({
          'x': 32,
          'y': 32,
          'font-family': 'sans-serif',
          'font-size': '15px',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 0
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr('opacity', 1);

      
    }; // End sortBarChart();

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
