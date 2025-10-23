.MODEL SMALL                  ; 定义内存模型为 small 模式
.STACK 100h                   ; 定义堆栈大小为 256 字节

.DATA
    newline DB 0Dh, 0Ah, '$'  ; 定义换行符，0Dh 是回车符，0Ah 是换行符，$ 是 DOS 输出字符串的结束符

.CODE
MAIN PROC
    MOV AX, @DATA             ; 将数据段基地址加载到 AX
    MOV DS, AX                ; 将 AX 的值加载到数据段寄存器 DS
    MOV CX, 26                ; 初始化 CX 为 26，表示小写字母的总数
    MOV AL, 'a'               ; 初始化 AL 为 'a'，即第一个小写字母

outer_loop:
    PUSH CX                   ; 保存外层循环的 CX，准备内层循环
    MOV CX, 13                ; 初始化 CX 为 13，表示每行输出 13 个字符
    CMP AL, 'z'               ; 检查 AL 中的值是否大于 'z'
    JA end_loop               ; 如果 AL 已经超过 'z'，跳转到结束标签

inter_loop:
    MOV AH, 02h               ; 设置 AH 为 2，调用 DOS 的输出单个字符功能
    MOV DL, AL                ; 将当前的字母存入 DL 准备输出
    INT 21h                   ; 调用 DOS 中断 21h，输出字符
    INC AL                    ; 递增 AL，指向下一个字母
    LOOP inter_loop           ; 内层循环，用 LOOP 指令控制循环 13 次
    MOV AH, 09h               ; 设置 AH 为 9，调用 DOS 输出字符串功能
    LEA DX, newline           ; 将换行符的地址加载到 DX
    INT 21h                   ; 调用 DOS 中断 21h，输出换行符
    POP CX                    ; 恢复外层循环的 CX
    SUB CX, 13                ; 减去已经打印的 13 个字符
    JNZ outer_loop            ; 如果还有剩余字母（CX 不为零），跳回 outer_loop

end_loop:
    MOV AH, 4Ch               ; 设置 AH 为 4Ch，调用 DOS 的程序退出功能
    INT 21h                   ; 调用 DOS 中断 21h，程序结束

MAIN ENDP
END MAIN                      ; 程序结束