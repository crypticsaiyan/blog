(function () {
  var ICON_COPY = '<svg viewBox="0 0 24 24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="12" height="12" rx="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';
  var ICON_CHECK = '<svg viewBox="0 0 24 24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';

  document.querySelectorAll('.highlighter-rouge').forEach(function (block) {
    var codeEl = block.querySelector('.rouge-code pre') || block.querySelector('.highlight pre');
    if (!codeEl) return;

    var button = document.createElement('button');
    button.className = 'copy-btn';
    button.type = 'button';
    button.setAttribute('aria-label', 'copy code');
    button.innerHTML = ICON_COPY;

    button.addEventListener('click', function () {
      navigator.clipboard.writeText(codeEl.textContent).then(function () {
        button.innerHTML = ICON_CHECK;
        button.classList.add('copied');
        button.setAttribute('aria-label', 'copied');
        window.setTimeout(function () {
          button.innerHTML = ICON_COPY;
          button.classList.remove('copied');
          button.setAttribute('aria-label', 'copy code');
        }, 1500);
      });
    });

    block.appendChild(button);
  });
})();
