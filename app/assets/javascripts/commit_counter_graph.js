var create_commit_graph = function(all_commit, own_commit, developer_name) {
//var create_comment_graph = function(nodes, links) {
    /* 取得データの一覧 */
    // developers: 開発者のリスト
    // comments: 各開発者のコメント数

    // 取得データサンプル(連携後に消去)
    var developers = ['DeveloperA', 'DeveloperB', 'DeveloperC', 'DeveloperD', '玄葉 条士郎'];
    var comments = [
      [0, 28, 48, 9, 10],
      [19, 0, 38, 23, 10],
      [44, 65, 0, 13, 20],
      [5, 10, 15, 0, 25],
      [9, 59, 8, 23, 33]
    ];

    // グラフの色
    var deep_color = '#ae403d';

    // SVG領域の設定
    var width = 960;
    var height = 540;
    var margin = {top: 50, right: 100, bottom: 0, left: 100};
    var padding = {top: 100, right:0, bottom: 0, left: 100};

    // SVG領域の描画
    var svg = d3.select('body')
          .append('svg')
          .attr({
            'class': 'comment_graph',
            'width': width,
            'height': height
          });

    // イベントの所要時間
    var event_time = 800;

    /**************/
    /* 描画の実行 */
    /**************/
    drawCommentGraph();
    //sortBarChart();

    /******************/
    /* 棒グラフの描画 */
    /******************/
    function drawCommentGraph() {
      // グラフエリアの設定
      svg.append('g')
        .attr({
          'class': 'heat_map',
          'transform': 'translate('+(margin.left)+', '+(margin.top)+')'
        });

      /*
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
              'd': line([[bar_start_x-20, bar_max_height-yScale(getCommitAverage())], [bar_start_x-20+developers.length*60+20, bar_max_height-yScale(getCommitAverage())]]),
              'stroke': '#aaaaaa',
              'stroke-width': 1,
              'stroke-dasharray': 10,
              'opacity': 0
            });
        })
        .attr({
          'opacity': 1
        });

      // 平均値の表示
      svg.select('.chart_area')
        .append('text')
        .transition()
        .duration(event_time)
        .each('start', function() {
          d3.select(this)
            .attr({
              'class': 'average_label',
              'x': bar_start_x-20+developers.length*60+22,
              'y': bar_max_height-yScale(getCommitAverage())-10,
              'font-family': 'sans-serif',
              'font-size': '15px',
              'text-anchor': 'start',
              'dominant-baseline': 'middle',
              'fill': '#777777',
              'opacity': 0
            })
            .text('平均');
        })
        .attr({
          'opacity': 1
        });

      // 同上
      svg.select('.chart_area')
        .append('text')
        .transition()
        .duration(event_time)
        .each('start', function() {
          d3.select(this)
            .attr({
              'class': 'average_label',
              'x': bar_start_x-20+developers.length*60+22,
              'y': bar_max_height-yScale(getCommitAverage())+10,
              'font-family': 'sans-serif',
              'font-size': '15px',
              'text-anchor': 'start',
              'dominant-baseline': 'middle',
              'fill': '#777777',
              'opacity': 0
            })
            .text(getCommitAverage());
        })
        .attr({
          'opacity': 1
        });


      */
      // マスの表示
      for (var j=0; j<comments.length; j++) {
        svg.select('.heat_map')
          .selectAll('.row_'+j)
          .data(comments[j])
          .enter()
          .append('g')
          .attr('class', function(d, i) {
            return 'column_'+i;
          })
          .append('rect')
          .attr('class', 'cell')
          .attr({
            'width': 32,
            'height': 32,
            'x': function(d,i) {
              return padding.left+i*32;
            },
            'y': padding.top+j*32,
            'fill': deep_color,
            'opacity': 1
          });
      }
      /*
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
            return bar_max_height-yScale(d)-10;
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
         }); */
    }; // End drawCommentGraph;

    /********************/
    /* 棒グラフのソート */ 
    /********************/
    /*function sortBarChart() {
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
          /*if (in_order == 0) {
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
          /*else if (in_order == 1) {
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
    /*function getCommitAverage() {
      var avg = 0;

      for (var i=0; i<commit_count.length; i++) {
        avg += commit_count[i];
      }

      avg = avg/commit_count.length;
      return avg.toFixed(1);
    }
    */
};
