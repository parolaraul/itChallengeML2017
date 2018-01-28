const fs = require('fs');

const MIN_LENGTH = 3;

function getNumberOfOccurrences(str, search) {
  const regex = new RegExp(search,"g");
  return (str.match(regex) || []).length;
}

const text = fs.readFileSync('level15.txt','utf8');
//const text = fs.readFileSync('teststr.txt','utf8');
let length = parseInt(text.length / 2);
while(length > MIN_LENGTH) {
	console.log(length);
	let position = 0;
	while(length * 2 + position <= text.length) {
		const firstString = text.substr(position, length);
		if (getNumberOfOccurrences(text, firstString) > 1) {
			console.log(firstString);
			return;
		}
		position++;
	}
	length--;
}