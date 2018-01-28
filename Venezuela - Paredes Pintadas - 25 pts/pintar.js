const str ="1 4 5 6 7 8 15 12 9 4 9 8 12 14 22 45 67 89 87 86 85 23 56 67 21 88 11 44 56 91 67 45 45 45 45 45 44 21 89 90 90 87 45 91 12 45 57";
//const str = "1 3 2 1 2 1 5 3 3 4 2";
const arr = str.split(" ");
const MAX = Math.max.apply(this, arr);
let hits = 0;
let lastIsHole = true;
for (let paintingLevel = 1; paintingLevel <= MAX; paintingLevel++) {
	//console.log("paintingLevel: ", paintingLevel);
	arr.forEach(currentLevel => {
		//console.log("currentLevel: ", currentLevel, ", lastIsHole: ", lastIsHole, ", hits: ", hits);
		if (paintingLevel > currentLevel) {
			lastIsHole = true;
		} else {
			if (lastIsHole) {
				hits++;
				lastIsHole = false;
			}
		}
	});
	lastIsHole = true;
}

console.log(hits);