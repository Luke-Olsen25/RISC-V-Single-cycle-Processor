.data
# Initial values for testing
val1: .word 0xAAAAAaaa  
val2: .word 0x55555555  

# Data for byte/halfword load tests
test_bytes:
    .byte 0x80      # Index 0: -128 signed, 128 unsigned
    .byte 0x7F      # Index 1: 127 signed, 127 unsigned
    .byte 0xFF      # Index 2: -1 signed, 255 unsigned
    .byte 0x01      # Index 3: 1 signed, 1 unsigned

test_halfs:
    .half 0x8000    # Index 0: -32768 signed, 32768 unsigned
    .half 0x7FFF    # Index 2: 32767 signed, 32767 unsigned
    .half 0xFFFF    # Index 4: -1 signed, 65535 unsigned
    .half 0x0001    # Index 6: 1 signed, 1 unsigned

# Space to store the result of each test operation
results: .space 120       # Allocate 120 bytes (30 words) for results

.text
.global _start

_start:
    # --- Setup ---
    # Load the base address of the results array into s0
    lui s0, %hi(results)
    addi s0, s0, %lo(results)

    # Load initial values into t0 and t1
    lui t0, %hi(val1)
    lw t0, %lo(val1)(t0)    # t0 = 0xAAAAAaaa
    
    lui t1, %hi(val2)
    lw t1, %lo(val2)(t1)    # t1 = 0x55555555

    # Store initial values for verification
    sw t0, 0(s0)            # results[0] = 0xAAAAAaaa
    sw t1, 4(s0)            # results[1] = 0x55555555
    addi s1, s0, 8          # s1 will be our results pointer

    # --- R-Type Instructions ---
    add t2, t0, t1          # t2 = 0xAAAAAAAA + 0x55555555 = 0xFFFFFFFF
    sw t2, 0(s1)
    addi s1, s1, 4

    sub t2, t0, t1          # t2 = 0xAAAAAAAA - 0x55555555 = 0x55555555
    sw t2, 0(s1)
    addi s1, s1, 4

    slt t2, t0, t1          # t2 = (signed(t0) < signed(t1)) -> 1
    sw t2, 0(s1)
    addi s1, s1, 4

    or t2, t0, t1           # t2 = 0xAAAAAAAA | 0x55555555 = 0xFFFFFFFF
    sw t2, 0(s1)
    addi s1, s1, 4

    and t2, t0, t1          # t2 = 0xAAAAAAAA & 0x55555555 = 0x00000000
    sw t2, 0(s1)
    addi s1, s1, 4

    xor t2, t0, t1          # t2 = 0xAAAAAAAA ^ 0x55555555 = 0xFFFFFFFF
    sw t2, 0(s1)
    addi s1, s1, 4

    li t5, 4                # Load shift amount into a register (t5)
    
    sll t2, t1, t5          # t2 = 0x55555555 << 4 = 0x55555550
    sw t2, 0(s1) 
    addi s1, s1, 4

    srl t2, t0, t5          # t2 = 0xAAAAAAAA >> 4 (logical) = 0x0AAAAAAA
    sw t2, 0(s1) 
    addi s1, s1, 4

    sra t2, t0, t5          # t2 = 0xAAAAAAAA >> 4 (arithmetic) = 0xFAAAAAAA
    sw t2, 0(s1) 
    addi s1, s1, 4

    # --- I-Type Instructions ---
    addi t2, t0, 100        # t2 = 0xAAAAAaaa + 100 = 0xAAAAAb0e
    sw t2, 0(s1)
    addi s1, s1, 4

    slti t2, t0, -1         # t2 = (signed(t0) < -1) -> 1
    sw t2, 0(s1)
    addi s1, s1, 4
    
    sltiu t2, t0, 100       # t2 = (unsigned(t0) < 100) -> 0
    sw t2, 0(s1)
    addi s1, s1, 4

    ori t2, t0, 0xF0        # t2 = 0xAAAAAaaa | 0xF0 = 0xAAAAAAFA
    sw t2, 0(s1)
    addi s1, s1, 4

    andi t2, t0, 0xF0       # t2 = 0xAAAAAaaa & 0xF0 = 0x000000A0
    sw t2, 0(s1)
    addi s1, s1, 4

    xori t2, t1, 0xFF       # t2 = 0x55555555 ^ 0xFF = 0x555555AA
    sw t2, 0(s1)
    addi s1, s1, 4

    slli t2, t1, 8          # t2 = 0x55555555 << 8 = 0x55555500
    sw t2, 0(s1)
    addi s1, s1, 4

    srli t2, t0, 8          # t2 = 0xAAAAAAAA >> 8 (logical) = 0x00AAAAAA
    sw t2, 0(s1)
    addi s1, s1, 4

    srai t2, t0, 8          # t2 = 0xAAAAAAAA >> 8 (arithmetic) = 0xFFFFAAAA
    sw t2, 0(s1)
    addi s1, s1, 4

    # --- U-Type Instructions ---
    lui t2, 0xDEADB         # t2 = 0xDEADB000
    sw t2, 0(s1)
    addi s1, s1, 4

    auipc t2, 0x1           # t2 = pc + 0x1000
    sw t2, 0(s1)
    addi s1, s1, 4

    # --- Load/Store Test (LW/SW already tested) ---
    # Load byte/half addresses
    lui t3, %hi(test_bytes)
    addi t3, t3, %lo(test_bytes) # t3 = address of test_bytes
    
    lui t4, %hi(test_halfs)
    addi t4, t4, %lo(test_halfs) # t4 = address of test_halfs
    
    lb t2, 0(t3)            # t2 = load byte 0x80 (signed) = 0xFFFFFF80
    sw t2, 0(s1)
    addi s1, s1, 4
    
    lbu t2, 0(t3)           # t2 = load byte 0x80 (unsigned) = 0x00000080
    sw t2, 0(s1)
    addi s1, s1, 4
    
    lb t2, 1(t3)            # t2 = load byte 0x7F (signed) = 0x0000007F
    sw t2, 0(s1)
    addi s1, s1, 4
    
    lbu t2, 2(t3)           # t2 = load byte 0xFF (unsigned) = 0x000000FF
    sw t2, 0(s1)
    addi s1, s1, 4
    
    lh t2, 0(t4)            # t2 = load half 0x8000 (signed) = 0xFFFF8000
    sw t2, 0(s1)
    addi s1, s1, 4
    
    lhu t2, 0(t4)           # t2 = load half 0x8000 (unsigned) = 0x00008000
    sw t2, 0(s1)
    addi s1, s1, 4

    lh t2, 2(t4)            # t2 = load half 0x7FFF (signed) = 0x00007FFF
    sw t2, 0(s1)
    addi s1, s1, 4

    lhu t2, 4(t4)           # t2 = load half 0xFFFF (unsigned) = 0x0000FFFF
    sw t2, 0(s1)
    addi s1, s1, 4
    
# --- End of Test ---
    done:
    	wfi
   
