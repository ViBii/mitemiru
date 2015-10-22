var create_ticket_digestion_graph = function(tracker,ticket_num,ticket_num_all){
  var tracker = tracker;
  var ticket_num = ticket_num;
  var ticket_num_all = ticket_num_all;

  var test_prospect_time = [20, 15, 8, 30];
  var test_ressult_time = [25, 10, 8, 40];

  var base_color = ['#4f81bd', '#c0504d', '#9bbb59', '#8064a2', '#4bacc6', '#f79646'];
  var bright_color = ['#99b6d9', '#db9a98', '#c7d9a1', '#b4a4c8', '#98d0df', '#fbcda8'];
  var dark_color = ['#2d5079', '#7b2e2c', '#647c33', '#4e3c64', '#296f82', '#ce6209'];

  var width = 960,
      height = 640,
      radius = Math.min(width, height)/2;

  var arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(0);

  var pie = d3.layout.pie()
      .sort(null)
      .value(function(d) {
          return d;
      });

  var svg = d3.select("body")
      .append("svg")
      .attr("width", width)
      .attr ("height", height)
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

  var g = svg.selectAll(".arc")
      .data(pie(test_prospect_time))
      .enter()
      .append("g")
      .attr("class", "arc");

  g.append("path")
      .attr("d", arc)
      .style("fill", function(d,i) {
          return bright_color[i%bright_color.length];
      });

//  g.append("text")
//      .attr("transform", function(d) {
//          return "translate("+arc.centroid(d)+")";
//      })
//      .style("text-anchor", "middle")
//      .style("dominant-baseline", "middle")
//      .text(function(d, i) {
//          if (ticket_num[i] > 0) {
//              return tracker[i];
//          }
//      })
//      .attr("y", -10)
//      .attr("font-size", "20px")
//      .attr("fill", "white");

  /*
  g.append("text")
      .attr("transform", function(d) {
          return "translate("+arc.centroid(d)+")";
      })
      .style("text-anchor", "middle")
      .style("dominant-baseline", "middle")
      .text(function(d, i) {
          if (ticket_num[i] > 0) {
              return ticket_num[i];
          }
      })
      .attr("y", 10)
      .attr("font-size", "20px")
      .attr("fill", "white");

  g.append("text")
      .style("text-anchor", "middle")
      .style("dominant-baseline", "middle")
      .text("Total")
      .attr("y", -20)
      .attr("font-size", "40px");

  g.append("text")
      .style("text-anchor", "middle")
      .style("dominant-baseline", "middle")
      .text(ticket_num_all)
      .attr("y", 20)
      .attr("font-size", "40px");
  */
}


