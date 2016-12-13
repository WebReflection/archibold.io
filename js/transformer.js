// archibold.io, by Andrea Giammarchi @WebReflection
this.onload = function () {

  // keep styles in the page
  for (var
    tmp = document.head || document.getElementsByTagName('head')[0],
    el = document.getElementsByTagName('link'),
    i = 0; i < el.length; i++
  ) {
    tmp.appendChild(el[i]);
  }

  // write markdown instead of text
  document.body.innerHTML = (new showdown.Converter()).makeHtml(
    (document.body.textContent || document.body.innerText).replace(
      /^[\s\S]*?echomd '([\s\S]+?)'[\s\S]*$/, '$1'
    )
  );

};