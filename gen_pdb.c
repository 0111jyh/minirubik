#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    N_CUBIES = 7,
    N_ORIENT = 729,
    FACES = 3
};

/* 
 * 面 0: R (Right)
 * 面 1: B (Back)
 * 面 2: D (Down)
 */
static const uint8_t src_pos[FACES][N_CUBIES] = {
    {1, 4, 2, 0, 3, 5, 6},
    {0, 1, 2, 4, 5, 6, 3},
    {0, 2, 5, 3, 1, 4, 6}
};

static const uint8_t face_twist[FACES][N_CUBIES] = {
    {1, 2, 0, 2, 1, 0, 0},
    {0, 0, 0, 1, 2, 1, 2},
    {0, 0, 0, 0, 0, 0, 0}
};

/* 把 6 個角塊的朝向 (0..2) 編碼成三進位整數 (0..728) */
static int encode_orient(const uint8_t o[N_CUBIES])
{
    int code = 0;
    for (int i = 0; i < 6; i++) {
        code = code * 3 + o[i];
    }
    return code;
}

/* 從三進位整數還原 7 個角塊的朝向（第 7 塊由總和為 3 的倍數推算） */
static void decode_orient(int code, uint8_t o[N_CUBIES])
{
    int sum = 0;
    for (int i = 5; i >= 0; i--) {
        o[i] = code % 3;
        sum += o[i];
        code /= 3;
    }
    o[6] = (3 - (sum % 3)) % 3;
}

/* 計算旋轉一個面之後的新朝向 */
static int rotate_face(int current_code, int face)
{
    uint8_t curr_o[N_CUBIES];
    uint8_t next_o[N_CUBIES];

    decode_orient(current_code, curr_o);

    for (int i = 0; i < N_CUBIES; i++) {
        uint8_t prev = src_pos[face][i];
        next_o[i] = (curr_o[prev] + face_twist[face][i]) % 3;
    }

    return encode_orient(next_o);
}

int main(void)
{
    uint8_t dist_table[N_ORIENT];
    int queue[N_ORIENT];
    int head = 0, tail = 0;

    memset(dist_table, 0xFF, sizeof(dist_table));

    /* 還原狀態編碼為 0，距離為 0 */
    dist_table[0] = 0;
    queue[tail++] = 0;

    /* 用 BFS 找出所有 729 種狀態的最短朝向還原步數 */
    while (head < tail) {
        int curr = queue[head++];
        uint8_t d = dist_table[curr];

        for (int f = 0; f < FACES; f++) {
            int nxt = rotate_face(curr, f);
            if (dist_table[nxt] == 0xFF) {
                dist_table[nxt] = d + 1;
                queue[tail++] = nxt;
            }
        }
    }

    if (tail != N_ORIENT) {
        fprintf(stderr, "Error: BFS could not reach all %d states (only reached %d)\n", N_ORIENT, tail);
        return 1;
    }

    FILE *out = fopen("pdb.h", "w");
    if (!out) {
        perror("Failed to open pdb.h");
        return 1;
    }

    fprintf(out, "#ifndef PDB_H\n");
    fprintf(out, "#define PDB_H\n\n");
    fprintf(out, "#include <stdint.h>\n\n");
    fprintf(out, "/* Orientation heuristic table (729 entries) */\n");
    fprintf(out, "static const uint8_t h_orient[729] = {\n");

    for (int i = 0; i < N_ORIENT; i++) {
        if (i % 16 == 0)
            fprintf(out, "    ");
        fprintf(out, "%d%s", dist_table[i], (i == N_ORIENT - 1) ? "" : ", ");
        if (i % 16 == 15 || i == N_ORIENT - 1)
            fprintf(out, "\n");
    }

    fprintf(out, "};\n\n");
    fprintf(out, "#endif /* PDB_H */\n");
    fclose(out);

    printf("Successfully built pdb.h (%d states reachable, max depth = %d)\n", tail, dist_table[queue[tail - 1]]);
    return 0;
}