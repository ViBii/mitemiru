var create_ticket_digestion_graph = function(tracker,ticket_num,ticket_num_all){
    var tracker = tracker;
    var ticket_num = ticket_num;
    var ticket_num_all = ticket_num_all;
   
    // テストデータ(Redmineと連携後に削除)
    var developers = ['devA', 'devB', 'devC', 'devD', 'devE'];
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

    var base_color = ['#4f81bd', '#c0504d', '#9bbb59', '#8064a2', '#4bacc6', '#f79646'];
    var bright_color = ['#99b6d9', '#db9a98', '#c7d9a1', '#b4a4c8', '#98d0df', '#fbcda8'];
    var dark_color = ['#2d5079', '#7b2e2c', '#647c33', '#4e3c64', '#296f82', '#ce6209'];
   
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

    var arc = function(outer_radius, inner_radius) {
      return d3.svg.arc()
               .outerRadius(outer_radius)
               .innerRadius(inner_radius);
    }

    // 円グラフの一覧表示
        var drawBoxPiChart = function(id, page_from, emerge_after) {
        // page_from ->
        //   0: 初期表示
        //   1: 拡大円グラフからのReturn

          var pros_arc = function(outer_radius, inner_radius) {
            return d3.svg.arc()
                     .outerRadius(outer_radius)
                     .innerRadius(inner_radius);
          }
      
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

          var pie = d3.layout.pie()
                      .sort(null)
                      .value(function(d) {
                        return d;
                      });

          circle_svg = svg.append("g")
              .attr("class", "developer_"+developers[id])
              .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(id%4))+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4))+")")
              // グラフクリック時のイベント
              .on("click", function() {
                // 縮小グラフの削除
                svg.selectAll(".developer_"+developers[id])
                  .selectAll("path")
                  .remove();

                // 拡大グラフの描画
                drawPiChart(id);

                // 他のグラフを削除する
                for (var j=0; j<developers.length; j++) {
                  if (j != id) {
                    // 見積もりグラフ
                    svg.selectAll(".developer_"+developers[j])
                      .selectAll(".prospect")
                      .selectAll("path")
                      .transition()
                      .duration(event_time)
                      .style("fill", "#ededed");

                    // 実績グラフ
                    svg.selectAll(".developer_"+developers[j])
                      .selectAll(".result")
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

                // 戻るボタンの設置
                addReturnButton(id,1);
              });

          // 見積もり部分の表示
          var pros_g = circle_svg.selectAll(".prospect")
                .data(pie(prospect[id]))
                .enter()
                .append("g")
                .attr("class", "prospect");
    
          pros_g.append("path")
            .transition()
            .duration(event_time)
            .delay(emerge_after)
            .each("start", function() {
              d3.select(this)
                .style("fill", "#ededed"); 
            })
            .attr("d", pros_arc(base_radius, 0))
            .style("fill", function(d,i) {
              return bright_color[i];
            });
   
          // 実績部分の表示
          var result_g = circle_svg.selectAll(".result")
                .data(pie(prospect[id]))
                .enter()
                .append("g")
                .attr("class", "result");
      
          result_g.append("path")
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

    // 拡大円グラフの作成
    var drawPiChart = function(id) {
      // 見積もり円グラフの半径設定
      var pros_arc = function(outer_radius, inner_radius) {
        return d3.svg.arc()
                 .outerRadius(outer_radius)
                 .innerRadius(inner_radius);
      }
      
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
   
      circle_svg = svg.append("g")
        .attr("class", "developer_"+developers[id]);
         
      circle_svg.transition()
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(id%4))+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4))+")");
        })
        .attr("transform", "translate("+(margin.left+(width/4))+", "+(margin.top+(height/2))+")")
        .each("end", function() {
        });     

      // 見積もり円グラフの生成
      var pros_g = circle_svg.selectAll(".prospect")
                             .data(pie(prospect[id]))
                             .enter()
                             .append("g")
                             .attr("class", "prospect");
    
      pros_g.append("path")
            .attr("d", pros_arc(base_radius, 0))
            .style("fill", function(d,i) {
              return bright_color[i];
            })
        .transition()
        .delay(event_time)
        .duration(event_time)
        .ease("bounce")
        .attr("d", pros_arc(2*base_radius, 0));
   
      // 実績円グラフの生成
      var result_g = circle_svg.selectAll(".result")
                               .data(pie(prospect[id]))
                               .enter()
                               .append("g")
                               .attr("class", "result");
    
      result_g.append("path")
        .attr("d", result_arc(base_radius, 0))
        .style("fill", function(d,i) {
          return base_color[i];
        })
        .transition()
        .delay(event_time)
        .duration(event_time)
        .ease("bounce")
        .attr("d", result_arc(2*base_radius, 0));
    };

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

          // 見積もりグラフ
          svg.selectAll(".developer_"+developers[id])
            .selectAll(".prospect")
            .selectAll("path")
            .transition()
            .duration(event_time)
            .style("fill", "#ededed");

          // 実績グラフ
          svg.selectAll(".developer_"+developers[id])
            .selectAll(".result")
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

          for (var j=0; j<developers.length; j++) {
            drawBoxPiChart(j, 0, event_time);
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
