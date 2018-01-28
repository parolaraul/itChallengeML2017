const fs = require('fs');

const data = fs.readFileSync('level4.txt','utf8');
let cube = [];
let ii = 0;
data.split('\n\n').forEach(matrix => {
	cube[ii] = [];
	let j = 0;
	matrix.split('\n').forEach(str => {
		cube[ii][j] = str.split("");
		j++;
	});
	ii++;
});

const sideLength = cube.length;
const halfLength = sideLength % 2 ? parseInt(sideLength / 2) + 1 : parseInt(sideLength / 2);

function recursive(str='', i=0, j=0, k=0, final=[sideLength - 1, sideLength - 1, sideLength - 1]) {
	if (i + j + k === 30) {
		console.log(str);
		results.push(str);
	} else {
		const possibleCharsForward = [cube[i+1,j,k], cube[i,j+1,k], cube[i,j,k+1]];
		const possibleCharsBackward = [cube[i-1,j,k], cube[i,j-1,k], cube[i,j,k-1]];

		possibleCharsForward.forEach((c, index) => {
			for (let h = 0; h < 3; h++) {
				if (possibleCharsBackward[h] === c) {
					final[h]--; 
					switch (h) {
						case 0:
							if (i+1 <= halfLength) {
								recursive(str + cube[i+1][j][k], i+1, j, k, final);
							}
							break;
						case 1:
							if (j+1 <= halfLength) {
								recursive(str + cube[i][j+1][k], i, j+1, k, final);
							}
							break;
						case 2:
							if (k+1 <= halfLength) {
								recursive(str + cube[i][j][k+1], i, j, k+1, final);
							}
							break;
					}
				}
			}
		});
	}
}

recursive()
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log(results);
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("length: ",results.lengt);