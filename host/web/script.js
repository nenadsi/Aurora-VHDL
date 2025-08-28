async function postJSON(url, data) {
  const r = await fetch(url, {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data)});
  return await r.json();
}
document.getElementById('apply').addEventListener('click', async () => {
  const val = +document.getElementById('maxIter').value;
  const res = await postJSON('/api/params', {max_iter: val});
  document.getElementById('msg').textContent = 'Applied max_iter=' + res.max_iter;
});
