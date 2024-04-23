# GODOT ASTEROIDS

### Export as Web with compressed wasm

- Export project as Web (without *Extension Support*, *For Desktop*). Make sure the html file name is *asteroids*.
- Gzip **asteroids.wasm** and rename it again to **asteroids.wasm**
- Download Pako https://raw.githubusercontent.com/nodeca/pako/master/dist/pako_inflate.min.js
- Open **asteroids.html** and add this `<script type="text/javascript" src="pako_inflate.min.js"></script>` line just before the line `<script type="text/javascript" src="asteroids.js"></script>`
- Open **asteroids.js** and edit this function like this:
```
	function loadFetch(file, tracker, fileSize, raw) {
		tracker[file] = {
			total: fileSize || 0,
			loaded: 0,
			done: false,
		};
		return fetch(file).then(function (response) {
			if (!response.ok) {
				return Promise.reject(new Error(`Failed loading file '${file}'`));
			}
			const tr = getTrackedResponse(response, tracker[file]);
			if (raw) {
				if (file === "asteroids.wasm") {
					return Promise.resolve(tr.arrayBuffer().then( buffer => {
						return new Response(pako.inflate(buffer), { headers: tr.headers })
					}));
				} else {
					return Promise.resolve(tr);
				}
			}
			return tr.arrayBuffer();
		});
	}
```

### Deploy it in Cloudflare

Compressed wasm required due to 25 Mb file size limitation. Additionally, you must create a file **_headers** with the following:
```
/*
	Access-Control-Allow-Origin: *
	Cross-Origin-Opener-Policy: same-origin
	Cross-Origin-Embedder-Policy: require-corp
```
