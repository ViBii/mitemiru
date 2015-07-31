$(window).load(function() {
  $('.flexslider').flexslider();
});
//var jump = function(path){
//  link = location.host + path;
//  location.href = link.toString();
//  console.log(link);
//}

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
