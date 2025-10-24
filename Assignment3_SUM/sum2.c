#include <stdio.h>

void main() {
    int i;
    int n;
    int sum = 0;

    printf("Please Enter A Number Between 1 And 100 ");
    scanf("%d", &n);

    for (i = 1; i <= n; i++) {
        sum = sum + i;
    }

    printf("The Sum is: %d\n", sum);
}