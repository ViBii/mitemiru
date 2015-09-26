var signUpRedmine = function() {
  $.ajax({
    type: 'post',
    url: 'select_developer',
    data: {
      url: $('#url').val(),
      login_id: $('#login_id').val(),
      password_digest: $('#password_digest').val(),
      api_key: $('#api_key').val()
    }
  })
  .done(function(returnData) {
    $('#addArea').append(returnData);
  });
}

