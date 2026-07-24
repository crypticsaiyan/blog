(function () {
  var interactiveSelector = 'a, button, [data-hoverable="true"]';
  var cursor = document.querySelector('.cursor');
  if (!cursor) return;

  document.addEventListener('mousemove', function (event) {
    cursor.style.left = (event.clientX - 20) + 'px';
    cursor.style.top = (event.clientY - 20) + 'px';
    cursor.classList.toggle('hover-link', Boolean(event.target.closest(interactiveSelector)));
  });

  document.addEventListener('click', function () {
    cursor.classList.add('click');
    window.setTimeout(function () {
      cursor.classList.remove('click');
    }, 200);
  });
})();
