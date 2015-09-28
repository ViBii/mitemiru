var tracker = gon.tracker;
var man_hour = ['実績工数', '予定工数'];
var task_result = gon.task_result;
var task_estimate = gon.task_estimate;
var color = ['#006ab3', '#b1d7e8'];

var topPadding = 50;
var bottomPadding = 30;
var leftPadding = 150;
var rightPadding = 100;

var w = 860;
var h = 200 + topPadding + bottomPadding + 70*tracker.length;

var maxScale = Math.max(d3.max(task_result), d3.max(task_estimate));

var xScale = d3.scale.linear()
               .domain([0, maxScale])
               .range([leftPadding, w-rightPadding])
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
     transform: "translate(0, "+(topPadding+70*tracker.length)+")"
   })
   .call(xAxis);

// x軸のラベル
svg.append("text")
   .text("工数[h]")
   .attr("x", (w+leftPadding-rightPadding)/2)
   .attr("y", topPadding+70*tracker.length+45)
   .attr("text-anchor", "middle")
   .attr("dominant-baseline", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "20px");

// 凡例の表示
svg.selectAll(".legend")
   .data(color)
   .enter()
   .append("rect")
   .attr("x", function(d, i) {
     return i * 200 + leftPadding + 50;
   })
   .attr("y", topPadding/2 - 8)
   .attr("width", 16)
   .attr("height", 16)
   .attr("fill", function(d) {
     return d;
   });

svg.selectAll(".tracker")
   .data(man_hour)
   .enter()
   .append("text")
   .text(function(d) {
     return d;
   })
   .attr("x", function(d, i) {
     return i * 200 + leftPadding + 70;
   })
   .attr("y", topPadding/2+2)
   .attr("text-anchor", "start")
   .attr("dominant-baseline", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "15px")
   .attr("fill", "black");

// 実績グラフの描画
svg.selectAll(".rect")
   .data(task_result)
   .enter()
   .append("rect")
   .transition()
   .delay(function(d, i) {
     return i * 300;
   })
   .each("start", function() {
     d3.select(this).attr({
       width: 0,
       fill: color[0]
     })
   })
   .duration(1000)
   .attr("x", leftPadding)
   .attr("y", function(d, i) {
     return topPadding + i * 70;
   })
   .attr("width", function(d, i) {
     return xScale(d)-leftPadding;
   })
   .attr("height", 30)
   .attr("fill", color[0]);

// 見積もりグラフの描画
svg.selectAll(".estimate")
   .data(task_estimate)
   .enter()
   .append("rect")
   .transition()
   .delay(function(d, i) {
     return i * 300 + tracker.length * 300;
   })
   .each("start", function() {
     d3.select(this).attr({
       width: 0,
       fill: color[1]
     })
   })
   .duration(1000)
   .attr("x", leftPadding)
   .attr("y", function(d, i) {
     return topPadding + i * 70 + 30;
   })
   .attr("width", function(d, i) {
     return xScale(d)-leftPadding;
   })
   .attr("height", 30)
   .attr("fill", color[1]);

// 実績工数の表示
svg.selectAll(".result_time")
   .data(task_result)
   .enter()
   .append("text")
   .attr("opacity", 0.0)
   .text(function(d, i) {
     return d+"h";
   })
   .attr("x", function(d, i) {
     if (d > maxScale/8) {
       return xScale(d)-5;
     } else {
       return xScale(d)+3;
     }
   })
   .attr("y", function(d, i) {
     return topPadding + i * 70 + 17;
   })
   .attr("text-anchor", function(d) {
     // 工数ラベルの表示位置調整
     if (d > maxScale/8) {
       return "end";
     } else {
       return "start";
     }
   })
   .attr("dominant-baseline", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "20px")
   .attr("fill", function(d) {
     if (d > maxScale/8) {
       return "white";
     } else {
       return "black";
     }
   })
   .transition()
   .delay(function(d, i) {
     return i * 300;
   })
   .each("end", function() {
     d3.select(this)
       .transition()
       .duration(2000)
       .attr("opacity", 1.0)
   });

// 見積もり工数の表示
svg.selectAll(".estimate_time")
   .data(task_estimate)
   .enter()
   .append("text")
   .attr("opacity", 0.0)
   .text(function(d, i) {
     return d+"h";
   })
   .attr("x", function(d, i) {
     if (d > maxScale/8) {
       return xScale(d)-5;
     } else {
       return xScale(d)+3;
     }
   })
   .attr("y", function(d, i) {
     return topPadding + i * 70 + 47;
   })
   .attr("text-anchor", function(d) {
     // 工数ラベルの表示位置調整
     if (d > maxScale/8) {
       return "end";
     } else {
       return "start";
     }
   })
   .attr("dominant-baseline", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "20px")
   .attr("fill", "black")
   .transition()
   .delay(function(d, i) {
     return i * 300 + tracker.length * 300;
   })
   .each("end", function() {
     d3.select(this)
       .transition()
       .duration(2000)
       .attr("opacity", 1.0)
   });

// トラッカー名の表示
svg.selectAll(".tracker")
   .data(tracker)
   .enter()
   .append("text")
   .attr("opacity", 0.0)
   .text(function(d) {
     return d;
   })
   .attr("x", function(d, i) {
       return leftPadding-10;
   })
   .attr("y", function(d, i) {
     return topPadding + i * 70 + 30;
   })
   .attr("text-anchor", "end")
   .attr("dominant-baseline", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "15px")
   .attr("fill", "black")
   .transition()
   .each("start", function() {
     d3.select(this)
       .transition()
       .duration(2000)
       .attr("opacity", 1.0)
   });
