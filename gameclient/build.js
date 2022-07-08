const fs = require('fs')
const path = require('path')
const crypto = require('crypto')
const basedir = 'build/windows/assets/assets/'
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

for (let i = 0; i < games.length; i++) {
	let gameid = games[i]
	let files = []
	getfiles(basedir, basedir + `/${gameid}`, files)
	let info = {}
	for (let j = 0; j < files.length; j++) {
		let file = basedir + files[j]
		let filesize = fs.statSync(file).size
		let md5value = crypto.createHash('md5').update(fs.readFileSync(file)).digest('hex')
		info[files[j]] = { m: md5value, s: filesize }
	}
	fs.writeFileSync(basedir + `/${gameid}/version.txt`, JSON.stringify(info))
}

let version = {}
try {
	version = JSON.parse(fs.readFileSync('build.json', 'utf-8'))
} catch (error) {}

console.log(version)
