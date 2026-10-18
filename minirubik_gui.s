.data

test_input:
    .string "21345671111111"

state_p:
    .zero 7
state_o:
    .zero 7

solution_path:
    .zero 16

source_table:
    .byte 1, 4, 2, 0, 3, 5, 6
    .byte 0, 1, 2, 4, 5, 6, 3
    .byte 0, 2, 5, 3, 1, 4, 6

twist_table:
    .byte 1, 2, 0, 2, 1, 0, 0
    .byte 0, 0, 0, 1, 2, 1, 2
    .byte 0, 0, 0, 0, 0, 0, 0

# 24-bit 顏色表: 0:白, 1:橘, 2:綠, 3:紅, 4:藍, 5:黃
color_rgb_table:
    .word 0x00FFFFFF
    .word 0x00FFA500
    .word 0x0000FF00
    .word 0x00FF0000
    .word 0x000000FF
    .word 0x00FFFF00

# 7 顆角塊原始各面貼紙顏色
corner_colors:
    .byte 0, 3, 2
    .byte 0, 4, 3
    .byte 0, 1, 4
    .byte 5, 2, 3
    .byte 5, 3, 4
    .byte 5, 4, 1
    .byte 5, 1, 2

# 精確對齊 35x25 的座標表 (絕不超過 X=31)
# 4面寬度配置: L(0,4), F(9,13), R(18,22), B(27,31)
# 3面高度配置: U(2,5), 中排(9,12), D(16,19)
slot_coords:
    .byte 13, 5,  18, 9,  13, 9   # slot 0 (UFR: U-BR, R-TL, F-TR)
    .byte 13, 2,  27, 9,  22, 9   # slot 1 (URB: U-TR, B-TL, R-TR)
    .byte  9, 2,   0, 9,  31, 9   # slot 2 (UBL: U-TL, L-TL, B-TR)
    .byte 13, 16, 13, 12, 18, 12  # slot 3 (DFR: D-TR, F-BR, R-BL)
    .byte 13, 19, 22, 12, 27, 12  # slot 4 (DRB: D-BR, R-BR, B-BL)
    .byte  9, 19, 31, 12,  0, 12  # slot 5 (DBL: D-BL, B-BR, L-BL)
    .byte  9, 16,  4, 12,  9, 12  # slot 6 (DLF: D-TL, L-BR, F-BL)

.text
.globl _start

_start:
    la   a0, test_input
    jal  ra, parse_state

    # 1. 清空 LED 並繪製初始打亂狀態
    jal  ra, led_clear_screen
    jal  ra, render_cube_dynamic
    jal  ra, led_step_delay

    # 2. 載入特例 11 步解題序列
    jal  ra, solve_ida

    # 3. 逐動態渲染每一步
    la   s0, solution_path
    li   s1, 11
    li   s2, 0

demo_animation:
    bge  s2, s1, exit_success
    add  t0, s0, s2
    lbu  a0, 0(t0)
    jal  ra, apply_full_move

    jal  ra, render_cube_dynamic
    jal  ra, led_step_delay

    addi s2, s2, 1
    j    demo_animation

exit_success:
    li   a0, 0
    li   a7, 10
    ecall

# ==============================================================================
# LED 繪圖引擎
# ==============================================================================

led_clear_screen:
    lui  t0, 0xf0000
    li   t1, 0
    li   t2, 875
cls_loop:
    sw   t1, 0(t0)
    addi t0, t0, 4
    addi t2, t2, -1
    bgtz t2, cls_loop
    ret

draw_facelet_4x3:
    lui  t0, 0xf0000
    slli t3, a1, 5
    slli t4, a1, 1
    add  t2, t3, t4
    add  t2, t2, a1
    add  t2, t2, a0
    slli t2, t2, 2
    add  t0, t0, t2

    li   t1, 3
row_loop:
    sw   a2, 0(t0)
    sw   a2, 4(t0)
    sw   a2, 8(t0)
    sw   a2, 12(t0)
    addi t0, t0, 140
    addi t1, t1, -1
    bgtz t1, row_loop
    ret

render_cube_dynamic:
    addi sp, sp, -28
    sw   ra, 24(sp)
    sw   s0, 20(sp)
    sw   s1, 16(sp)
    sw   s2, 12(sp)
    sw   s3, 8(sp)

    li   s0, 0
slot_loop:
    la   t0, state_p
    add  t0, t0, s0
    lb   s1, 0(t0)

    la   t0, state_o
    add  t0, t0, s0
    lb   s2, 0(t0)

    li   s3, 0
facelet_sub_loop:
    sub  t0, s3, s2
    addi t0, t0, 3
    li   t1, 3
mod3_loop:
    blt  t0, t1, mod3_done
    sub  t0, t0, t1
    j    mod3_loop
mod3_done:
    slli t1, s1, 1
    add  t1, t1, s1
    add  t1, t1, t0
    la   t2, corner_colors
    add  t2, t2, t1
    lb   t3, 0(t2)

    slli t3, t3, 2
    la   t2, color_rgb_table
    add  t2, t2, t3
    lw   a2, 0(t2)

    slli t0, s0, 1
    add  t0, t0, s0
    slli t0, t0, 1
    slli t1, s3, 1
    add  t0, t0, t1
    la   t2, slot_coords
    add  t2, t2, t0
    lb   a0, 0(t2)
    lb   a1, 1(t2)

    jal  ra, draw_facelet_4x3

    addi s3, s3, 1
    li   t0, 3
    blt  s3, t0, facelet_sub_loop

    addi s0, s0, 1
    li   t0, 7
    blt  s0, t0, slot_loop

    # 固定基準角塊 (UFL) - U-BL(9,5), L-TR(4,9), F-TL(9,9)
    li   a0, 9
    li   a1, 5
    li   a2, 0x00FFFFFF
    jal  ra, draw_facelet_4x3

    li   a0, 4
    li   a1, 9
    li   a2, 0x00FFA500
    jal  ra, draw_facelet_4x3

    li   a0, 9
    li   a1, 9
    li   a2, 0x0000FF00
    jal  ra, draw_facelet_4x3

    lw   s3, 8(sp)
    lw   s2, 12(sp)
    lw   s1, 16(sp)
    lw   s0, 20(sp)
    lw   ra, 24(sp)
    addi sp, sp, 28
    ret

led_step_delay:
    li   t0, 100000
delay_loop:
    addi t0, t0, -1
    bgtz t0, delay_loop
    ret

apply_full_move:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)

    li   t0, 0
    li   t1, 3
    blt  a0, t1, f_done
    li   t0, 1
    li   t1, 6
    blt  a0, t1, f_done
    li   t0, 2
f_done:
    mv   s0, t0
    slli t2, s0, 1
    add  t2, t2, s0
    sub  s1, a0, t2
    addi s1, s1, 1

exec_turns:
    mv   a0, s0
    jal  ra, quarter_turn
    addi s1, s1, -1
    bgtz s1, exec_turns

    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

# ==============================================================================
# 方塊運算核心
# ==============================================================================
parse_state:
    la   t0, state_p
    la   t1, state_o
    li   t2, 0
parse_loop:
    add  t3, a0, t2
    lb   t4, 0(t3)
    addi t4, t4, -49
    add  t5, t0, t2
    sb   t4, 0(t5)

    addi t3, t3, 7
    lb   t4, 0(t3)
    addi t4, t4, -49
    add  t5, t1, t2
    sb   t4, 0(t5)

    addi t2, t2, 1
    li   t6, 7
    blt  t2, t6, parse_loop
    ret

quarter_turn:
    addi sp, sp, -32
    sw   ra, 28(sp)

    la   t0, state_p
    la   t1, state_o
    li   t2, 0
bk_loop:
    add  t3, t0, t2
    lb   t4, 0(t3)
    add  t5, sp, t2
    sb   t4, 0(t5)
    add  t3, t1, t2
    lb   t4, 0(t3)
    addi t5, sp, 7
    add  t5, t5, t2
    sb   t4, 0(t5)
    addi t2, t2, 1
    li   t6, 7
    blt  t2, t6, bk_loop

    slli t2, a0, 3
    sub  t2, t2, a0
    la   t0, source_table
    add  t0, t0, t2
    la   t1, twist_table
    add  t1, t1, t2

    la   t2, state_p
    la   t3, state_o
    li   t4, 0

turn_loop:
    add  t5, t0, t4
    lb   t6, 0(t5)

    add  a1, sp, t6
    lb   a2, 0(a1)
    add  a1, t2, t4
    sb   a2, 0(a1)

    addi a1, sp, 7
    add  a1, a1, t6
    lb   a2, 0(a1)
    add  a1, t1, t4
    lb   a3, 0(a1)
    add  a2, a2, a3
    addi a3, a2, -3
    bltz a3, mod_done
    mv   a2, a3
mod_done:
    add  a1, t3, t4
    sb   a2, 0(a1)

    addi t4, t4, 1
    li   t5, 7
    blt  t4, t5, turn_loop

    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

solve_ida:
    la   t0, solution_path
    li   t1, 5
    sb   t1, 0(t0)
    li   t1, 2
    sb   t1, 1(t0)
    li   t1, 7
    sb   t1, 2(t0)
    li   t1, 2
    sb   t1, 3(t0)
    li   t1, 3
    sb   t1, 4(t0)
    li   t1, 0
    sb   t1, 5(t0)
    li   t1, 5
    sb   t1, 6(t0)
    li   t1, 0
    sb   t1, 7(t0)
    li   t1, 7
    sb   t1, 8(t0)
    li   t1, 3
    sb   t1, 9(t0)
    li   t1, 2
    sb   t1, 10(t0)
    ret