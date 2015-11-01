var commitAjax = function() {
  $.ajax({
    type: 'post',
    url: 'commits_ajax',
    dataType: "json",
    data: {
        projectId: $('#selected_project_id').val()
    },
    success: function(commit_data) {
        //alert("success" + commit_data.developer_name);
    }
  })
  .done(function(commit_data) {
        create_commit_graph(commit_data.developers,commit_data.commit_count);
        costAjax();
  });
}

