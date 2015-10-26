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
    if(gon.action === "new") {
      datetimepickerJapanese();

      $('.date').datepicker({
        format: "yyyy/mm/dd",
        language: 'ja',
        autoclose: true,
        orientation: "bottom",
        todayHighlight: true
      });

      $('#new_project_button').click(function() {
        signUpRedmine();
      });
    }
  };

  if(gon.controller === "comp") {
  };
  if(gon.controller === 'portfolio'){
    //$('.flexslider').flexslider();
    //工数グラフの生成function
    if(gon.action === "productivity") {
        costAjax();
    }
    if(gon.action === "ticket_digestion") {
        ticketDigestionAjax();
        commitAjax();
    }
  }
  if(gon.controller === 'commit_counter'){
      commitAjax();
  }
  if(gon.controller === 'comments_counter'){
      commentAjax();
  }

};

//Windowの読込が完了したらVibi.loadを実行する
window.addEventListener("load", Vibi.load, false);
