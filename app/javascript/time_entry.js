$(document).on('turbolinks:load', fillTimeFields);

$(document).on('ajax:success',  fillTimeFields);

function fillTimeFields() {
  $('#start_timer_form').submit(function() {
    $('#time_entry_start_time').val(getCurrentTime());
  })

  $('#stop_timer_form').submit(function() {
    $('#time_entry_end_time').val(getCurrentTime());
  })
}

function getCurrentTime() {
  const offsetInMs = new Date().getTimezoneOffset() * 60000;
  return new Date(new Date() - offsetInMs).toISOString().substring(0, 19);
}