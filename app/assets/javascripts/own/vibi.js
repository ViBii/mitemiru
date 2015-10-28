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
    if(gon.action === "index") {
        $('#selectProjectBtn').click(function() {
            $('#selected_project_id').val($('#project_info_project_id').val());
            ticketDigestionAjax();
            commitAjax();
        });
        //ticketDigestionAjax();
        //commitAjax();
    }
  }

};

//Windowの読込が完了したらVibi.loadを実行する
window.addEventListener("load", Vibi.load, false);
