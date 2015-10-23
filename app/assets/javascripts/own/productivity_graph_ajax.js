var costAjax = function() {
  $.ajax({
    type: 'post',
    url: 'productivity_ajax',
    dataType: "json",
    data: {
        projectId: $('#selected_project_id').val(),
        developerId: $('#selected_developer_id').val()
    },
    success: function(commit_data) {

    }
  })
  .done(function(commit_data) {
        create_productivity_graph(commit_data.tracker,commit_data.result_hours_result,commit_data.estimated_hours_result);
        commentAjax();
  });
}

