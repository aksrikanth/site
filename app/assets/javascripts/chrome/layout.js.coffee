$(document).ready () ->
  $('#sidebar_button').click (e) ->
    if $('#sidebar').hasClass('show')
      $('#sidebar').removeClass('show')
    else
      $('#sidebar').addClass('show')
    false

  $(window).click (e) ->
    if $('#sidebar').hasClass('show')
      $('#sidebar').removeClass('show')
      return false
    true

  false
