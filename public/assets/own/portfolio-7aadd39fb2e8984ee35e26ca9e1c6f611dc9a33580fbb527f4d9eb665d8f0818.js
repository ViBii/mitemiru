var commitAjax = function() {
  dispLoading("処理中...");
  $('#selectProjectBtn').prop('disabled', true);

  commitReq = $.ajax({
    type: 'post',
    url: '/portfolio/commits_ajax',
    data: {
      project_id: $('#project_info_id').val()
    },
    error: function(){
      d3.select("#commit_counter_graph")
        .append('text')
        .attr({
          'x': 540,
          'y': 240,
          'font-size': '20px',
          'text-anchor': 'middle',
          'dominant-baseline': 'middle'
        })
      .text('データの取得に失敗しました');
    },
    success: function(commit_data) {
    }
  })
  .done(function(commit_data) {
    create_commit_graph(commit_data.developers,commit_data.commit_count);
    commitReq = false;
  });
}

var costAjax = function() {
  costReq = $.ajax({
    type: 'post',
    url: '/portfolio/productivity_ajax',
    data: {
      project_id: $('#project_info_id').val()
    },
    error: function(){
      d3.select("#productivity_graph")
          .append('text')
          .attr({
            'x': 540,
            'y': 240,
            'font-size': '20px',
            'text-anchor': 'middle',
            'dominant-baseline': 'middle'
          })
          .text('データの取得に失敗しました');
      //commentAjax();
    },
    success: function(data) {
    }
  })
  .done(function(data) {
    create_productivity_graph(data.developers, data.trackers, data.prospect, data.result);
    costReq = false;
  });
}

var commentAjax = function() {
  commentReq = $.ajax({
    type: 'post',
    url: '/portfolio/comments_ajax',
    data: {
      project_id: $('#project_info_id').val()
    },
    error: function(){
      d3.select("#comments_counter_graph")
        .append('text')
        .attr({
          'x': 540,
          'y': 240,
          'font-size': '20px',
          'text-anchor': 'middle',
          'dominant-baseline': 'middle'
        })
      .text('データの取得に失敗しました');
      removeLoading();
    },
    success: function(comment_data) {
    }
  })
  .done(function(comment_data) {
    console.log(comment_data);
    create_comment_graph(comment_data.speakers,comment_data.comments);
    commentReq = false;

    removeLoading();
    $('#selectProjectBtn').prop('disabled', false);
  });
}

var skillAjax = function() {
    comment_req = $.ajax({
        type: 'post',
        url: '/portfolio/skills_ajax',
        data: {
            project_id: $('#project_info_id').val()
        },
        error: function(){
            removeLoading();
        },
        success: function(comment_data) {
        }
    })
        .done(function(comment_data) {
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

// var killAjax = function(){
//   console.log(commentReq);
//   console.log(costReq);
//   console.log(commentReq);
//   if(commitReq){
//     commitReq.abort();
//     commitReq = false;
//   }
//   if(costReq){
//     costReq.abort();
//     costReq = false;
//   }
//   if(commentReq){
//     commentReq.abort();
//     commentReq = false;
//   }
// }
