const fs = require('fs');

const teste = (index) => {
  const t1 = Date.now();

  try {
    const data = fs.readFileSync('./teste.txt', 'utf8');

    const lowerCased = data.toLowerCase();
    // console.log(lowerCased); //0.058s

    const withoutComma = lowerCased.replace(/[\,|\.]/, '');
    // console.log(withoutComma); //0.054s

    const splitted = withoutComma.split(' ');
    // console.log(splited); //0.062s

    const replacedMap = splitted.map((word) => {
      if (word[0] === 'a') return 1;
      if (word[0] === 'b') return 2;
      if (word[0] === 'c') return 3;
      if (word[0] === 'd') return 4;
      if (word[0] === 'e') return 5;
      if (word[0] === 'f') return 6;
      if (word[0] === 'g') return 7;
      if (word[0] === 'h') return 8;
      if (word[0] === 'i') return 9;
      return 10;
    });
    // console.log(replaceMap); //0.060s

    const removedNumberTen = replacedMap.filter((number) => number != 10);
    // console.log(removedNumberTen); //0.062s

    // console.log('List size: ' + removedNumberTen.length); //0.058s

    const multipliedForTen = removedNumberTen.map((number) => number * index);
    // console.log(multipliedForTen); //0.060s

    const resultSum = multipliedForTen.reduce(
      (accumulator, currentValue) => accumulator + currentValue,
      0,
    );
    // console.log(resultSum); //0.075s

    const t2 = Date.now();
    const timer = t2 - t1;
    // console.log(timer); //7
    return { timer, resultSum };
  } catch (error) {
    console.log('Deu erro!');
  }
};

// teste();
// 7

// let total = 0;

// for (let index = 0; index < 100; index++) {
//   total += teste(index);
// }

// console.log(`total: ${total}`); //105ms

let total = { timer: 0, resultSum: 0 };

for (let index = 0; index < 1_000; index++) {
  const { timer, resultSum } = teste(index);
  total.timer += timer;
  total.resultSum += resultSum;
}

console.log(`total: ${total.resultSum}, tempo: ${total.timer}ms`);
//total: 5154481312500, tempo: 17263ms

// 936ms
