function isValidCardNumber (cardNumber) {
    let numbers = cardNumber.replace(/\D/g, '').split('').map(Number);
    let totalSum = 0;

    for (let i = numbers.length - 1; i>=0; i--) {
        let currentNumber = numbers[i];

        if ((numbers.length - 1 - i) % 2 === 1) {
            currentNumber *= 2;
            if (currentNumber > 9) {
                currentNumber -= 9;
            }
        }
        totalSum += currentNumber;
    }

    return totalSum % 10 === 0;
}

console.log(isValidCardNumber('4532 0151 1283 0366'));