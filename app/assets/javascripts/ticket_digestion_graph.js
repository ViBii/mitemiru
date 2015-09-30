var tracker = gon.tracker;
var ticket_num = gon.ticket_num;
var ticket_num_all = gon.ticket_num_all;
var color = d3.scale.category20();

var width = 960,
    height = 500,
    radius = Math.min(width, height) / 2;

var arc = d3.svg.arc()
            .outerRadius(radius - 10)
            .innerRadius(radius - 150);

var pie = d3.layout.pie()
            .sort(null)
            .value(function(d) {
              return d;
            });

var svg = d3.select("body").append("svg")
            .attr("width", width)
            .attr ("height", height)
            .append("g")
            .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

var g = svg.selectAll(".arc")
           .data(pie(ticket_num))
           .enter()
           .append("g")
           .attr("class", "arc");

g.append("path")
 .attr("d", arc)
 .style("fill", function(d,i) {
   return color(i);
 });

g.append("text")
 .attr("transform", function(d) {
   return "translate("+arc.centroid(d)+")";
 })
 .style("text-anchor", "middle")
 .style("dominant-baseline", "middle")
 .text(function(d, i) {
   if (ticket_num[i] > 0) {
     return tracker[i];
   }
 })
 .attr("y", -10)
 .attr("font-size", "20px")
 .attr("fill", "white");

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
