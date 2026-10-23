(function () {
  "use strict";

  var THRESHOLD_DAYS = 30;
  var timeEl = document.querySelector("time.now-last-updated[data-last-updated]");
  if (!timeEl) {
    return;
  }

  var iso = timeEl.getAttribute("data-last-updated");
  if (!iso || !/^\d{4}-\d{2}-\d{2}$/.test(iso)) {
    return;
  }

  var parts = iso.split("-");
  var updated = Date.UTC(
    Number(parts[0]),
    Number(parts[1]) - 1,
    Number(parts[2])
  );
  var now = new Date();
  var today = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
  var days = (today - updated) / 86400000;

  var mark = document.querySelector(".now-staleness");
  if (!mark) {
    return;
  }

  mark.classList.remove("now-staleness--fresh", "now-staleness--stale");
  if (days < THRESHOLD_DAYS) {
    mark.classList.add("now-staleness--fresh");
  } else {
    mark.classList.add("now-staleness--stale");
  }
  mark.hidden = false;
  mark.setAttribute("aria-hidden", "false");
  mark.title =
    days < THRESHOLD_DAYS
      ? "Updated within the last 30 days"
      : "Updated 30 or more days ago";
})();
