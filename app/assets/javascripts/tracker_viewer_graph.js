var tracker_category = gon.tracker_category;
var ticket_num = gon.ticket_num;
var ticket_num_all = gon.ticket_num_all;
var color = d3.scale.category20();

document.write("<p>");
for (var i=0; i<tracker_category.length; i++) {
  document.write(tracker_category[i]+": "+ticket_num[i]+" <br />");
}
document.write("Total: "+ticket_num_all);
document.write("</p>");
