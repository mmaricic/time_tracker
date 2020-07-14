$(document).on('turbolinks:load', function() {
  removeElementsMarkedForDestruction();
  fillTimeFields();
  startTimer();
});

$(document).on('ajax:success', function() {
  removeElementsMarkedForDestruction();
  fillTimeFields();
  startTimer();

  $('[data-total-time]').each(function(index, el) {
    const totalTime = el.dataset.totalTime;
    el.textContent = formatTime(totalTime);
  })
});

function removeElementsMarkedForDestruction(){
  $('[data-marked-for-destruction]').remove();
}

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
      const timerValue =  Math.floor((new Date().getTime() - startTime.getTime()) / 1000);
      element.innerHTML = formatTimerValue(timerValue);
    }, 1000)
  })
}

function formatTimerValue(seconds) {
  const secs = pad(Math.floor(seconds % 60));
  const mins = pad(Math.floor(seconds / 60 % 60));
  const hours = pad(Math.floor(seconds / 3600));

  return `${hours}:${mins}:${secs}`;
}

function formatTime(seconds) {
  const secs = Math.floor(seconds % 60);
  const mins = Math.floor(seconds / 60 % 60);
  const hours = Math.floor(seconds / 3600);

  return `${hours}h ${mins}m ${secs}s`;
}


function pad(val) {
  var valString = val + "";
  if (valString.length < 2) {
    return "0" + valString;
  } else {
    return valString;
  }
}