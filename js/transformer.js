// archibold.io, by Andrea Giammarchi @WebReflection
this.onload = function () {

  // keep styles in the page
  for (var
    d = document,
    html = d.documentElement.style,
    head = d.head || d.getElementsByTagName('head')[0],
    body = d.body,
    el = d.getElementsByTagName('link'),
    i = 0; i < el.length; i++
  ) {
    head.appendChild(el[i]);
  }

  // write markdown instead of text
  body.innerHTML = (new showdown.Converter()).makeHtml(
    (body.textContent || body.innerText).replace(
      /^[\s\S]*?echomd '([\s\S]+?)'[\s\S]*$/, '$1'
    )
  );

  html.transition = 'opacity .8s ease-out';
  setTimeout(function(){ html.opacity = 1; }, 200);

};