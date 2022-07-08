import { _decorator, Component, VideoPlayer, find, sys, assetManager, Prefab, instantiate, math } from 'cc'
const { ccclass, property } = _decorator
@ccclass('Update')
export class Update extends Component {
	@property({ type: VideoPlayer, tooltip: '视频播放组件' })
	video: VideoPlayer = null
	private _downloader: jsb.Downloader
	start() {
		if (sys.isNative) {
			this.check()
		} else {
			this.node.parent.getChildByPath('bgImg').active = true
			let bundlename = sys.isNative ? jsb.fileUtils.getWritablePath() + 'hall' : 'hall'
			assetManager.loadBundle(bundlename, (berr, bundle) => {
				if (berr) return console.log(berr)
				bundle.load('login/prefab/login', Prefab, (perr, prefab) => {
					if (perr) return console.log(perr)
					this.node.parent.getChildByName('hall').addChild(instantiate(prefab))
				})
			})
		}
	}
	private check() {
		console.log('abu', '*********************update*********************')
		jsb.fileUtils.addSearchPath(jsb.fileUtils.getWritablePath(), false)
		let remoteurl = localStorage.getItem('UPDATEURL') + '/update.js?t=' + Math.random()
		console.log('abu', remoteurl)
		this._downloader = new jsb.Downloader()
		let savepath = jsb.fileUtils.getWritablePath() + 'update.js'
		if (jsb.fileUtils.isFileExist(savepath)) jsb.fileUtils.removeFile(savepath)
		this._downloader.createDownloadFileTask(remoteurl, savepath)
		this._downloader.setOnTaskError(() => {})
		this._downloader.setOnFileTaskSuccess(() => {
			let updatejs = jsb.fileUtils.getStringFromFile('update.js')
			eval(updatejs)
		})
	}
}
