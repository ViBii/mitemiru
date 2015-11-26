var Vibi = Vibi || {};
var gon = gon || {};

function jump(action, method) {
  var form = document.createElement('form');
  document.body.appendChild( form );
  var input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  form.appendChild( input );
  form.setAttribute('action', action);
  form.setAttribute('method', method);
  form.submit();
}

Vibi.load = function(e) {
  if(gon.controller === "projects") {
    $('.new_project_button').click(function() {
      dispLoading("処理中...");
    });
    if(gon.action === "new") {
      datetimepickerJapanese();

      $('.date').datepicker({
        format: "yyyy/mm/dd",
        language: 'ja',
        autoclose: true,
        orientation: "bottom",
        todayHighlight: true
      });
    }else if(gon.action === "confirm"){
      removeLoading();
    }else if(gon.action === "index"){
      removeLoading();
    }
  };

  if(gon.controller === 'portfolio'){
    if(gon.action === "index") {
      $('#selectProjectBtn').click(function() {
        dispLoading("処理中...");

        //前回実行したグラフの削除
        //$("svg").remove();
          $("svg").empty();

         // 既存の枠の削除
         d3.selectAll('svg')
           .selectAll('.frame')
           .transition()
           .duration(500)
           .attr({
             'opacity': 0
           });

        // svg領域のリセット
        d3.selectAll('svg')
          .transition()
          .delay(500)
          .empty();

        d3.selectAll('svg')
          .transition()
          .delay(500)
          .attr({
            'height': 480
          });

        //枠の再設定
        d3.selectAll('svg')
          .append('rect')
          .attr('class', 'frame')
          .transition()
          .delay(500)
          .attr({
            'x': 0,
            'y': 0,
            'width': 1080,
            'height': 480,
            'fill':'white',
            'stroke':'gray',
            'stroke-width':5,
            'opacity':0
          })
          .transition()
          .duration(500)
          .attr({
            'opacity': 0.5
          });

        //グラフの生成
        commitAjax();
        costAjax();
        commentAjax();
      });
    }
  }
};

//Windowの読込が完了したらVibi.loadを実行する
window.addEventListener("load", Vibi.load, false);
