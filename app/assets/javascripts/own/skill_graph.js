var create_skill_graph = function(developers_data, extensions_data, developers_edit_data) {
  var developers = developers_data;
  var extensions = extensions_data;
  var developers_edit = developers_edit_data;

    // Chart colors
    var base_color = ['#4f81bd', '#c0504d', '#9bbb59', '#8064a2', '#4bacc6', '#f79646'];

    // SVG領域の範囲設定
    var box_width = 240,
        box_height = 240;
    
    var margin = {top: 60, right: 45, bottom: 60, left: 45};
    var width = 1080;
    var height = Math.max(480+margin.top+margin.bottom, Math.ceil(developers.length/4)*(box_height+10)-10+margin.top+margin.bottom); 

    var event_time = 700;
    
    // SVG領域の設定
    var svg = d3.select("#skill_graph");
    
    svg.transition()
       .duration(event_time)
       .attr({
         'height': height
       });

    // グラフ描画枠の変形
    svg.select(".frame")
       .transition()
       .duration(event_time)
       .attr({
         'height': height
       });

    var bar_svg;
    var box_circle_svg;
    var circle_svg;
    var base_radius = box_width/4;

    // 半径の設定
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

      // グラフ間のスペース調整
      var xSpace = 0;
      var ySpace = 0;
      if ((id%4) != 0) {
        xSpace = 10;
      }

      if (id < 4)  {
        ySpace = 10;
      }

      // 開発者のファイル編集履歴が残されていない場合
      if (getArraySum(developers_edit[id]) == 0) {
        svg.append('g')
          .attr('class', 'developer_'+id)
          .attr("transform", function() {
            return "translate("+(margin.left+(box_width/2)+box_width*(id%4)+xSpace)+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4)+ySpace)+")"
          })
          .append('circle')
          .attr('class', 'none_data')
          .attr({
            'cx': 0,
            'cy': 0,
            'r': base_radius,
            'fill': '#aaaaaa',
            'opacity': 0
          })
          .transition()
          .duration(event_time)
          .delay(event_time)
          .attr({
            'opacity': 1
          });
      } else { // 開発者のファイル編集履歴が残されている場合 
        // 小円の設定
        svg.append("g")
          .attr("class", "developer_"+id)
          .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(id%4)+xSpace)+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4)+ySpace)+")")
          .on("mouseover", function() {
            for (var j=0; j<developers.length; j++) {
              svg.selectAll(".developer_"+j)
                .selectAll(".pi")
                .data(extensions)
                .select(".prospect")
                .attr({
                  "opacity": function() {
                    if (j == id) {
                      return 1.0;
                    } else {
                      return 0.5;
                    }
                  }
                });
            }
          })
          .on("mouseout", function() {
            for (var j=0; j<developers.length; j++) {
              svg.selectAll(".developer_"+j)
                .selectAll(".pi")
                .data(extensions)
                .select(".prospect")
                .attr({
                  "opacity": 1.0
                });
            }
          })
          .on("click", function() { // グラフクリック時のイベント
            // 縮小グラフの削除
            svg.selectAll(".developer_"+id)
            .remove();

            // 拡大グラフの描画
            zoomPiChart(id);
            drawPiChart(id);

            // 開発者名の削除
            svg.selectAll('.dev_name')
              .selectAll('text')
              .transition()
              .duration(event_time)
              .attr({
                'opacity': 0
              });

            svg.selectAll(".dev_name")
              .transition()
              .delay(event_time)
              .remove();

            /* 他のグラフを削除する */
            svg.selectAll('.none_data')
              .transition()
              .duration(event_time)
              .attr({
                'opacity': 0
              });

            svg.selectAll('.none_data')
              .transition()
              .delay(event_time)
              .remove();

            for (var j=0; j<developers.length; j++) {
              if (j != id) {
                // 見積もりグラフ
                svg.selectAll(".developer_"+j)
                  .selectAll("path")
                  .transition()
                  .duration(event_time)
                  .attr({
                    'opacity': 0
                  });

                svg.selectAll(".developer_"+j)
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

          var base_pi = svg.selectAll(".developer_"+id)
                          .selectAll(".pi")
                          .data(pie(developers_edit[id]))
                          .enter()
                          .append("g")
                          .attr("class", "pi");

          // 見積もり円グラフの作成
          base_pi.append('path')
            .attr({
              'class': 'prospect',
              'd': arc(base_radius, 0),
              'fill': function(d,i) {
                return base_color[i%base_color.length];
              },
              'opacity': 0.0
            })
            .transition()
            .duration(event_time)
            .delay(emerge_after)
            .attr({
              'opacity': 1.0
            });
      }

      var dev_name = svg.append("g")
                       .attr("class", "dev_name")
                       .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(id%4)+xSpace)+", "+(margin.top+(box_height/2)+box_height*Math.floor(id/4)+ySpace)+")");

      // 開発者名の表示
      dev_name.append("text")
        .text(developers[id])
        .attr({
          'x': 0,
          'y': 0,
          'font-family': 'sans-serif',
          'font-size': '10px',
          'text-anchor': 'middle',
          'deominant-baseline': 'middle',
          'fill': '#ffffff',
          'opacity': 0.0
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr({
          "opacity": 1.0
        });
    };

    //
    // 円グラフのズームイベント
    //
    var zoomPiChart = function(developer_id) {
      // グラフ間のスペース調整
      var xSpace = 0;
      var ySpace = 0;
      if ((developer_id%4) != 0) {
        xSpace = 10;
      }

      if (developer_id < 4)  {
        ySpace = 10;
      }

      // 拡大円グラフの基本クラス
      svg.append("g")
        .attr("class", "developer_"+developer_id)
        .append("g")
        .attr("class", "event_circle")
        .transition()
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("transform", "translate("+(margin.left+(box_width/2)+box_width*(developer_id%4)+xSpace)+", "+(margin.top+(box_height/2)+box_height*Math.floor(developer_id/4)+ySpace)+")");
        })
        .attr("transform", "translate("+(width/2)+", "+(height/2)+")");

      // Zoomイベント用Piのクラス設定
      var zoom_event_pi = svg.selectAll(".developer_"+developer_id)
                      .selectAll(".event_circle")
                      .selectAll(".pi")
                      .data(pie(developers_edit[developer_id]))
                      .enter()
                      .append("g")
                      .attr("class", "pi");
     
      // Zoomイベント円グラフの作成
      zoom_event_pi.append("path")
        .attr("class", "prospect")
        .attr("d", arc(base_radius, 0))
        .style("fill", function(d,i) {
          return base_color[i%base_color.length];
        })
        .transition()
        .delay(event_time)
        .duration(event_time)
        .ease("bounce")
        .attr("d", arc(2*base_radius, 0));

      // 開発者クラスの削除 
      svg.select(".developer_"+developer_id)
        .transition()
        .delay(2*event_time)
        .remove();
    }

    //
    // 円グラフの出現イベント
    //
    var emergePiChart = function(developer_id) {
      // 円グラフの基本クラスの生成
      svg.append("g")
        .attr("class", "developer_"+developer_id)
        .append("g")
        .attr("class", "emerge_event_circle")
        .attr("transform", "translate("+(width/2)+", "+(height/2)+")");

      // 出現イベント用Piのクラス設定
      var emerge_event_pi = svg.selectAll(".developer_"+developer_id)
                      .selectAll(".emerge_event_circle")
                      .selectAll(".pi")
                      .data(pie(developers_edit[developer_id]))
                      .enter()
                      .append("g")
                      .attr("class", "pi");
     
      // 出現イベント用円グラフの作成
      emerge_event_pi.append('path')
        .attr({
          'class': 'prospect',
          'd': arc(2*base_radius, 0),
          'fill': function(d,i) {
            return base_color[i%base_color.length];
          },
          'opacity': 0.0
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr({
          'opacity': 1.0
        })

      // 開発者クラスの削除 
      svg.select(".developer_"+developer_id)
        .transition()
        .delay(2*event_time)
        .remove();
    }

    //
    // 拡大円グラフの作成
    //
    var drawPiChart = function(id) {
      // 開発者クラスの生成
      svg.append("g")
        .attr("class", "developer_"+id);

      // 操作用円グラフの作成
      var base_pi = svg.selectAll(".developer_"+id)
                      .append("g")
                      .attr("class", "circle")
                      .attr("transform", "translate("+(width/2)+", "+(height/2)+")")
                      .selectAll(".pi")
                      .data(pie(developers_edit[id]))
                      .enter()
                      .append("g")
                      .attr("class", "pi");
      
      // 操作用円グラフの作成
      base_pi.append("path")
        .attr("class", "prospect")
        .style("fill", function(d,i) {
          return base_color[i%base_color.length];
        })
        .transition()
        .delay(2*event_time)
        .attr("d", arc(2*base_radius, 0));

      // 操作用円グラフのマウスイベント
      svg.selectAll(".developer_"+id)
        .selectAll(".circle")
        .selectAll(".pi")
        .data(extensions)
        .on("mouseover", function(d,i) {
          displayInfo(i);
          highlight(i);
        })
        .on("mouseout", function(d,i) {
          normalize();
        })
        .on("click", function(d,i) {
          // 円グラフの削除
          vanishPiChart(id);
          svg.selectAll("g")
            .transition()
            .delay(event_time)
            .remove();

          // 棒グラフの描画
          drawBarChart(i);
        });

      //
      // ハイライト
      //
      var highlight = function(mouse_over) {
        // グラフのハイライト
        var highlight_pi = svg.selectAll(".developer_"+id)
                      .selectAll(".circle")
                      .selectAll(".pi")
                      .data(extensions);
       
        highlight_pi.select(".prospect")
          .attr({
            'opacity': function(d,i) {
              if (mouse_over == i) {
                return 1.0;
              } else {
                return 0.5;
              }
            }
          });

        // 凡例のハイライト
        for (var i=0; i<extensions.length; i++) {
          svg.selectAll(".legend")
            .selectAll(".extension_"+i)
            .selectAll(".prospect")
            .attr({
              'opacity': function() {
                if (mouse_over == i) {
                  return 1.0;
                } else {
                  return 0.5;
                }
              }
            });

          svg.selectAll(".legend")
            .selectAll(".extension_"+i)
            .select(".label")
            .attr({
              'opacity': function() {
                if (mouse_over == i) {
                  return 1.0;
                } else {
                  return 0.5;
                }
              }
            });
        }
      };

      //
      // 工数情報の表示
      // 
      var displayInfo = function(extension_id) {
        var info_list = svg.select(".developer_"+id)
              .select(".circle")
              .selectAll(".pi")
              .append("g")
              .attr("class", "info");

        // 編集回数
        info_list.append("text")
          .text("編集回数: ")
          .attr("transform", "translate(-2, 0)")
          .attr("text-anchor", "end");
       
        info_list.append("text")
          .text(developers_edit[id][extension_id].toFixed(1)+"回")
          .attr("transform", "translate(2, 0)")
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
        var normal_pi = svg.selectAll(".developer_"+id)
                         .selectAll(".circle")
                         .selectAll(".pi")
                         .data(extensions);
       
        normal_pi.select(".prospect")
          .attr({
            'opacity': 1.0
          });

        // 凡例の通常化
        for (var i=0; i<extensions.length; i++) {
          svg.selectAll(".legend")
            .selectAll(".extension_"+i)
            .selectAll(".prospect")
            .attr({
              'opacity': 1.0
            });

          svg.selectAll(".legend")
            .selectAll(".extension_"+i)
            .select(".label")
            .attr({
              'opacity': 1.0
            });
        }

        svg.selectAll(".developer_"+id)
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
        .selectAll("extension_id")
        .data(extensions)
        .enter()
        .append("g")
        .attr("class", function(d,i) {
          return "extension_"+i;
        });

      // 凡例の一覧表示
      for (var i=0; i<extensions.length; i++) {
        svg.selectAll(".legend")
          .selectAll(".extension_"+i)
          .append("rect")
          .attr("class", "prospect")
          .attr({
            'x': (width/2)+base_radius*4+30,
            'y': (height/2)-base_radius*4+(i*30)+20,
            'width': 20,
            'height': 20,
            'fill': base_color[i%base_color.length],
            'opacity': 0
          }) 
          .transition()
          .duration(event_time)
          .delay(event_time)
          .attr({
            'opacity': 1
          });

        svg.selectAll(".legend")
          .selectAll(".extension_"+i)
          .append("text")
          .attr("class", "label")
          .text(extensions[i])
          .attr({
            'x': (width/2)+base_radius*4+30+25,
            'y': (height/2)-base_radius*4+(i*30)+20+10,
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
      }
    }

    //
    // 開発者名の表示
    //
    var showDeveloperName = function(developer_id) {
      svg.append("g")
        .attr("class", "developer_name")
        .append("text")
        .text(developers[developer_id])
        .attr({
          'x': (width/2)+base_radius*4+30,
          'y': (height/2)-base_radius*4,
          'font-family': 'sans-serif',
          'font-size': '30px',
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
                        .attr("transform", "translate("+((width/2)-(base_radius*4))+", "+((height/2)-(base_radius*4))+")");

      // マークの追加
      svg.selectAll('.return_button')
        .selectAll('.mark')
        .data(mark_default_colors)
        .enter()
        .append('g')
        .attr({
          'class': 'mark'
        })
        .append('circle')
        .attr({
          'cx': 10,
          'cy': 10,
          'r': 0,
          'fill': function(d,i) {
            return mark_default_colors[i%mark_default_colors.length];
          },
          'opacity': 1
        })
        .transition()
        .duration(event_time)
        .delay(event_time)
        .attr({
          'r': function(d,i) {
            return mark_radius[i];
          }
        });
        
      // テキストの表示
      svg.selectAll('.return_button')
        .append('text')
        .text("Return")
        .attr({
          'class': 'label',
          'x': 25,
          'y': 12,
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
        .attr({
          'opacity': 1
        });

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
               return mark_event_colors[i%mark_event_colors.length];
             });
        })
        .on("mouseout", function() {
         svg.selectAll(".return_button")
            .selectAll(".mark")
            .data(mark_event_colors)
            .select("circle")
            .transition()
            .attr("fill", function(d,i) {
              return mark_default_colors[i%mark_default_colors.length];
            });
        })
        // クリック時
        .on("click", function() {
          vanishPiChart(id);

          for (var j=0; j<developers.length; j++) {
            drawBoxPiChart(j, 0, event_time);
          }
        });
    }; 

    //
    // 円グラフの削除
    //
    var vanishPiChart = function(developer_id) {
      var mark_event_colors = ['#db9a98', '#c0504d'];
      var mark_radius = [10, 8];

      // イベント用円グラフの生成
      var base_pi = svg.selectAll('.developer_'+developer_id)
                      .append('g')
                      .attr({
                        'class': 'event_circle',
                        'transform': 'translate('+(width/2)+', '+(height/2)+')'
                      })
                      .selectAll('.pi')
                      .data(pie(developers_edit[developer_id]))
                      .enter()
                      .append('g')
                      .attr({
                        'class': 'pi'
                      });
     
      // イベント用円グラフの作成
      base_pi.append('path')
        .attr({
          'class': 'prospect',
          'd': arc(2*base_radius, 0),
          'fill': function(d,i) {
            return base_color[i%base_color.length];
          },
          'opacity': 1
        });

      // 操作用円グラフの削除
      svg.selectAll('.developer_'+developer_id)
        .selectAll('.circle')
        .remove();

      // イベント用円グラフの消滅
      svg.selectAll('.developer_'+developer_id)
        .selectAll('.event_circle')
        .selectAll('path')
        .transition()
        .duration(event_time)
        .attr({
          'opacity': 0
        });
        
      // Returnボタン(マーク)の消滅
      svg.selectAll('.return_button')
        .selectAll('.dummy_mark')
        .data(mark_event_colors)
        .enter()
        .append('g')
        .attr({
          'class': 'dummy_mark'
        })
        .append('circle')
        .attr({
          'cx': 10,
          'cy': 10,
          'r': function(d,i) {
            return mark_radius[i];
          },
          'fill': function(d,i) {
            return mark_event_colors[i%mark_event_colors.length];
          },
          'opacity': 1
        })
        .transition()
        .duration(event_time)
        .attr({
          'opacity': 0
        });

      // Returnボタン(マーク)の消滅
      svg.selectAll('.return_button')
        .selectAll('.mark')
        .remove();

      // Returnボタン(テキスト)の消滅
      svg.selectAll('.return_button')
        .select('.label')
        .transition()
        .duration(event_time)
        .attr({
          'opacity': 0
        });

      // 凡例の消滅
      svg.selectAll('.legend')
        .selectAll('rect')
        .transition()
        .duration(event_time)
        .attr({
          'opacity': 0
        });

      svg.select('.legend')
        .selectAll('text')
        .transition()
        .duration(event_time)
        .attr({
          'opacity': 0
        });
         
      // 開発者名の消滅
      svg.select('.developer_name')
        .select('text')
        .transition()
        .duration(event_time)
        .attr({
          'opacity': 0
        });

      // returnボタンの削除
      svg.selectAll(".return_button")
        .transition()
        .delay(event_time)
        .remove();

      //拡大グラフの削除
      svg.selectAll(".developer_"+developer_id)
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

      // 開発者グループの削除
      svg.selectAll(".developer_"+developer_id)
        .transition()
        .delay(event_time)
        .remove();
    };

    //
    // 棒グラフの描画
    //
    var drawBarChart = function(extension_id) {
      var bar_width = width-margin.left-margin.right;
      var bar_height = 380;

      var bar_margin = {top: margin.top, left: Math.max(margin.left+50,(width/2)-developers.length*30), right: margin.right, bottom: margin.bottom};

      svg.append("g")
        .attr("class", "bar_chart")
        .attr("transform", "translate("+((width/2)-(developers.length*30))+", "+(height/4)+")");

      var editNum = [];
      for (var i=0; i<developers_edit.length; i++) {
        editNum.push(developers_edit[i][extension_id]);
      }

      // 拡張子の最大編集数を取得
      console.log(editNum);
      var maxEdit = getMaxNum(editNum);

      // 棒グラフのスケール調整
      var yScale = d3.scale.linear()
                     .domain([0, maxEdit])
                     .range([0, height/2])
                     .nice();

      // 座標軸の基本設定
      var line = d3.svg.line()
            .x(function(d){ return d[0]; })
            .y(function(d){ return d[1]; })
    
      // 座標軸の表示
      svg.select(".bar_chart")
        .append("path")
        .attr("class", "yaxis")
        .transition()
        .duration(event_time)
        .delay(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("d", line([[-20, 0], [-20, yScale(maxEdit)]])) 
            .attr("stroke", "#aaaaaa")
            .attr("opacity", 0);
        })
        .attr("opacity", 1);

      // 0 Line
      svg.select(".bar_chart")
        .append("path")
        .attr("class", "yaxis")
        .transition()
        .duration(event_time)
        .delay(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("d", line([[-20, yScale(maxEdit)], [developers.length*60, yScale(maxEdit)]])) 
            .attr("stroke", "#aaaaaa")
            .attr("opacity", 0);
        })
        .attr("opacity", 1);

      // 平均ライン
      svg.select(".bar_chart")
        .append("path")
        .attr("class", "yaxis")
        .transition()
        .duration(event_time)
        .delay(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("d", line([[-20, yScale(getArraySum(editNum)/developers.length)], [developers.length*60, yScale(getArraySum(editNum)/developers.length)]])) 
            .attr("stroke", "#aaaaaa")
            .attr("opacity", 0)
            .attr("stroke-width", 1)
            .attr("stroke-dasharray", 10);
        })
        .attr("opacity", 1);

      // グラフタイトルの表示
      svg.selectAll(".bar_chart")
        .append("text")
        .attr("class", "graph_name")
        .transition()
        .delay(event_time)
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("fill", "#777777")
            .attr("opacity", 0);
        })
        .text(extensions[extension_id])
        .attr("x", (developers.length*60-20)/2)
        .attr("y", -50)
        .attr("font-family", "sans-serif")
        .attr("font-size", "20px")
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "middle")
        .attr("opacity", 1);

      // 座標項目名の表示
      svg.selectAll(".bar_chart")
        .append("text")
        .attr("class", "yaxis_name")
        .transition()
        .delay(event_time)
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("fill", "#777777")
            .attr("opacity", 0);
        })
        .text("編集回数(回)")
        .attr("x", -50)
        .attr("y", yScale(maxEdit/2))
        .attr("font-family", "sans-serif")
        .attr("font-size", "20px")
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "middle")
        .attr("writing-mode", "tb")
        .attr("opacity", 1);

      // 座標軸ラベルの表示
      svg.selectAll(".bar_chart")
        .append("text")
        .attr("class", "yaxis_label")
        .transition()
        .delay(event_time)
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("fill", "#777777")
            .attr("opacity", 0);
        })
        .text("平均: "+(getArraySum(editNum)/developers.length).toFixed(1))
        .attr("x", developers.length*60+10)
        .attr("y", yScale(getArraySum(editNum)/developers.length))
        .attr("font-family", "sans-serif")
        .attr("font-size", "15px")
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("opacity", 1);

      // 開発者名の表示
      svg.selectAll(".bar_chart")
        .selectAll(".developer_label")
        .data(developers)
        .enter()
        .append("text")
        .attr("class", "developer_label")
        .transition()
        .delay(event_time)
        .duration(event_time)
        .each("start", function() {
          d3.select(this)
            .attr("fill", "#777777")
            .attr("opacity", 0);
        })
        .text(function(d,i) {
          return developers[i];
        })
        .attr("x", function(d,i) {
          return i*60+20;
        })
        .attr("y", yScale(maxEdit)+10)
        .attr("font-family", "sans-serif")
        .attr("font-size", "15px")
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("writing-mode", "tb")
        .attr("opacity", 1);

      // 棒の表示
      var bar = svg.selectAll(".bar_chart")
                  .selectAll(".bar")
                  .data(editNum)
                  .enter()
                  .append("rect")
                  .attr("class", "bar")
                  .transition()
                  .duration(1000)
                  .delay(event_time)
                  .each("start", function() {
                    svg.selectAll(".bar_chart")
                      .selectAll(".bar")
                      .data(editNum)
                      .attr("width", 40)
                      .attr("height", 0)
                      .attr("x", function(d,i) {
                        return i*60;
                      })
                      .attr("y", yScale(maxEdit))
                      .attr("fill", base_color[extension_id%base_color.length]);
                  })
                  .attr("y", function(d) {
                    return yScale(maxEdit)-yScale(d);
                  })
                  .attr("height", function(d,i) {
                    return yScale(d);
                  })
                  .attr("opacity", 1);

        // 編集回数の数値表示
        svg.selectAll(".bar_chart")
          .selectAll(".bar_figure")
          .data(editNum)
          .enter()
          .append("text")
          .attr("class", "bar_figure")
          .transition()
          .delay(2*event_time)
          .duration(event_time)
          .each("start", function() {
            d3.select(this)
              .attr("fill", "#ededed");
          })
          .text(function(d,i) {
            return Math.round(editNum[i]);
          })
          .attr("x", function(d,i) {
            return i*60+20;
          })
          .attr("y", function(d) {
            return yScale(maxEdit)-yScale(d)-10;
          })
          .attr("font-family", "sans-serif")
          .attr("font-size", "15px")
          .attr("text-anchor", "middle")
          .attr("dominant-baseline", "middle")
          .attr("fill", function(d) {
            return "#777777";
          })
          .attr("opacity", 1);

        // 棒のマウスイベント
        svg.selectAll(".bar_chart")
          .selectAll(".bar")
          .data(editNum)
          .on("mouseover", function(d,i) {
            barHighlight(i)
          })
          .on("mouseout", function() {
            svg.selectAll(".bar_chart")
              .selectAll(".bar")
              .attr({
                'opacity': 1.0
              });

            svg.select(".bar_chart")
              .selectAll(".bar_figure")
              .data(editNum)
              .attr({
                'opacity': 1.0
              });
          })
          .on("click", function(d, i) { // クリックイベント
            // 座標軸の消滅
            svg.select(".bar_chart")
              .selectAll(".yaxis")
              .transition()
              .duration(event_time)
              .attr("opacity", 0)

            // 棒グラフの消滅
            svg.selectAll(".bar_chart")
              .selectAll(".bar")
              .transition()
              .duration(event_time)
              .attr("opacity", 0);

            // 各テキストの削除
            svg.select(".bar_chart")
              .selectAll("text")
              .transition()
              .duration(event_time)
              .attr("opacity", 0);
           
            // ソートボタンの消滅
            svg.select(".bar_chart")
              .selectAll(".button")
              .transition()
              .duration(event_time)
              .attr("opacity", 0);

            // 棒グラフの完全削除
            svg.selectAll(".bar_chart")
              .transition()
              .delay(event_time)
              .remove();

            // Returnボタンの表示
            addReturnButton(i,1);

            // 開発者名の表示
            showDeveloperName(i);

            // 凡例の表示
            drawLegend();

            emergePiChart(i);
            drawPiChart(i);
          });

      //
      // 棒グラフのハイライト
      //
      var barHighlight = function(mouse_over) {
        // グラフのハイライト
        svg.selectAll(".bar_chart")
          .selectAll(".bar")
          .data(editNum)
          .attr({
            'opacity': function(d,i) {
              if (mouse_over == i) {
                return 1.0;
              } else {
                return 0.5;
              }
            }
          });

        svg.select(".bar_chart")
          .selectAll(".bar_figure")
          .data(editNum)
          .attr({
            'opacity': function(d, i) {
              if (mouse_over == i) {
                return 1.0;
              } else {
                return 0.5;
              }
            }
          });
      };

      //
      // 棒グラフのソート
      //
      var sortBarChart = function() {
        var button_base_color = ['#4f81bd', '#c0504d'];
        var button_pale_color = ['#99b6d9', '#db9a98'];
        var button_radius = [10, 8];
        var order = ['開発者の登録順', '編集回数順'];
        var in_order = 0;

        /* ソート済みのデータの準備 */
        var swp_editNum = [];
        var sort_editNum = [];
        var swp_developers = [];
        var sort_developers = [];
        for (var i=0; i<editNum.length; i++) {
          swp_editNum.push(editNum[i]);
          sort_editNum.push(editNum[i]);
          swp_developers.push(developers[i]);
        }

        // 編集回数のソート
        sort_editNum.sort(function(a,b) {
          if (a<b) return -1;
          if (a>b) return 1;
          return 0;
        });
        
        // 開発者名のソート
        for (var i=0; i<developers.length; i++) {
          for (var j=0; j<developers.length; j++) {
            if (sort_editNum[i] == swp_editNum[j]) {
              sort_developers.push(swp_developers[j]);
              swp_editNum.splice(j,1);
              swp_developers.splice(j,1);
              break;
            }
          }
        }

        // sortグループの生成
        svg.select(".bar_chart")
          .append("g")
          .attr("class", "sort");

        // テキストの表示
        svg.select(".bar_chart")
          .select(".sort")
          .append("text")
          .attr("class", "function_name")
          .transition()
          .duration(event_time)
          .delay(event_time)
          .each("start", function() {
            d3.select(this)
              .text("Sort")
              .attr("x", developers.length*60+20)
              .attr("y", -50)
              .attr("font-family", "sans-serif")
              .attr("font-size", "20px")
              .attr("text-anchor", "start")
              .attr("dominant-baseline", "middle")
              .attr("fill", "#777777")
              .attr("opacity", 0);
          })
          .attr("opacity", 1);

        // ボタンの追加
        svg.select(".bar_chart")
          .select(".sort")
          .selectAll(".button")
          .data(button_radius)
          .enter()
          .append("circle")
          .attr("class", "button")
          .attr({
            cx: developers.length*60+30,
            cy: -25,
            r: 0,
            fill: function(d,i) {
              if (i == 0) {
                return button_pale_color[0];
              } else if (i == 1) {
                return button_base_color[0];
              }
            },
            opacity: 0
          })
          .transition()
          .duration(event_time)
          .delay(event_time)
          .attr({
            r: function(d,i) {
              return button_radius[i];
            },
            opacity: 1
          });

        // ボタンのマウスイベント
        svg.select(".bar_chart")
          .selectAll(".sort")
          .on("mouseover", function() {
            svg.select(".bar_chart")
              .select(".sort")
              .selectAll(".button")
              .data(button_radius)
              .attr("fill", function(d,i) {
                if (i == 0) {
                  return button_pale_color[1];
                } else if (i == 1) {
                  return button_base_color[1];
                }
              });
          })
          .on("mouseout", function() {
            svg.select(".bar_chart")
              .select(".sort")
              .selectAll(".button")
              .data(button_radius)
              .attr("fill", function(d,i) {
                if (i == 0) {
                  return button_pale_color[0];
                } else if (i == 1) {
                  return button_base_color[0];
                }
              });
          })
          .on("click", function() {
            in_order = (in_order+1)%order.length;
            svg.select(".bar_chart")
              .select(".sort")
              .select(".sort_name")
              .text(order[in_order]);

            // 開発者の登録順
            if (in_order == 0) {
            // 開発者ラベルのソート
              svg.select(".bar_chart")
                .selectAll(".developer_label")
                .data(developers)
                .transition()
                .duration(event_time)
                .attr("x", function(d,i) {
                  return i*60+20;
                });

              // 棒グラフのソート
              svg.select(".bar_chart")
                .selectAll(".bar")
                .data(editNum)
                .transition()
                .duration(event_time)
                .attr("x", function(d,i) {
                  return i*60;
                });

              // 生産性数値のソート
              svg.select(".bar_chart")
                .selectAll(".bar_figure")
                .data(editNum)
                .transition()
                .duration(event_time)
                .attr("x", function(d,i) {
                  return i*60+20;
                });
            }
            // 生産性順
            else if (in_order == 1) {
              // 開発者ラベルのソート
              svg.select(".bar_chart")
                .selectAll(".developer_label")
                .data(developers)
                .transition()
                .duration(event_time)
                .attr("x", function(d) {
                  for (var j=0; j<developers.length; j++) {
                    if (d == sort_developers[j]) {
                      return (developers.length-j-1)*60+20;
                    }
                  }
                });

              // 棒グラフのソート
              svg.select(".bar_chart")
                .selectAll(".bar")
                .data(developers)
                .transition()
                .duration(event_time)
                .attr("x", function(d) {
                  for (var j=0; j<developers.length; j++) {
                    if (d == sort_developers[j]) {
                      return (developers.length-j-1)*60;
                    }
                  }
                });

              // 生産性数値のソート
              svg.select(".bar_chart")
                .selectAll(".bar_figure")
                .data(developers)
                .transition()
                .duration(event_time)
                .attr("x", function(d) {
                  for (var j=0; j<developers.length; j++) {
                    if (d == sort_developers[j]) {
                      return (developers.length-j-1)*60+20;
                    }
                  }
                });
            }
          });

        // ソート順の表示
        svg.select(".bar_chart")
          .select(".sort")
          .append("text")
          .attr("class", "sort_name")
          .transition()
          .duration(event_time)
          .delay(event_time)
          .each("start", function() {
            d3.select(this)
              .text(order[in_order])
              .attr("x", developers.length*60+45)
              .attr("y", -25)
              .attr("font-family", "sans-serif")
              .attr("font-size", "15px")
              .attr("text-anchor", "start")
              .attr("dominant-baseline", "middle")
              .attr("fill", "#777777")
              .attr("opacity", 0);
          })
          .attr("opacity", 1);

      }

      // ソート機能の生成
      sortBarChart();
    };

    // 描画処理

    // 初期画面表示
    for (var num=0; num<developers.length; num++) {
      drawBoxPiChart(num, 0, event_time);
    }

    /*************/
    /* Utilities */
    /*************/
    
    // 配列の合計値を取得
    function getArraySum(array) {
      var sum = 0;
      for (var i=0; i<array.length; i++) {
        sum += array[i];
      }
      return sum;
    }

    // 配列の最大値を取得 
    function getMaxNum(array) {
      var max = array[0];

      for (var i=1; i<array.length; i++) {
        if (max < array[i]) {
          max = array[i];
        }
      }

      return max;
    };
}
