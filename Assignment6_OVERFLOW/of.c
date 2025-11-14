#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

// 模拟 INTO 中断服务程序（4号中断）
void interrupt_into_handler() {
    printf("\n检测到溢出（OF = 1）\n");
    printf("算术溢出错误\n");
}

int main()
{
    int a, b;
    int result = 0;
    int overflow_occurred = 0;

    printf("输入第一个整数: ");
    scanf("%d", &a);

    printf("输入第二个整数: ");
    scanf("%d", &b);

    // 使用内联汇编进行加法运算并检测溢出
    __asm {
        mov eax, a
        add eax, b          // 执行加法，可能设置 OF 标志
        mov result, eax

        // 检测 OF 标志位
        pushfd              // 将 FLAGS 寄存器压栈
        pop edx             // 弹出到 edx
        and edx, 0x800      // 检测第11位（OF标志）
        jz NoOverflow       // 如果 OF=0，跳转到 NoOverflow

        // OF=1，表示溢出发生
        mov overflow_occurred, 1

        NoOverflow:
    }

    // 模拟 INTO 指令的行为：如果 OF=1，调用中断服务程序
    if (overflow_occurred) {
        interrupt_into_handler();  // 调用 INTO 中断服务程序
    }
    else {
        printf("\n运算结果: %d + %d = %d\n", a, b, result);
        printf("未检测到溢出（OF = 0）\n");
    }

    return 0;
}