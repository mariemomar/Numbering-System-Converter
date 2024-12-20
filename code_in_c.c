#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

void reverseString(char* str) {   // func
    int length = strlen(str);
    for (int i = 0; i < length / 2; i++) {
        char temp = str[i];
        str[i] = str[length - i - 1];
        str[length - i - 1] = temp;
    }
}

const char* decimalToAnyBase(const char* decimalStr, int base) {
    static char result[32];
    int decimal = 0;

    // Convert string to integer manually
    for (int i = 0; decimalStr[i] != '\0'; i++) {
        decimal = decimal * 10 + (decimalStr[i] - '0');
    }

    int i = 0;

    if (decimal == 0) {
        result[i++] = '0';
    } else {
        while (decimal > 0) {
            int remainder = decimal % base;
            result[i++] = (remainder < 10) ? remainder + '0' : remainder - 10 + 'A';
            decimal /= base;
        }
    }

    result[i] = '\0';

    reverseString(result);
    return result;
}

int anyBaseToDecimal(int base, const char* number) {
    int decimal = 0, power = 1;
    int length = strlen(number);

    for (int i = length - 1; i >= 0; i--) {
        char digit = toupper(number[i]);
        int value = (digit >= '0' && digit <= '9') ? digit - '0' : digit - 'A' + 10;
        decimal += value * power;
        power *= base;
    }

    return decimal;
}

int validateNumber(const char* number, int base) {
    for (int i = 0; i < strlen(number); i++) {
        char digit = toupper(number[i]);
        int value = (digit >= '0' && digit <= '9') ? digit - '0' : digit - 'A' + 10;

        if (value >= base) {
            printf("Error: The digit '%c' is not valid in base %d.\n", digit, base);
            return 0;
        }
    }

    return 1; // Number is valid for the given base
}

int main() {
    while (true) {
        int base1, base2;
        char number[32];

        printf("\nEnter the current base (2-16): ");
        scanf("%d", &base1);

        printf("Enter the number: ");
        scanf("%s", number);

        printf("Enter the new base (2-16): ");
        scanf("%d", &base2);

        if (base1 < 2 || base1 > 16 || base2 < 2 || base2 > 16) {
            printf("Invalid base. Please enter a base between 2 and 16.\n");
            continue;
        }

        if (!validateNumber(number, base1)) {
            printf("Invalid number for the given base.\n");
            continue;
        }

        if (base1 == base2) {
            printf("The number is already in the new base: %s\n", number);
        } else if (base1 == 10) {
            printf("The number in the new base is: %s\n", decimalToAnyBase(number, base2));
        } else if (base2 == 10) {
            printf("The number in decimal is: %d\n", anyBaseToDecimal(base1, number));
        } else { // convert from any base to another except the decimal
            int decimal = anyBaseToDecimal(base1, number);
            char decimalStr[32];

            // Convert integer to string manually
            int idx = 0;
            while (decimal > 0) {
                decimalStr[idx++] = (decimal % 10) + '0';
                decimal /= 10;
            }
            decimalStr[idx] = '\0';
            reverseString(decimalStr);

            printf("The number in the new base is: %s\n", decimalToAnyBase(decimalStr, base2));
        }
    }

    return 0;
}
