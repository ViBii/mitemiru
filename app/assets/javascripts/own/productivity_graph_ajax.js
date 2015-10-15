var costAjax = function() {
  $.ajax({
    type: 'post',
    url: 'productivity_ajax',
    dataType: "json",
    data: "",
    success: function(commit_data) {
      create_productivity_graph(commit_data.tracker,commit_data.result_hours_result,commit_data.estimated_hours_result);
    }
  })
  .done(function(commit_data) {
  });
}

