#各平台配置

&Facebook：
	AppId : 441880973935033
	Token : bc76b34584429245b5de939a83b3acfa
	Display name : 999.bet
&Line:
	ChannelID : 1657207579
&Mob:
	AppKey : 3611813ed37f5
	AppSecret : 537612016deaea225d9ed9c569b80d49
	URL Schemes : q52link
&Universal Link:
	applinks:69b34587037d37c04befd938eaf37be0.share2dlink.com
	applinks:cblj.t4m.cn

#cocos 设置
	同Android，构建时平台改成IOS，填好应用ID和开发者账号即可

#Xcode 设置
	首先将cocos工程目录下 native\engine\ios路径中的SDK文件夹拖入到Xcode工程中，勾选 Copy items if needed ，add targets选择（cocos构建设置的游戏名称）+‘-mobile’。
	添加完毕后，在project——‘-mobile’——General中添加库，按照frameworks.png一一添加

	将界面转到 Signing&Capabilities，点击 All前的加号，添加 Associated Domains支持，之后在Domains中 添加 Universal Link

	转到Info,如果第三方内容有所改动，需要在这更改对应内容，其中LINE 的 URL Schemes 需要改为 line3rdp.+bundle id。其余具体设置参照 infolist.png。

	转到Build Settings，按照 BuildSetting1.png, BuildSetting2.png的顺序修改设置。之后便可以build打包。

#IOS资源打包
	为免打包ipa以及打包大厅资源及游戏资源产生混乱，需要分为三个cocos工程，一个用以打包ipa，一个打包大厅资源，一个打包子游戏资源。

&打包大厅资源
	将工程内子游戏资源删除，如果拉取后有子游戏资源更新也记得删除。
	构建完成后，在xclient目录下打开终端，执行：
		node version_generator.js -v 1.0.3 -u https://test-exc-image.oss-cn-hongkong.aliyuncs.com/hotUpdate/ios/    -s build/android-002/assets -d assets/
	其中 -v为大厅版本号， -u为热更新目录，-s 为构建出的工程路径,  
	构建完成后会在xclient/assets下生成project.manifest 与 version.manifest，将这两个文件拷贝到构建出的工程的assets目录下，之后将assets、 src、 project.manifest、 version.manifest一起上传到服务器即可
&打包子游戏
	构建，构建完毕后打开到构建的Ios文件夹下，把xclient路径下的 version_generator.js放到remote 同级的路径下，如果打出的子游戏资源不在remote下也一并放在里面
	打开终端，输入：
		node  version_game_generator.js -v 1.0.1 -u https://test-exc-image.oss-cn-hongkong.aliyuncs.com/hotUpdate/ios/   -s remote  -g 1003
	其中 -v为子游戏版本号， -u为热更新目录， -g 为子游戏ID
	执行完毕会在子游戏文件夹下生成 游戏ID+project.manifest文件
	所有子游戏生成完毕之后将子游戏文件夹上传到服务器

