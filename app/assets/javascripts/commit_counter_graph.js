var create_commit_graph = function(all_commit,own_commit,developer_name){
    alert(all_commit + developer_name + own_commit);
    var commit_count = [all_commit, own_commit];
    var developer_name = ['その他', developer_name];
    var color = ['#b1d7e8', '#006ab3'];

    var topPadding = 50;
    var leftPadding = 100;
    var rightPadding = 20;
    var w = 500+leftPadding+rightPadding;
    var h = 400;

    var barHeight = 100;

    var xScale = d3.scale.linear()
        .domain([0, gon.all_commit])
        .range([0, 500])
        .nice();

    var xAxis = d3.svg.axis()
        .scale(xScale)
        .orient("bottom");

    var svg = d3.select("body")
        .append("svg")
        .attr("width", w)
        .attr("height", h);

// x軸の表示
    svg.append("g")
        .attr({
            class: "axis",
            transform: "translate("+leftPadding+", 150)"
        })
        .call(xAxis);

// 棒グラフの描画
    svg.selectAll("rect")
        .data(commit_count)
        .enter()
        .append("rect")
        .attr("fill", function(d, i) {
            return color[i];
        })
        .transition()
        .duration(2000)
        .each("start", function() {
            d3.select(this).attr({
                width: 0
            })
        })
        .attr("x", leftPadding)
        .attr("y", 40)
        .attr("width", function(d) {
            return xScale(d);
        })
        .attr("height", barHeight);

// コミット数の表示
    svg.selectAll("commit_count")
        .data(commit_count)
        .enter()
        .append("text")
        .attr("opacity", 0.0)
        .text(function(d, i) {
            if (i == 0) {
                return d - commit_count[i+1];
            } else {
                return d;
            }
        })
        .attr("x", function(d, i) {
            if (i == 0) {
                return leftPadding + xScale(commit_count[i+1]) + xScale(d - commit_count[i+1])/2;
            } else {
                return leftPadding + xScale(d)/2;
            }
        })
        .attr("y", function(d) {
            return 30 + barHeight/2;
        })
        .attr("text-anchor", "middle")
        .attr("font-family", "sans-serif")
        .attr("font-size", "20px")
        .attr("fill", "white")
        .transition()
        .each("end", function() {
            d3.select(this)
                .transition()
                .duration(2000)
                .attr("opacity", 1.0)
        });

// 開発者名の表示
    svg.selectAll("developer_name")
        .data(developer_name)
        .enter()
        .append("text")
        .attr("opacity", 0.0)
        .text(function(d, i) {
            return d;
        })
        .attr("x", function(d, i) {
            if (i == 0) {
                return leftPadding + xScale(commit_count[i+1]) + xScale(commit_count[i] - commit_count[i+1])/2;
            } else {
                return leftPadding + xScale(commit_count[i])/2;
            }
        })
        .attr("y", function(d) {
            return 30;
        })
        .attr("text-anchor", "middle")
        .attr("font-family", "sans-serif")
        .attr("font-size", "15px")
        .attr("fill", "black")
        .transition()
        .each("end", function() {
            d3.select(this)
                .transition()
                .duration(2000)
                .attr("opacity", 1.0)
        });
}


