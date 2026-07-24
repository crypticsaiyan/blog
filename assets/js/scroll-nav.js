(function () {
  var indicator = document.querySelector('.scroll-indicator');
  var speed = 32;
  var direction = 0;
  var rafId = null;
  var pendingG = false;
  var pendingGTimeout = null;

  function setActive(dir) {
    if (!indicator) return;
    indicator.querySelectorAll('.active').forEach(function (el) {
      el.classList.remove('active');
    });
    if (dir) {
      indicator.querySelectorAll('[data-dir="' + dir + '"]').forEach(function (el) {
        el.classList.add('active');
      });
    }
  }

  function step() {
    if (direction === 0) {
      rafId = null;
      return;
    }
    window.scrollBy(0, direction * speed);
    rafId = window.requestAnimationFrame(step);
  }

  function isTypingTarget(target) {
    var tag = target && target.tagName;
    return tag === 'INPUT' || tag === 'TEXTAREA' || (target && target.isContentEditable);
  }

  document.addEventListener('keydown', function (event) {
    if (isTypingTarget(event.target)) return;

    if (event.key === 'g') {
      event.preventDefault();
      if (pendingG) {
        window.clearTimeout(pendingGTimeout);
        pendingG = false;
        window.scrollTo({ top: 0, behavior: 'smooth' });
      } else {
        pendingG = true;
        pendingGTimeout = window.setTimeout(function () {
          pendingG = false;
        }, 400);
      }
      return;
    }

    if (event.key === 'G') {
      event.preventDefault();
      pendingG = false;
      window.scrollTo({ top: document.documentElement.scrollHeight, behavior: 'smooth' });
      return;
    }

    if (event.key !== 'j' && event.key !== 'k') return;

    event.preventDefault();
    var dir = event.key === 'j' ? 1 : -1;

    if (direction !== dir) {
      direction = dir;
      setActive(dir === 1 ? 'down' : 'up');
    }

    if (!rafId) {
      rafId = window.requestAnimationFrame(step);
    }
  });

  document.addEventListener('keyup', function (event) {
    if (event.key !== 'j' && event.key !== 'k') return;

    var dir = event.key === 'j' ? 1 : -1;
    if (direction === dir) {
      direction = 0;
      setActive(null);
    }
  });
})();
