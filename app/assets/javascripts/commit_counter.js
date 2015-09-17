var dataset = [ 5, 10, 13, 19, 21, 25, 22, 18, 15, 13, 11, 12, 15, 20, 18, 17, 16, 18, 23, 25 ];

var w = 500;
var h = 300;
var padding = 20;
var barPadding = 1;

var yScale = d3.scale.linear()
               .domain([0, d3.max(dataset)])
               .range([padding, h-padding])
               .nice();

var yAxis = d3.svg.axis()
                  .scale(yScale)
                  .orient("left");

var svg = d3.select("body")
            .append("svg")
            .attr("width", w)
            .attr("height", h);

svg.append("g")
   .attr({
     class: "axis",
     transform: "translate(20, 0)"
   })
   .call(yAxis);

svg.selectAll("rect")
   .data(dataset)
   .enter()
   .append("rect")
   .attr("x", function(d, i) {
     return padding + 5 + i * ((w - padding - 5) / dataset.length);
   })
   .attr("y", function(d) {
     return padding;
   })
   .attr("width", (w - padding - 5) / dataset.length - barPadding)
   .attr("height", function(d) {
     return yScale(d);
   })
   .attr("fill", "teal")
