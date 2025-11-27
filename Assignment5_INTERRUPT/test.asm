CODE SEGMENT
    ASSUME CS:CODE, DS:CODE

START:
    MOV AX, CS       ; .EXE 格式需要初始化 DS
    MOV DS, AX
MAIN_LOOP:
    MOV AH, 02H      ; 查询键盘状态
    INT 16H          ; 返回 AL＝Shift键状态

    TEST AL, 03H     ; 检查左右 shift
    JNZ EXIT_PROG    ; 任意 shift 按下就退出
    
    MOV AH, 01H      ; 查询键盘缓冲区状态
    INT 16H
    JZ MAIN_LOOP     ; 如果 ZF=1，说明没按键，跳回开头继续循环

    MOV AH, 0H       ; 从缓冲区读取字符
    INT 16H          ; AL 中将保存字符的 ASCII 码

    MOV BH, 0H
    MOV AH, 0EH      ; 显示字符
    INT 10H          ; 显示 AL 中的字符
    JMP MAIN_LOOP    ; 处理完一个字符，跳回开头

EXIT_PROG:
    INT 20H

CODE ENDS
END START