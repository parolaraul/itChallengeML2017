const fs = require('fs');

const data = fs.readFileSync('level4.txt','utf8');
let cube = [];
let i = 0;
data.split('\n\n').forEach(matrix => {
	cube[i] = [];
	let j = 0;
	matrix.split('\n').forEach(str => {
		cube[i][j] = str.split("");
		j++;
	});
	i++;
});

const LENGTH = 21;

function checkPalindrom(str) {
    return str == str.split('').reverse().join('');
}

let results = [];

function recursive(str='', i=0, j=0, k=0) {
	if (i === LENGTH - 1 && j === LENGTH - 1 && k === LENGTH - 1 && checkPalindrom(str)) {
		console.log(str);
		results.push(str);
	} else {
		for (let h = 0; h < 3; h++) {
			switch (h) {
				case 0:
					if (i+1 <= LENGTH - 1) {
						recursive(str + cube[i+1][j][k], i+1, j, k);
					}
					break;
				case 1:
					if (j+1 <= LENGTH - 1) {
						recursive(str + cube[i][j+1][k], i, j+1, k);
					}
					break;
				case 2:
					if (k+1 <= LENGTH - 1) {
						recursive(str + cube[i][j][k+1], i, j, k+1);
					}
					break;
			}
			
		}
	}
}

recursive();
console.log("----------------------------------------");
console.log("----------------------------------------");
console.log("----------------------------------------");
console.log("----------------------------------------");
console.log(results);