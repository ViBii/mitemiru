var tracker = gon.tracker;
var task_result = gon.task_result;
var task_estimate = gon.task_estimate;
var color = ['#006ab3', '#b1d7e8'];

for (var i=0; i<tracker.length; i++) {
  document.write("<p>");
  document.write(tracker[i]+" <br />");
  document.write("実績: "+task_result[i]+" <br />");
  document.write("予定: "+task_estimate[i]+" <br />");
  document.write("</p>");
}

var w = 720;
var h = 420;

var leftPadding = 100;
var rightPadding = 100;

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
     transform: "translate(0, "+70*task_result.length+")"
   })
   .call(xAxis);

/*
// x軸のラベル
svg.append("text")
   .text("時間")
   .attr("x", w/2)
   .attr("y", 300)
   .attr("text-anchor", "middle")
   .attr("font-family", "sans-serif")
   .attr("font-size", "15px");
*/

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
     return i * 70;
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
     return i * 300 + task_result.length * 300;
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
     return i * 70 + 30;
   })
   .attr("width", function(d, i) {
     return xScale(d)-leftPadding;
   })
   .attr("height", 30)
   .attr("fill", color[1]);

// 実績時間の表示
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
     return i * 70 + 17;
   })
   .attr("text-anchor", function(d) {
     // 時間ラベルの表示位置調整
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

// 見積もり時間の表示
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
     return i * 70 + 47;
   })
   .attr("text-anchor", function(d) {
     // 時間ラベルの表示位置調整
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
     return i * 300 + task_result.length * 300;
   })
   .each("end", function() {
     d3.select(this)
       .transition()
       .duration(2000)
       .attr("opacity", 1.0)
   });


/*
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
