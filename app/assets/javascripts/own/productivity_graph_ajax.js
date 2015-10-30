var costAjax = function() {
  $.ajax({
    type: 'post',
    url: 'productivity_ajax',
    dataType: "json",
    data: {
        projectId: $('#selected_project_id').val()
    },
    success: function(data) {

    }
  })
  .done(function(data) {
        //alert(data.prospect[9][3]);
        //alert(data.result[3][3]);
        create_productivity_graph(data.developers, data.trackers, data.prospect, data.result);
        commentAjax();
  });
}

