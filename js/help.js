document.addEventListener(
  'DOMContentLoaded',
  function () {
    alert(document.body.textContent.replace(/^[\s\S]+?echomd '[\s\S]+?'.*$/, '$1'));
  }
);