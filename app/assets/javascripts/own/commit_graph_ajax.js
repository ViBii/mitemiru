var commitAjax = function() {
  $.ajax({
    type: 'post',
    url: 'commits_ajax',
    dataType: "json",
    data: {
        projectId: $('#selected_project_id').val(),
        developerId: $('#selected_developer_id').val()
    },
    success: function(commit_data) {
        //alert("success" + commit_data.developer_name);
    }
  })
  .done(function(commit_data) {
        //$('#detail').html("開発者の人数は合計" + commit_data.total_developers + "人です。<br>コミット率は" + commit_data.commit_rate +"%です。");
        create_commit_graph(commit_data.all_commit,commit_data.own_commit,commit_data.developer_name);
        costAjax();
  });
}

