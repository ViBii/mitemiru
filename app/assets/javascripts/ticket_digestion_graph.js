var create_ticket_digestion_graph = function(tracker,ticket_num,ticket_num_all){
    var tracker = tracker;
    var ticket_num = ticket_num;
    var ticket_num_all = ticket_num_all;
   
    // テストデータ(Redmineと連携後に削除)
    var developers = ['DeveloperA', 'DeveloperB', 'DeveloperC', 'DeveloperD', 'DeveloperE'];
    var trackers = ['DESIGN', 'IMPLEMENTATION', 'TEST', 'BUG'];
    var prospect = [
      [30, 10, 20, 10],
      [25, 25, 0, 10],
      [10, 10, 10, 10],
      [10, 15, 20, 25],
      [0, 30, 30, 5]
    ];
    var result = [
      [25, 15, 20, 5],
      [20, 20, 0, 20],
      [30, 5, 5, 10],
      [15, 20, 5, 5],
      [0, 40, 10, 15]
    ];
    var test_prospect_time = [20, 15, 8, 30];
    var test_result_time = [25, 10, 8, 40];
    var test_productivity_data = [89, 105, 72, 90, 100];

    // Concentration: deep > base > pale > faint
    var deep_color = ['#4070aa', '#ae403d', '#8bac46', '#6f568f', '#399bb6', '#f68425'];
    var base_color = ['#4f81bd', '#c0504d', '#9bbb59', '#8064a2', '#4bacc6', '#f79646'];
    var pale_color = ['#749ccb', '#cd7573', '#b1ca7d', '#9a84b5', '#72bed2', '#f9b277'];
    var faint_color = ['#a5bfdd', '#dfa6a5', '#cedead', '#bdaecf', '#a5d6e3', '#fcd7b8'];
    var low_faint_color = ['#cbd9eb', '#eccbca', '#e4ecd1', '#d7cee2', '#cce7ef', '#fef2e9']

    // SVG領域の範囲設定
    var margin = {top: 0, right: 100, bottom: 0, left: 100};
    var width = 960 + margin.right + margin.left;
    var height = 480 + margin.top + margin.bottom;

    var box_width = 240,
        box_height = 240;

    var padding = {top: 10, right: 50, bottom: 10, left: 30};

    var svg = d3.select("body")
                .append("svg")
                .attr("width", width)
                .attr ("height", height);

    var bar_svg;
    var box_circle_svg;
    var circle_svg;
    var base_radius = box_width/4;

    var event_time = 700;

    // 半径の設定(見積もり円グラフ)
    var arc = function(outer_radius, inner_radius) {
      return d3.svg.arc()
               .outerRadius(outer_radius)
               .innerRadius(inner_radius);
    }

    // Piの生成
    var pie = d3.layout.pie()
                .sort(null)
                .value(function(d) {
                  return d;
                });

    // 円グラフの一覧表示
    var drawBoxPiChart = function(id, page_from, emerge_after) {
      // page_from ->
      //   0: 初期表示
      //   1: 拡大円グラフからのReturn

      var result_arc = function(base_radius, inner_radius) {
        return d3.svg.arc()
                 .outerRadius(function(d, i) {
                   if (Math.sqrt(prospect[id][i]/result[id][i]) < 2) {
                     return base_radius*Math.sqrt(prospect[id][i]/result[id][i]);
                   } else {
                     // 最大半径は2倍までに設定
                     return base_radius*2;
                   }
                 })
                 .innerRadius(inner_radius);
      }

      svg.append("g")
        .attr("class", "developer_"+developers[id])
        .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(id%4))+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4))+")")
        // グラフクリック時のイベント
        .on("click", function() {
          // 縮小グラフの削除
          svg.selectAll(".developer_"+developers[id])
          .remove();

          // 拡大グラフの描画
          drawPiChart(id);

          // 他のグラフを削除する
          for (var j=0; j<developers.length; j++) {
            if (j != id) {
              // 見積もりグラフ
              svg.selectAll(".developer_"+developers[j])
                .selectAll("path")
                .transition()
                .duration(event_time)
                .style("fill", "#ededed");

              svg.selectAll(".developer_"+developers[j])
                .transition()
                .delay(event_time)
                .remove();
            }
          }  

          // Returnボタンの表示
          addReturnButton(id,1);

          // 開発者名の表示
          showDeveloperName(id);

          // 凡例の表示
          drawLegend();
        });

        var base_pi = svg.selectAll(".developer_"+developers[id])
                        .selectAll(".pi")
                        .data(pie(prospect[id]))
                        .enter()
                        .append("g")
                        .attr("class", "pi");

        // 見積もり円グラフの作成
        base_pi.append("path")
          .attr("class", "prospect")
          .transition()
          .duration(event_time)
          .delay(emerge_after)
          .each("start", function() {
            d3.select(this)
              .style("fill", "#ededed");
          })
          .attr("d", arc(base_radius, 0))
          .style("fill", function(d,i) {
            return pale_color[i];
          });
   
        // 実績円グラフの生成
        base_pi.append("path")
          .attr("class", "result")
          .transition()
          .duration(event_time)
          .delay(emerge_after)
          .each("start", function() {
            d3.select(this)
              .style("fill", "#ededed");
          })
          .attr("d", result_arc(base_radius, 0))
          .style("fill", function(d,i) {
            return base_color[i];
          });
    };

    //
    // 拡大円グラフの作成
    //
    var drawPiChart = function(id) {
      // 実績円グラフの半径設定
      var result_arc = function(base_radius, inner_radius) {
        return d3.svg.arc()
                 .outerRadius(function(d, i) {
                   if (Math.sqrt(prospect[id][i]/result[id][i]) < 2) {
                     return base_radius*Math.sqrt(prospect[id][i]/result[id][i]);
                   } else {
                     // 最大半径は2倍までに設定
                     return base_radius*2;
                   }
                 })
                 .innerRadius(inner_radius);
      }

      // 扇形の設定
      var pie = d3.layout.pie()
                  .sort(null)
                  .value(function(d) {
                    return d;
                  });
   
         
      // 拡大円グラフの基本クラス
      svg.append("g")
        .attr("class", "developer_"+developers[id])
        .append("g")
        .attr("class", "event_circle")
        .transition()
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(id%4))+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4))+")");
        })
        .attr("transform", "translate("+(margin.left+(width/4))+", "+(margin.top+(height/2))+")")
        .each("end", function() {
        });     

      // Zoomイベント用Piのクラス設定
      var zoom_event_pi = svg.selectAll(".developer_"+developers[id])
                      .selectAll(".event_circle")
                      .selectAll(".pi")
                      .data(pie(prospect[id]))
                      .enter()
                      .append("g")
                      .attr("class", "pi");
     
      // Zoomイベント用見積もり円グラフの作成
      zoom_event_pi.append("path")
        .attr("class", "prospect")
        .attr("d", arc(base_radius, 0))
        .style("fill", function(d,i) {
          return pale_color[i];
        })
        .transition()
        .delay(event_time)
        .duration(event_time)
        .ease("bounce")
        .attr("d", arc(2*base_radius, 0));

      // Zoomイベント用実績円グラフの作成
      zoom_event_pi.append("path")
        .attr("class", "result")
        .attr("d", result_arc(base_radius, 0))
        .style("fill", function(d,i) {
          return base_color[i];
        })
        .transition()
        .delay(event_time)
        .duration(event_time)
        .ease("bounce")
        .attr("d", result_arc(2*base_radius, 0));

      // Zoomイベント用円グラフの削除
      svg.select(".developer_"+developers[id])
        .select(".event_circle")
        .transition()
        .delay(2*event_time)
        .remove();

      // 操作用円グラフの作成
      var base_pi = svg.selectAll(".developer_"+developers[id])
                      .append("g")
                      .attr("class", "circle")
                      .attr("transform", "translate("+(margin.left+(width/4))+", "+(margin.top+(height/2))+")")
                      .selectAll(".pi")
                      .data(pie(prospect[id]))
                      .enter()
                      .append("g")
                      .attr("class", "pi");
     
      // 操作用見積もり円グラフの作成
      base_pi.append("path")
        .attr("class", "prospect")
        .style("fill", function(d,i) {
          return pale_color[i];
        })
        .transition()
        .delay(2*event_time)
        .attr("d", arc(2*base_radius, 0));

      // 操作用実績円グラフの作成
      base_pi.append("path")
        .attr("class", "result")
        .style("fill", function(d,i) {
          return base_color[i];
        })
        .transition()
        .delay(2*event_time)
        .attr("d", result_arc(2*base_radius, 0));

      // 操作用円グラフのマウスイベント
      svg.selectAll(".developer_"+developers[id])
        .selectAll(".circle")
        .selectAll(".pi")
        .data(trackers)
        .on("mouseover", function(d,i) {
          //console.log("Mouseover "+i);
          highlight(i);
          displayInfo(i);
        })
        .on("mouseout", function(d,i) {
          //console.log("Mouseout "+i)
          normalize();
        })
        .on("click", function(d,i) {
          //console.log("Click "+i);
        });

      //
      // ハイライト
      //
      var highlight = function(mouse_over) {
        // グラフのハイライト
        var highlight_pi = svg.selectAll(".developer_"+developers[id])
                      .selectAll(".circle")
                      .selectAll(".pi")
                      .data(trackers);
       
        highlight_pi.select(".prospect")
          .style("fill", function(d, i) {
            if (i != mouse_over) {
              return low_faint_color[i];
            } else {
              return pale_color[i];
            }
          });

        highlight_pi.select(".result")
          .style("fill", function(d, i) {
            if (i != mouse_over) {
              return faint_color[i];
            } else {
              return base_color[i];
            }
          });

        // 凡例のハイライト
        for (var i=0; i<trackers.length; i++) {
          svg.selectAll(".legend")
            .selectAll(".tracker_"+i)
            .selectAll(".prospect")
            .attr("fill", function() {
              if (mouse_over == i) {
                return pale_color[i];
              } else {
                return low_faint_color[i];
              }
            });

          svg.selectAll(".legend")
            .selectAll(".tracker_"+i)
            .selectAll(".result")
            .attr("fill", function() {
              if (mouse_over == i) {
                return base_color[i];
              } else {
                return faint_color[i];
              }
            });

          svg.selectAll(".legend")
            .selectAll(".tracker_"+i)
            .select(".label")
            .attr("fill", function() {
              if (mouse_over == i) {
                return "#777777";
              } else {
                return "#aaaaaa";
              }
            });
        }
      };

      //
      // 工数情報の表示
      // 
      var displayInfo = function(tracker_id) {
        var info_list = svg.select(".developer_"+developers[id])
              .select(".circle")
              .selectAll(".pi")
              .append("g")
              .attr("class", "info");

        // 背景の設定
        info_list.append("rect")
             .attr("x", 0)
             .attr("width", 140)
             .attr("y", 0)
             .attr("height", 60)
             .attr("transform", "translate(-75, -32)")
             .attr("fill", faint_color[tracker_id])
             .attr("opacity", "0.1");
        

        // 見積もり工数
        info_list.append("text")
          .text("見積もり:")
          .attr("transform", "translate(-2, -20)")
          .attr("text-anchor", "end");
       
        info_list.append("text")
          .text(prospect[id][tracker_id].toFixed(1)+"h")
          .attr("transform", "translate(2, -20)")
          .attr("text-anchor", "start");

        // 実績工数
        info_list.append("text")
          .text("実績:")
          .attr("transform", "translate(-2, 0)")
          .attr("text-anchor", "end");
        
        info_list.append("text")
          .text(result[id][tracker_id].toFixed(1)+"h")
          .attr("transform", "translate(2,0)")
          .attr("text-anchor", "start");

        // 生産性
        info_list.append("text")
          .text("生産性:")
          .attr("transform", "translate(-2, 20)")
          .attr("text-anchor", "end");

        info_list.append("text")
          .text(Math.round(100*(prospect[id][tracker_id]/result[id][tracker_id]))+"%")
          .attr("transform", "translate(2, 20)")
          .attr("text-anchor", "start");

        // テキストの共通設定
        info_list.selectAll("text")
          .attr("font-family", "sans-serif")
          .attr("font-size", "15px")
          .attr("dominant-baseline", "middle")
          .attr("fill", "#ffffff");
      };

      // 通常化
      var normalize = function() {
        // 円グラフの通常化
        var normal_pi = svg.selectAll(".developer_"+developers[id])
                         .selectAll(".circle")
                         .selectAll(".pi")
                         .data(trackers);
       
        normal_pi.select(".prospect")
          .style("fill", function(d,i) {
            return pale_color[i];
          });
        
        normal_pi.select(".result")
          .style("fill", function(d,i) {
            return base_color[i];
          });

        // 凡例の通常化
        for (var i=0; i<trackers.length; i++) {
          svg.selectAll(".legend")
            .selectAll(".tracker_"+i)
            .selectAll(".prospect")
            .attr("fill", function() {
              return pale_color[i];
            });

          svg.selectAll(".legend")
            .selectAll(".tracker_"+i)
            .selectAll(".result")
            .attr("fill", function() {
              return base_color[i];
            });

          svg.selectAll(".legend")
            .selectAll(".tracker_"+i)
            .select(".label")
            .attr("fill", function() {
              return "#777777";
            });
        }

        svg.selectAll(".developer_"+developers[id])
          .selectAll(".info")
          .remove();
      };
    };

    //
    // 凡例の表示
    //
    var drawLegend = function() {
      svg.append("g")
        .attr("class", "legend");

      svg.selectAll(".legend")
        .selectAll("tracker_id")
        .data(trackers)
        .enter()
        .append("g")
        .attr("class", function(d,i) {
          return "tracker_"+i;
        });

      // 凡例の一覧表示
      for (var i=0; i<trackers.length; i++) {
        svg.selectAll(".legend")
          .selectAll(".tracker_"+i)
          .append("rect")
          .attr("class", "prospect")
          .transition()
          .duration(event_time)
          .delay(event_time)
          .each("start", function() {
            d3.select(this)
              .attr({
                fill: "#ededed"
              });
          })
          .attr({
            x: margin.left+600,
            y: margin.top+100+(i*30),
            width: 20,
            height: 20,
            fill: pale_color[i]
          });

        svg.selectAll(".legend")
          .selectAll(".tracker_"+i)
          .append("rect")
          .attr("class", "result")
          .transition()
          .duration(event_time)
          .delay(event_time)
          .each("start", function() {
            d3.select(this)
              .attr({
                fill: "#ededed"
              });
          })
          .attr({
            x: margin.left+600+2,
            y: margin.top+100+(i*30)+2,
            width: 16,
            height: 16,
            fill: base_color[i]
          });

        svg.selectAll(".legend")
          .selectAll(".tracker_"+i)
          .append("text")
          .attr("class", "label")
          .transition()
          .duration(event_time)
          .delay(event_time)
          .each("start", function() {
          d3.select(this)
            .attr({
              fill: "#ededed"
            });
          })
          .text(trackers[i])
          .attr("x", margin.left+600+25)
          .attr("y", margin.top+100+(i*30)+10)
          .attr("font-family", "sans-serif")
          .attr("font-size", "30px")
          .attr("text-anchor", "start")
          .attr("dominant-baseline", "middle")
          .attr("fill", "#777777");
      }
    }

    //
    // 開発者名の表示
    //
    var showDeveloperName = function(developer_id) {
      svg.append("g")
        .attr("class", "developer_name")
        .append("text")
        .transition()
        .duration(event_time)
        .delay(event_time)
        .each("start", function() {
        d3.select(this)
          .attr({
            fill: "#ededed"
          });
        })
        .text(developers[developer_id])
        .attr("x", margin.left+600)
        .attr("y", margin.top+70+10)
        .attr("font-family", "sans-serif")
        .attr("font-size", "30px")
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("fill", "#777777");
    }

    //
    // Returnボタンの追加
    //
    var addReturnButton = function(id, page_from) {
      var mark_default_colors = ['#99b6d9', '#4f81bd'];
      var mark_event_colors = ['#db9a98', '#c0504d'];
      var mark_radius = [10, 8];

      return_button = svg.append("g")
                        .attr("class", "return_button")
                        .attr("transform", "translate("+(margin.left)+", "+(margin.top)+")");

      // マークの追加
      svg.selectAll(".return_button")
        .selectAll(".mark")
        .data(mark_default_colors)
        .enter()
        .append("g")
        .attr("class", "mark")
        .append("circle")
        .transition()
        .duration(event_time)
        .delay(event_time)
        .each("start", function() {
          d3.select(this)
            .attr({
              cx: 10,
              cy: 10,
              r: 0,
              fill: "#ededed"
            });
        })
        .attr({
          r: function(d,i) {
            return mark_radius[i];
          },
          fill: function(d,i) {
            return mark_default_colors[i];
          }
        });
        
      // テキストの表示
      svg.selectAll(".return_button")
        .append("text")
        .attr("class", "label")
        .transition()
        .duration(event_time)
        .delay(event_time)
        .each("start", function() {
          d3.select(this)
            .attr({
              fill: "#ededed"
            });
        })
        .text("Return")
        .attr("x", 25)
        .attr("y", 12)
        .attr("font-family", "sans-serif")
        .attr("font-size", "15px")
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("fill", "#777777");

      // マウスイベント
      svg.selectAll(".return_button")
        .selectAll(".mark")
        // マウスオーバー時
        .on("mouseover", function() {
           svg.selectAll(".return_button")
             .selectAll(".mark")
             .data(mark_default_colors)
             .select("circle")
             .transition()
             .attr("fill", function(d,i) {
               return mark_event_colors[i];
             });
        })
        .on("mouseout", function() {
         svg.selectAll(".return_button")
            .selectAll(".mark")
            .data(mark_event_colors)
            .select("circle")
            .transition()
            .attr("fill", function(d,i) {
              return mark_default_colors[i];
            });
        })
        // クリック時
        .on("click", function() {
          console.log("onClick");

          // 円グラフの半径の設定(実績グラフ)
          var result_arc = function(base_radius, inner_radius) {
            return d3.svg.arc()
                     .outerRadius(function(d, i) {
                       if (Math.sqrt(prospect[id][i]/result[id][i]) < 2) {
                         return base_radius*Math.sqrt(prospect[id][i]/result[id][i]);
                       } else {
                         // 最大半径は2倍までに設定
                         return base_radius*2;
                       }
                     })
                     .innerRadius(inner_radius);
          }

          // イベント用円グラフの生成
          var base_pi = svg.selectAll(".developer_"+developers[id])
                      .append("g")
                      .attr("class", "event_circle")
                      .attr("transform", "translate("+(margin.left+(width/4))+", "+(margin.top+(height/2))+")")
                      .selectAll(".pi")
                      .data(pie(prospect[id]))
                      .enter()
                      .append("g")
                      .attr("class", "pi");
     
          // イベント用見積もり円グラフの作成
          base_pi.append("path")
            .attr("class", "prospect")
            .style("fill", function(d,i) {
              return pale_color[i];
            })
            .attr("d", arc(2*base_radius, 0));

          // イベント用実績円グラフの作成
          base_pi.append("path")
            .attr("class", "result")
            .style("fill", function(d,i) {
              return base_color[i];
            })
            .attr("d", result_arc(2*base_radius, 0));
 
          // 操作用円グラフの削除
          svg.selectAll(".developer_"+developers[id])
            .selectAll(".circle")
            .remove();

          // イベント用円グラフの消滅
          svg.selectAll(".developer_"+developers[id])
            .selectAll(".event_circle")
            .selectAll("path")
            .transition()
            .duration(event_time)
            .style("fill", "#ededed");
          
          // Returnボタン(マーク)の消滅
          svg.selectAll(".return_button")
            .selectAll(".dummy_mark")
            .data(mark_event_colors)
            .enter()
            .append("g")
            .attr("class", "dummy_mark")
            .append("circle")
            .transition()
            .duration(event_time)
            .each("start", function(d,i) {
              d3.select(this)
                .attr({
                  cx: 10,
                  cy: 10,
                  r: function() {
                    return mark_radius[i];
                  },
                  fill: function() {
                    return mark_event_colors[i];
                  }
                });

              svg.selectAll(".return_button")
                .selectAll(".mark")
                .remove();
            })
            .attr("fill", "#ededed");

          // Returnボタン(テキスト)の消滅
          svg.selectAll(".return_button")
            .select(".label")
            .transition()
            .duration(event_time)
            .attr("fill", "#ededed");

         // 凡例の消滅
         svg.selectAll(".legend")
           .selectAll("rect")
           .transition()
           .duration(event_time)
           .attr("fill", "#ededed");

         svg.select(".legend")
           .selectAll("text")
           .transition()
           .duration(event_time)
           .attr("fill", "#ededed");
         
          // 開発者名の消滅
          svg.select(".developer_name")
            .select("text")
            .transition()
            .duration(event_time)
            .attr("fill", "#ededed");

          // returnボタンの削除
          svg.selectAll(".return_button")
            .transition()
            .delay(event_time)
            .remove();

          //拡大グラフの削除
          svg.selectAll(".developer_"+developers[id])
            .transition()
            .delay(event_time)
            .remove();

          // 凡例の削除
          svg.selectAll(".legend")
            .transition()
            .delay(event_time)
            .remove();

          // 開発者名の削除
          svg.selectAll(".developer_name")
            .transition()
            .delay(event_time)
            .remove();

          for (var j=0; j<developers.length; j++) {
            drawBoxPiChart(j, 0, event_time+200);
          }
        });
    }; 
    //
    // 棒グラフの描画
    //
    var draw_bar_chart = function(id) {
      svg.selectAll("g").remove();

      bar_svg = svg.append("g")
                   .attr("transform", "translate(0,0)");

      /*
      var maxScale = Math.max(test_productivity_data);

      var yScale = d3.scale.linear()
                     .domain([0, maxScale])
                     .range([padding.top, height-padding.bottom])
                     .nice();

      var yAxis = d3.svg.axis()
                    .scale(yScale)
                    .orient("left");
      // y軸の追加
      bar_svg.append("g")
             .attr("class", "y_axis")
             .attr("transform", "translate(300, 100)")
             .call(yAxis);
      */

      bar_svg.selectAll(".bar")
             .data(test_productivity_data)
             .enter()
             .append("rect")
             .attr("x", function(d, i) {
               return padding.left + i*40;
             })
             .attr("width", 30)
             .attr("y", function(d){
               return height-(d*3);
             })
             .attr("height", function(d) {
               return d*3;
             })
             .attr("fill", base_color[id])
             .on("click", function(d, i) {
               draw_pi_chart(id);
             });
    };

    // 描画処理

    // 初期画面表示
    for (var num=0; num<developers.length; num++) {
      drawBoxPiChart(num, 0, 0);
    }
}
