var costAjax = function() {
  $.ajax({
    type: 'post',
    url: 'productivity_ajax',
    dataType: "json",
    data: "",
    success: function(commit_data) {
    }
  })
  .done(function(commit_data) {
           create_productivity_graph();
  });
}

