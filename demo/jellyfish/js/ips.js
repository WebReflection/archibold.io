fetch('/ips').then(b => b.json()).then(ips => {
  document.getElementById('ips').innerHTML = ips.join('<br>');
});

document.addEventListener('keypress', ({key, ctrlKey, metaKey}) => {
  if (key === 'q' && (ctrlKey || metaKey))
    fetch('/quit').catch(Object);
});
