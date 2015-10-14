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
    if(gon.action === "select_developer") {
      $('#redmine_auth_button').click(function() {
        signUpRedmine();
      });
    }
  };

  if(gon.controller === "comp") {
  };
  if(gon.controller === 'portfolio'){
    $('.flexslider').flexslider();
  }

  if(gon.controller === "commit") {
          showCommitsGraph();
  }

};

//Windowの読込が完了したらVibi.loadを実行する
window.addEventListener("load", Vibi.load, false);
