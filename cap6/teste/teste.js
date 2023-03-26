const fs = require('fs');

const teste = (index) => {
  try {
    const data = fs.readFileSync('./teste.txt', 'utf8');

    const lowerCased = data.toLowerCase();

    const withoutComma = lowerCased.replace(/[\,|\.]/, '');

    const splitted = withoutComma.split(' ');

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

    const removedNumberTen = replacedMap.filter((number) => number != 10);

    const multipliedForTen = removedNumberTen.map((number) => number * index);

    const resultSum = multipliedForTen.reduce(
      (accumulator, currentValue) => accumulator + currentValue,
      0,
    );

    return resultSum;
  } catch (error) {
    console.log('Deu erro!');
  }
};

const t1 = Date.now();
for (let index = 0; index < 50_000; index++) {
  teste(index);
}
const t2 = Date.now();
const timer = t2 - t1;

console.log(`tempo: ${timer}ms`);
// tempo: 34_197ms
