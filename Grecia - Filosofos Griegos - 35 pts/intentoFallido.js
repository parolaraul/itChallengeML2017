const fs = require('fs');

const data = fs.readFileSync('level13.txt','utf8');
let arr = data.split('\n');
let map = new Map([]);
for (let i = 0; i < arr.length; i++) {
	let newValue;
	if (map.has(arr[i])) {
		let value = map.get(arr[i]);
		value.frecuency++;
		let lastIndex = value.indixes[value.indixes.length - 1];
		value.distancies.push(i - lastIndex);
		value.indixes.push(i)
		newValue = value;
	} else {
		newValue = {
			frecuency: 1,
			indixes: [i],
			distancies: [i]
		}
	}
	map.set(arr[i], newValue);
}

const isPrime = num => {
  for(let i = 2; i < num; i++)
    if(num % i === 0) return false;
  return num !== 1;
}

const isPythagoreanPrime = num => isPrime(num) && (num - 1) % 4 === 0;

const arr2 = Array.from(map)
				.filter(ele => isPythagoreanPrime(ele[0]))
				.sort((a, b) => a[0].frecuency > b[0].frecuency);


results = [];
arr2.forEach(ele => {
	let distancies = ele[1].distancies;
	let asdmap = new Map([]);
	for (let i = 0; i < distancies.length; i++) {
		const dist = distancies[i];
		const newValue = asdmap.has('' + ele[0] + '-' + dist) ? asdmap.get('' + ele[0] + '-' + dist) + 1 : 1;
		asdmap.set('' + ele[0] + '-' + dist , newValue);
	}
	//console.log(asdmap);
	results.push({
		number: ele[0],
		//error: asdmap.size * 100 / ele[1].frecuency,
		//repetitions: ele[1].frecuency,
		//distancies: ele[1].distancies,
		mapsize: asdmap.size,
		map: asdmap
	});
});
//console.log(results[results.length-1]);




/*
let max = 1;
let num = 0;
let mapR;
results.forEach(ele => {
	ele.map.forEach((value, key) => {
		if (value > max) {
			max = value;
			num = parseInt(key.split('-')[0]);
			mapR = ele.map;
		}
	})
	console.log(max);
});

console.log(num + ' ' + max);
console.log(mapR);*/


let str = '';
results.forEach(ele => {
	ele.map.forEach((value, key) => {
		if (value >= 7) {
			str += key + " => " + value + "\n";
		}
	});
});
fs.writeFileSync('log.txt', str);

//results.filter(ele => ele.mapsize < 165).forEach(ele => console.log(ele));

//arr2.sort((a, b) => a[0].frecuency - 1000 * b[0].frecuency).forEach(ele => console.log(ele[0], ' aparece ', ele[1].frecuency, ' veces'));


//console.log(arr2[arr2.length - 1])
//console.log(arr2.length)
/*
arr2.forEach(ele => {
	let obj = {};
	let maxDistRepetition = 0;
	ele[1].distancies.forEach(dist => {
		const newValue = map.has(dist) ? map.get(dist) + 1 : 1;
		map.set(dist, newValue);
		if (true) {}
	});
})*/