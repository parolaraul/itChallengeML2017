const fs = require('fs');
const data = fs.readFileSync('diccionarioChino.csv','utf8');
const arr = ['。','3','2','0','x','4','R','G','B','，','7','：','-','\n'].concat(data.split(","));

let superString = fs.readFileSync('level3.txt','utf8');

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

function removeDuplicateCharacters(string){
 return string
		.split('')
		.filter(function(item, pos, self) {
    		return self.indexOf(item) == pos;
		})
		.join('');
}

for (let i = 0; i < 217	; i++) {
	superString = superString.replaceAll(arr[i], '');
}

fs.writeFileSync('results.txt', removeDuplicateCharacters(superString));