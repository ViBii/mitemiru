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
  $(function(){
    setTimeout(function(){
      $('.alert').fadeOut("slow");
    }, 1500);
  });

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

        //変動したsvgの高さを一致にする
        d3.selectAll('svg')
            .attr({
                'height': 840
            });

        //枠の設定
        d3.selectAll('svg')
            .append('rect')
            .attr({
                    'x': 0,
                    'y': 0,
                    'width': 1160,
                    'height': 840,
                    'fill':'white',
                    'stroke':'gray',
                    'stroke-width':5,
                    'opacity':0.5
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
