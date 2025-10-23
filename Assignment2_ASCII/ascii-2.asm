.MODEL SMALL			; 定义内存模型为 small 模式
.STACK 100h			; 定义堆栈大小为 256 字节
.DATA
    newline DB 0Dh, 0Ah, '$'	; 定义换行符，0Dh 是回车符，0Ah 是换行符，$ 是 DOS 输出字符串的结束符
    counter DB 0              ; 字符计数器
.CODE
MAIN PROC
    MOV AX, @DATA		; 将数据段基地址加载到 AX
    MOV DS, AX			; 将 AX 的值加载到数据段寄存器 DS
    MOV AL, 'a'               ; 初始化 AL 为 'a'，即第一个小写字母
    MOV counter, 0            ; 初始化计数器
print_loop:			; 打印循环
    CMP AL, 'z'			; 检查是否已经打印完所有字母
    JA end_program            	; 如果超过 'z',结束程序
    MOV AH, 02h			; 设置 AH 为 2，调用 DOS 打印单个字符
    MOV DL, AL			; 将当前的字母存入 DL 准备输出
    INT 21h			; 调用 DOS 中断 21h，输出字符
    INC AL			; 递增 AL，指向下一个字母
    INC counter			; 递增计数器
    CMP counter, 13		; 检查是否需要换行(每13个字符)
    JNE print_loop            	; 如果不等于13,继续打印
    MOV AH, 09h			; 设置 AH 为 9，调用 DOS 输出字符串功能
    LEA DX, newline		; 将换行符的地址加载到 DX
    INT 21h			; 调用 DOS 中断 21h，输出换行符
    MOV counter, 0		; 重置计数器
    JMP print_loop            	; 继续下一行
end_program:
    MOV AH, 4Ch			; 设置 AH 为 4Ch，调用 DOS 的程序退出功能
    INT 21h			; 调用 DOS 中断 21h，程序结束
MAIN ENDP
END MAIN			; 程序结束
