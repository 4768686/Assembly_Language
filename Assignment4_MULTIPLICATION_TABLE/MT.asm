; (推荐) 任务2：打印九九乘法表
; 目标：清晰地演示 CALL/RET 和 寄存器保存
assume cs:code, ds:data, ss:stack

data segment
    str_mul  db '*$'
    str_eq   db '=$'
    str_crlf db 0dh, 0ah, '$' ; 回车换行
data ends

stack segment
    dw 128 dup(?)
stack ends

code segment

PRINT_NUM proc

    push ax
    push bx
    push cx
    push dx
    
    ; 核心逻辑: 将 AL 中的数字 (例如 81) 拆分为 '8' 和 '1'
    mov ah, 0       ; 清空 ah，因为 16 位除法 DIV 使用 AX
    mov bl, 10      ; 除数
    div bl          ; AX / 10 -> 商在 AL (8), 余数在 AH (1)
    
    ; 保存结果: AL=8, AH=1
    ; 我们把 商(AL) 存入 CL, 余数(AH) 存入 CH
    mov cx, ax      
    
    ; 检查商是否为 0 (例如，如果要打印的数字是 9)
    cmp cl, 0       
    je print_ones   ; 如果是 0，只打印个位数
    
    ; 1. 打印十位数 (在 CL 中)
    mov dl, cl
    add dl, '0'     ; 转换为 ASCII '8'
    mov ah, 02h     ; DOS 打印字符功能
    int 21h
    
print_ones:
    ; 2. 打印个位数 (在 CH 中)
    mov dl, ch
    add dl, '0'     ; 转换为 ASCII '1'
    mov ah, 02h
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ; (要求 1: ret 指令)
    ret             ; 从堆栈弹出"返回地址"，返回到 CALL 指令的下一行
PRINT_NUM endp

start:
    ; 设置数据段寄存器
    mov ax, data
    mov ds, ax

    ; (要求 2: 双重循环)
    ; 外循环: BL 寄存器 = X (从 9 递减到 1)
    mov bl, 9

outer_loop:
    cmp bl, 0
    je outer_done   ; (je: jump if equal)

    ; 内循环: CL 寄存器 = Y (从 1 递增到 X)
    mov cl, 1
inner_loop:
    cmp cl, bl
    jg inner_done   ; (jg: jump if greater than)

    ; 1. 打印 X (在 bl 中)
    mov al, bl          ; ; 将参数(X)放入 AL
    call PRINT_NUM      ; ; (要求 1: call 指令)

    ; 2. 打印 "*"
    lea dx, str_mul
    mov ah, 09h
    int 21h

    ; 3. 打印 Y (在 cl 中)
    mov al, cl          ; ; 将参数(Y)放入 AL
    call PRINT_NUM      ; ; (要求 1: call 指令)

    ; 4. 打印 "="
    lea dx, str_eq
    mov ah, 09h
    int 21h

    ; 5. 计算并打印 Result = X * Y
    mov al, bl
    mul cl              ; al = bl * cl
    call PRINT_NUM      ; ; 将参数(Result)放入 AL, (要求 1: call 指令)

    ; 6. 打印制表符 (Tab)
    mov dl, 09h         ; 09h = Tab 字符
    mov ah, 02h
    int 21h

    ; 内循环继续
    inc cl
    jmp inner_loop

inner_done:
    ; 一行结束后，打印回车换行
    lea dx, str_crlf
    mov ah, 09h
    int 21h
    
    ; 外循环继续
    dec bl
    jmp outer_loop

outer_done:
    ; 退出程序
    mov ax, 4c00h
    int 21h
code ends
end start