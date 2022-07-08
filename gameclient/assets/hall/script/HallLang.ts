export default class HallLang {
	private static _langid: Number = -2 //-2未初始化,-1中文,0英语,1泰语
	private static getLangCode() {
		return localStorage.getItem('language')
	}
	public static get(word) {
		if (HallLang._langid == -2) {
			let langsymbol = localStorage.getItem('language')
			if (!langsymbol) langsymbol = 'zh'
			if (langsymbol == 'zh') {
				HallLang._langid == -1
			} else if (langsymbol == 'en') {
				HallLang._langid == 0
			} else if (langsymbol == 'th') {
				HallLang._langid == 1
			} else {
				HallLang._langid == -1
			}
		}
		let words = HallLang._lang[word]
		if (!words) {
			console.log('语言未定义:', word)
			return word
		}
		if (HallLang._langid == -1) return word
		return words[HallLang._langid]
	}
	private static _lang: Object = {
		测试: ['test', 'thtest'],
	}
}
