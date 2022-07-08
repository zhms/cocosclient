import { _decorator, Component, Node, assetManager } from 'cc'
const { ccclass, property } = _decorator
@ccclass('LoginScene')
export class LoginScene extends Component {
	start() {
		let bundle = assetManager.getBundle('hall')
		console.log('fuckc', bundle)
	}
}
