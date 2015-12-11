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
    datetimepickerJapanese();
    $('.date').datepicker({
      format: "yyyy/mm/dd",
      language: 'ja',
      autoclose: true,
      orientation: "bottom",
      todayHighlight: true
    });

    $('.new_project_button').click(function() {
      dispLoading("処理中...");
    });
    if(gon.action === "new") {
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
        $("svg").empty();

        //枠の再設定
        d3.selectAll('svg')
          .append('rect')
          .attr('class', 'frame')
          .attr({
            'class': 'frame',
            'x': 0,
            'y': 0,
            'width': 1080,
            'height': 480,
            'fill':'white',
            'stroke':'gray',
            'stroke-width':5,
            'opacity':0.5
          });

        //コミットメトリクス説明文の再作成
        d3.select("#commit_counter_graph")
            .append('text')
            .attr({
                'id': 'commit_explanation',
                'x': 540,
                'y': 460,
                    'font-size': '15px',
                'text-anchor': 'middle'
            })
            .text('チーム内の開発者のコミット回数を表すグラフ（単位：回）');

        //効率メトリクス説明文1の再作成
        d3.select("#productivity_graph")
            .append('text')
            .attr({
                'id': 'productivity_explanation1',
                'x': 540,
                'y': 40,
                'font-size': '15px',
                'text-anchor': 'middle'
            })
            .text('見積り作業時間/実績作業時間で各開発者の効率を算出している。');

        //効率メトリクス説明文2の再作成
        d3.select("#productivity_graph")
            .append('text')
            .attr({
                'id': 'productivity_explanation2',
                'x': 540,
                'y': 60,
                'font-size': '15px',
                'text-anchor': 'middle'
            })
            .text('棒グラフの棒をクリックすると、該当開発者の円グラフに遷移する。「return」ボタンを押すと、円グラフリストに戻る。');
        //グラフの生成
        commitAjax();
        costAjax();
        commentAjax();
        skillAjax();
      });
    }
  }
};

//Windowの読込が完了したらVibi.loadを実行する
window.addEventListener("load", Vibi.load, false);
