var signUpRedmine = function() {
  $.ajax({
    type: 'post',
    url: 'auth_redmine',
    data: {
      url: $('#url').val(),
      login_name: $('#login_name').val(),
      password_digest: $('#password_digest').val(),
      api_key: $('#api_key').val()
    }
  })
  .done(function(returnData) {
    $('#addArea').append('<li>' + returnData + '</li>');
  });
}
