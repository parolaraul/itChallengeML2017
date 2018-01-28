let total = 0;

function recursive(arr=[], d=3, f=3, c=3, m=1) {
	if (d > 0) {
		recursive(arr.concat(["d"]), d-1, f, c, m);
	}
	if (f > 0) {
		recursive(arr.concat(["f"]), d, f-1, c, m);
	}
	if (c > 0) {
		recursive(arr.concat(["c"]), d, f, c-1, m);
	}
	if (m > 0) {
		recursive(arr.concat(["m"]), d, f, c, m-1);
	}
	if (arr.length === 9 && isTasty(arr)) {
		console.log("-------------------");
		console.log("| ",arr[0]," | ",arr[1]," | ",arr[2]," |");
		console.log("-------------------");
		console.log("| ",arr[3]," | ",arr[4]," | ",arr[5]," |");
		console.log("-------------------");
		console.log("| ",arr[6]," | ",arr[7]," | ",arr[8]," |");
		console.log("-------------------");
		total++;
	}
}

function isTasty(cake) {
	return 	(cake[0] === cake[1] && cake[1] === cake[2]) ||
			(cake[3] === cake[4] && cake[4] === cake[5]) ||
			(cake[6] === cake[7] && cake[7] === cake[8]) ||

			(cake[0] === cake[3] && cake[3] === cake[6]) ||
			(cake[1] === cake[4] && cake[4] === cake[7]) ||
			(cake[2] === cake[5] && cake[5] === cake[8]) ||

			(cake[0] === "m" && cake[1] === cake[2]) ||
			(cake[3] === "m" && cake[4] === cake[5]) ||
			(cake[6] === "m" && cake[7] === cake[8]) ||

			(cake[0] === "m" && cake[3] === cake[6]) ||
			(cake[1] === "m" && cake[4] === cake[7]) ||
			(cake[2] === "m" && cake[5] === cake[8]) ||

			(cake[0] === cake[1] && "m" === cake[2]) ||
			(cake[3] === cake[4] && "m" === cake[5]) ||
			(cake[6] === cake[7] && "m" === cake[8]) ||

			(cake[0] === cake[3] && "m" === cake[6]) ||
			(cake[1] === cake[4] && "m" === cake[7]) ||
			(cake[2] === cake[5] && "m" === cake[8]) ||

			(cake[0] === cake[2] && cake[1] === "m") ||
			(cake[3] === cake[5] && cake[4] === "m") ||
			(cake[6] === cake[8] && cake[7] === "m") ||

			(cake[0] === cake[6] && cake[3] === "m") ||
			(cake[1] === cake[7] && cake[4] === "m") ||
			(cake[2] === cake[8] && cake[5] === "m");
}

recursive();
console.log("total: ", total);