# Expected sorted result:
# [-5, -2, 0, 3, 3, 5, 7, 8, 10, 100]

.data
ARRAY_SIZE: .word 10

# The array to be sorted
array:
    .word 5
    .word -2
    .word 10
    .word 0
    .word 8
    .word 3
    .word 3
    .word -5
    .word 100
    .word 7

# A temporary buffer of the same size, required for merging
temp_array:
    .space 40   # 10 elements * 4 bytes/word

.text
.global _start

_start:
    # --- Setup Stack Pointer ---
    li sp, 0x7FFFFFFC     # sp = 0x10000000
    
    # --- Setup Global Pointers ---
    # We will store the pointers to the main array and temp array
    # in saved registers (s0, s1) to act as 'global' variables
    # for all functions, simplifying our function arguments.
    
    # s0 = &array
    lui s0, %hi(array)
    addi s0, s0, %lo(array)
    
    # s1 = &temp_array
    lui s1, %hi(temp_array)
    addi s1, s1, %lo(temp_array)

    # --- Initial Call to mergesort ---
    # Load arguments for mergesort(array, left, right)
    # We pass the array pointer in 'a0' even though it's
    # also in 's0', just to be clear.
    
    mv a0, s0           # a0 = &array
    li a1, 0            # a1 = left (index 0)
    
    # Load array size
    lui t0, %hi(ARRAY_SIZE)
    lw t0, %lo(ARRAY_SIZE)(t0)
    addi a2, t0, -1     # a2 = right (index N-1)
    
    # Call the main function
    jal mergesort

    # --- End of Test ---
done:
    li a7, 10      
    ecall

mergesort:
    # s2 = mid
    # s3 = left
    # s4 = right
    # Stack space = 4 words (16 bytes)
    addi sp, sp, -16
    sw ra, 0(sp)        # Save return address
    sw s2, 4(sp)        # Save s2
    sw s3, 8(sp)        # Save s3
    sw s4, 12(sp)       # Save s4
    
    # Save arguments into saved registers
    mv s3, a1           # s3 = left
    mv s4, a2           # s4 = right

    # --- Base Case ---
    # if (left >= right), return
    bge s3, s4, mergesort_return

    # --- Find Middle Index ---
    # mid = (left + right) / 2
    add t0, s3, s4      # t0 = left + right
    srai s2, t0, 1      # s2 = mid (arithmetic shift right by 1)

    # --- Recursive Call 1: mergesort(array, left, mid) ---
    mv a0, s0           # a0 = &array
    mv a1, s3           # a1 = left
    mv a2, s2           # a2 = mid
    jal mergesort

    # --- Recursive Call 2: mergesort(array, mid + 1, right) ---
    mv a0, s0           # a0 = &array
    addi a1, s2, 1      # a1 = mid + 1
    mv a2, s4           # a2 = right
    jal mergesort

    # --- Merge the two halves ---
    # Call merge(array, left, mid, right)
    mv a0, s0           # a0 = &array
    mv a1, s3           # a1 = left
    mv a2, s2           # a2 = mid
    mv a3, s4           # a3 = right
    jal merge

mergesort_return:
    # Restore saved registers and return
    lw ra, 0(sp)
    lw s2, 4(sp)
    lw s3, 8(sp)
    lw s4, 12(sp)
    addi sp, sp, 16
    
    jalr zero, ra, 0    # return


merge:
    # s2 = left
    # s3 = mid
    # s4 = right
    # s5 = mid + 1 (for loop boundary)
    # s6 = right + 1 (for loop boundary)
    # Stack space = 5 words (20 bytes)
    addi sp, sp, -20
    sw s2, 0(sp)
    sw s3, 4(sp)
    sw s4, 8(sp)
    sw s5, 12(sp)
    sw s6, 16(sp)
    
    mv s2, a1           # s2 = left
    mv s3, a2           # s3 = mid
    mv s4, a3           # s4 = right
    addi s5, s3, 1      # s5 = mid + 1
    addi s6, s4, 1      # s6 = right + 1 (loop boundary)

    # --- Step 1: Copy array[left...right] to temp_array ---
    mv t0, s2           # t0 = i = left
copy_loop:
    # if (i >= right + 1), end loop
    bge t0, s6, copy_done
    
    # Get value from array[i]
    slli t1, t0, 2      # t1 = i * 4 (offset)
    add t2, s0, t1      # t2 = &array[i]
    lw t3, 0(t2)        # t3 = array[i]
    
    # Store value in temp_array[i]
    add t4, s1, t1      # t4 = &temp_array[i]
    sw t3, 0(t4)        # temp_array[i] = t3
    
    addi t0, t0, 1      # i++
    j copy_loop
copy_done:

    # --- Step 2: Merge from temp_array back into array ---
    mv t0, s2           # t0 = i (pointer for left half, starts at left)
    mv t1, s5           # t1 = j (pointer for right half, starts at mid + 1)
    mv t2, s2           # t2 = k (pointer for main array, starts at left)
    
merge_loop:
    # Check if left half is exhausted (i >= mid + 1)
    bge t0, s5, merge_right_only
    # Check if right half is exhausted (j >= right + 1)
    bge t1, s6, merge_left_only

    # Get values from temp_array
    # t4 = temp_array[i]
    slli t3, t0, 2
    add t3, s1, t3
    lw t4, 0(t3)
    
    # t5 = temp_array[j]
    slli t3, t1, 2
    add t3, s1, t3
    lw t5, 0(t3)
    
    # Compare: if (temp_array[i] <= temp_array[j])
    # We use (temp_array[j] >= temp_array[i])
    bge t5, t4, merge_take_left

merge_take_right:
    # array[k] = temp_array[j]
    slli t3, t2, 2
    add t3, s0, t3
    sw t5, 0(t3)        # array[k] = t5
    addi t1, t1, 1      # j++
    j merge_next_k

merge_take_left:
    # array[k] = temp_array[i]
    slli t3, t2, 2
    add t3, s0, t3
    sw t4, 0(t3)        # array[k] = t4
    addi t0, t0, 1      # i++
    
merge_next_k:
    addi t2, t2, 1      # k++
    j merge_loop

merge_right_only:
    # Left half is empty, copy rest of right half
    # if (j >= right + 1), done
    bge t1, s6, merge_done
    
    # array[k] = temp_array[j]
    slli t3, t1, 2
    add t3, s1, t3
    lw t4, 0(t3)        # t4 = temp_array[j]
    
    slli t3, t2, 2
    add t3, s0, t3
    sw t4, 0(t3)        # array[k] = t4
    
    addi t1, t1, 1      # j++
    addi t2, t2, 1      # k++
    j merge_right_only

merge_left_only:
    # Right half is empty, copy rest of left half
    # if (i >= mid + 1), done
    bge t0, s5, merge_done
    
    # array[k] = temp_array[i]
    slli t3, t0, 2
    add t3, s1, t3
    lw t4, 0(t3)        # t4 = temp_array[i]
    
    slli t3, t2, 2
    add t3, s0, t3
    sw t4, 0(t3)        # array[k] = t4
    
    addi t0, t0, 1      # i++
    addi t2, t2, 1      # k++
    j merge_left_only

merge_done:
    # Restore saved registers and return
    lw s2, 0(sp)
    lw s3, 4(sp)
    lw s4, 8(sp)
    lw s5, 12(sp)
    lw s6, 16(sp)
    addi sp, sp, 20
    
    jalr zero, ra, 0    # return
