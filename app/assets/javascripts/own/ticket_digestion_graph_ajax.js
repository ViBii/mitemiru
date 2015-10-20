var ticketDigestionAjax = function() {
  $.ajax({
    type: 'post',
    url: 'ticket_digestion_ajax',
    dataType: "json",
    data: {
      projectId: $('#selected_project_id').val(),
      developerId: $('#selected_developer_id').val()
    },
    success: function(ticket_data) {
        //alert("success " + ticket_data.firstName);
    }
  })
  .done(function(ticket_data) {
        $('#ticket_digestion_graph_h1').html(ticket_data.lastName + " " + ticket_data.firstName + "さんのチケット消化数");
        $('#ticket_digestion_graph_p').html("開発者名: " + ticket_data.lastName + " " + ticket_data.firstName + "<br />" + "プロジェクト名: " + ticket_data.projectName + "<br />");
        create_ticket_digestion_graph(ticket_data.tracker,ticket_data.ticket_num,ticket_data.ticket_num_all);
  });
}

