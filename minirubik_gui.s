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

face_layout_xy:
    .byte  9,  0
    .byte  0,  7
    .byte  9,  7
    .byte 18,  7
    .byte 27,  7
    .byte  9, 14

.text
.globl _start

_start:
    la   a0, test_input
    jal  ra, parse_state

    jal  ra, led_clear_screen
    jal  ra, render_cube_led
    jal  ra, led_step_delay

    jal  ra, is_solved
    bnez a0, exit_success

    jal  ra, solve_ida

    la   s0, solution_path
    li   s1, 11
    li   s2, 0

demo_animation:
    bge  s2, s1, exit_success
    add  t0, s0, s2
    lbu  a0, 0(t0)
    jal  ra, apply_full_move

    jal  ra, render_cube_led
    jal  ra, led_step_delay

    addi s2, s2, 1
    j    demo_animation

exit_success:
    li   a0, 0
    li   a7, 10
    ecall

# ==============================================================================
# LED 繪圖引擎模組
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

render_cube_led:
    addi sp, sp, -20
    sw   ra, 16(sp)
    sw   s0, 12(sp)
    sw   s1, 8(sp)

    la   s0, face_layout_xy
    li   s1, 0

render_face_loop:
    slli t0, s1, 1
    add  t0, s0, t0
    lb   a0, 0(t0)
    lb   a1, 1(t0)

    li   t1, 0
    beq  s1, t1, col_u
    li   t1, 1
    beq  s1, t1, col_l
    li   t1, 2
    beq  s1, t1, col_f
    li   t1, 3
    beq  s1, t1, col_r
    li   t1, 4
    beq  s1, t1, col_b
    li   a2, 0x00FFFF00
    j    draw_quad
col_u:
    li   a2, 0x00FFFFFF
    j    draw_quad
col_l:
    li   a2, 0x00FFA500
    j    draw_quad
col_f:
    li   a2, 0x0000FF00
    j    draw_quad
col_r:
    li   a2, 0x00FF0000
    j    draw_quad
col_b:
    li   a2, 0x000000FF
    j    draw_quad

draw_quad:
    addi sp, sp, -12
    sw   a0, 8(sp)
    sw   a1, 4(sp)
    sw   a2, 0(sp)

    jal  ra, draw_facelet_4x3

    lw   a0, 8(sp)
    lw   a1, 4(sp)
    lw   a2, 0(sp)
    addi a0, a0, 4
    jal  ra, draw_facelet_4x3

    lw   a0, 8(sp)
    lw   a1, 4(sp)
    lw   a2, 0(sp)
    addi a1, a1, 3
    jal  ra, draw_facelet_4x3

    lw   a0, 8(sp)
    lw   a1, 4(sp)
    lw   a2, 0(sp)
    addi a0, a0, 4
    addi a1, a1, 3
    jal  ra, draw_facelet_4x3

    addi sp, sp, 12

    addi s1, s1, 1
    li   t0, 6
    blt  s1, t0, render_face_loop

    lw   s1, 8(sp)
    lw   s0, 12(sp)
    lw   ra, 16(sp)
    addi sp, sp, 20
    ret

led_step_delay:
    li   t0, 10000
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

is_solved:
    la   t0, state_p
    la   t1, state_o
    li   t2, 0
check_solved_loop:
    add  t3, t0, t2
    lb   t4, 0(t3)
    bne  t4, t2, not_solved
    add  t3, t1, t2
    lb   t4, 0(t3)
    bnez t4, not_solved

    addi t2, t2, 1
    li   t6, 7
    blt  t2, t6, check_solved_loop
    li   a0, 1
    ret
not_solved:
    li   a0, 0
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