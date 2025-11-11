.text
.global _start

_start:
    lui sp, 0x10010     # sp = 0x10000000
    # Load initial values for branching
    li t0, 10
    li t1, 10
    li t2, 20
    
    # Load unsigned values
    lui t3, 0xAAAAA     # t3 = 0xAAAAA000 (large unsigned)
    li t4, 100          # t4 = 100 (small unsigned)


    # begin tests

    # Test BEQ (taken)
    beq t0, t1, beq_taken
    li a0, 0xBAD        # This line should be skipped
beq_taken:
    nop                 # Target for beq

    # Test BEQ (not taken)
    beq t0, t2, beq_not_taken
    li a0, 1            # This line should execute
beq_not_taken:
    nop

    # Test BNE (taken)
    bne t0, t2, bne_taken
    li a0, 0xBAD        # This line should be skipped
bne_taken:
    nop

    # Test BNE (not taken)
    bne t0, t1, bne_not_taken
    li a0, 2            # This line should execute
bne_not_taken:
    nop

    # Test BLT (taken)
    blt t0, t2, blt_taken   # (signed) 10 < 20 -> True
    li a0, 0xBAD        # This line should be skipped
blt_taken:
    nop

    # Test BLT (not taken)
    blt t0, t1, blt_not_taken # (signed) 10 < 10 -> False
    li a0, 3            # This line should execute
blt_not_taken:
    nop

    # Test BGE (taken)
    bge t0, t1, bge_taken   # (signed) 10 >= 10 -> True
    li a0, 0xBAD        # This line should be skipped
bge_taken:
    nop

    # Test BGE (not taken)
    bge t0, t2, bge_not_taken # (signed) 10 >= 20 -> False
    li a0, 4            # This line should execute
bge_not_taken:
    nop
    
    # Test BLTU (taken)
    bltu t4, t3, bltu_taken   # (unsigned) 100 < 0xAAAAA000 -> True
    li a0, 0xBAD        # This line should be skipped
bltu_taken:
    nop
    
    # Test BLTU (not taken)
    bltu t3, t4, bltu_not_taken # (unsigned) 0xAAAAA000 < 100 -> False
    li a0, 5            # This line should execute
bltu_not_taken:
    nop
    
    # Test BGEU (taken)
    bgeu t3, t4, bgeu_taken   # (unsigned) 0xAAAAA000 >= 100 -> True
    li a0, 0xBAD        # This line should be skipped
bgeu_taken:
    nop
    
    # Test BGEU (not taken)
    bgeu t4, t3, bgeu_not_taken # (unsigned) 100 >= 0xAAAAA000 -> False
    li a0, 6            # This line should execute
bgeu_not_taken:
    nop

    # -- Function Call Test (Depth 5) --
    # 'a0' will hold the result (call depth)
    li a0, 0

    # Test JAL (Call Depth 1)
    jal funcA

    # After funcA returns, a0 should be 5
    # Store it in s1 for final verification
    mv s1, a0

    # --- JALR (Computed Jump) Test ---
    # Jump to the 'done' label using jalr
    lui t0, %hi(done)
    addi t0, t0, %lo(done)
    
    # Use jalr to jump. We use 'zero' as the link register
    # because we don't care about returning.
    jalr zero, t0, 0

    # This code should be skipped
    li a0, 0xBAD
    li s1, 0xBAD

done:
    li a7, 10   # 10 is the ecall code for "exit"
    ecall       # Tell RARS to halt

funcA: # Call Depth 1
    addi sp, sp, -4     # Allocate 4 bytes on stack
    sw ra, 0(sp)        # Save return address
    
    addi a0, a0, 1      # a0 = 1
    jal funcB           # Call Depth 2
    
    lw ra, 0(sp)        # Restore return address
    addi sp, sp, 4      # Deallocate stack
    jalr zero, ra, 0    # Return (tests JALR)

funcB: # Call Depth 2
    addi sp, sp, -4
    sw ra, 0(sp)
    
    addi a0, a0, 1      # a0 = 2
    jal funcC           # Call Depth 3
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr zero, ra, 0    # Return

funcC: # Call Depth 3
    addi sp, sp, -4
    sw ra, 0(sp)
    
    addi a0, a0, 1      # a0 = 3
    jal funcD           # Call Depth 4
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr zero, ra, 0    # Return

funcD: # Call Depth 4
    addi sp, sp, -4
    sw ra, 0(sp)
    
    addi a0, a0, 1      # a0 = 4
    jal funcE           # Call Depth 5
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr zero, ra, 0    # Return

funcE: # Call Depth 5
    addi a0, a0, 1      # a0 = 5
    jalr zero, ra, 0    # Return
