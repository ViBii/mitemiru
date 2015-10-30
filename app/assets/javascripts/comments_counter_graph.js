var create_comment_graph = function(nodes,links){
    var width = 500,
        height = 700

    var svg = d3.select("body").append("svg")
        .attr("width", width)
        .attr("height", height);

    var force = d3.layout.force()
        .gravity(.05)
        .distance(200)
        .charge(-100)
        .size([width, height]);

    force
        .nodes(nodes)
        .links(links)
        .start();

    var marker = svg.append("defs").append("marker")
        .attr({
            'id': "arrowhead",
            'refX': 13,
            'refY': 2,
            'markerWidth': 4,
            'markerHeight': 4,
            'orient': "auto"
        });

    marker.append("path")
        .attr({
            d: "M 0,0 V 4 L4,2 Z",
            fill: "#ccc"
        });

    var link = svg.selectAll(".link")
        .data(links)
        .enter().append("g")
        .attr("class", "link")
        .append("line")
        .attr("class", "link-line")
        .attr("marker-end","url(#arrowhead)")
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
        .data(nodes)
        .enter().append("g")
        .attr("class", "node")
        .call(force.drag);

    node.append("image")
        .attr("xlink:href", "https://github.com/favicon.ico")
        .attr("x", -8)
        .attr("y", -8)
        .attr("width", 40)
        .attr("height", 40);

    node.append("text")
        .attr("dx", 35)
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
}

