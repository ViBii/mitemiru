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
    var width = 960,
        height = 480;

    var box_width = 240,
        box_height = 240;

    var margin = {top: 10, right: 10, bottom: 10, left: 10}
    var padding = {top: 10, right: 50, bottom: 10, left: 30};

    var svg = d3.select("body")
                .append("svg")
                .attr("width", width)
                .attr ("height", height);

    var bar_svg;
    var box_circle_svg;
    var circle_svg;

    // 円グラフの一覧表示
    var draw_box_pi_chart = function(id) {
      var base_radius = box_width/4;
    
      var pros_arc = d3.svg.arc()
                       .outerRadius(base_radius)
                       .innerRadius(0);
    
      var result_arc = d3.svg.arc()
                         .outerRadius(function(d, i) {
                           if (prospect[id][i]/result[id][i] < 1.5) {
                             base_radius*(prospect[id][i]/result[id][i]);
                           } else {
                             return base_radius*1.5;
                           }
                         })
                         .innerRadius(0);
    
      var pie = d3.layout.pie()
                  .sort(null)
                  .value(function(d) {
                    return d;
                  });
   
      circle_svg = svg.append("g")
          .attr("class", developers[id])
          .attr("transform", "translate("+((box_width/2)+box_width*(id%4))+", "+((box_height/2)+box_height*Math.floor(id/4))+")");
    
      var pros_g = circle_svg.selectAll(".prospect")
                             .data(pie(prospect[id]))
                             .enter()
                             .append("g")
                             .attr("class", "prospect");
    
      pros_g.append("path")
            .attr("d", pros_arc)
            .style("fill", function(d,i) {
              return bright_color[i];
            });
   
      var result_g = circle_svg.selectAll(".productivity")
                               .data(pie(prospect[id]))
                               .enter()
                               .append("g")
                               .attr("class", "productivity");
    
      result_g.append("path")
              .attr("d", result_arc)
              .style("fill", function(d,i) {
                return base_color[i];
              });
    };


    // 初期画面表示
    for (var i=0; i<developers.length; i++) {
      draw_box_pi_chart(i);
    }

    // 円グラフの描画
    var draw_pi_chart = function(id) {
      // 棒グラフの削除
      svg.selectAll("g").remove();

      var base_radius = Math.min(width, height) / 3;
    
      var pros_arc = d3.svg.arc()
                       .outerRadius(base_radius)
                       .innerRadius(0);
    
      var result_arc = d3.svg.arc()
                         .outerRadius(function(d, i) {
                           return base_radius*(test_prospect_time[i]/test_result_time[i]);
                         })
                         .innerRadius(0);
    
      var pie = d3.layout.pie()
                  .sort(null)
                  .value(function(d) {
                    return d;
                  });
    
      circle_svg = svg.append("g")
                      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
    
      var pros_g = circle_svg.selectAll(".prospect")
                             .data(pie(test_prospect_time))
                             .enter()
                             .append("g")
                             .attr("class", "prospect");
    
      pros_g.append("path")
            .attr("d", pros_arc)
            .style("fill", function(d,i) {
              return bright_color[i];
            });
    
      var result_g = circle_svg.selectAll(".result")
                               .data(pie(test_prospect_time))
                               .enter()
                               .append("g")
                               .attr("class", "result");
    
      result_g.append("path")
              .attr("d", result_arc)
              .style("fill", function(d,i) {
                return base_color[i];
              })
              .on("click", function(d, i) {
                draw_bar_chart(i);
              });
    };
  
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

    // 初期グラフの描画
    //draw_pi_chart(0);
}
