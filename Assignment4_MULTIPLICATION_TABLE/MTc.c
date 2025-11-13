#include <stdio.h>

int main(void) {

    int x, y;

    for (x = 9; x >= 1; x--) {

        for (y = 1; y <= x; y++) {
            printf("%d*%d=%-2d\t", x, y, x * y);
        }

        printf("\n");
    }

    return 0;
}