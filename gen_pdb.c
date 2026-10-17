#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CUBIES 7
#define MOVES 9
#define N_ORIENT 729

/* 定義方塊狀態：包含 7 顆角塊的位置 (p) 與 朝向 (o) */
typedef struct {
    uint8_t p[CUBIES];
    uint8_t o[CUBIES];
} state_t;

/* 從方塊狀態計算前 6 顆角塊的三進位朝向索引 (0..728) */
static uint16_t get_orient_index(const state_t *state)
{
    uint16_t idx = 0;
    for (uint8_t i = 0; i < 6; ++i)
        idx = (uint16_t) (idx * 3U + state->o[i]);
    return idx;
}

/* 定義轉動某個面時，角塊位置的置換來源 */
static const uint8_t source[3][CUBIES] = {
    {1, 4, 2, 0, 3, 5, 6}, /* 面 0: R */
    {0, 1, 2, 4, 5, 6, 3}, /* 面 1: B */
    {0, 2, 5, 3, 1, 4, 6}, /* 面 2: D */
};

/* 定義轉動某個面時，角塊角度的增減變化 */
static const uint8_t twist[3][CUBIES] = {
    {1, 2, 0, 2, 1, 0, 0}, /* 面 0: R */
    {0, 0, 0, 1, 2, 1, 2}, /* 面 1: B */
    {0, 0, 0, 0, 0, 0, 0}, /* 面 2: D */
};

/* 核心基本動作：將指定面順時針轉動 90 度 (1/4 圈) */
static state_t quarter_turn(state_t state, uint8_t face)
{
    state_t next;
    for (uint8_t i = 0; i < CUBIES; ++i) {
        uint8_t prev = source[face][i];
        next.p[i] = state.p[prev];
        next.o[i] = (uint8_t) ((state.o[prev] + twist[face][i]) % 3U);
    }
    return next;
}

/* 執行 9 種合法動作之一 (0..8)，回傳轉動後的完整狀態 */
static state_t apply_move(state_t state, uint8_t move)
{
    /* move % 3 + 1 代表轉動次數：0 -> 1 次 (90°), 1 -> 2 次 (180°), 2 -> 3 次 (270°) */
    uint8_t turns = (uint8_t) (move % 3U + 1U);
    /* move / 3 代表轉動的面：0, 1, 2 對應 R, B, D */
    uint8_t face = (uint8_t) (move / 3U);

    for (uint8_t i = 0; i < turns; ++i)
        state = quarter_turn(state, face);

    return state;
}

/* 佇列容量：足夠容納 BFS 探索的所有層級節點 */
#define QUEUE_SIZE 4000000
static state_t queue[QUEUE_SIZE];
static uint8_t dist_orient[N_ORIENT];

int main(void)
{
    /* 0xFF 代表尚未走訪過 */
    memset(dist_orient, 0xFF, sizeof(dist_orient));

    /* 還原狀態：位置為 0..6，朝向全為 0 */
    state_t solved = {
        .p = {0, 1, 2, 3, 4, 5, 6},
        .o = {0, 0, 0, 0, 0, 0, 0}
    };

    uint32_t head = 0, tail = 0;

    /* 將還原狀態放入佇列，步數為 0 */
    queue[tail++] = solved;
    dist_orient[0] = 0;

    int discovered_orients = 1;

    /* BFS 走訪：直到 729 種朝向的最短步數全部找到為止 */
    while (head < tail && discovered_orients < N_ORIENT) {
        state_t curr = queue[head++];
        uint16_t curr_idx = get_orient_index(&curr);
        uint8_t current_dist = dist_orient[curr_idx];

        /* 嘗試全部 9 種動作 (R, R2, R', B, B2, B', D, D2, D') */
        for (uint8_t move = 0; move < MOVES; ++move) {
            state_t next = apply_move(curr, move);
            uint16_t next_idx = get_orient_index(&next);

            /* 第一次看到這個朝向，記錄最短步數 */
            if (dist_orient[next_idx] == 0xFF) {
                dist_orient[next_idx] = current_dist + 1;
                discovered_orients++;
            }

            /* 將新狀態加入佇列繼續向下擴展 */
            if (tail < QUEUE_SIZE) {
                queue[tail++] = next;
            }
        }
    }

    FILE *out = fopen("pdb.h", "w");
    if (!out) {
        perror("Failed to open pdb.h");
        return 1;
    }

    fprintf(out, "#ifndef PDB_H\n");
    fprintf(out, "#define PDB_H\n\n");
    fprintf(out, "#include <stdint.h>\n\n");
    fprintf(out, "static const uint8_t h_orient[729] = {\n");

    for (int i = 0; i < N_ORIENT; ++i) {
        if (i % 16 == 0)
            fprintf(out, "    ");
        fprintf(out, "%u%s", dist_orient[i], (i == N_ORIENT - 1) ? "" : ", ");
        if (i % 16 == 15 || i == N_ORIENT - 1)
            fprintf(out, "\n");
    }

    fprintf(out, "};\n\n");
    fprintf(out, "#endif /* PDB_H */\n");
    fclose(out);

    printf("Successfully built pdb.h (%d orientations covered, queue used: %u)\n", 
           discovered_orients, tail);
    return 0;
}