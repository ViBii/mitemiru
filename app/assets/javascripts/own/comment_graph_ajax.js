var commentAjax = function() {
  $.ajax({
    type: 'post',
    url: 'comments_ajax',
    dataType: "json",
    data: {
        projectId: $('#selected_project_id').val(),
        developerId: $('#selected_developer_id').val()
    },
    success: function(comment_data) {
        //alert("success" + comment_data.nodes);
    }
  })
  .done(function(comment_data) {
          create_comment_graph(comment_data.nodes,comment_data.links);
  });
}

