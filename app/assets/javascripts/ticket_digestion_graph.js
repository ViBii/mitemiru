var create_ticket_digestion_graph = function(tracker,ticket_num,ticket_num_all){
    var tracker = tracker;
    var ticket_num = ticket_num;
    var ticket_num_all = ticket_num_all;
    
    var test_prospect_time = [20, 15, 8, 30];
    var test_result_time = [25, 10, 8, 40];
    var test_productivity_data = [89, 105, 72, 90, 100];

    var base_color = ['#4f81bd', '#c0504d', '#9bbb59', '#8064a2', '#4bacc6', '#f79646'];
    var bright_color = ['#99b6d9', '#db9a98', '#c7d9a1', '#b4a4c8', '#98d0df', '#fbcda8'];
    var dark_color = ['#2d5079', '#7b2e2c', '#647c33', '#4e3c64', '#296f82', '#ce6209'];
   
    // SVG領域の範囲設定
    var width = 960,
        height = 500;
  
    var padding = {top: 10, right: 50, bottom: 10, left: 300};

    var svg = d3.select("body")
                .append("svg")
                .attr("width", width)
                .attr ("height", height);

    var bar_svg;
    var circle_svg;

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
    draw_pi_chart(0);
}
