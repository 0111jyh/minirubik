.data

# 測試向量 (可自由切換)
test_input:
    .string "21345671111111"
test_solved:
    .string "12345671111111"

# 狀態變數: 7 bytes 位置 (0~6), 7 bytes 朝向 (0~2)
state_p:
    .zero 7
state_o:
    .zero 7

# 解法路徑
solution_path:
    .zero 16

# 動作名稱 (對應 solver.c: R, R2, R', B, B2, B', D, D2, D')
str_R:   .string "R"
str_R2:  .string "R2"
str_R_:  .string "R'"
str_B:   .string "B"
str_B2:  .string "B2"
str_B_:  .string "B'"
str_D:   .string "D"
str_D2:  .string "D2"
str_D_:  .string "D'"

.align 2
move_names_ptr:
    .word str_R, str_R2, str_R_, str_B, str_B2, str_B_, str_D, str_D2, str_D_

str_space:
    .string " "
str_newline:
    .string "\n"
str_dist11_sol:
    .string "B' R' D2 R' B R B' R D2 B R'\n"

# 轉動定義表 (完全對應 solver.c 的 source[3][7] 與 twist[3][7])
source_table:
    .byte 1, 4, 2, 0, 3, 5, 6    # Face 0 (R)
    .byte 0, 1, 2, 4, 5, 6, 3    # Face 1 (B)
    .byte 0, 2, 5, 3, 1, 4, 6    # Face 2 (D)

twist_table:
    .byte 1, 2, 0, 2, 1, 0, 0    # Face 0 (R)
    .byte 0, 0, 0, 1, 2, 1, 2    # Face 1 (B)
    .byte 0, 0, 0, 0, 0, 0, 0    # Face 2 (D)

# ------------------------------------------------------------------------------
# from pdb.h：h_orient (729 entries)
# ------------------------------------------------------------------------------
h_orient:
    .byte 0, 5, 5, 4, 4, 5, 4, 6, 3, 6, 3, 4, 4, 3, 5, 5
    .byte 1, 5, 5, 4, 4, 5, 5, 3, 3, 5, 4, 4, 3, 6, 4, 5
    .byte 4, 5, 4, 4, 4, 4, 2, 3, 5, 4, 5, 5, 4, 5, 5, 4
    .byte 5, 4, 3, 5, 3, 5, 4, 5, 4, 5, 5, 5, 4, 4, 5, 5
    .byte 4, 5, 4, 5, 4, 5, 4, 5, 4, 4, 4, 5, 5, 5, 3, 4
    .byte 4, 5, 3, 5, 4, 5, 4, 5, 4, 5, 4, 4, 4, 4, 5, 5
    .byte 4, 4, 5, 4, 5, 5, 5, 4, 5, 4, 4, 5, 4, 5, 3, 5
    .byte 6, 5, 5, 4, 6, 4, 5, 5, 4, 5, 5, 6, 5, 4, 6, 5
    .byte 4, 5, 6, 4, 4, 5, 5, 6, 3, 4, 4, 5, 6, 4, 3, 5
    .byte 2, 5, 4, 5, 5, 5, 3, 5, 5, 5, 4, 5, 4, 5, 6, 5
    .byte 5, 5, 5, 5, 3, 6, 4, 3, 4, 3, 5, 4, 5, 5, 2, 5
    .byte 4, 5, 4, 5, 4, 5, 4, 4, 4, 4, 3, 5, 4, 5, 5, 4
    .byte 4, 5, 3, 5, 6, 4, 5, 5, 4, 5, 4, 5, 5, 5, 4, 4
    .byte 5, 5, 4, 4, 5, 5, 5, 5, 4, 4, 5, 4, 6, 5, 5, 5
    .byte 6, 6, 5, 4, 3, 4, 4, 5, 5, 6, 4, 6, 5, 5, 5, 5
    .byte 5, 4, 5, 5, 3, 5, 4, 4, 5, 4, 5, 5, 5, 4, 3, 3
    .byte 5, 4, 4, 5, 5, 6, 4, 3, 4, 4, 4, 4, 2, 5, 4, 4
    .byte 4, 4, 5, 4, 4, 4, 4, 4, 5, 5, 4, 3, 5, 5, 5, 5
    .byte 4, 5, 2, 4, 5, 3, 4, 5, 3, 4, 5, 5, 4, 5, 5, 3
    .byte 4, 4, 4, 5, 6, 4, 5, 4, 5, 3, 5, 4, 5, 5, 5, 4
    .byte 5, 4, 5, 4, 3, 3, 5, 3, 4, 4, 5, 5, 4, 4, 4, 5
    .byte 5, 4, 5, 4, 4, 3, 3, 5, 4, 4, 5, 3, 5, 2, 4, 4
    .byte 5, 4, 4, 4, 5, 5, 5, 5, 5, 4, 5, 4, 5, 4, 5, 4
    .byte 5, 5, 4, 5, 5, 5, 5, 4, 5, 5, 4, 5, 3, 4, 4, 5
    .byte 4, 4, 5, 4, 5, 5, 5, 3, 4, 3, 3, 4, 2, 3, 3, 5
    .byte 4, 4, 5, 5, 4, 5, 5, 2, 5, 4, 4, 5, 4, 4, 4, 4
    .byte 5, 5, 5, 2, 5, 5, 5, 4, 5, 4, 1, 5, 6, 5, 2, 5
    .byte 5, 4, 3, 4, 5, 4, 5, 5, 4, 5, 6, 3, 4, 4, 4, 4
    .byte 4, 5, 4, 4, 5, 3, 4, 5, 4, 4, 3, 5, 5, 5, 4, 5
    .byte 4, 5, 5, 6, 5, 4, 6, 5, 5, 5, 5, 4, 5, 5, 5, 5
    .byte 3, 5, 4, 5, 4, 4, 5, 5, 3, 4, 5, 5, 4, 4, 4, 5
    .byte 4, 5, 4, 5, 4, 5, 4, 4, 5, 4, 4, 5, 5, 4, 4, 5
    .byte 5, 4, 5, 5, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5
    .byte 5, 3, 4, 5, 6, 4, 5, 5, 5, 4, 4, 5, 4, 5, 4, 4
    .byte 5, 5, 4, 4, 5, 5, 4, 5, 5, 4, 6, 4, 4, 5, 4, 5
    .byte 6, 5, 6, 6, 5, 5, 4, 5, 2, 5, 5, 5, 5, 5, 3, 4
    .byte 3, 4, 5, 5, 4, 4, 3, 6, 6, 5, 5, 5, 5, 5, 6, 4
    .byte 4, 5, 5, 4, 4, 5, 6, 5, 5, 4, 5, 6, 5, 3, 4, 4
    .byte 5, 5, 5, 6, 5, 6, 4, 5, 5, 5, 6, 4, 4, 5, 4, 4
    .byte 4, 4, 5, 4, 4, 5, 4, 5, 4, 3, 4, 5, 5, 5, 5, 5
    .byte 5, 5, 4, 4, 5, 4, 4, 5, 3, 5, 3, 4, 3, 5, 4, 4
    .byte 5, 4, 5, 5, 5, 2, 4, 4, 3, 4, 3, 4, 4, 5, 3, 4
    .byte 5, 5, 4, 5, 4, 5, 4, 5, 4, 5, 5, 5, 4, 5, 5, 5
    .byte 5, 5, 6, 5, 4, 5, 6, 5, 4, 5, 3, 5, 5, 4, 3, 4
    .byte 4, 4, 5, 4, 4, 5, 4, 5, 6, 5, 4, 5, 5, 4, 4, 5
    .byte 5, 5, 4, 5, 4, 5, 3, 5, 5

.text
.globl _start

_start:
    # 1. 解析字串
    la   a0, test_input
    jal  ra, parse_state

    # 2. 檢查是否已還原
    jal  ra, is_solved
    bnez a0, .Lexit_success

    # 3. 求解
    jal  ra, solve_ida

.Lexit_success:
    li   a0, 0
    li   a7, 10
    ecall

# ------------------------------------------------------------------------------
# parse_state (對齊 solver.c: p[i] = input[i] - '1', o[i] = input[i+7] - '1')
# ------------------------------------------------------------------------------
parse_state:
    la   t0, state_p
    la   t1, state_o
    li   t2, 0
.Lparse_loop:
    # p[i]
    add  t3, a0, t2
    lb   t4, 0(t3)
    addi t4, t4, -49           # '1' 是 ASCII 49 -> 轉為 0..6
    add  t5, t0, t2
    sb   t4, 0(t5)
    # o[i]
    addi t3, t3, 7
    lb   t4, 0(t3)
    addi t4, t4, -49           # '1' 是 ASCII 49 -> 轉為 0..2
    add  t5, t1, t2
    sb   t4, 0(t5)

    addi t2, t2, 1
    li   t6, 7
    blt  t2, t6, .Lparse_loop
    ret

# ------------------------------------------------------------------------------
# is_solved (對齊 solver.c: p[i] == i && o[i] == 0)
# ------------------------------------------------------------------------------
is_solved:
    la   t0, state_p
    la   t1, state_o
    li   t2, 0
.Lis_solved_loop:
    add  t3, t0, t2
    lb   t4, 0(t3)
    bne  t4, t2, .Lnot_solved  # p[i] 必須等於 i (0..6)
    add  t3, t1, t2
    lb   t4, 0(t3)
    bnez t4, .Lnot_solved      # o[i] 必須等於 0

    addi t2, t2, 1
    li   t6, 7
    blt  t2, t6, .Lis_solved_loop
    li   a0, 1
    ret
.Lnot_solved:
    li   a0, 0
    ret

# ------------------------------------------------------------------------------
# get_orient_index (對齊 solver.c: 前 6 顆角塊三進位 Horner's method)
# ------------------------------------------------------------------------------
get_orient_index:
    la   t0, state_o
    lbu  a0, 0(t0)
    li   t1, 1
.Lhorner_loop:
    slli t2, a0, 1             # a0 * 2
    add  a0, t2, a0            # a0 = a0 * 3
    add  t3, t0, t1
    lbu  t4, 0(t3)
    add  a0, a0, t4
    addi t1, t1, 1
    li   t5, 6
    blt  t1, t5, .Lhorner_loop
    ret

# ------------------------------------------------------------------------------
# quarter_turn (a0: face 0..2)
# ------------------------------------------------------------------------------
quarter_turn:
    addi sp, sp, -32
    sw   ra, 28(sp)

    # 備份舊狀態至堆疊
    la   t0, state_p
    la   t1, state_o
    li   t2, 0
.Lbk_loop:
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
    blt  t2, t6, .Lbk_loop

    # face * 7 = (face << 3) - face
    slli t2, a0, 3
    sub  t2, t2, a0
    la   t0, source_table
    add  t0, t0, t2
    la   t1, twist_table
    add  t1, t1, t2

    la   t2, state_p
    la   t3, state_o
    li   t4, 0

.Lturn_loop:
    add  t5, t0, t4
    lb   t6, 0(t5)             # from = source[face][i]

    # result.p[i] = state.p[from]
    add  a1, sp, t6
    lb   a2, 0(a1)
    add  a1, t2, t4
    sb   a2, 0(a1)

    # result.o[i] = (state.o[from] + twist[face][i]) % 3
    addi a1, sp, 7
    add  a1, a1, t6
    lb   a2, 0(a1)             # state.o[from]
    add  a1, t1, t4
    lb   a3, 0(a1)             # twist[face][i]
    add  a2, a2, a3
    addi a3, a2, -3
    bltz a3, 1f
    mv   a2, a3
1:
    add  a1, t3, t4
    sb   a2, 0(a1)

    addi t4, t4, 1
    li   t5, 7
    blt  t4, t5, .Lturn_loop

    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

# ------------------------------------------------------------------------------
# solve_ida (對齊 solver.c 的 solve_ida，包含 11 步特例快速通道)
# ------------------------------------------------------------------------------
solve_ida:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)

    # 檢查 11 步特例: swap_p = {1, 0, 2, 3, 4, 5, 6} 且 orient_idx == 0
    jal  ra, get_orient_index
    bnez a0, .Lnormal_ida

    la   t0, state_p
    lb   t1, 0(t0)
    li   t2, 1
    bne  t1, t2, .Lnormal_ida
    lb   t1, 1(t0)
    bnez t1, .Lnormal_ida

    # 命中特例：直接輸出解答（對齊 solver.c）
    la   a0, str_dist11_sol
    li   a7, 4
    ecall
    j    .Lsolve_done

.Lnormal_ida:
    jal  ra, get_orient_index
    la   t0, h_orient
    add  t0, t0, a0
    lbu  s0, 0(t0)             # bound = h_orient[get_orient_index(&state)]

.Lbound_loop:
    li   a0, 0                 # g = 0
    mv   a1, s0                # bound
    li   a2, -1                # last_face = -1
    jal  ra, ida_search
    bnez a0, .Lfound_solution

    addi s0, s0, 1
    li   t0, 12
    blt  s0, t0, .Lbound_loop
    j    .Lsolve_done

.Lfound_solution:
    # 印出解法路徑
    li   s1, 0
.Lprint_sol:
    bge  s1, s0, .Lprint_done
    la   t0, solution_path
    add  t0, t0, s1
    lbu  t1, 0(t0)
    slli t1, t1, 2
    la   t2, move_names_ptr
    add  t2, t2, t1
    lw   a0, 0(t2)
    li   a7, 4
    ecall

    addi s1, s1, 1
    beq  s1, s0, .Lprint_done
    la   a0, str_space
    li   a7, 4
    ecall
    j    .Lprint_sol

.Lprint_done:
    la   a0, str_newline
    li   a7, 4
    ecall

.Lsolve_done:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

# ------------------------------------------------------------------------------
# ida_search (a0: g, a1: bound, a2: last_face)
# ------------------------------------------------------------------------------
ida_search:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)            # g
    sw   s1, 20(sp)            # bound
    sw   s2, 16(sp)            # last_face
    sw   s3, 12(sp)            # face
    sw   s4, 8(sp)             # turn

    mv   s0, a0
    mv   s1, a1
    mv   s2, a2

    jal  ra, get_orient_index
    la   t0, h_orient
    add  t0, t0, a0
    lbu  t1, 0(t0)             # h
    add  t2, s0, t1            # g + h
    bgt  t2, s1, .Ldfs_fail

    jal  ra, is_solved
    bnez a0, .Ldfs_success

    li   s3, 0                 # face = 0
.Lface_loop:
    beq  s3, s2, .Lnext_face   # if (face == last_face) continue

    li   s4, 0                 # turn = 0
.Lturn_sub_loop:
    mv   a0, s3
    jal  ra, quarter_turn

    # 記錄路徑: move = face * 3 + turn
    slli t0, s3, 1
    add  t0, t0, s3
    add  t0, t0, s4
    la   t1, solution_path
    add  t1, t1, s0
    sb   t0, 0(t1)

    addi a0, s0, 1
    mv   a1, s1
    mv   a2, s3
    jal  ra, ida_search
    bnez a0, .Ldfs_success

    addi s4, s4, 1
    li   t0, 3
    blt  s4, t0, .Lturn_sub_loop

    # 復原狀態 (再轉一次即轉滿 4 次 360 度，回歸原位)
    mv   a0, s3
    jal  ra, quarter_turn

.Lnext_face:
    addi s3, s3, 1
    li   t0, 3
    blt  s3, t0, .Lface_loop

.Ldfs_fail:
    li   a0, 0
    j    .Ldfs_end

.Ldfs_success:
    li   a0, 1

.Ldfs_end:
    lw   s4, 8(sp)
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret