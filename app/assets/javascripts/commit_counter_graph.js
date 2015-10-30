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

    /* コメント数の合計値 */
    var send_comments_sum = [];
    var recieve_comments_sum = [];
    
    for (var i=0; i<developers.length; i++) {
      // 送信コメント数
      send_comments_sum.push(getSum(comments[i]));

      //受信コメント数
      var sum = 0;
      for (var j=0; j<developers.length; j++) {
        sum += comments[j][i];
      }
      recieve_comments_sum.push(sum);
    }

    console.log(send_comments_sum);
    //console.log(recieve_comments_sum);

    var max_comment_num = getMaxCommentNum();
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
    sortHeatMap();

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

      */
      for (var j=0; j<comments.length; j++) {
        // マスの表示
        svg.select('.heat_map')
          .selectAll('.column')
          .data(comments[j])
          .enter()
          .append('g')
          .attr('class', 'row_'+j)
          .append('g')
          .attr('class', function(d, i) {
            return 'column_'+i;
          })
          .append('rect')
          .attr('class', 'cell')
          .attr({
            'width': 31,
            'height': 31,
            'x': function(d,i) {
              return padding.left+i*31;
            },
            'y': padding.top+j*31,
            'fill': deep_color,
            'opacity': function(d) {
              if (d != 0 && max_comment_num != 0) {
                return d/max_comment_num;
              } else {
                return 0;
              }
            }
          });
      }

      /* 境界線の設定 */

      // 線の基本設定表
      var line = d3.svg.line()
                   .x(function(d) {
                     return d[0];
                   })
                   .y(function(d) {
                     return d[1];
                   });

      // 行境界線の表示
      svg.select('.heat_map')
        .selectAll('.row_border')
        .data(developers)
        .enter()
        .append('path')
        .attr('class', function(d, i) {
          return 'row_border_'+i;
        })
        .attr({
          'd': function(d, i) {
            return line([[padding.left+0, padding.top+i*31],[padding.left+developers.length*31, padding.top+i*31]]);
          },
          'stroke': '#aaaaaa',
          'stroke-width': 1,
          'opacity': 1
        });

      // 列境界線の表示
      svg.select('.heat_map')
        .selectAll('.column_border')
        .data(developers)
        .enter()
        .append('path')
        .attr('class', function(d, i) { 
            return 'column_border_'+i;
        })
        .attr({
          'd': function(d, i) {
            return line([[padding.left+i*31, padding.top],[padding.left+i*31, padding.top+developers.length*31]]);
          },
          'stroke': '#aaaaaa',
          'stroke-width': 1,
          'opacity': 1
        });

      var heat_map_edgelines = [
        [[padding.left, padding.top], [padding.left+developers.length*31, padding.top]],
        [[padding.left+developers.length*31, padding.top], [padding.left+developers.length*31, padding.top+developers.length*31]],
        [[padding.left, padding.top+developers.length*31], [padding.left+developers.length*31, padding.top+developers.length*31]],
        [[padding.left, padding.top], [padding.left, padding.top+developers.length*31]]
      ];
      
      // ヒートマップの縁の表示
      svg.select('.heat_map')
        .selectAll('.edge_line')
        .data(heat_map_edgelines)
        .enter()
        .append('path')
        .attr('class', 'edge_line')
        .attr({
          'd': function(d, i) {
            return line(heat_map_edgelines[i])
          },
          'stroke': '#aaaaaa',
          'stroke-width': 1,
          'opacity': 1
        });

      // 開発者名の表示(行)
      svg.select('.heat_map')
        .selectAll('.row_developer_label')
        .data(developers)
        .enter()
        .append('text')
        .attr('class', 'row_developer_label')
        .text(function(d) {
          return d;
        })
        .attr({
          'x': padding.left-10,
          'y': function(d, i) {
            return padding.top+i*31+18;
          },
          'font-family': 'sans-serif',
          'font-size': '15px',
          'text-anchor': 'end',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 1
        });

      // 開発者名の表示(列)
      svg.select('.heat_map')
        .selectAll('.column_developer_label')
        .data(developers)
        .enter()
        .append('text')
        .attr('class', 'column_developer_label')
        .text(function(d) {
          return d;
        })
        .attr({
          'x': function(d, i) {
            return padding.left+i*31+16
          },
          'y': padding.top-10,
          'font-family': 'sans-serif',
          'font-size': '15px',
          'text-anchor': 'end',
          'dominant-baseline': 'middle',
          'writing-mode': 'tb',
          'fill': '#777777',
          'opacity': 1
        });

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
        }); */
    }; // End drawCommentGraph;

    /************************/
    /* ヒートマップのソート */ 
    /************************/
    function sortHeatMap() {
      var button_base_color = ['#4f81bd', '#c0504d'];
      var button_pale_color = ['#99b6d9', '#db9a98'];
      var button_radius = [10, 8];
      var order = ['開発者の登録順', 'コメント数順'];
      var in_order = 0;

      // ソート済みデータの準備
      var swp_send_comments_sum = [];
      var swp_recieve_comments_sum = [];
      var sort_send_comments_sum = [];
      var sort_recieve_comments_sum = [];
      var swp_send_developers = [];
      var swp_recieve_developers = [];
      var sort_send_developers = [];
      var sort_recieve_developers = [];

      // データの準備
      for (var i=0; i<developers.length; i++) {
        //  開発者
        swp_send_developers.push(developers[i]);
        swp_recieve_developers.push(developers[i]);

        // コメント数
        swp_send_comments_sum.push(send_comments_sum[i]);
        swp_recieve_comments_sum.push(recieve_comments_sum[i]);
        sort_send_comments_sum.push(send_comments_sum[i]);
        sort_recieve_comments_sum.push(recieve_comments_sum[i]);
      }

      //console.log(swp_send_developers);
      //console.log(swp_recieve_developers);
      //console.log(swp_send_comments_sum);
      //console.log(swp_recieve_comments_sum);

      // コミット数のソート
      sort_send_comments_sum.sort(function(a, b) {
        if (a<b) return -1;
        if (a>b) return 1;
        return 0;
      });

      sort_recieve_comments_sum.sort(function(a, b) {
        if (a<b) return -1;
        if (a>b) return 1;
        return 0;
      });

      //console.log(sort_send_comments_sum);
      //console.log(sort_recieve_comments_sum);

      /* 開発者名のソート */
      // 送信者
      for (var i=0; i<developers.length; i++) {
        for (var j=0; j<developers.length; j++) {
          if (sort_send_comments_sum[i] == swp_send_comments_sum[j]) {
            sort_send_developers.push(swp_send_developers[j]);
            swp_send_comments_sum.splice(j,1);
            swp_send_developers.splice(j,1);
            break;
          }
        }
      }

      // 受信者
      for (var i=0; i<developers.length; i++) {
        for (var j=0; j<developers.length; j++) {
          if (sort_recieve_comments_sum[i] == swp_recieve_comments_sum[j]) {
            sort_recieve_developers.push(swp_recieve_developers[j]);
            swp_recieve_comments_sum.splice(j,1);
            swp_recieve_developers.splice(j,1);
            break;
          }
        }
      }

      // ソートグループの作成
      svg.select('.heat_map')
        .append('g')
        .attr('class', 'sort')
        .attr('transform', 'translate('+(padding.left+developers.length*31+40)+', '+(padding.top-50)+')');

      // テキストの表示
      svg.select('.heat_map')
        .select('.sort')
        .append('text')
        .attr('class', 'function_name')
        .text('Sort')
        .attr({
          'x': 0,
          'y': 0,
          'font-family': 'sans-serif',
          'font-size': '20px',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 1
        });

      // ボタンの追加
      svg.select('.heat_map')
        .select('.sort')
        .selectAll('.button')
        .data(button_radius)
        .enter()
        .append('circle')
        .attr('class', 'button')
        .attr({
          'cx': 20,
          'cy': 30,
          'r': function(d, i) {
            return button_radius[i];
          },
          'fill': function(d, i) {
            if (i == 0) {
              return button_pale_color[0];
            } else if (i == 1) {
              return button_base_color[0];
            }
          },
          'opacity': 1
        });
      
      // ボタンのマウスイベント
      svg.select('.heat_map')
        .select('.sort')
        .selectAll('.button')
        .on('mouseover', function() {
          svg.select('.heat_map')
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
          svg.select('.heat_map')
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
          svg.select('.heat_map')
            .select('.sort')
            .select('.sort_name')
            .text(order[in_order]);

          if (in_order == 0) {
            /*
            // 開発者ラベルのソート
            svg.select('.chart_area')
              .selectAll('.developer_label')
              .data(developers)
              .transition()
              .duration(event_time)
              .attr('x', function(d, i) {
                return bar_start_x+i*60+20;
              });
            */
            // マスのソート
            for (var i=0; i<developers.length; i++) {
              for (var j=0; j<developers.length; j++) {
                svg.select('.heat_map')
                  .selectAll('.row_'+i)
                  .selectAll('.column_'+j)
                  .select('.cell')
                  .transition()
                  .duration(event_time)
                  .delay(event_time)
                  .attr({
                    'x': function() {
                      return padding.left+j*31;
                    },
                    'y': function() {
                      return padding.top+i*31;
                    }
                  });
              }
            }
            /*
            // マスのソート(行)
            for (var i=0; i<developers.length; i++) {
              svg.select('.heat_map')
                .selectAll('.row_'+i)
                .selectAll('.cell')
                .transition()
                .duration(event_time)
                .attr({
                  'y': function() {
                    return padding.top+i*31;
                  }
                });
            }

            // マスのソート(列)
            for (var i=0; i<developers.length; i++) {
              svg.select('.heat_map')
                .selectAll('.column_'+i)
                .selectAll('.cell')
                .transition()
                .duration(event_time)
                .attr({
                  'x': function() {
                    return padding.top+i*31;
                  }
                });
            } */
          }
          else if (in_order == 1) {
            // マスのソート
            for (var i=0; i<developers.length; i++) {
              for (var j=0; j<developers.length; j++) {
                svg.select('.heat_map')
                  .selectAll('.row_'+i)
                  .selectAll('.column_'+j)
                  .select('.cell')
                  .transition()
                  .duration(event_time)
                  .delay(event_time)
                  .attr({
                    'x': function() {
                      for (var k=0; k<developers.length; k++) {
                        if (recieve_comments_sum[j] == sort_recieve_comments_sum[k]) {
                          return padding.left+(developers.length-1-k)*31;
                        }
                      }
                    },
                    'y': function() {
                      for (var k=0; k<developers.length; k++) {
                        if (send_comments_sum[i] == sort_send_comments_sum[k]) {
                          return padding.top+(developers.length-1-k)*31;
                        }
                      }
                    }
                  });
              }
            }
          }

          /*
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
          } */
        });

      // ソート順の表示
      svg.select('.heat_map')
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
    }; // End sortHeatMap();

    /*************/
    /* Utilities */
    /*************/
    
    // コメント数の最大値
    function getMaxCommentNum() {
      var max = 0;
      for (var i=0; i<comments.length; i++) {
        max = Math.max(max, Math.max.apply(null, comments[i]));
      }
      return max;
    }

    // 合計値の算出
    function getSum(array) {
      var sum = 0;
      for (var i=0; i<array.length; i++) {
        sum += array[i];
      }
      return sum;
    }
};
