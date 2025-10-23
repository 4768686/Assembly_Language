#include <stdio.h>

int main() {
    int count = 0; 
    char ch;
    for (ch = 'a'; ch <= 'z'; ch++) {
        printf("%c", ch);
        count++;
        
        if (count == 13) {
            printf("\n");
            count = 0;
        }
    }   
    return 0;
}
