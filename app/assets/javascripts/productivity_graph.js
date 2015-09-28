/*
var commit_count = gon.commit_count;
var project_id = gon.project_name;

var xPadding = 140;
var yPadding = 20;
var barPadding = 2;
var barWidth = 150;

var w = xPadding + commit_count.length * (barWidth + barPadding);
var h = 420;

var yScale = d3.scale.linear()
               .domain([0, d3.max(commit_count)])
               .range([h-yPadding, yPadding])
               .nice();

var yAxis = d3.svg.axis()
                  .scale(yScale)
                  .orient("left");

var svg = d3.select("body")
            .append("svg")
            .attr("width", w)
            .attr("height", h);

// y軸の表示
svg.append("g")
   .attr({
     class: "axis",
     transform: "translate(140, 0)"
   })
   .call(yAxis);

// y軸のラベル
svg.append("text")
   .text("コミット数")
   .attr("x", xPadding-50)
   .attr("y", h/2)
   .attr("text-anchor", "middle")
   .attr("writing-mode", "tb")
   .attr("font-family", "sans-serif")
   .attr("font-size", "15px");

// 棒グラフの描画
svg.selectAll("rect")
   .data(commit_count)
   .enter()
   .append("rect")
   .attr("x", function(d, i) {
     return xPadding + 5 + i * (barPadding + barWidth);
   })
   .attr("y", function(d) {
     return yScale(d);
   })
   .attr("width", barWidth)
   .attr("height", function(d) {
     return h-yScale(d)-yPadding;
   })
   .attr("fill", "teal");

// 棒グラフの高さのテキスト表示
svg.selectAll("graph_tag")
   .data(commit_count)
   .enter()
   .append("text")
   .text(function(d) {
     return d;
   })
   .attr("x", function(d, i) {
     return xPadding + 5 + i * (barPadding + barWidth) + barWidth / 2;
   })
   .attr("y", function(d) {
     return yScale(d) + 25;
   })
   .attr("text-anchor", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "20px")
   .attr("fill", "white");

// プロジェクト名の表示
svg.selectAll("project_name")
   .data(project_id)
   .enter()
   .append("text")
   .text(function(d) {
     return d;
   })
   .attr("x", function(d, i) {
     return xPadding + 5 + i * (barPadding + barWidth) + barWidth / 2;
   })
   .attr("y", function(d) {
     return h-6;
   })
   .attr("text-anchor", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "11px")
   .attr("fill", "black");
*/
