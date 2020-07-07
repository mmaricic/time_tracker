$(document).on('turbolinks:load', function() {
  fillTimeFields();
  startTimer();
});

$(document).on('ajax:success', function() {
  fillTimeFields();
  startTimer();
});

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

function startTimer() {
  $('[data-timer]').each(function(index, element) {
    const startTime = new Date(element.dataset.timer);
   
    const timerValue =  (new Date().getTime() - startTime.getTime()) / 1000;
    element.innerHTML = formatTimerValue(timerValue);
    setInterval(function() {
      const timerValue =  (new Date().getTime() - startTime.getTime()) / 1000;
      element.innerHTML = formatTimerValue(timerValue);
    }, 1000)
  })
}

function formatTimerValue(seconds) {
  const secs = pad(Math.round(seconds % 60));
  const mins = pad(Math.round(seconds / 60 % 60));
  const hours = pad(Math.round(seconds / 3600));

  return `${hours}:${mins}:${secs}`;
}

function pad(val) {
  var valString = val + "";
  if (valString.length < 2) {
    return "0" + valString;
  } else {
    return valString;
  }
}