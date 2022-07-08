let doupdate
let showvideo = false
if (showvideo) {
	this.video.node.active = true
	this.video.node.on(
		'ready-to-play',
		(event) => {
			this.video.play()
		},
		this
	)
	this.video.node.on(
		'completed',
		(event) => {
			this.video.node.active = false
			doupdate()
		},
		this
	)
} else {
	setTimeout(() => doupdate(), 1)
}
doupdate = () => {
	localStorage.setItem('showvideo', 'true')
	this.node.parent.getChildByPath('bgImg').active = true
	assetManager.loadBundle('hall', (berr, bundle) => {
		if (berr) return console.log(berr)
		bundle.load('login/prefab/login', Prefab, (perr, prefab) => {
			if (perr) return console.log(perr)
			this.node.parent.getChildByName('hall').addChild(instantiate(prefab))
		})
	})
}
