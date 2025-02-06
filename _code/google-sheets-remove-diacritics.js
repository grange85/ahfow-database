/**
 * Removes all diacritics from a string and replace some letters without diacritics considered as letters with diacritics or ligatures
 *
 * Note: This function normalises the characters, therefore if you use some characters that are combined with non-diacritics, it will be returned decomposed.
 *
 * TODO: Replace more ligatures (like `ﬁ`, `ffl`, `ﬀ`, `ﬂ`, `ﬆ`).
 *
 * TODO: Add support for German-like replacements (e.g. `Ä` → `Ae`, `Ü` → `Ue`).
 *
 * This function is based on many answers from https://stackoverflow.com/questions/990904/remove-accents-diacritics-in-a-string-in-javascript
 *
 * * Tested with 'ÁàÀĂăâÂǎǍåÅäÄãÃȧȦąĄāĀạAʾá̱Á̱ǻǺᵫẚẠæÆǽǼḅḄćĆĉĈčČçÇďĎḋḊḑḐđĐḍḌéÉèÈêÊěĚëËẽẼĔĕėĖȩȨęĘēĒẹẸḟḞǵǴĞğĝĜǧǦġĠģĢḡḠĥĤȟȞḣḢḩḨḥḤíÍìÌîÎǐǏïÏĩĨİīĪĬĭịỊỊ̣ıĵĴȷḱḰǩǨķĶḳḲĺĹľĽļĻŁłḷḶŀĿḿḾṁṀṃṂńŃǹǸňŇñÑṅṄņŅṇṆóÓŏŎọỌòÒôÔǒǑöÖőŐõÕȯȮǫǪōŌŎŏœŒœ́Œ́œ̀Œ̀œ̂Œ̂œ̃Œ̃œ̨Œ̨œ̨̃Œ̨̃œ̄Œ̄œ̄́Œ̄́œ̄̆Œ̄̆œ̄̃Œ̄̃œ̯Œ̯œ̣Œ̣ṕṔṗṖřŘṙṘŗŖṛṚśŚŝŜšŠṡṠşŞṣṢșȘßẞťŤṫṪţŢṭṬțȚúÚùÙûÛǔǓůŮüÜǘǗǜǛǚǙűŰũŨųŲūŪụỤŬŭṽṼṿṾẃẂẁẀŵŴW̊ẘẅẄẉẈẍẌẋẊýÝỳỲŷŶY̊ẙỹỸẏẎȳȲỵỴźŹẑẐžŽżŻẓẒ'
 *
 * @param      {string}  text    Text with diacritics
 * @return     {string}  Text with diacritics removed
 * @customfunction
 */
function removeDiacritics(text) {
	const replacements = {
		ß: 'ss',
		ẞ: 'SS',
		æ: 'ae',
		Æ: 'Ae',
		ø: 'o',
		Ø: 'O',
		đ: 'd',
		Đ: 'D',
		ı: 'i',
		ŀ: 'l',
		Ŀ: 'L',
		Ł: 'L',
		ł: 'l',
		œ: 'oe',
		Œ: 'Oe',
		ȷ: 'j',
		ᵫ: 'ue',
		ẚ: 'a',
		ﬁ: 'fi',
		ffl: 'ffl',
		ﬀ: 'ff',
		ﬂ: 'fl',
		ﬆ: 'st'
	}

	// Define an array of characters to keep unchanged, even if they are in `replacement`
	const charsToKeep = [
		// Uppercase and lowercase letters, numbers and underscore (same as `[A-Za-z0-9_]`)
		'\\w',
		// Whitespace characters (same as `[ \t\r\n\f]`)
		'\\s',
		// A list of special characters to match; all but `\'` (`'`) and `\\` (`\`) are matched literally in this list
		'!"#$%&\'()*+,./:;<=>?@[\\]^`{|}~£¬-'
	]

	const re = new RegExp(`[^${charsToKeep}]`, 'g')

	return text
		// Normalise to NFD Unicode normal form to decompose combined characters into the combination of simple ones
		// src: https://stackoverflow.com/a/37511463/3408342
		.normalize('NFD')
		// Remove all diacritics
		.replace(/\p{Diacritic}/gu, '')
		// Replace letters without diacritics (ligatures, etc)
		// src: https://stackoverflow.com/a/22513545/3408342
		.replace(re, letter => replacements[letter] || letter)
}
