.MODEL SMALL
.STACK 100H

.DATA
    ; === 游戏常量 ===
    GROUND_Y    EQU 160     ; 地面Y坐标
    
    ; 恐龙属性
    DINO_X_POS  EQU 40      ; 恐龙固定X
    DINO_W      EQU 16      ; 恐龙宽
    DINO_H      EQU 18      ; 恐龙高（去掉底部空行）
    
    ; 障碍物属性
    OBST_W      EQU 12      ; 障碍宽
    OBST_H      EQU 18      ; 障碍高
    
    ; === 游戏变量 ===
    dino_y      DW 140      ; 恐龙当前Y (左上角). 地面是160, 所以站立时Y=140
    dino_vel    DW 0        ; 垂直速度
    is_jumping  DB 0        ; 跳跃状态
    
    ; 多障碍物系统（3个障碍物）
    ; 每个障碍物的X坐标，-1表示未激活
    obst_x1     DW 332      ; 障碍物1
    obst_x2     DW -1       ; 障碍物2
    obst_x3     DW -1       ; 障碍物3
    
    ; 生成计时器
    spawn_timer DW 60       ; 生成倒计时
    
    game_over   DB 0

    ; === 文本与状态 ===
    game_state  DB 0        ; 0=等待开始, 1=游戏中
    msg_start   DB 'Press SPACE to start',0
    msg_over    DB 'Game Over!  Score:',0
    msg_over2   DB 'SPACE=Restart  ESC=Quit',0
    msg_pause   DB 'PAUSED',0
    msg_pause2  DB 'SPACE=Continue  ESC=Quit',0
    
    ; === 计分系统 ===
    score       DW 0        ; 当前分数
    score_str   DB '0000',0 ; 分数字符串(4位)
    
    ; === 速度控制 ===
    game_speed  DW 4        ; 当前障碍物移动速度
    
    ; === 控制标志 ===
    esc_pressed DB 0        ; ESC按下标志
    jump_request DB 0       ; 跳跃预输入请求
    
    ; === 随机数 ===
    rand_seed   DW 12345    ; 随机种子

    ; === 精灵数据 ===           
    ; Chrome T-Rex 风格 (面朝右), 宽16高18
    dino_sprite DW 00FE0h  ; 0000011111100000 头顶
                DW 01FE0h  ; 0000111111100000
                DW 01BE0h  ; 0000110111100000 眼睛
                DW 01FE0h  ; 0000111111100000
                DW 01F00h  ; 0000111110000000 嘴
                DW 01FC0h  ; 0000111111000000
                DW 087C0h  ; 1000011111000000 小手
                DW 0C7C0h  ; 1100011111000000
                DW 07FE0h  ; 0111111111100000 身体
                DW 03FC0h  ; 0011111111000000
                DW 01F80h  ; 0001111110000000
                DW 00F80h  ; 0000111110000000
                DW 00F00h  ; 0000111100000000
                DW 00F00h  ; 0000111100000000
                DW 00D80h  ; 0000110110000000 腿分开
                DW 00900h  ; 0000100100000000
                DW 01100h  ; 0001000100000000
                DW 01100h  ; 0001000100000000

    ; 仙人掌精灵：宽12，高18 (每行16位，只用前12位)
    obst_sprite DW 00C00h  ; 000011000000
                DW 00C00h  ; 000011000000
                DW 00C20h  ; 000011000010
                DW 00C60h  ; 000011000110
                DW 04C60h  ; 010011000110
                DW 04C40h  ; 010011000100
                DW 06F80h  ; 011011111000
                DW 07F80h  ; 011111111000
                DW 03F00h  ; 001111110000
                DW 00C00h  ; 000011000000
                DW 00C00h  ; 000011000000
                DW 00C00h  ; 000011000000
                DW 00C00h  ; 000011000000
                DW 00C00h  ; 000011000000
                DW 00C00h  ; 000011000000
                DW 01E00h  ; 000111100000
                DW 01E00h  ; 000111100000
                DW 01E00h  ; 000111100000

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. === 初始化 ===
    MOV AX, 0013H       ; VGA 320x200 256色
    INT 10H
    
    CLD                 ; 显式清除方向标志，确保 STOSB 正向

; === 开始等待界面 ===
START_WAIT:
    CALL CLEAR_SCREEN_AREA
    CALL DRAW_GROUND
    CALL DRAW_DINO
    CALL DRAW_ALL_OBSTACLES
    CALL DRAW_START_TEXT
    CALL DELAY_FRAME
    ; 检查是否按下空格开始或ESC退出
    MOV AH, 01H
    INT 16H
    JZ START_WAIT
    MOV AH, 00H
    INT 16H
    CMP AL, 27          ; ESC
    JE EXIT_GAME
    CMP AL, 32          ; SPACE
    JNE START_WAIT
    CALL RESET_GAME
    MOV game_state, 1

GAME_LOOP:
    CALL CHECK_INPUT
    
    ; ESC 暂停检测（检查标志）
    CMP esc_pressed, 1
    JNE NO_ESC_CHECK
    CALL PAUSE_GAME     ; 进入暂停
    CMP AL, 27          ; 暂停返回后检查是否要退出
    JE EXIT_GAME
NO_ESC_CHECK:

    CALL UPDATE_PHYSICS
    CALL UPDATE_ALL_OBSTACLES
    CALL UPDATE_SPAWN_TIMER
    
    CALL CHECK_ALL_COLLISIONS
    CMP game_over, 1
    JE GAME_OVER_HANDLER

    CALL CLEAR_SCREEN_AREA
    CALL DRAW_GROUND
    CALL DRAW_DINO
    CALL DRAW_ALL_OBSTACLES
    CALL DRAW_SCORE

    CALL DELAY_FRAME
    JMP GAME_LOOP

EXIT_GAME:
    MOV AX, 0003H       ; 恢复文本模式
    INT 10H
    
    MOV AX, 4C00H
    INT 21H

GAME_OVER_HANDLER:
    CALL DRAW_CRASH     ; 撞击反馈
WAIT_RESTART:
    CALL DRAW_GAMEOVER_TEXT
    ; 轮询按键：SPACE重开，ESC退出
    MOV AH, 01H
    INT 16H
    JZ WAIT_RESTART
    MOV AH, 00H
    INT 16H
    CMP AL, 27
    JE EXIT_GAME
    CMP AL, 32
    JNE WAIT_RESTART
    CALL RESET_GAME
    MOV game_state, 1
    JMP GAME_LOOP

MAIN ENDP

; ==========================================
; 逻辑处理模块
; ==========================================

CHECK_INPUT PROC
    ; 循环读取所有按键，确保缓冲区清空
    MOV esc_pressed, 0  ; 清除ESC标志
INPUT_LOOP:
    MOV AH, 01H
    INT 16H
    JZ INPUT_DONE       ; 缓冲区空，处理跳跃请求
    
    ; 读出按键清空缓冲区
    MOV AH, 00H
    INT 16H
    
    ; 检测ESC
    CMP AL, 27
    JNE NOT_ESC_KEY
    MOV esc_pressed, 1  ; 设置ESC标志
    JMP INPUT_LOOP
    
NOT_ESC_KEY:
    CMP AL, 32          ; 空格
    JNE INPUT_LOOP      ; 不是空格，继续读下一个键
    
    ; 记录跳跃请求（无论是否在空中）
    MOV jump_request, 1
    JMP INPUT_LOOP      ; 继续清空剩余按键

INPUT_DONE:
    ; 检查是否有跳跃请求且不在跳跃中
    CMP jump_request, 0
    JE IN_RET
    CMP is_jumping, 0
    JNE IN_RET          ; 正在跳跃，保留请求等落地
    
    ; 执行跳跃
    MOV dino_vel, -9    ; 初速度
    MOV is_jumping, 1
    MOV jump_request, 0 ; 清除请求

IN_RET:
    RET
CHECK_INPUT ENDP

UPDATE_PHYSICS PROC
    CMP is_jumping, 0
    JE PHY_RET

    ; Y += Vel
    MOV AX, dino_vel
    ADD dino_y, AX
    
    ; Vel += Gravity (1)
    INC dino_vel
    
    ; 地面检测
    ; 恐龙脚底 = dino_y + DINO_H
    ; 地面Y = GROUND_Y
    MOV AX, dino_y
    ADD AX, DINO_H
    CMP AX, GROUND_Y
    JL PHY_RET          ; 还没落地
    
    ; 落地修正
    MOV AX, GROUND_Y
    SUB AX, DINO_H
    MOV dino_y, AX      ; 修正 Y 到地面之上
    MOV dino_vel, 0
    MOV is_jumping, 0
    
    ; 落地时检查跳跃预输入
    CMP jump_request, 1
    JNE PHY_RET
    ; 立即响应预输入跳跃
    MOV dino_vel, -9
    MOV is_jumping, 1
    MOV jump_request, 0

PHY_RET:
    RET
UPDATE_PHYSICS ENDP

; 更新所有障碍物
UPDATE_ALL_OBSTACLES PROC
    ; 更新障碍物1
    CMP obst_x1, -1
    JE UPDATE_OBS2
    MOV AX, game_speed
    SUB obst_x1, AX
    ; 检查是否离开屏幕
    CMP obst_x1, 0
    JG CHECK_PASS1
    MOV obst_x1, -1     ; 禁用此障碍物
    JMP UPDATE_OBS2
CHECK_PASS1:
    ; 检查是否通过恐龙加分
    MOV AX, obst_x1
    ADD AX, OBST_W
    CMP AX, DINO_X_POS
    JGE UPDATE_OBS2
    CMP AX, DINO_X_POS
    JL MAYBE_SCORE1
    JMP UPDATE_OBS2
MAYBE_SCORE1:
    ; 只有刚刚通过时加分（通过且还在屏幕内）
    MOV AX, obst_x1
    ADD AX, OBST_W
    ADD AX, game_speed  ; 上一帧的位置
    CMP AX, DINO_X_POS
    JL UPDATE_OBS2      ; 上一帧就已经通过了
    ADD score, 10
    CALL UPDATE_SPEED
    
UPDATE_OBS2:
    ; 更新障碍物2
    CMP obst_x2, -1
    JE UPDATE_OBS3
    MOV AX, game_speed
    SUB obst_x2, AX
    CMP obst_x2, 0
    JG CHECK_PASS2
    MOV obst_x2, -1
    JMP UPDATE_OBS3
CHECK_PASS2:
    MOV AX, obst_x2
    ADD AX, OBST_W
    CMP AX, DINO_X_POS
    JGE UPDATE_OBS3
    MOV AX, obst_x2
    ADD AX, OBST_W
    ADD AX, game_speed
    CMP AX, DINO_X_POS
    JL UPDATE_OBS3
    ADD score, 10
    CALL UPDATE_SPEED
    
UPDATE_OBS3:
    ; 更新障碍物3
    CMP obst_x3, -1
    JE UPDATE_OBS_DONE
    MOV AX, game_speed
    SUB obst_x3, AX
    CMP obst_x3, 0
    JG CHECK_PASS3
    MOV obst_x3, -1
    JMP UPDATE_OBS_DONE
CHECK_PASS3:
    MOV AX, obst_x3
    ADD AX, OBST_W
    CMP AX, DINO_X_POS
    JGE UPDATE_OBS_DONE
    MOV AX, obst_x3
    ADD AX, OBST_W
    ADD AX, game_speed
    CMP AX, DINO_X_POS
    JL UPDATE_OBS_DONE
    ADD score, 10
    CALL UPDATE_SPEED
    
UPDATE_OBS_DONE:
    RET
UPDATE_ALL_OBSTACLES ENDP

; 更新生成计时器
UPDATE_SPAWN_TIMER PROC
    DEC spawn_timer
    CMP spawn_timer, 0
    JG SPAWN_DONE
    
    ; 计时器到期，尝试生成新障碍物
    CALL SPAWN_OBSTACLE
    
    ; 重置计时器为随机值 (20~100帧)
    CALL GET_RANDOM
    XOR DX, DX
    MOV BX, 61
    DIV BX              ; DX = 0~60
    ADD DX, 20          ; 20~100
    MOV spawn_timer, DX
    
SPAWN_DONE:
    RET
UPDATE_SPAWN_TIMER ENDP

; 生成新障碍物（在空闲槽位）
SPAWN_OBSTACLE PROC
    ; 检查是否有空闲槽位
    CMP obst_x1, -1
    JE SPAWN_IN_1
    CMP obst_x2, -1
    JE SPAWN_IN_2
    CMP obst_x3, -1
    JE SPAWN_IN_3
    JMP SPAWN_FAIL      ; 没有空闲槽位
    
SPAWN_IN_1:
    MOV obst_x1, 320
    JMP SPAWN_FAIL
SPAWN_IN_2:
    MOV obst_x2, 320
    JMP SPAWN_FAIL
SPAWN_IN_3:
    MOV obst_x3, 320
    
SPAWN_FAIL:
    RET
SPAWN_OBSTACLE ENDP

; 获取随机数 (返回AX)
GET_RANDOM PROC
    MOV AX, rand_seed
    MOV BX, 25173
    MUL BX
    ADD AX, 13849
    MOV rand_seed, AX
    RET
GET_RANDOM ENDP

; 根据分数更新游戏速度
UPDATE_SPEED PROC
    PUSH AX
    
    ; 每50分增加1速度，最大速度8
    MOV AX, score
    MOV BL, 50
    DIV BL              ; AL = score / 50
    ADD AL, 4           ; 基础速度4
    CMP AL, 8
    JLE SPEED_OK
    MOV AL, 8           ; 最大速度8
SPEED_OK:
    XOR AH, AH
    MOV game_speed, AX
    
    POP AX
    RET
UPDATE_SPEED ENDP

; 检查与所有障碍物的碰撞
CHECK_ALL_COLLISIONS PROC
    ; 检查障碍物1
    CMP obst_x1, -1
    JE CHECK_COLL2
    MOV AX, obst_x1
    CALL CHECK_ONE_COLLISION
    CMP game_over, 1
    JE COLL_DONE
    
CHECK_COLL2:
    CMP obst_x2, -1
    JE CHECK_COLL3
    MOV AX, obst_x2
    CALL CHECK_ONE_COLLISION
    CMP game_over, 1
    JE COLL_DONE
    
CHECK_COLL3:
    CMP obst_x3, -1
    JE COLL_DONE
    MOV AX, obst_x3
    CALL CHECK_ONE_COLLISION
    
COLL_DONE:
    RET
CHECK_ALL_COLLISIONS ENDP

; 检查与单个障碍物的碰撞 (AX=obst_x)
CHECK_ONE_COLLISION PROC
    ; 如果障碍物还在屏幕外，则无需检测
    CMP AX, 320
    JGE NO_COLL
    CMP AX, 0
    JL NO_COLL
    
    ; 保存obst_x到BX
    MOV BX, AX
    
    ; 1. Dino Right < Obst Left ?
    MOV AX, DINO_X_POS
    ADD AX, DINO_W
    CMP AX, BX
    JLE NO_COLL         ; 恐龙在障碍物左边

    ; 2. Dino Left > Obst Right ?
    MOV AX, BX
    ADD AX, OBST_W
    CMP AX, DINO_X_POS
    JLE NO_COLL         ; 恐龙在障碍物右边

    ; 3. Dino Bottom < Obst Top ?
    MOV CX, GROUND_Y
    SUB CX, OBST_H      ; CX = Obst Top
    
    MOV AX, dino_y
    ADD AX, DINO_H      ; AX = Dino Bottom
    
    CMP AX, CX
    JLE NO_COLL         ; 恐龙跳过了

    ; === 发生碰撞 ===
    MOV game_over, 1

NO_COLL:
    RET
CHECK_ONE_COLLISION ENDP

; ==========================================
; 绘图模块
; ==========================================

; 通用画块函数
; 输入: CX=X, DX=Y, SI=W, DI=H, AL=Color
DRAW_BOX PROC
    PUSH BP
    PUSH ES
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV BL, AL          ; 保存颜色到BL
    MOV BP, DI          ; 保存高度到BP

    MOV AX, 0A000H
    MOV ES, AX

    ; 计算首像素偏移 DI = Y*320 + X
    MOV AX, 320
    MUL DX              ; DX:AX = Y * 320
    ADD AX, CX
    MOV DI, AX

DRAW_LINE_LOOP:
    MOV CX, SI          ; 宽度
    MOV AL, BL          ; 颜色
    REP STOSB
    ADD DI, 320         ; 下一行
    SUB DI, SI          ; 回到下一行起点
    DEC BP              ; 高度--
    JNZ DRAW_LINE_LOOP

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POP ES
    POP BP
    RET
DRAW_BOX ENDP

DRAW_DINO PROC
    ; 使用像素精灵绘制恐龙
    MOV CX, DINO_X_POS  ; X
    MOV DX, dino_y      ; Y
    LEA SI, dino_sprite ; 精灵数据
    MOV BH, DINO_W      ; 宽度(10)
    MOV DI, DINO_H      ; 高度(20)
    MOV AL, 15          ; 颜色(白)
    CALL DRAW_SPRITE
    RET
DRAW_DINO ENDP

; 绘制所有障碍物
DRAW_ALL_OBSTACLES PROC
    ; 绘制障碍物1
    MOV AX, obst_x1
    CMP AX, 0FFFFh      ; -1 表示未激活
    JE DRAW_OBS2
    CMP AX, 308
    JG DRAW_OBS2        ; 超出右边界
    CMP AX, 0
    JL DRAW_OBS2        ; 超出左边界
    MOV CX, AX
    CALL DRAW_ONE_OBSTACLE
    
DRAW_OBS2:
    MOV AX, obst_x2
    CMP AX, 0FFFFh
    JE DRAW_OBS3
    CMP AX, 308
    JG DRAW_OBS3
    CMP AX, 0
    JL DRAW_OBS3
    MOV CX, AX
    CALL DRAW_ONE_OBSTACLE
    
DRAW_OBS3:
    MOV AX, obst_x3
    CMP AX, 0FFFFh
    JE DRAW_OBS_DONE
    CMP AX, 308
    JG DRAW_OBS_DONE
    CMP AX, 0
    JL DRAW_OBS_DONE
    MOV CX, AX
    CALL DRAW_ONE_OBSTACLE
    
DRAW_OBS_DONE:
    RET
DRAW_ALL_OBSTACLES ENDP

; 绘制单个障碍物 (CX=X坐标)
DRAW_ONE_OBSTACLE PROC
    ; 使用像素精灵绘制仙人掌
    MOV DX, GROUND_Y
    SUB DX, OBST_H      ; Top Y
    LEA SI, obst_sprite ; 精灵数据
    MOV BH, OBST_W      ; 宽度(12)
    MOV DI, OBST_H      ; 高度(18)
    MOV AL, 2           ; 颜色(绿色)
    CALL DRAW_SPRITE
    RET
DRAW_ONE_OBSTACLE ENDP

; 通用按位绘制精灵
; 输入: CX=X, DX=Y, SI=sprite数据, BH=宽度, DI=高度, AL=颜色
DRAW_SPRITE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH BP
    PUSH ES
    
    ; 保存参数到内存变量（使用栈）
    MOV BP, SP
    SUB SP, 8           ; 分配局部变量
    ; [BP-2] = X坐标
    ; [BP-4] = 颜色
    ; [BP-6] = 宽度
    ; [BP-8] = 行计数
    
    MOV [BP-2], CX      ; 保存X
    MOV [BP-4], AL      ; 保存颜色
    XOR AH, AH
    MOV AL, BH
    MOV [BP-6], AX      ; 保存宽度
    MOV [BP-8], DI      ; 保存高度(行数)
    
    MOV AX, 0A000H
    MOV ES, AX

SPR_ROW_LP:
    ; 计算行起始偏移: offset = Y*320 + X
    MOV AX, DX          ; AX = Y
    MOV BX, 320
    PUSH DX
    MUL BX              ; DX:AX = Y*320
    POP DX
    ADD AX, [BP-2]      ; AX += X
    MOV DI, AX          ; DI = 显存偏移

    ; 读取一行位图 (16 bits)
    LODSW               ; AX = [SI], SI += 2
    MOV BX, AX          ; BX = 位图数据
    
    ; 逐像素绘制
    MOV CX, [BP-6]      ; CX = 宽度

SPR_COL_LP:
    TEST BX, 8000h      ; 测试最高位
    JZ SPR_NO_PIX
    MOV AL, [BP-4]      ; 颜色
    MOV ES:[DI], AL     ; 画像素
SPR_NO_PIX:
    INC DI
    SHL BX, 1           ; 下一位
    LOOP SPR_COL_LP

    INC DX              ; 下一行Y
    DEC WORD PTR [BP-8]
    JNZ SPR_ROW_LP

    ADD SP, 8           ; 释放局部变量
    
    POP ES
    POP BP
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_SPRITE ENDP

DRAW_GROUND PROC
    ; 画一条简单的横线
    PUSH ES
    MOV AX, 0A000H
    MOV ES, AX
    
    MOV AX, 320
    MOV DX, GROUND_Y
    MUL DX
    MOV DI, AX          ; Offset start
    
    MOV CX, 320         ; 宽度
    MOV AL, 6           ; 棕色
    REP STOSB
    
    POP ES
    RET
DRAW_GROUND ENDP

CLEAR_SCREEN_AREA PROC
    PUSH ES
    MOV AX, 0A000H
    MOV ES, AX
    ; 清理从 Y=0 到地面线(含)的全部区域，避免顶部残影
    XOR DI, DI          ; 从屏幕起点
    MOV AX, 320
    MOV DX, GROUND_Y
    INC DX              ; 包含地面线本身
    MUL DX              ; AX = 320 * (GROUND_Y+1)
    MOV CX, AX
    XOR AL, AL
    REP STOSB           ; 清除顶端活动区域
    
    POP ES
    RET
CLEAR_SCREEN_AREA ENDP

DRAW_CRASH PROC
    ; 全屏变黑
    PUSH ES
    MOV AX, 0A000H
    MOV ES, AX
    XOR DI, DI
    MOV CX, 320*200
    XOR AL, AL          ; 黑色
    REP STOSB
    POP ES
    RET
DRAW_CRASH ENDP

DELAY_FRAME PROC
    ; 短忙等延时，保持输入响应灵敏
    PUSH CX
    MOV CX, 2800H       ; 调整此值控制游戏速度
DELAY_LP:
    NOP
    NOP
    NOP
    NOP
    LOOP DELAY_LP
    POP CX
    RET
DELAY_FRAME ENDP

; ==========================================
; 文本/提示与重置
; ==========================================

; 在(row, col)打印以0结尾的字符串，图形模式下使用TTY输出
; 输入: DH=row(0-24), DL=col(0-39), DS:SI=字符串, BL=颜色
PRINT_AT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP
    
    ; 设置光标位置(即使在图形模式也会作为TTY基准)
    MOV AH, 02H
    MOV BH, 0
    INT 10H

    ; 逐字符TTY输出
    MOV AH, 0EH
PRN_LOOP:
    LODSB
    OR AL, AL
    JZ PRN_DONE
    INT 10H            ; BL为颜色
    JMP PRN_LOOP
PRN_DONE:
    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_AT ENDP

DRAW_START_TEXT PROC
    MOV DH, 10         ; 行
    MOV DL, 8          ; 列(约居中)
    LEA SI, msg_start
    MOV BL, 15         ; 白色
    CALL PRINT_AT
    RET
DRAW_START_TEXT ENDP

DRAW_GAMEOVER_TEXT PROC
    ; 显示 Game Over! Score:
    MOV DH, 9
    MOV DL, 10
    LEA SI, msg_over
    MOV BL, 15
    CALL PRINT_AT
    
    ; 转换并显示分数
    MOV AX, score
    LEA BX, score_str
    CALL CONVERT_SCORE
    
    MOV DH, 9
    MOV DL, 28
    LEA SI, score_str
    MOV BL, 14          ; 黄色
    CALL PRINT_AT
    
    ; 显示操作提示
    MOV DH, 11
    MOV DL, 8
    LEA SI, msg_over2
    MOV BL, 15
    CALL PRINT_AT
    RET
DRAW_GAMEOVER_TEXT ENDP

; 转换分数为字符串 (AX=分数, BX=字符串地址)
CONVERT_SCORE PROC
    PUSH CX
    PUSH DX
    
    ; 千位
    XOR DX, DX
    MOV CX, 1000
    DIV CX
    ADD AL, '0'
    MOV [BX], AL
    
    ; 百位
    MOV AX, DX
    XOR DX, DX
    MOV CX, 100
    DIV CX
    ADD AL, '0'
    MOV [BX+1], AL
    
    ; 十位
    MOV AX, DX
    XOR DX, DX
    MOV CX, 10
    DIV CX
    ADD AL, '0'
    MOV [BX+2], AL
    
    ; 个位
    ADD DL, '0'
    MOV [BX+3], DL
    
    POP DX
    POP CX
    RET
CONVERT_SCORE ENDP

RESET_GAME PROC
    MOV dino_y, 140
    MOV dino_vel, 0
    MOV is_jumping, 0
    MOV jump_request, 0
    MOV obst_x1, 300
    MOV obst_x2, -1
    MOV obst_x3, -1
    MOV spawn_timer, 60
    MOV game_over, 0
    MOV score, 0
    MOV game_speed, 4
    
    ; 用BIOS时钟初始化随机种子
    PUSH ES
    MOV AX, 0040H
    MOV ES, AX
    MOV AX, ES:[006CH]
    MOV rand_seed, AX
    POP ES
    RET
RESET_GAME ENDP

; 将分数转换为字符串并显示在左上角
DRAW_SCORE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; 转换分数为字符串
    MOV AX, score
    LEA BX, score_str
    CALL CONVERT_SCORE
    
    ; 显示分数
    MOV DH, 1           ; 行1
    MOV DL, 1           ; 列1
    LEA SI, score_str
    MOV BL, 14          ; 黄色
    CALL PRINT_AT
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_SCORE ENDP

; 暂停游戏
; 返回: AL=27表示退出，其他表示继续
PAUSE_GAME PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; 绘制暂停界面
    CALL CLEAR_SCREEN_AREA
    CALL DRAW_GROUND
    
    ; 显示 PAUSED
    MOV DH, 9
    MOV DL, 17
    LEA SI, msg_pause
    MOV BL, 15
    CALL PRINT_AT
    
    ; 显示操作提示
    MOV DH, 11
    MOV DL, 8
    LEA SI, msg_pause2
    MOV BL, 15
    CALL PRINT_AT
    
PAUSE_WAIT:
    ; 等待按键
    MOV AH, 01H
    INT 16H
    JZ PAUSE_WAIT
    
    MOV AH, 00H
    INT 16H
    
    CMP AL, 32          ; SPACE继续
    JE PAUSE_CONTINUE
    CMP AL, 27          ; ESC退出
    JE PAUSE_EXIT
    JMP PAUSE_WAIT
    
PAUSE_CONTINUE:
    MOV AL, 0           ; 返回0表示继续
    JMP PAUSE_DONE
    
PAUSE_EXIT:
    MOV AL, 27          ; 返回27表示退出
    
PAUSE_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
PAUSE_GAME ENDP

END MAIN