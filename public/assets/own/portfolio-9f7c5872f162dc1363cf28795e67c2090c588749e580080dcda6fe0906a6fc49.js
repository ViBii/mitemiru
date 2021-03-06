var commitAjax = function() {
  commit_req = $.ajax({
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
    //costAjax();
  });
}

var costAjax = function() {
  cost_req = $.ajax({
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
    //commentAjax();
  });
}

var commentAjax = function() {
  comment_req = $.ajax({
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
