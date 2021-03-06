var create_comment_graph = function(nodes, links) {
    /* 取得データの一覧 */
    // developers: 開発者のリスト
    // comments: 各開発者のコメント数

    // 取得データサンプル(連携後に消去)
    //var developers = ['DeveloperA', 'DeveloperB', 'DeveloperC', 'DeveloperD', '玄葉 条士郎'];
    //var comments = [
    //   [0, 28, 48, 11, 10],
    //   [19, 0, 38, 30, 10],
    //   [44, 65, 0, 13, 20],
    //   [5, 10, 15, 0, 25],
    //   [9, 59, 8, 23, 33]
    // ];

    console.log(nodes);
    var developers = nodes;
    var comments   = links;

    // ソート時の交換行と列の保存
    var swp_row = [];
    var swp_column = [];

    // ソート時の転移先
    var rowSortIndex = [];
    var columnSortIndex = [];

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

    var max_comment_num = getMaxCommentNum();
    // グラフの色
    var deep_color = '#ae403d';

    // SVG領域の設定
    var width = 1080;
    var margin = {top: 50, right: 0, bottom: 50, left: Math.max(50, (width/2)-developers.length*16-120)};
    var padding = {top: 100, right:0, bottom: 0, left: 100};
    var height = Math.max(480, developers.length*31+margin.top+margin.bottom+padding.top);

    // イベントの所要時間
    var event_time = 700;

    // SVG領域の描画
    var svg = d3.select("#comments_counter_graph");

    svg.transition()
      .duration(event_time)
      .attr({
        'height': height
      });

    // グラフ描画枠の変形
    svg.select('.frame')
      .transition()
      .duration(event_time)
      .attr({
        'height': height
      });

    // ソートのステータス
    var in_order = 0;

    // 線の基本設定表
    var line = d3.svg.line()
                 .x(function(d) {
                   return d[0];
                 })
                 .y(function(d) {
                   return d[1];
                 });

    /**************/
    /* 描画の実行 */
    /**************/
    drawCommentGraph();
    sortHeatMap();

    /**********************/
    /* ヒートマップの描画 */
    /**********************/
    function drawCommentGraph() {
      // グラフエリアの設定
      svg.append('g')
        .attr({
          'class': 'heat_map',
          'transform': 'translate('+(margin.left)+', '+(margin.top)+')'
        });

      // グラフタイトルの表示
      svg.select('.heat_map')
        .append('text')
        .attr('class', 'title')
        .text('コメント数の送受信数(回)')
        .attr({
          'x': padding.left+developers.length*31+40,
          'y': padding.top-50,
          'font-family': 'sans-serif',
          'font-size': '20px',
          'font-weight': 'bold',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 1
        });


      for (var j=0; j<comments.length; j++) {
        // マスの表示
        svg.select('.heat_map')
          .selectAll('.data')
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

      // マウスイベントの設定関数
      function setMauseEventOnCells(j) {
        svg.select('.heat_map')
          .selectAll('.row_'+j)
          .data(comments[j])
          .on('mouseover', function(d, i) {
            // 背景の表示
            svg.select('.heat_map')
              .append('rect')
              .attr('class', 'text_back')
              .attr({
                'width': 30,
                'height': 18,
                'x': function() {
                  if (in_order == 1) {
                    for (var k=0; k<developers.length; k++) {
                      if (i == swp_column[k]) {
                        return padding.left+(developers.length-1-k)*31+1;
                      }
                    }
                  } else {
                    return padding.left+i*31+1;
                  }
                },
                'y': function() {
                  if (in_order == 1) {
                    for (var k=0; k<developers.length; k++) {
                      if (j == swp_row[k]) {
                        return padding.top+(developers.length-1-k)*31-25;
                      }
                    }
                  } else {
                    return padding.top+j*31-25;
                  }
                },
                'fill': '#000000',
                'opacity': 0.5
              });

            // 矢印の表示
            svg.select('.heat_map')
              .append('path')
              .attr('class', 'arrow')
              .attr({
                'd': function() {
                  if (in_order == 1) {
                    for (var m=0; m<developers.length; m++) {
                      if (i == swp_column[m]) {
                        for (var n=0; n<developers.length; n++) {
                          if (j == swp_row[n]) {
                            return 'M '+(padding.left+(developers.length-1-m)*31+16)+' '+(padding.top+(developers.length-1-n)*31)+
                                   'l 5 -5'+
                                   'l -10 0'+
                                   'l 5 5';
                          }
                        }
                      }
                    }
                  } else {
                    return 'M '+(padding.left+i*31+16)+' '+(padding.top+j*31)+
                           'l 5 -5'+
                           'l -10 0'+
                           'l 5 5';
                  }
                },
                'stroke': '#000000',
                'stroke-width': 1,
                'fill': '#000000',
                'opacity': 0.5
            });

            // コメント数の表示
            svg.select('.heat_map')
              .append('text')
              .attr('class', 'comment_num')
              .text(comments[j][i])
              .attr({
                'x': function() {
                  if (in_order == 1) {
                    for (var k=0; k<developers.length; k++) {
                      if (i == swp_column[k]) {
                        return padding.left+(developers.length-1-k)*31+16;
                      }
                    }
                  } else {
                    return padding.left+i*31+16;
                  }
                },
                'y': function() {
                  if (in_order == 1) {
                    for (var k=0; k<developers.length; k++) {
                      if (j == swp_row[k]) {
                        return padding.top+(developers.length-1-k)*31-15;
                      }
                    }
                  } else {
                    return padding.top+j*31-15;
                  }
                },
                'font-family': 'sans-serif',
                'font-size': '10px',
                'text-anchor': 'middle',
                'dominant-baseline': 'middle',
                'fill': '#ffffff',
                'opacity': 1
              });
          })
          .on('mouseout', function() {
            svg.select('.heat_map')
              .selectAll('.comment_num')
              .remove();

            svg.select('.heat_map')
              .selectAll('.arrow')
              .remove();

            svg.select('.heat_map')
              .selectAll('.text_back')
              .remove();
          });
      }

      // 設定の実行
      for (var j=0; j<developers.length; j++) {
        setMauseEventOnCells(j);
      }

      /* 境界線の設定 */
      // 行境界線の表示
      svg.select('.heat_map')
        .selectAll('.row_border')
        .data(developers)
        .enter()
        .append('path')
        .attr('class', function(d, i) {
          return 'row_border';
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
            return 'column_border';
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

      // 項目名の表示(行)
      svg.select('.heat_map')
        .append('text')
        .attr('class', 'row_term_label')
        .text('送信者')
        .attr({
          'x': padding.left-15,
          'y': padding.top-10,
          'font-family': 'sans-serif',
          'font-size': '10px',
          'text-anchor': 'end',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 1
        });

      // 項目名の表示(列)
      svg.select('.heat_map')
        .append('text')
        .attr('class', 'row_term_label')
        .text('受信者')
        .attr({
          'x': padding.left-10,
          'y': padding.top-15,
          'font-family': 'sans-serif',
          'font-size': '10px',
          'text-anchor': 'end',
          'dominant-baseline': 'middle',
          'writing-mode': 'tb',
          'fill': '#777777',
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

      // 送信コメント数の表示
      svg.select('.heat_map')
        .selectAll('.send_comments_sum_label')
        .data(send_comments_sum)
        .enter()
        .append('text')
        .attr('class', 'send_comments_sum_label')
        .text(function(d) {
          return d;
        })
        .attr({
          'x': padding.left+developers.length*31+5,
          'y': function(d, i) {
            return padding.top+i*31+18;
          },
          'font-family': 'sans-serif',
          'font-size': '10px',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'fill': '#777777',
          'opacity': 1
        });

      // 受信コメント数の表示
      svg.select('.heat_map')
        .selectAll('.recieve_comments_sum_label')
        .data(recieve_comments_sum)
        .enter()
        .append('text')
        .attr('class', 'recieve_comments_sum_label')
        .text(function(d) {
          return d;
        })
        .attr({
          'x': function(d, i) {
            return padding.left+i*31+16
          },
          'y': padding.top+developers.length*31+5,
          'font-family': 'sans-serif',
          'font-size': '10px',
          'text-anchor': 'start',
          'dominant-baseline': 'middle',
          'writing-mode': 'tb',
          'fill': '#777777',
          'opacity': 1
        });
    }; // End drawCommentGraph;

    /************************/
    /* ヒートマップのソート */ 
    /************************/
    function sortHeatMap() {
      var button_base_color = ['#4f81bd', '#c0504d'];
      var button_pale_color = ['#99b6d9', '#db9a98'];
      var button_radius = [10, 8];
      var order = ['開発者の登録順', 'コメント数順'];

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
        // 転移先の初期化
        rowSortIndex.push(i);
        columnSortIndex.push(i);

        //  開発者
        swp_send_developers.push(developers[i]);
        swp_recieve_developers.push(developers[i]);

        // コメント数
        swp_send_comments_sum.push(send_comments_sum[i]);
        swp_recieve_comments_sum.push(recieve_comments_sum[i]);
        sort_send_comments_sum.push(send_comments_sum[i]);
        sort_recieve_comments_sum.push(recieve_comments_sum[i]);
      }

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

      // ソート行列の初期化
      swp_row = [];
      swp_column = [];
      /* 開発者名のソート */
      // 送信者
      for (var i=0; i<developers.length; i++) {
        for (var j=0; j<developers.length; j++) {
          if (sort_send_comments_sum[i] == swp_send_comments_sum[j]) {
            // 転移先の記録(降順)
            rowSortIndex[j] = rowSortIndex.length-1-i;

            sort_send_developers.push(swp_send_developers[j]);
            
            // ソート済みのコメント数は-1とする
            swp_send_comments_sum.splice(j,1,-1);
            swp_send_developers.splice(j,1,-1);
            swp_row.push(j);
            break;
          }
        }
      }

      // 受信者
      for (var i=0; i<developers.length; i++) {
        for (var j=0; j<developers.length; j++) {
          if (sort_recieve_comments_sum[i] == swp_recieve_comments_sum[j]) {
            // 転移先の記録(降順)
            columnSortIndex[j] = columnSortIndex.length-1-i;

            sort_recieve_developers.push(swp_recieve_developers[j]);
            
            // ソート済みのコメント数は-1とする
            swp_recieve_comments_sum.splice(j,1,-1);
            swp_recieve_developers.splice(j,1,-1);
            swp_column.push(j);
            break;
          }
        }
      }

      // ソートグループの作成
      svg.select('.heat_map')
        .append('g')
        .attr('class', 'sort')
        .attr('transform', 'translate('+(padding.left+developers.length*31+40)+', '+(padding.top)+')');

      // テキストの表示
      svg.select('.heat_map')
        .select('.sort')
        .append('text')
        .attr('class', 'function_name')
        .text('Sort')
        .attr({
          'x': 10,
          'y': 10,
          'font-family': 'sans-serif',
          'font-size': '15px',
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
            // 開発者名のソート(行)
            svg.select('.heat_map')
              .selectAll('.row_developer_label')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'y': function(d, i) {
                  return padding.top+i*31+18;
                }
              });

            // 開発者名のソート(列)
            svg.select('.heat_map')
              .selectAll('.column_developer_label')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'x': function(d, i) {
                  return padding.left+i*31+16;
                },
              });

            // マスのソート
            for (var i=0; i<developers.length; i++) {
              for (var j=0; j<developers.length; j++) {
                svg.select('.heat_map')
                  .selectAll('.row_'+i)
                  .selectAll('.column_'+j)
                  .select('.cell')
                  .transition()
                  .duration(2*event_time)
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

            // 行境界線の移動
            svg.select('.heat_map')
              .selectAll('.row_border')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'd': function(d, i) {
                  return line([[padding.left+0, padding.top+i*31],[padding.left+developers.length*31, padding.top+i*31]]);
                }
              });

            // 列境界線の移動
            svg.select('.heat_map')
              .selectAll('.column_border')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'd': function(d, i) {
                  return line([[padding.left+i*31, padding.top],[padding.left+i*31, padding.top+developers.length*31]]);
                }
              });

            // 送信コメント数の移動
            svg.select('.heat_map')
              .selectAll('.send_comments_sum_label')
              .data(send_comments_sum)
              .transition()
              .duration(2*event_time)
              .attr({
                'y': function(d, i) {
                  return padding.top+i*31+18;
                }
              });

              // 受信コメント数の移動
              svg.select('.heat_map')
                .selectAll('.recieve_comments_sum_label')
                .data(recieve_comments_sum)
                .transition()
                .duration(2*event_time)
                .attr({
                  'x': function(d, i) {
                    return padding.left+i*31+16;
                  }
                });
          }
          else if (in_order == 1) {
            // 開発者名のソート(行)
            svg.select('.heat_map')
              .selectAll('.row_developer_label')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'y': function(d, i) {
                  return padding.top+rowSortIndex[i]*31+18;
                }
              });

            // 開発者名の表示(列)
            svg.select('.heat_map')
              .selectAll('.column_developer_label')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'x': function(d, i) {
                  return padding.left+columnSortIndex[i]*31+16;
                }
              });
             

            // マスのソート
            for (var i=0; i<developers.length; i++) {
              for (var j=0; j<developers.length; j++) {
                svg.select('.heat_map')
                  .selectAll('.row_'+i)
                  .selectAll('.column_'+j)
                  .select('.cell')
                  .transition()
                  .duration(2*event_time)
                  .attr({
                    'x': function() {
                      return padding.left+columnSortIndex[j]*31;
                    },
                    'y': function() {
                      return padding.top+rowSortIndex[i]*31;
                    }
                  });
              }
            }

            // 行境界線の移動
            svg.select('.heat_map')
              .selectAll('.row_border')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'd': function(d, i) {
                  return line([[padding.left+0, padding.top+rowSortIndex[i]*31],[padding.left+developers.length*31, padding.top+rowSortIndex[i]*31]]);
                }
              });

            // 列境界線の移動
            svg.select('.heat_map')
              .selectAll('.column_border')
              .data(developers)
              .transition()
              .duration(2*event_time)
              .attr({
                'd': function(d, i) {
                  return line([[padding.left+columnSortIndex[i]*31, padding.top],[padding.left+columnSortIndex[i]*31, padding.top+developers.length*31]]);
                }
              });

            // 送信コメント数の移動
            svg.select('.heat_map')
              .selectAll('.send_comments_sum_label')
              .data(send_comments_sum)
              .transition()
              .duration(2*event_time)
              .attr({
                'y': function(d, i) {
                  return padding.top+rowSortIndex[i]*31+18;
                }
              });

            // 受信コメント数の移動
            svg.select('.heat_map')
              .selectAll('.recieve_comments_sum_label')
              .data(recieve_comments_sum)
              .transition()
              .duration(2*event_time)
              .attr({
                'x': function(d, i) {
                  return padding.left+columnSortIndex[i]*31+16;
                }
              });
          }
        }); // End onClick;

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
