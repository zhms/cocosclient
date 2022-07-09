const fs = require('fs')
const path = require('path')
const crypto = require('crypto')
const http = require('http')
const basedir = 'build/android/assets/assets/'
let versionurl = 'abunewtest.oss-me-east-1.aliyuncs.com'
let games = []
function deleteFolder(filePath) {
	const files = []
	if (fs.existsSync(filePath)) {
		const files = fs.readdirSync(filePath)
		files.forEach((file) => {
			const nextFilePath = `${filePath}/${file}`
			const states = fs.statSync(nextFilePath)
			if (states.isDirectory()) {
				deleteFolder(nextFilePath)
			} else {
				fs.unlinkSync(nextFilePath)
			}
		})
		fs.rmdirSync(filePath)
	}
}
deleteFolder(basedir + '/main')
games = fs.readdirSync(basedir)

const getfiles = (baseentry, entry, files) => {
	while (baseentry.indexOf('\\') >= 0) baseentry = baseentry.replace('\\', '/')
	while (entry.indexOf('\\') >= 0) entry = entry.replace('\\', '/')
	const dirInfo = fs.readdirSync(entry)
	dirInfo.forEach((item) => {
		const location = path.join(entry, item)
		const info = fs.statSync(location)
		if (info.isDirectory()) {
			getfiles(baseentry, location, files)
		} else {
			let file = `${location}`
			while (file.indexOf('\\') >= 0) file = file.replace('\\', '/')
			file = file.replace(baseentry, '')
			files.push(file)
		}
	})
}

try {
	fs.mkdirSync('../_packages')
} catch (error) {}

function setVersion(callback) {
	let options = {
		host: versionurl,
		path: '/version.txt',
	}
	var req = http.get(options, function (res) {
		let bodyChunks = []
		res
			.on('data', function (chunk) {
				bodyChunks.push(chunk)
			})
			.on('end', function () {
				let body = Buffer.concat(bodyChunks)
				let vfile = `../_packages/version.txt`
				if (body.indexOf('NoSuchKey') >= 0) {
					fs.writeFileSync(vfile, JSON.stringify({}))
				} else {
					fs.writeFileSync(vfile, body)
				}
				callback()
			})
	})
	req.on('error', function (e) {
		fs.writeFileSync(vfile, JSON.stringify({}))
		callback()
	})
}

setVersion(() => {
	for (let i = 0; i < games.length; i++) {
		let gameid = games[i]
		let files = []
		getfiles(basedir, basedir + `/${gameid}`, files)
		let info = {}
		for (let j = 0; j < files.length; j++) {
			let file = basedir + files[j]
			let filesize = fs.statSync(file).size
			let md5value = crypto.createHash('md5').update(fs.readFileSync(file)).digest('hex')
			info[files[j].replace(`${gameid}/`, '')] = { m: md5value, s: filesize }
		}
		fs.writeFileSync(basedir + `${gameid}/version.txt`, JSON.stringify(info))
		let version = {}
		try {
			version = JSON.parse(fs.readFileSync('build.json', 'utf-8'))
		} catch (error) {}
		let v = version[gameid] || 0
		v += 1
		let src = basedir + `${gameid}`
		fs.writeFileSync('zzcopy.bat', '@echo off\r\n')
		fs.appendFileSync('zzcopy.bat', `xcopy /D /E /I /F /Y "${src}" "../_packages/${gameid}/v${v}"\r\n`)
		version[gameid] = v
		fs.writeFileSync('build.json', JSON.stringify(version))
		let vfile = `../_packages/version.txt`
		let rv = {}
		try {
			rv = JSON.parse(fs.readFileSync(vfile, 'utf-8'))
		} catch (error) {}
		rv[`${gameid}`] = v
		fs.writeFileSync(vfile, JSON.stringify(rv))
	}
})
