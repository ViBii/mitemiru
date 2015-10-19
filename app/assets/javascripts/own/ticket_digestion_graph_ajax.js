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
        alert("success " + ticket_data.a);
    }
  })
  .done(function(ticket_data) {
          //$('#detail').html("開発者の人数は合計" + commit_data.total_developers + "人です。<br>コミット率は" + commit_data.commit_rate +"%です。");
          //create_commit_graph(commit_data.all_commit,commit_data.own_commit,commit_data.developer_name);
  });
}

