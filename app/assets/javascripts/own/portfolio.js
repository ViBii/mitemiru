var commitAjax = function() {
  $.ajax({
    type: 'post',
    url: '/portfolio/commits_ajax',
    data: {
      projectId: $('#project_info_id').val()
    },
    error: function(){
      costAjax();
    },
    success: function(commit_data) {
    }
  })
  .done(function(commit_data) {
    create_commit_graph(commit_data.developers,commit_data.commit_count);
    costAjax();
  });
}

var costAjax = function() {
  $.ajax({
    type: 'post',
    url: '/portfolio/productivity_ajax',
    data: {
      projectId: $('#project_info_id').val()
    },
    error: function(){
      commentAjax();
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

var commentAjax = function() {
  $.ajax({
    type: 'post',
    url: '/portfolio/comments_ajax',
    data: {
      projectId: $('#project_info_id').val()
    },
    error: function(){
      removeLoading();
    },
    success: function(comment_data) {
      //alert("success" + comment_data.nodes);
    }
  })
  .done(function(comment_data) {
    create_comment_graph(comment_data.speakers,comment_data.comments);
    removeLoading();
  });
}

var dispLoading = function(msg){
  var dispMsg = "";

  if( msg != "" ){
    dispMsg = "<div class='loadingMsg'>" + msg + "</div>";
  }
  if($("#loading").size() == 0){
    $("body").append("<div id='loading'>" + dispMsg + "</div>");
  }
}

var removeLoading = function(){
  $("#loading").remove();
}
