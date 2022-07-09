import { _decorator, Component, VideoPlayer, find, sys, assetManager, Prefab, instantiate, math, Label, game } from 'cc'
const { ccclass, property } = _decorator
@ccclass('Update')
export class Update extends Component {
	@property({ type: VideoPlayer, tooltip: '视频播放组件' })
	video: VideoPlayer = null
	private _downloader: jsb.Downloader
	private _videofinish: Boolean = true
	private _updatejsfinish: Boolean = false
	start() {
		if (sys.isNative) {
			this._get_updatejs(0)
			let showvideo = localStorage.getItem('showvideo')
			if (showvideo == 'true') {
				this._videofinish = false
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
						this._videofinish = true
						this.node.parent.getChildByPath('bgImg').active = true
						this.node.getChildByPath('UpdateNode').active = true
						this._doupdate()
					},
					this
				)
			} else {
				this.node.parent.getChildByPath('bgImg').active = true
				this.node.getChildByPath('UpdateNode').active = true
				this.node.getChildByPath('UpdateNode/ProgressNode/ProgressBar').active = false
			}
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
	private _get_updatejs(trycount) {
		console.log('abu', '*********************update*********************')
		trycount = trycount || 0
		jsb.fileUtils.addSearchPath(jsb.fileUtils.getWritablePath(), false)
		let remoteurl = localStorage.getItem('UPDATEURL') + '/update.js?t=' + Math.floor(Math.random() * 100)
		console.log('abu', remoteurl)
		this.node.getChildByPath('UpdateNode/ProgressNode/lblPercent').getComponent(Label).string = '正在更新信息···'
		this._downloader = new jsb.Downloader()
		let savepath = jsb.fileUtils.getWritablePath() + 'update.js'
		if (jsb.fileUtils.isFileExist(savepath)) jsb.fileUtils.removeFile(savepath)
		this._downloader.createDownloadFileTask(remoteurl, savepath)
		this._downloader.setOnTaskError(() => {
			if (trycount < 10) {
				setTimeout(() => {
					this._get_updatejs(trycount + 1)
				}, 1000)
			} else {
				this.node.getChildByPath('UpdateNode/ProgressNode/lblPercent').getComponent(Label).string = '获取更新信息失败,系统将在5秒后重试···'
				setTimeout(() => {
					game.restart()
				}, 5000)
			}
		})
		this._downloader.setOnFileTaskSuccess(() => {
			this._updatejsfinish = true
			this._doupdate()
		})
	}
	private _doupdate() {
		if (this._videofinish) {
			this.node.getChildByPath('UpdateNode').active = true
			this.node.getChildByPath('UpdateNode/ProgressNode/ProgressBar').active = false
		}
		if (this._updatejsfinish && this._videofinish) {
			let updatejs = jsb.fileUtils.getStringFromFile('update.js')
			eval(updatejs)
		}
	}
}
