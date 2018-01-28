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

let results = new Map([]);
const sideLength = cube.length;
const halfLength = sideLength % 2 ? parseInt(sideLength / 2) + 1 : parseInt(sideLength / 2);

function recursive(str='', i=0, j=0, k=0, final=[sideLength - 1, sideLength - 1, sideLength - 1]) {
	/*console.log(final);
	if (i + j + k > 20) {
		console.log(`Suma > 20 - i:${i} - j:${j} - k:${k}`);
	}*/
	if (str.length === 32) {
		//console.log(str);
		const newValue = results.has(str) ? results.get(str) + 1 : 1;
		const oldSize = results.size;
		results.set(str, newValue);
		if (results.size !== oldSize) {
			console.log(str);
		//	console.log(results.size);
		}
	} else {
		const possibleCharsForward = [cube[i+1][j][k], cube[i][j+1][k], cube[i][j][k+1]];
		const possibleCharsBackward = [cube[final[0]-1][final[1]][final[2]], cube[final[0]][final[1]-1][final[2]], cube[final[0]][final[1]][final[2]-1]];

		possibleCharsBackward.forEach((c, index) => {
			for (let h = 0; h < 3; h++) {
				if (possibleCharsForward[h] === c) {
					//console.log(`Sip - i:${i} - j:${j} - k:${k} - h:${h}`);
					const newFinal = final.concat([]);
					newFinal[index]--; 
					if (h === 0 && i+1 <= halfLength) {
						recursive(str + cube[i+1][j][k], i+1, j, k, newFinal);
					} else if (h === 1 && j+1 <= halfLength) {
						recursive(str + cube[i][j+1][k], i, j+1, k, newFinal);
					} else if (h === 2 && k+1 <= halfLength) {
						recursive(str + cube[i][j][k+1], i, j, k+1, newFinal);
					}
				} else {
					//console.log("sikipped");
				}
			}
		});
	}
}

recursive(cube[0][0][0]);
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log(results);
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("-----------------------------------------");
console.log("length: ",results.size);

/*
console.log("(0,0,1) = ", cube[0][0][1]);
console.log("(0,1,0) = ", cube[0][1][0]);
console.log("(1,0,0) = ", cube[1][0][0]);

console.log("(20,20,19) = ", cube[20][20][19]);
console.log("(20,19,20) = ", cube[20][19][20]);
console.log("(19,20,20) = ", cube[19][20][20]);
*/