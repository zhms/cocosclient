console.log('*********************remote update*********************')
let updateurl = localStorage.getItem('UPDATEURL')
localStorage.setItem('showvideo', 'false')
let doupdate
let downloader = new jsb.Downloader()
setTimeout(() => doupdate(), 1)
doupdate = () => {
	// let parent = this.node.parent
	// this.node.removeFromParent()
	// assetManager.loadBundle('hall', (berr, bundle) => {
	// 	if (berr) return console.log(berr)
	// 	bundle.load('login/prefab/login', Prefab, (perr, prefab) => {
	// 		if (perr) return console.log(perr)
	// 		parent.getChildByName('hall').addChild(instantiate(prefab))
	// 	})
	// })
	this.node.getChildByPath('UpdateNode').active = true
	this.node.getChildByPath('UpdateNode/ProgressNode/ProgressBar').active = false
	this.node.getChildByPath('UpdateNode/ProgressNode/lblPercent').node.getco
	let remoteurl = `${updateurl}/version.txt`
	let savepath = jsb.fileUtils.getWritablePath() + 'version.txt'
	if (jsb.fileUtils.isFileExist(savepath)) jsb.fileUtils.removeFile(savepath)
	this._downloader.createDownloadFileTask(remoteurl, savepath)
	this._downloader.setOnTaskError(() => {})
	this._downloader.setOnFileTaskSuccess(() => {
		let versionstr = jsb.fileUtils.getStringFromFile('version.txt')
		let jversion = JSON.parse(versionstr)
	})
}
