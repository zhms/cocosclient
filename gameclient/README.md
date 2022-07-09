# 安卓打包流程

# 在 build\android\proj\gradle.properties 文件末尾添加如下代码

MobSDK.spEdition=FP
android.useAndroidX=true
android.enableJetifier=true

# 构建设置

游戏名称 bet999
游戏 ID com.bet999.game
APP ABI arm64-v8a
密钥文件 bet999.keystore
密钥库/别名密码 111111111
密钥库别名 bet999
安卓 SDK 版本 28
NDK 版本:21.0.6113669
JDK：1.8.0

# 安卓证书信息

查看方式：进入 jdk 安装（./jdk1.8.0/bin），并将 keystore 文件拷贝到该目录下进入 cmd 再执行“keytool -list -v -keystore bet999.keystore”指令,输入密码"111111111"即可看到如下信息
别名: bet999.keystore
创建日期: 2022-6-10
条目类型: PrivateKeyEntry
证书链长度: 1
证书[1]:
所有者: CN=chen, OU=panda, O=blue, L=guangdong, ST=shenzhen, C=cn
发布者: CN=chen, OU=panda, O=blue, L=guangdong, ST=shenzhen, C=cn
序列号: 5248f152
有效期为 Fri Jun 10 00:52:39 CST 2022 至 Sat Mar 13 00:52:39 CST 2077
证书指纹:
MD5: FB:3E:BD:22:05:7C:68:0A:A8:88:6F:A4:F9:31:9E:82
SHA1: 7E:BE:83:FC:AD:89:9F:90:DE:88:E3:B5:7B:22:93:E7:DC:E8:19:E0
SHA256: 5D:03:58:62:F5:3D:13:90:3E:52:38:3E:33:91:A3:D8:5D:A2:DA:98:F0:C5:C4:91:06:B1:2B:1F:4F:6D:0F:EE
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 7F 51 76 F3 68 1F 03 1F DB 4A 8B 2D E7 C0 DD AD .Qv.h....J.-....
0010: D8 7D 73 F6 ..s.
]
]

# 打包

    制作安装包不需要生成 manifest 文件，构建成功后将 .\build-templates\android\assets\main.js 文件中内容拷贝到 .\build\android\assets\main.js 文件中即可构建生成安装包

# 特别注意

    LaunchScene.ts中的 isDevelop 属性值，每次打包或者做热更时候需要在cocos creator编辑器中打开LaunchScene场景文件确认这个值的状态。当被勾选的时候为开发版，如果是生产发布版本则不能勾选，该选项决定了热更的文件服务器地址。

(function () {
if (typeof window.jsb === 'object') {
var hotUpdateSearchPaths = localStorage.getItem('HotUpdateSearchPaths');
if (hotUpdateSearchPaths) {
var paths = JSON.parse(hotUpdateSearchPaths);
jsb.fileUtils.setSearchPaths(paths);

            var fileList = [];
            var storagePath = paths[0] || '';
            var tempPath = storagePath + '_temp/';
            var baseOffset = tempPath.length;

            if (jsb.fileUtils.isDirectoryExist(tempPath) && !jsb.fileUtils.isFileExist(tempPath + 'project.manifest.temp')) {
                jsb.fileUtils.listFilesRecursively(tempPath, fileList);
                fileList.forEach(srcPath => {
                    var relativePath = srcPath.substr(baseOffset);
                    var dstPath = storagePath + relativePath;

                    if (srcPath[srcPath.length] == '/') {
                        jsb.fileUtils.createDirectory(dstPath)
                    }
                    else {
                        if (jsb.fileUtils.isFileExist(dstPath)) {
                            jsb.fileUtils.removeFile(dstPath)
                        }
                        jsb.fileUtils.renameFile(srcPath, dstPath);
                    }
                })
                jsb.fileUtils.removeDirectory(tempPath);
            }
        }
    }

})();

测试服:
(function () {
if (typeof window.jsb === 'object') {
localStorage.setItem("_develop_","true")
localStorage.setItem("UPDATEURL","https://api-dubai.c92.xyz")
localStorage.setItem("HTTPSURL","https://ce-api.c90.xyz")
localStorage.setItem('SIGNKEY',"mCF2VImR&bytw4sgasg24ASGSlYI5!EGj0z4MYo1aK5KNt4SU!M17hNuaDYu!W")
localStorage.setItem('PACKAGEID',"52011")
var hotUpdateSearchPaths = localStorage.getItem('HotUpdateSearchPaths');
if (hotUpdateSearchPaths) {
var paths = JSON.parse(hotUpdateSearchPaths);
jsb.fileUtils.setSearchPaths(paths);
}
}
})();

正式服:
(function () {
if (typeof window.jsb === 'object') {
localStorage.setItem("_develop_","false")
localStorage.setItem("UPDATEURL","https://api-dubai.c92.xyz")
localStorage.setItem("HTTPSURL","https://ohfd.xyz")
localStorage.setItem('SIGNKEY',"mCF2VImR&bytw4sgasg24ASGSlYI5!EGj0z4MYo1aK5KNt4SU!M17hNuaDYu!W")
localStorage.setItem('PACKAGEID',"2011")
var hotUpdateSearchPaths = localStorage.getItem('HotUpdateSearchPaths');
if (hotUpdateSearchPaths) {
var paths = JSON.parse(hotUpdateSearchPaths);
jsb.fileUtils.setSearchPaths(paths);
}
}
})();

(function () {
if (typeof window.jsb === 'object') {
localStorage.setItem("_develop_","false")
localStorage.setItem("UPDATEURL","https://hall-hot.wums.xyz")
localStorage.setItem("HTTPSURL","https://ohfd.xyz")
localStorage.setItem('SIGNKEY',"mCF2VImR&bytw4sgasg24ASGSlYI5!EGj0z4MYo1aK5KNt4SU!M17hNuaDYu!W")
localStorage.setItem('PACKAGEID',"2011")
var hotUpdateSearchPaths = localStorage.getItem('HotUpdateSearchPaths');
if (hotUpdateSearchPaths) {
var paths = JSON.parse(hotUpdateSearchPaths);
jsb.fileUtils.setSearchPaths(paths);
}
}
})();

if(!localStorage.getItem("showvideo")) localStorage.setItem("showvideo","true")
localStorage.setItem("engineversion","1")
localStorage.setItem("defaultlang","zh")
localStorage.setItem("UPDATEURL","https://abunewtest.oss-me-east-1.aliyuncs.com")
