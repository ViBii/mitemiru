var Vibi = Vibi || {};
var gon = gon || {};
var commitReq;
var costReq;
var commentReq;

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
                'y': 30,
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
                'y': 30,
                'font-size': '15px',
                'text-anchor': 'middle'
            })
            .text('このグラフは作業効率を表すグラフである。作業効率は以下の数式で計算している：見積り作業時間/実績作業時間');

        //効率メトリクス説明文2の再作成
        d3.select("#productivity_graph")
            .append('text')
            .attr({
                'id': 'productivity_explanation2',
                'x': 540,
                'y': 50,
                'font-size': '15px',
                'text-anchor': 'middle'
            })
            .text('グラフの中の元素をクリックし、画面が遷移できる。');
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
