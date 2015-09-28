var width = 960,
    height = 250

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

var force = d3.layout.force()
    .gravity(.05)
    .distance(150)
    .charge(-100)
    .size([width, height]);

var graph = gon.graph

force
    .nodes(graph.nodes)
    .links(graph.links)
    .start();

var link = svg.selectAll(".link")
    .data(graph.links)
    .enter().append("g")
    .attr("class", "link")
    .append("line")
    .attr("class", "link-line")
    .style("stroke-width", function(d) { return Math.sqrt(d.value); });

var linkText = svg.selectAll(".link")
    .append("text")
    .attr("class", "link-label")
    .attr("font-family", "Arial, Helvetica, sans-serif")
    .attr("fill", "Black")
    .style("font", "normal 12px Arial")
    .attr("dy", ".35em")
    .attr("text-anchor", "middle")
    .text(function(d) {
        return d.value;
    });

var node = svg.selectAll(".node")
    .data(graph.nodes)
    .enter().append("g")
    .attr("class", "node")
    .call(force.drag);

node.append("image")
    .attr("xlink:href", "https://github.com/favicon.ico")
    .attr("x", -8)
    .attr("y", -8)
    .attr("width", 30)
    .attr("height", 30);

node.append("text")
    .attr("dx", 25)
    .attr("dy", ".35em")
    .text(function(d) { return d.name });

force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    linkText
        .attr("x", function(d) {
            return ((d.source.x + d.target.x)/2);
        })
        .attr("y", function(d) {
            return ((d.source.y + d.target.y)/2);
        });

    node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
});