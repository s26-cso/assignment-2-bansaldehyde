.text

.globl make_node
make_node:
    addi sp, sp, -16            # grab stack space
    sd ra, 8(sp)                # save ra
    sd s0, 0(sp)                # save s0

    mv s0, a0                   # keep our value safe in s0

    li a0, 24                   # need 24 bytes for a new node
    call malloc

    # got the new node in a0 now
    sw s0, 0(a0)                # set the value
    sd zero, 8(a0)              # left child is null for now
    sd zero, 16(a0)             # right child is null too

    ld ra, 8(sp)                # bring back ra
    ld s0, 0(sp)                # bring back s0
    addi sp, sp, 16             # clean up stack space
    ret

.globl insert
insert:
    addi sp, sp, -32            # grab 32 bytes on stack
    sd ra, 24(sp)               # save ra
    sd s0, 16(sp)               # save s0 for root ptr
    sd s1, 8(sp)                # save s1 for the value

    mv s0, a0                   # s0 = root
    mv s1, a1                   # s1 = val

    # if root is null, just make a new node and dip
    bnez s0, .insert_not_null

    mv a0, s1                   # pass val to make_node
    call make_node
    j .insert_done              # got the new node, we are done

.insert_not_null:
    # figure out if we go left or right based on val
    lw t0, 0(s0)                    # t0 = root->val
    blt s1, t0, .insert_go_left     # go left if val < root->val
    bgt s1, t0, .insert_go_right    # go right if val > root->val

    # duplicate value, don't do anything just return the root
    mv a0, s0
    j .insert_done

.insert_go_left:
    # go down the left side
    ld a0, 8(s0)                # arg1 = root->left
    mv a1, s1                   # arg2 = val
    call insert
    sd a0, 8(s0)                # link the left child back
    mv a0, s0                   # setup return value
    j .insert_done

.insert_go_right:
    # go down the right side
    ld a0, 16(s0)               # arg1 = root->right
    mv a1, s1                   # arg2 = val
    call insert
    sd a0, 16(s0)               # link the right child back
    mv a0, s0                   # setup return value
    j .insert_done

.insert_done:
    ld ra, 24(sp)               # restore return address
    ld s0, 16(sp)               # restore s0
    ld s1, 8(sp)                # restore s1
    addi sp, sp, 32             # free stack space
    ret

.globl get
get:
.get_loop:
    # hit a dead end, didn't find the value
    beqz a0, .get_not_found

    # check the current node's value
    lw t0, 0(a0)                # get root->val
    beq a1, t0, .get_found      # woohoo found it!
    blt a1, t0, .get_go_left    # too small, go left
    # it's bigger, so keep looking right
    ld a0, 16(a0)               # root = root->right
    j .get_loop

.get_go_left:
    ld a0, 8(a0)                # root = root->left
    j .get_loop

.get_found:
    ret                         # a0 already has the node pointer

.get_not_found:
    li a0, 0                    # return null
    ret

.globl getAtMost
getAtMost:
    mv t1, a0                   # t1 = val (save it)
    li a0, -1                   # result = -1 (default answer)

.getAtMost_loop:
    # if root is null we are out of nodes to check
    beqz a1, .getAtMost_done

    # check the value
    lw t0, 0(a1)                # t0 = root->val
    beq t0, t1, .getAtMost_exact     # exact match
    bgt t0, t1, .getAtMost_go_left   # too big, gotta search the left side

    # found a smaller one, might be the answer
    mv a0, t0                   # save this as current best
    ld a1, 16(a1)               # try right side for a better match
    j .getAtMost_loop

.getAtMost_exact:
    # exact match, best possible answer
    mv a0, t0                   # result = root->val
    j .getAtMost_done

.getAtMost_go_left:
    # root->val is too big, go left to find smaller values
    ld a1, 8(a1)                # root = root->left
    j .getAtMost_loop

.getAtMost_done:
    ret
