this.onload = function () {
  document.body.innerHTML = tinydown(
    (document.body.textContent || document.body.innerText).replace(
      /^[\s\S]+?echomd '([\s\S]+?)'.*$/, '$1'
    )
  );
};