//=========================================================================
// riscv-add.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( add, 0x00000000, 0x00000000, 0x00000000 )
        TEST_RR_OP( add, 0x00000001, 0x00000001, 0x00000002 )
        TEST_RR_OP( add, 0x00000003, 0x00000007, 0x0000000a )

        TEST_RR_OP( add, 0x00000000, 0xffff8000, 0xffff8000 )
        TEST_RR_OP( add, 0x80000000, 0x00000000, 0x80000000 )
        TEST_RR_OP( add, 0x80000000, 0xffff8000, 0x7fff8000 )

        TEST_RR_OP( add, 0x00000000, 0x00007fff, 0x00007fff )
        TEST_RR_OP( add, 0x7fffffff, 0x00000000, 0x7fffffff )
        TEST_RR_OP( add, 0x7fffffff, 0x00007fff, 0x80007ffe )

        TEST_RR_OP( add, 0x80000000, 0x00007fff, 0x80007fff )
        TEST_RR_OP( add, 0x7fffffff, 0xffff8000, 0x7fff7fff )

        TEST_RR_OP( add, 0x00000000, 0xffffffff, 0xffffffff )
        TEST_RR_OP( add, 0xffffffff, 0x00000001, 0x00000000 )
        TEST_RR_OP( add, 0xffffffff, 0xffffffff, 0xfffffffe )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( add, 13, 11, 24 )
        TEST_RR_SRC1_EQ_DEST( add, 14, 11, 25 )
        TEST_RR_SRC0_EQ_SRC1( add, 15, 30 )
        TEST_RR_SRCS_EQ_DEST( add, 16, 32 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, add, 13, 11, 24 )
        TEST_RR_DEST_BYP( 1, add, 14, 11, 25 )
        TEST_RR_DEST_BYP( 2, add, 15, 11, 26 )

        TEST_RR_SRC01_BYP( 0, 0, add, 13, 11, 24 )
        TEST_RR_SRC01_BYP( 0, 1, add, 14, 11, 25 )
        TEST_RR_SRC01_BYP( 0, 2, add, 15, 11, 26 )
        TEST_RR_SRC01_BYP( 1, 0, add, 13, 11, 24 )
        TEST_RR_SRC01_BYP( 1, 1, add, 14, 11, 25 )
        TEST_RR_SRC01_BYP( 2, 0, add, 15, 11, 26 )

        TEST_RR_SRC10_BYP( 0, 0, add, 13, 11, 24 )
        TEST_RR_SRC10_BYP( 0, 1, add, 14, 11, 25 )
        TEST_RR_SRC10_BYP( 0, 2, add, 15, 11, 26 )
        TEST_RR_SRC10_BYP( 1, 0, add, 13, 11, 24 )
        TEST_RR_SRC10_BYP( 1, 1, add, 14, 11, 25 )
        TEST_RR_SRC10_BYP( 2, 0, add, 15, 11, 26 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( addi, 0x00000000,  0x000, 0x00000000 )
        TEST_IMM_OP( addi, 0x00000001,  0x001, 0x00000002 )
        TEST_IMM_OP( addi, 0x00000003,  0x007, 0x0000000a )

        TEST_IMM_OP( addi, 0x00000000, -0x800, 0xfffff800 )
        TEST_IMM_OP( addi, 0x80000000,  0x000, 0x80000000 )
        TEST_IMM_OP( addi, 0x80000000, -0x800, 0x7ffff800 )

        TEST_IMM_OP( addi, 0x00000000,  0x7ff, 0x000007ff )
        TEST_IMM_OP( addi, 0x7fffffff,  0x000, 0x7fffffff )
        TEST_IMM_OP( addi, 0x7fffffff,  0x7ff, 0x800007fe )

        TEST_IMM_OP( addi, 0x80000000,  0x7ff, 0x800007ff )
        TEST_IMM_OP( addi, 0x7fffffff, -0x800, 0x7ffff7ff )

        TEST_IMM_OP( addi, 0x00000000, -0x001, 0xffffffff )
        TEST_IMM_OP( addi, 0xffffffff,  0x001, 0x00000000 )
        TEST_IMM_OP( addi, 0xffffffff, -0x001, 0xfffffffe )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( addi, 13, 11, 24 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, addi, 13, 11, 24 )
        TEST_IMM_DEST_BYP( 1, addi, 13, 10, 23 )
        TEST_IMM_DEST_BYP( 2, addi, 13,  9, 22 )

        TEST_IMM_SRC0_BYP( 0, addi, 13, 11, 24 )
        TEST_IMM_SRC0_BYP( 1, addi, 13, 10, 23 )
        TEST_IMM_SRC0_BYP( 2, addi, 13,  9, 22 )

        //-----------------------------------------------------------------
        // Logical tests
        //-----------------------------------------------------------------

        TEST_RR_OP( and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_OP( and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_OP( and, 0x00ff00ff, 0x0f0f0f0f, 0x000f000f )
        TEST_RR_OP( and, 0xf00ff00f, 0xf0f0f0f0, 0xf000f000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_SRC1_EQ_DEST( and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_SRCS_EQ_DEST( and, 0xff00ff00, 0xff00ff00 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_DEST_BYP( 1, and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_DEST_BYP( 2, and, 0x00ff00ff, 0x0f0f0f0f, 0x000f000f )

        TEST_RR_SRC01_BYP( 0, 0, and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_SRC01_BYP( 0, 1, and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_SRC01_BYP( 0, 2, and, 0x00ff00ff, 0x0f0f0f0f, 0x000f000f )
        TEST_RR_SRC01_BYP( 1, 0, and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_SRC01_BYP( 1, 1, and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_SRC01_BYP( 2, 0, and, 0x00ff00ff, 0x0f0f0f0f, 0x000f000f )

        TEST_RR_SRC10_BYP( 0, 0, and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_SRC10_BYP( 0, 1, and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_SRC10_BYP( 0, 2, and, 0x00ff00ff, 0x0f0f0f0f, 0x000f000f )
        TEST_RR_SRC10_BYP( 1, 0, and, 0xff00ff00, 0x0f0f0f0f, 0x0f000f00 )
        TEST_RR_SRC10_BYP( 1, 1, and, 0x0ff00ff0, 0xf0f0f0f0, 0x00f000f0 )
        TEST_RR_SRC10_BYP( 2, 0, and, 0x00ff00ff, 0x0f0f0f0f, 0x000f000f )

        //-----------------------------------------------------------------
        // Logical tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( andi, 0xff00ff00, -0x0f1, 0xff00ff00 )
        TEST_IMM_OP( andi, 0x0ff00ff0,  0x0f0, 0x000000f0 )
        TEST_IMM_OP( andi, 0x00ff00ff, -0x0f1, 0x00ff000f )
        TEST_IMM_OP( andi, 0xf00ff00f,  0x0f0, 0x00000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( andi, 0xff00ff00,  0x0f0, 0x00000000 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, andi, 0x0ff00ff0, -0x0f1, 0x0ff00f00 )
        TEST_IMM_DEST_BYP( 1, andi, 0x00ff00ff,  0x0f0, 0x000000f0 )
        TEST_IMM_DEST_BYP( 2, andi, 0xf00ff00f, -0x0f1, 0xf00ff00f )

        TEST_IMM_SRC0_BYP( 0, andi, 0x0ff00ff0, -0x0f1, 0x0ff00f00 )
        TEST_IMM_SRC0_BYP( 1, andi, 0x00ff00ff,  0x0f0, 0x000000f0 )
        TEST_IMM_SRC0_BYP( 2, andi, 0xf00ff00f, -0x0f1, 0xf00ff00f )

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------

        // Zero and one operands

        TEST_RR_OP( div,  0,  1, 0 )
        TEST_RR_OP( div,  1,  1, 1 )
        TEST_RR_OP( div,  0, -1, 0 )
        TEST_RR_OP( div, -1, -1, 1 )

        // Positive evenly-divisible operands

        TEST_RR_OP( div,       546,    42,   13 )
        TEST_RR_OP( div,     63724,   716,   89 )
        TEST_RR_OP( div, 167882820, 20154, 8330 )

        // Negative evenly-divisible operands

        TEST_RR_OP( div,      -546,     42,   -13 )
        TEST_RR_OP( div,    -63724,   -716,    89 )
        TEST_RR_OP( div, 167882820, -20154, -8330 )

        // Positive not evenly-divisible operands

        TEST_RR_OP( div,        50,   546,    0 )
        TEST_RR_OP( div,       546,    50,   10 )
        TEST_RR_OP( div,     63724,   793,   80 )
        TEST_RR_OP( div, 167882820, 20150, 8331 )

        // Negative not evenly-divisible operands

        TEST_RR_OP( div,        50,   -546,     0 )
        TEST_RR_OP( div,      -546,     50,   -10 )
        TEST_RR_OP( div,    -63724,   -793,    80 )
        TEST_RR_OP( div, 167882820, -20150, -8331 )

        // Mixed tests

        TEST_RR_OP( div, 0xdeadbeef, 0x0000beef, 0xffffd353 )
        TEST_RR_OP( div, 0xf5fe4fbc, 0x00004eb6, 0xffffdf75 )
        TEST_RR_OP( div, 0xf5fe4fbc, 0xffffb14a, 0x0000208b )

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( div, 143, 11, 13 )
        TEST_RR_SRC1_EQ_DEST( div, 154, 11, 14 )
        TEST_RR_SRC0_EQ_SRC1( div, 15, 1 )
        TEST_RR_SRCS_EQ_DEST( div, 16, 1 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, div, 143, 11, 13 )
        TEST_RR_DEST_BYP( 1, div, 154, 11, 14 )
        TEST_RR_DEST_BYP( 2, div, 165, 11, 15 )
        TEST_RR_DEST_BYP( 3, div, 176, 11, 16 )
        TEST_RR_DEST_BYP( 4, div, 187, 11, 17 )

        TEST_RR_SRC01_BYP( 0, 0, div, 143, 11, 13 )
        TEST_RR_SRC01_BYP( 0, 1, div, 154, 11, 14 )
        TEST_RR_SRC01_BYP( 0, 2, div, 165, 11, 15 )
        TEST_RR_SRC01_BYP( 0, 3, div, 176, 11, 16 )
        TEST_RR_SRC01_BYP( 0, 4, div, 187, 11, 17 )

        TEST_RR_SRC01_BYP( 1, 0, div, 143, 11, 13 )
        TEST_RR_SRC01_BYP( 1, 1, div, 154, 11, 14 )
        TEST_RR_SRC01_BYP( 2, 0, div, 165, 11, 15 )

        TEST_RR_SRC10_BYP( 0, 0, div, 143, 11, 13 )
        TEST_RR_SRC10_BYP( 0, 1, div, 154, 11, 14 )
        TEST_RR_SRC10_BYP( 0, 2, div, 165, 11, 15 )
        TEST_RR_SRC10_BYP( 0, 3, div, 176, 11, 16 )
        TEST_RR_SRC10_BYP( 0, 4, div, 187, 11, 17 )

        TEST_RR_SRC10_BYP( 1, 0, div, 143, 11, 13 )
        TEST_RR_SRC10_BYP( 1, 1, div, 154, 11, 14 )
        TEST_RR_SRC10_BYP( 2, 0, div, 165, 11, 15 )

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------

        // Zero and one operands

        TEST_RR_OP( divu,  0,  1, 0 )
        TEST_RR_OP( divu,  1,  1, 1 )

        // Positive evenly-divisible operands

        TEST_RR_OP( divu,       546,    42,   13 )
        TEST_RR_OP( divu,     63724,   716,   89 )
        TEST_RR_OP( divu, 167882820, 20154, 8330 )

        // Positive not evenly-divisible operands

        TEST_RR_OP( divu,        50,   546,    0 )
        TEST_RR_OP( divu,       546,    50,   10 )
        TEST_RR_OP( divu,     63724,   793,   80 )
        TEST_RR_OP( divu, 167882820, 20150, 8331 )

        // Test that operands are treated as unsigned

        TEST_RR_OP( divu, 0x00000000, 0xffffffff, 0x00000000 )
        TEST_RR_OP( divu, 0xffffffff, 0xffffffff, 0x00000001 )
        TEST_RR_OP( divu, 0x0a01b044, 0xffffb14a, 0x00000000 )
        TEST_RR_OP( divu, 0xdeadbeef, 0x0000beef, 0x00012a90 )
        TEST_RR_OP( divu, 0xf5fe4fbc, 0x00004eb6, 0x00032012 )
        TEST_RR_OP( divu, 0xf5fe4fbc, 0xffffb14a, 0x00000000 )

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( divu, 143, 11, 13 )
        TEST_RR_SRC1_EQ_DEST( divu, 154, 11, 14 )
        TEST_RR_SRC0_EQ_SRC1( divu, 15, 1 )
        TEST_RR_SRCS_EQ_DEST( divu, 16, 1 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, divu, 143, 11, 13 )
        TEST_RR_DEST_BYP( 1, divu, 154, 11, 14 )
        TEST_RR_DEST_BYP( 2, divu, 165, 11, 15 )
        TEST_RR_DEST_BYP( 3, divu, 176, 11, 16 )
        TEST_RR_DEST_BYP( 4, divu, 187, 11, 17 )

        TEST_RR_SRC01_BYP( 0, 0, divu, 143, 11, 13 )
        TEST_RR_SRC01_BYP( 0, 1, divu, 154, 11, 14 )
        TEST_RR_SRC01_BYP( 0, 2, divu, 165, 11, 15 )
        TEST_RR_SRC01_BYP( 0, 3, divu, 176, 11, 16 )
        TEST_RR_SRC01_BYP( 0, 4, divu, 187, 11, 17 )

        TEST_RR_SRC01_BYP( 1, 0, divu, 143, 11, 13 )
        TEST_RR_SRC01_BYP( 1, 1, divu, 154, 11, 14 )
        TEST_RR_SRC01_BYP( 2, 0, divu, 165, 11, 15 )

        TEST_RR_SRC10_BYP( 0, 0, divu, 143, 11, 13 )
        TEST_RR_SRC10_BYP( 0, 1, divu, 154, 11, 14 )
        TEST_RR_SRC10_BYP( 0, 2, divu, 165, 11, 15 )
        TEST_RR_SRC10_BYP( 0, 3, divu, 176, 11, 16 )
        TEST_RR_SRC10_BYP( 0, 4, divu, 187, 11, 17 )

        TEST_RR_SRC10_BYP( 1, 0, divu, 143, 11, 13 )
        TEST_RR_SRC10_BYP( 1, 1, divu, 154, 11, 14 )
        TEST_RR_SRC10_BYP( 2, 0, divu, 165, 11, 15 )

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------

        // Zero and one operands

        TEST_RR_OP( mul,  0,  0, 0 )
        TEST_RR_OP( mul,  0,  1, 0 )
        TEST_RR_OP( mul,  1,  0, 0 )
        TEST_RR_OP( mul,  1,  1, 1 )
        TEST_RR_OP( mul,  0, -1, 0 )
        TEST_RR_OP( mul, -1,  0, 0 )
        TEST_RR_OP( mul, -1, -1, 1 )

        // Positive operands

        TEST_RR_OP( mul,    42,   13,       546 )
        TEST_RR_OP( mul,   716,   89,     63724 )
        TEST_RR_OP( mul, 20154, 8330, 167882820 )

        // Negative operands

        TEST_RR_OP( mul,    42,    -13,      -546 )
        TEST_RR_OP( mul,  -716,     89,    -63724 )
        TEST_RR_OP( mul, -20154, -8330, 167882820 )

        // Mixed tests

        TEST_RR_OP( mul, 0x0deadbee, 0x10000000, 0xe0000000 )
        TEST_RR_OP( mul, 0xdeadbeef, 0x10000000, 0xf0000000 )

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( mul, 13, 11, 143 )
        TEST_RR_SRC1_EQ_DEST( mul, 14, 11, 154 )
        TEST_RR_SRC0_EQ_SRC1( mul, 15, 225 )
        TEST_RR_SRCS_EQ_DEST( mul, 16, 256 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, mul, 13, 11, 143 )
        TEST_RR_DEST_BYP( 1, mul, 14, 11, 154 )
        TEST_RR_DEST_BYP( 2, mul, 15, 11, 165 )
        TEST_RR_DEST_BYP( 3, mul, 16, 11, 176 )
        TEST_RR_DEST_BYP( 4, mul, 17, 11, 187 )

        TEST_RR_SRC01_BYP( 0, 0, mul, 13, 11, 143 )
        TEST_RR_SRC01_BYP( 0, 1, mul, 14, 11, 154 )
        TEST_RR_SRC01_BYP( 0, 2, mul, 15, 11, 165 )
        TEST_RR_SRC01_BYP( 0, 3, mul, 16, 11, 176 )
        TEST_RR_SRC01_BYP( 0, 4, mul, 17, 11, 187 )

        TEST_RR_SRC01_BYP( 1, 0, mul, 13, 11, 143 )
        TEST_RR_SRC01_BYP( 1, 1, mul, 14, 11, 154 )
        TEST_RR_SRC01_BYP( 2, 0, mul, 15, 11, 165 )

        TEST_RR_SRC10_BYP( 0, 0, mul, 13, 11, 143 )
        TEST_RR_SRC10_BYP( 0, 1, mul, 14, 11, 154 )
        TEST_RR_SRC10_BYP( 0, 2, mul, 15, 11, 165 )
        TEST_RR_SRC10_BYP( 0, 3, mul, 16, 11, 176 )
        TEST_RR_SRC10_BYP( 0, 4, mul, 17, 11, 187 )

        TEST_RR_SRC10_BYP( 1, 0, mul, 13, 11, 143 )
        TEST_RR_SRC10_BYP( 1, 1, mul, 14, 11, 154 )
        TEST_RR_SRC10_BYP( 2, 0, mul, 15, 11, 165 )

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------

        // Zero and one operands

        TEST_RR_OP( rem,  0,  1, 0 )
        TEST_RR_OP( rem,  1,  1, 0 )
        TEST_RR_OP( rem,  0, -1, 0 )
        TEST_RR_OP( rem, -1, -1, 0 )

        // Positive evenly-divisible operands

        TEST_RR_OP( rem,       546,    42, 0 )
        TEST_RR_OP( rem,     63724,   716, 0 )
        TEST_RR_OP( rem, 167882820, 20154, 0 )

        // Positive not evenly-divisible operands

        TEST_RR_OP( rem,        50,   546,    50 )
        TEST_RR_OP( rem,       546,    50,    46 )
        TEST_RR_OP( rem,     63724,   793,   284 )
        TEST_RR_OP( rem, 167882820, 20150, 13170 )

        // Mixed tests

        TEST_RR_OP( rem, 0x0a01b044, 0xffffb146, 0x00000000 )
        TEST_RR_OP( rem, 0x0a01b044, 0xffffb14a, 0x00003372 )
        TEST_RR_OP( rem, 0xdeadbeef, 0x0000beef, 0xffffda72 )
        TEST_RR_OP( rem, 0xf5fe4fbc, 0x00004eb6, 0xffffcc8e )
        TEST_RR_OP( rem, 0xf5fe4fbc, 0xffffb14a, 0xffffcc8e )

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( rem, 143, 10, 3 )
        TEST_RR_SRC1_EQ_DEST( rem, 154, 10, 4 )
        TEST_RR_SRC0_EQ_SRC1( rem, 15, 0 )
        TEST_RR_SRCS_EQ_DEST( rem, 16, 0 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, rem, 143, 10, 3 )
        TEST_RR_DEST_BYP( 1, rem, 154, 10, 4 )
        TEST_RR_DEST_BYP( 2, rem, 165, 10, 5 )
        TEST_RR_DEST_BYP( 3, rem, 176, 10, 6 )
        TEST_RR_DEST_BYP( 4, rem, 187, 10, 7 )

        TEST_RR_SRC01_BYP( 0, 0, rem, 143, 10, 3 )
        TEST_RR_SRC01_BYP( 0, 1, rem, 154, 10, 4 )
        TEST_RR_SRC01_BYP( 0, 2, rem, 165, 10, 5 )
        TEST_RR_SRC01_BYP( 0, 3, rem, 176, 10, 6 )
        TEST_RR_SRC01_BYP( 0, 4, rem, 187, 10, 7 )

        TEST_RR_SRC01_BYP( 1, 0, rem, 143, 10, 3 )
        TEST_RR_SRC01_BYP( 1, 1, rem, 154, 10, 4 )
        TEST_RR_SRC01_BYP( 2, 0, rem, 165, 10, 5 )

        TEST_RR_SRC10_BYP( 0, 0, rem, 143, 10, 3 )
        TEST_RR_SRC10_BYP( 0, 1, rem, 154, 10, 4 )
        TEST_RR_SRC10_BYP( 0, 2, rem, 165, 10, 5 )
        TEST_RR_SRC10_BYP( 0, 3, rem, 176, 10, 6 )
        TEST_RR_SRC10_BYP( 0, 4, rem, 187, 10, 7 )

        TEST_RR_SRC10_BYP( 1, 0, rem, 143, 10, 3 )
        TEST_RR_SRC10_BYP( 1, 1, rem, 154, 10, 4 )
        TEST_RR_SRC10_BYP( 2, 0, rem, 165, 10, 5 )

        //--------------------------------------------------------------------
        // Arithmetic tests
        //--------------------------------------------------------------------

        // Zero and one operands

        TEST_RR_OP( remu,  0,  1, 0 )
        TEST_RR_OP( remu,  1,  1, 0 )

        // Positive evenly-divisible operands

        TEST_RR_OP( remu,       546,    42, 0 )
        TEST_RR_OP( remu,     63724,   716, 0 )
        TEST_RR_OP( remu, 167882820, 20154, 0 )

        // Positive not evenly-divisible operands

        TEST_RR_OP( remu,        50,   546,    50 )
        TEST_RR_OP( remu,       546,    50,    46 )
        TEST_RR_OP( remu,     63724,   793,   284 )
        TEST_RR_OP( remu, 167882820, 20150, 13170 )

        // Test that operands are treated as unsigned

        TEST_RR_OP( remu, 0x00000000, 0xffffffff, 0x00000000 )
        TEST_RR_OP( remu, 0xffffffff, 0xffffffff, 0x00000000 )
        TEST_RR_OP( remu, 0x0a01b044, 0xffffb14a, 0x0a01b044 )
        TEST_RR_OP( remu, 0xdeadbeef, 0x0000beef, 0x0000227f )
        TEST_RR_OP( remu, 0xf5fe4fbc, 0x00004eb6, 0x000006f0 )
        TEST_RR_OP( remu, 0xf5fe4fbc, 0xffffb14a, 0xf5fe4fbc )

        //--------------------------------------------------------------------
        // Source/Destination tests
        //--------------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( remu, 143, 10, 3 )
        TEST_RR_SRC1_EQ_DEST( remu, 154, 10, 4 )
        TEST_RR_SRC0_EQ_SRC1( remu, 15, 0 )
        TEST_RR_SRCS_EQ_DEST( remu, 16, 0 )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, remu, 143, 10, 3 )
        TEST_RR_DEST_BYP( 1, remu, 154, 10, 4 )
        TEST_RR_DEST_BYP( 2, remu, 165, 10, 5 )
        TEST_RR_DEST_BYP( 3, remu, 176, 10, 6 )
        TEST_RR_DEST_BYP( 4, remu, 187, 10, 7 )

        TEST_RR_SRC01_BYP( 0, 0, remu, 143, 10, 3 )
        TEST_RR_SRC01_BYP( 0, 1, remu, 154, 10, 4 )
        TEST_RR_SRC01_BYP( 0, 2, remu, 165, 10, 5 )
        TEST_RR_SRC01_BYP( 0, 3, remu, 176, 10, 6 )
        TEST_RR_SRC01_BYP( 0, 4, remu, 187, 10, 7 )

        TEST_RR_SRC01_BYP( 1, 0, remu, 143, 10, 3 )
        TEST_RR_SRC01_BYP( 1, 1, remu, 154, 10, 4 )
        TEST_RR_SRC01_BYP( 2, 0, remu, 165, 10, 5 )

        TEST_RR_SRC10_BYP( 0, 0, remu, 143, 10, 3 )
        TEST_RR_SRC10_BYP( 0, 1, remu, 154, 10, 4 )
        TEST_RR_SRC10_BYP( 0, 2, remu, 165, 10, 5 )
        TEST_RR_SRC10_BYP( 0, 3, remu, 176, 10, 6 )
        TEST_RR_SRC10_BYP( 0, 4, remu, 187, 10, 7 )

        TEST_RR_SRC10_BYP( 1, 0, remu, 143, 10, 3 )
        TEST_RR_SRC10_BYP( 1, 1, remu, 154, 10, 4 )
        TEST_RR_SRC10_BYP( 2, 0, remu, 165, 10, 5 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( sll, 0x00000001,  0, 0x00000001 )
        TEST_RR_OP( sll, 0x00000001,  1, 0x00000002 )
        TEST_RR_OP( sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_OP( sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_OP( sll, 0x00000001, 31, 0x80000000 )

        TEST_RR_OP( sll, 0xffffffff,  0, 0xffffffff )
        TEST_RR_OP( sll, 0xffffffff,  1, 0xfffffffe )
        TEST_RR_OP( sll, 0xffffffff,  7, 0xffffff80 )
        TEST_RR_OP( sll, 0xffffffff, 14, 0xffffc000 )
        TEST_RR_OP( sll, 0xffffffff, 31, 0x80000000 )

        TEST_RR_OP( sll, 0x21212121,  0, 0x21212121 )
        TEST_RR_OP( sll, 0x21212121,  1, 0x42424242 )
        TEST_RR_OP( sll, 0x21212121,  7, 0x90909080 )
        TEST_RR_OP( sll, 0x21212121, 14, 0x48484000 )
        TEST_RR_OP( sll, 0x21212121, 31, 0x80000000 )

        // Verify that shifts only use bottom five bits

        TEST_RR_OP( sll, 0x21212121, 0xffffffe0, 0x21212121 )
        TEST_RR_OP( sll, 0x21212121, 0xffffffe1, 0x42424242 )
        TEST_RR_OP( sll, 0x21212121, 0xffffffe7, 0x90909080 )
        TEST_RR_OP( sll, 0x21212121, 0xffffffee, 0x48484000 )
        TEST_RR_OP( sll, 0x21212121, 0xffffffff, 0x80000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_SRC1_EQ_DEST( sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_SRCS_EQ_DEST( sll, 3, 24 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_DEST_BYP( 1, sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_DEST_BYP( 2, sll, 0x00000001, 31, 0x80000000 )

        TEST_RR_SRC01_BYP( 0, 0, sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_SRC01_BYP( 0, 1, sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_SRC01_BYP( 0, 2, sll, 0x00000001, 31, 0x80000000 )
        TEST_RR_SRC01_BYP( 1, 0, sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_SRC01_BYP( 1, 1, sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_SRC01_BYP( 2, 0, sll, 0x00000001, 31, 0x80000000 )

        TEST_RR_SRC10_BYP( 0, 0, sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_SRC10_BYP( 0, 1, sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_SRC10_BYP( 0, 2, sll, 0x00000001, 31, 0x80000000 )
        TEST_RR_SRC10_BYP( 1, 0, sll, 0x00000001,  7, 0x00000080 )
        TEST_RR_SRC10_BYP( 1, 1, sll, 0x00000001, 14, 0x00004000 )
        TEST_RR_SRC10_BYP( 2, 0, sll, 0x00000001, 31, 0x80000000 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( slli, 0x00000001,  0, 0x00000001 )
        TEST_IMM_OP( slli, 0x00000001,  1, 0x00000002 )
        TEST_IMM_OP( slli, 0x00000001,  7, 0x00000080 )
        TEST_IMM_OP( slli, 0x00000001, 14, 0x00004000 )
        TEST_IMM_OP( slli, 0x00000001, 31, 0x80000000 )

        TEST_IMM_OP( slli, 0xffffffff,  0, 0xffffffff )
        TEST_IMM_OP( slli, 0xffffffff,  1, 0xfffffffe )
        TEST_IMM_OP( slli, 0xffffffff,  7, 0xffffff80 )
        TEST_IMM_OP( slli, 0xffffffff, 14, 0xffffc000 )
        TEST_IMM_OP( slli, 0xffffffff, 31, 0x80000000 )

        TEST_IMM_OP( slli, 0x21212121,  0, 0x21212121 )
        TEST_IMM_OP( slli, 0x21212121,  1, 0x42424242 )
        TEST_IMM_OP( slli, 0x21212121,  7, 0x90909080 )
        TEST_IMM_OP( slli, 0x21212121, 14, 0x48484000 )
        TEST_IMM_OP( slli, 0x21212121, 31, 0x80000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( slli, 0x00000001, 7, 0x00000080 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, slli, 0x00000001,  7, 0x00000080 )
        TEST_IMM_DEST_BYP( 1, slli, 0x00000001, 14, 0x00004000 )
        TEST_IMM_DEST_BYP( 2, slli, 0x00000001, 31, 0x80000000 )

        TEST_IMM_SRC0_BYP( 0, slli, 0x00000001,  7, 0x00000080 )
        TEST_IMM_SRC0_BYP( 1, slli, 0x00000001, 14, 0x00004000 )
        TEST_IMM_SRC0_BYP( 2, slli, 0x00000001, 31, 0x80000000 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( slt, 0x00000000, 0x00000000, 0 )
        TEST_RR_OP( slt, 0x00000001, 0x00000001, 0 )
        TEST_RR_OP( slt, 0x00000003, 0x00000007, 1 )
        TEST_RR_OP( slt, 0x00000007, 0x00000003, 0 )

        TEST_RR_OP( slt, 0x00000000, 0xffff8000, 0 )
        TEST_RR_OP( slt, 0x80000000, 0x00000000, 1 )
        TEST_RR_OP( slt, 0x80000000, 0xffff8000, 1 )

        TEST_RR_OP( slt, 0x00000000, 0x00007fff, 1 )
        TEST_RR_OP( slt, 0x7fffffff, 0x00000000, 0 )
        TEST_RR_OP( slt, 0x7fffffff, 0x00007fff, 0 )

        TEST_RR_OP( slt, 0x80000000, 0x00007fff, 1 )
        TEST_RR_OP( slt, 0x7fffffff, 0xffff8000, 0 )

        TEST_RR_OP( slt, 0x00000000, 0xffffffff, 0 )
        TEST_RR_OP( slt, 0xffffffff, 0x00000001, 1 )
        TEST_RR_OP( slt, 0xffffffff, 0xffffffff, 0 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( slt, 14, 13, 0 )
        TEST_RR_SRC1_EQ_DEST( slt, 11, 13, 1 )
        TEST_RR_SRCS_EQ_DEST( slt, 13, 0 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, slt, 11, 13, 1 )
        TEST_RR_DEST_BYP( 1, slt, 14, 13, 0 )
        TEST_RR_DEST_BYP( 2, slt, 12, 13, 1 )

        TEST_RR_SRC01_BYP( 0, 0, slt, 14, 13, 0 )
        TEST_RR_SRC01_BYP( 0, 1, slt, 11, 13, 1 )
        TEST_RR_SRC01_BYP( 0, 2, slt, 15, 13, 0 )
        TEST_RR_SRC01_BYP( 1, 0, slt, 10, 13, 1 )
        TEST_RR_SRC01_BYP( 1, 1, slt, 16, 13, 0 )
        TEST_RR_SRC01_BYP( 2, 0, slt,  9, 13, 1 )

        TEST_RR_SRC10_BYP( 0, 0, slt, 17, 13, 0 )
        TEST_RR_SRC10_BYP( 0, 1, slt,  8, 13, 1 )
        TEST_RR_SRC10_BYP( 0, 2, slt, 18, 13, 0 )
        TEST_RR_SRC10_BYP( 1, 0, slt,  7, 13, 1 )
        TEST_RR_SRC10_BYP( 1, 1, slt, 19, 13, 0 )
        TEST_RR_SRC10_BYP( 2, 0, slt,  6, 13, 1 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( slti, 0x00000000,  0x000, 0 )
        TEST_IMM_OP( slti, 0x00000001,  0x001, 0 )
        TEST_IMM_OP( slti, 0x00000003,  0x007, 1 )
        TEST_IMM_OP( slti, 0x00000007,  0x003, 0 )

        TEST_IMM_OP( slti, 0x00000000, -0x800, 0 )
        TEST_IMM_OP( slti, 0x80000000,  0x000, 1 )
        TEST_IMM_OP( slti, 0x80000000, -0x800, 1 )

        TEST_IMM_OP( slti, 0x00000000,  0x7ff, 1 )
        TEST_IMM_OP( slti, 0x7fffffff,  0x000, 0 )
        TEST_IMM_OP( slti, 0x7fffffff,  0x7ff, 0 )

        TEST_IMM_OP( slti, 0x80000000,  0x7ff, 1 )
        TEST_IMM_OP( slti, 0x7fffffff, -0x800, 0 )

        TEST_IMM_OP( slti, 0x00000000, -0x001, 0 )
        TEST_IMM_OP( slti, 0xffffffff,  0x001, 1 )
        TEST_IMM_OP( slti, 0xffffffff, -0x001, 0 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( slti, 11, 13, 1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, slti, 15, 10, 0 )
        TEST_IMM_DEST_BYP( 1, slti, 10, 16, 1 )
        TEST_IMM_DEST_BYP( 2, slti, 16,  9, 0 )

        TEST_IMM_SRC0_BYP( 0, slti, 11, 15, 1 )
        TEST_IMM_SRC0_BYP( 1, slti, 17,  8, 0 )
        TEST_IMM_SRC0_BYP( 2, slti, 12, 14, 1 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( sltiu, 0x00000000,  0x000, 0 )
        TEST_IMM_OP( sltiu, 0x00000001,  0x001, 0 )
        TEST_IMM_OP( sltiu, 0x00000003,  0x007, 1 )
        TEST_IMM_OP( sltiu, 0x00000007,  0x003, 0 )

        TEST_IMM_OP( sltiu, 0x00000000, -0x800, 1 )
        TEST_IMM_OP( sltiu, 0x80000000,  0x000, 0 )
        TEST_IMM_OP( sltiu, 0x80000000, -0x800, 1 )

        TEST_IMM_OP( sltiu, 0x00000000,  0x7ff, 1 )
        TEST_IMM_OP( sltiu, 0x7fffffff,  0x000, 0 )
        TEST_IMM_OP( sltiu, 0x7fffffff,  0x7ff, 0 )

        TEST_IMM_OP( sltiu, 0x80000000,  0x7ff, 0 )
        TEST_IMM_OP( sltiu, 0x7fffffff, -0x800, 1 )

        TEST_IMM_OP( sltiu, 0x00000000, -0x001, 1 )
        TEST_IMM_OP( sltiu, 0xffffffff,  0x001, 0 )
        TEST_IMM_OP( sltiu, 0xffffffff, -0x001, 0 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( sltiu, 11, 13, 1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, sltiu, 15, 10, 0 )
        TEST_IMM_DEST_BYP( 1, sltiu, 10, 16, 1 )
        TEST_IMM_DEST_BYP( 2, sltiu, 16,  9, 0 )

        TEST_IMM_SRC0_BYP( 0, sltiu, 11, 15, 1 )
        TEST_IMM_SRC0_BYP( 1, sltiu, 17,  8, 0 )
        TEST_IMM_SRC0_BYP( 2, sltiu, 12, 14, 1 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( sltu, 0x00000000, 0x00000000, 0 )
        TEST_RR_OP( sltu, 0x00000001, 0x00000001, 0 )
        TEST_RR_OP( sltu, 0x00000003, 0x00000007, 1 )
        TEST_RR_OP( sltu, 0x00000007, 0x00000003, 0 )

        TEST_RR_OP( sltu, 0x00000000, 0xffff8000, 1 )
        TEST_RR_OP( sltu, 0x80000000, 0x00000000, 0 )
        TEST_RR_OP( sltu, 0x80000000, 0xffff8000, 1 )

        TEST_RR_OP( sltu, 0x00000000, 0x00007fff, 1 )
        TEST_RR_OP( sltu, 0x7fffffff, 0x00000000, 0 )
        TEST_RR_OP( sltu, 0x7fffffff, 0x00007fff, 0 )

        TEST_RR_OP( sltu, 0x80000000, 0x00007fff, 0 )
        TEST_RR_OP( sltu, 0x7fffffff, 0xffff8000, 1 )

        TEST_RR_OP( sltu, 0x00000000, 0xffffffff, 1 )
        TEST_RR_OP( sltu, 0xffffffff, 0x00000001, 0 )
        TEST_RR_OP( sltu, 0xffffffff, 0xffffffff, 0 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( sltu, 14, 13, 0 )
        TEST_RR_SRC1_EQ_DEST( sltu, 11, 13, 1 )
        TEST_RR_SRCS_EQ_DEST( sltu, 13, 0 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, sltu, 11, 13, 1 )
        TEST_RR_DEST_BYP( 1, sltu, 14, 13, 0 )
        TEST_RR_DEST_BYP( 2, sltu, 12, 13, 1 )

        TEST_RR_SRC01_BYP( 0, 0, sltu, 14, 13, 0 )
        TEST_RR_SRC01_BYP( 0, 1, sltu, 11, 13, 1 )
        TEST_RR_SRC01_BYP( 0, 2, sltu, 15, 13, 0 )
        TEST_RR_SRC01_BYP( 1, 0, sltu, 10, 13, 1 )
        TEST_RR_SRC01_BYP( 1, 1, sltu, 16, 13, 0 )
        TEST_RR_SRC01_BYP( 2, 0, sltu,  9, 13, 1 )

        TEST_RR_SRC10_BYP( 0, 0, sltu, 17, 13, 0 )
        TEST_RR_SRC10_BYP( 0, 1, sltu,  8, 13, 1 )
        TEST_RR_SRC10_BYP( 0, 2, sltu, 18, 13, 0 )
        TEST_RR_SRC10_BYP( 1, 0, sltu,  7, 13, 1 )
        TEST_RR_SRC10_BYP( 1, 1, sltu, 19, 13, 0 )
        TEST_RR_SRC10_BYP( 2, 0, sltu,  6, 13, 1 )

        //-----------------------------------------------------------------
        // Logical tests
        //-----------------------------------------------------------------

        TEST_RR_OP( or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_OP( or, 0x0ff00ff0, 0xf0f0f0f0, 0xfff0fff0 )
        TEST_RR_OP( or, 0x00ff00ff, 0x0f0f0f0f, 0x0fff0fff )
        TEST_RR_OP( or, 0xf00ff00f, 0xf0f0f0f0, 0xf0fff0ff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_SRC1_EQ_DEST( or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_SRCS_EQ_DEST( or, 0xff00ff00, 0xff00ff00 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_DEST_BYP( 1, or, 0x0ff00ff0, 0xf0f0f0f0, 0xfff0fff0 )
        TEST_RR_DEST_BYP( 2, or, 0x00ff00ff, 0x0f0f0f0f, 0x0fff0fff )

        TEST_RR_SRC01_BYP( 0, 0, or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_SRC01_BYP( 0, 1, or, 0x0ff00ff0, 0xf0f0f0f0, 0xfff0fff0 )
        TEST_RR_SRC01_BYP( 0, 2, or, 0x00ff00ff, 0x0f0f0f0f, 0x0fff0fff )
        TEST_RR_SRC01_BYP( 1, 0, or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_SRC01_BYP( 1, 1, or, 0x0ff00ff0, 0xf0f0f0f0, 0xfff0fff0 )
        TEST_RR_SRC01_BYP( 2, 0, or, 0x00ff00ff, 0x0f0f0f0f, 0x0fff0fff )

        TEST_RR_SRC10_BYP( 0, 0, or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_SRC10_BYP( 0, 1, or, 0x0ff00ff0, 0xf0f0f0f0, 0xfff0fff0 )
        TEST_RR_SRC10_BYP( 0, 2, or, 0x00ff00ff, 0x0f0f0f0f, 0x0fff0fff )
        TEST_RR_SRC10_BYP( 1, 0, or, 0xff00ff00, 0x0f0f0f0f, 0xff0fff0f )
        TEST_RR_SRC10_BYP( 1, 1, or, 0x0ff00ff0, 0xf0f0f0f0, 0xfff0fff0 )
        TEST_RR_SRC10_BYP( 2, 0, or, 0x00ff00ff, 0x0f0f0f0f, 0x0fff0fff )

        //-------------------------------------------------------------
        // Logical tests
        //-------------------------------------------------------------

        TEST_IMM_OP( ori, 0xff00ff00, -0x0f1, 0xffffff0f )
        TEST_IMM_OP( ori, 0x0ff00ff0,  0x0f0, 0x0ff00ff0 )
        TEST_IMM_OP( ori, 0x00ff00ff, -0x0f1, 0xffffffff )
        TEST_IMM_OP( ori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        //-------------------------------------------------------------
        // Source/Destination tests
        //-------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( ori, 0xff00ff00,  0x0f0, 0xff00fff0 )

        //-------------------------------------------------------------
        // Bypassing tests
        //-------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, ori, 0x0ff00ff0,  0x0f0, 0x0ff00ff0 );
        TEST_IMM_DEST_BYP( 1, ori, 0x00ff00ff, -0x0f1, 0xffffffff );
        TEST_IMM_DEST_BYP( 2, ori, 0xf00ff00f,  0x0f0, 0xf00ff0ff );

        TEST_IMM_SRC0_BYP( 0, ori, 0x0ff00ff0,  0x0f0, 0x0ff00ff0 );
        TEST_IMM_SRC0_BYP( 1, ori, 0x00ff00ff, -0x0f1, 0xffffffff );
        TEST_IMM_SRC0_BYP( 2, ori, 0xf00ff00f,  0x0f0, 0xf00ff0ff );

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( sra, 0x80000000,  0, 0x80000000 )
        TEST_RR_OP( sra, 0x80000000,  1, 0xc0000000 )
        TEST_RR_OP( sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_OP( sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_OP( sra, 0x80000001, 31, 0xffffffff )

        TEST_RR_OP( sra, 0x7fffffff,  0, 0x7fffffff )
        TEST_RR_OP( sra, 0x7fffffff,  1, 0x3fffffff )
        TEST_RR_OP( sra, 0x7fffffff,  7, 0x00ffffff )
        TEST_RR_OP( sra, 0x7fffffff, 14, 0x0001ffff )
        TEST_RR_OP( sra, 0x7fffffff, 31, 0x00000000 )

        TEST_RR_OP( sra, 0x81818181,  0, 0x81818181 )
        TEST_RR_OP( sra, 0x81818181,  1, 0xc0c0c0c0 )
        TEST_RR_OP( sra, 0x81818181,  7, 0xff030303 )
        TEST_RR_OP( sra, 0x81818181, 14, 0xfffe0606 )
        TEST_RR_OP( sra, 0x81818181, 31, 0xffffffff )

        // Verify that shifts only use bottom five bits

        TEST_RR_OP( sra, 0x81818181, 0xffffffe0, 0x81818181 )
        TEST_RR_OP( sra, 0x81818181, 0xffffffe1, 0xc0c0c0c0 )
        TEST_RR_OP( sra, 0x81818181, 0xffffffe7, 0xff030303 )
        TEST_RR_OP( sra, 0x81818181, 0xffffffee, 0xfffe0606 )
        TEST_RR_OP( sra, 0x81818181, 0xffffffff, 0xffffffff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_SRC1_EQ_DEST( sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_SRCS_EQ_DEST( sra, 7, 0 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_DEST_BYP( 1, sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_DEST_BYP( 2, sra, 0x80000000, 31, 0xffffffff )

        TEST_RR_SRC01_BYP( 0, 0, sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_SRC01_BYP( 0, 1, sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_SRC01_BYP( 0, 2, sra, 0x80000000, 31, 0xffffffff )
        TEST_RR_SRC01_BYP( 1, 0, sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_SRC01_BYP( 1, 1, sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_SRC01_BYP( 2, 0, sra, 0x80000000, 31, 0xffffffff )

        TEST_RR_SRC10_BYP( 0, 0, sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_SRC10_BYP( 0, 1, sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_SRC10_BYP( 0, 2, sra, 0x80000000, 31, 0xffffffff )
        TEST_RR_SRC10_BYP( 1, 0, sra, 0x80000000,  7, 0xff000000 )
        TEST_RR_SRC10_BYP( 1, 1, sra, 0x80000000, 14, 0xfffe0000 )
        TEST_RR_SRC10_BYP( 2, 0, sra, 0x80000000, 31, 0xffffffff )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( srai, 0x80000000,  0, 0x80000000 )
        TEST_IMM_OP( srai, 0x80000000,  1, 0xc0000000 )
        TEST_IMM_OP( srai, 0x80000000,  7, 0xff000000 )
        TEST_IMM_OP( srai, 0x80000000, 14, 0xfffe0000 )
        TEST_IMM_OP( srai, 0x80000001, 31, 0xffffffff )

        TEST_IMM_OP( srai, 0x7fffffff,  0, 0x7fffffff )
        TEST_IMM_OP( srai, 0x7fffffff,  1, 0x3fffffff )
        TEST_IMM_OP( srai, 0x7fffffff,  7, 0x00ffffff )
        TEST_IMM_OP( srai, 0x7fffffff, 14, 0x0001ffff )
        TEST_IMM_OP( srai, 0x7fffffff, 31, 0x00000000 )

        TEST_IMM_OP( srai, 0x81818181,  0, 0x81818181 )
        TEST_IMM_OP( srai, 0x81818181,  1, 0xc0c0c0c0 )
        TEST_IMM_OP( srai, 0x81818181,  7, 0xff030303 )
        TEST_IMM_OP( srai, 0x81818181, 14, 0xfffe0606 )
        TEST_IMM_OP( srai, 0x81818181, 31, 0xffffffff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( srai, 0x80000000, 7, 0xff000000 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, srai, 0x80000000,  7, 0xff000000 )
        TEST_IMM_DEST_BYP( 1, srai, 0x80000000, 14, 0xfffe0000 )
        TEST_IMM_DEST_BYP( 2, srai, 0x80000001, 31, 0xffffffff )

        TEST_IMM_SRC0_BYP( 0, srai, 0x80000000,  7, 0xff000000 )
        TEST_IMM_SRC0_BYP( 1, srai, 0x80000000, 14, 0xfffe0000 )
        TEST_IMM_SRC0_BYP( 2, srai, 0x80000001, 31, 0xffffffff )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( srl, 0x80000000,  0, 0x80000000 )
        TEST_RR_OP( srl, 0x80000000,  1, 0x40000000 )
        TEST_RR_OP( srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_OP( srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_OP( srl, 0x80000001, 31, 0x00000001 )

        TEST_RR_OP( srl, 0xffffffff,  0, 0xffffffff )
        TEST_RR_OP( srl, 0xffffffff,  1, 0x7fffffff )
        TEST_RR_OP( srl, 0xffffffff,  7, 0x01ffffff )
        TEST_RR_OP( srl, 0xffffffff, 14, 0x0003ffff )
        TEST_RR_OP( srl, 0xffffffff, 31, 0x00000001 )

        TEST_RR_OP( srl, 0x21212121,  0, 0x21212121 )
        TEST_RR_OP( srl, 0x21212121,  1, 0x10909090 )
        TEST_RR_OP( srl, 0x21212121,  7, 0x00424242 )
        TEST_RR_OP( srl, 0x21212121, 14, 0x00008484 )
        TEST_RR_OP( srl, 0x21212121, 31, 0x00000000 )

        // Verify that shifts only use bottom five bits

        TEST_RR_OP( srl, 0x21212121, 0xffffffe0, 0x21212121 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffe1, 0x10909090 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffe7, 0x00424242 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffee, 0x00008484 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffff, 0x00000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC1_EQ_DEST( srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRCS_EQ_DEST( srl, 7, 0 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_DEST_BYP( 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_DEST_BYP( 2, srl, 0x80000000, 31, 0x00000001 )

        TEST_RR_SRC01_BYP( 0, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC01_BYP( 0, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC01_BYP( 0, 2, srl, 0x80000000, 31, 0x00000001 )
        TEST_RR_SRC01_BYP( 1, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC01_BYP( 1, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC01_BYP( 2, 0, srl, 0x80000000, 31, 0x00000001 )

        TEST_RR_SRC10_BYP( 0, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC10_BYP( 0, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC10_BYP( 0, 2, srl, 0x80000000, 31, 0x00000001 )
        TEST_RR_SRC10_BYP( 1, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC10_BYP( 1, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC10_BYP( 2, 0, srl, 0x80000000, 31, 0x00000001 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( srli, 0x80000000,  0, 0x80000000 )
        TEST_IMM_OP( srli, 0x80000000,  1, 0x40000000 )
        TEST_IMM_OP( srli, 0x80000000,  7, 0x01000000 )
        TEST_IMM_OP( srli, 0x80000000, 14, 0x00020000 )
        TEST_IMM_OP( srli, 0x80000001, 31, 0x00000001 )

        TEST_IMM_OP( srli, 0xffffffff,  0, 0xffffffff )
        TEST_IMM_OP( srli, 0xffffffff,  1, 0x7fffffff )
        TEST_IMM_OP( srli, 0xffffffff,  7, 0x01ffffff )
        TEST_IMM_OP( srli, 0xffffffff, 14, 0x0003ffff )
        TEST_IMM_OP( srli, 0xffffffff, 31, 0x00000001 )

        TEST_IMM_OP( srli, 0x21212121,  0, 0x21212121 )
        TEST_IMM_OP( srli, 0x21212121,  1, 0x10909090 )
        TEST_IMM_OP( srli, 0x21212121,  7, 0x00424242 )
        TEST_IMM_OP( srli, 0x21212121, 14, 0x00008484 )
        TEST_IMM_OP( srli, 0x21212121, 31, 0x00000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( srli, 0x80000000, 7, 0x01000000 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, srli, 0x80000000,  7, 0x01000000 )
        TEST_IMM_DEST_BYP( 1, srli, 0x80000000, 14, 0x00020000 )
        TEST_IMM_DEST_BYP( 2, srli, 0x80000001, 31, 0x00000001 )

        TEST_IMM_SRC0_BYP( 0, srli, 0x80000000,  7, 0x01000000 )
        TEST_IMM_SRC0_BYP( 1, srli, 0x80000000, 14, 0x00020000 )
        TEST_IMM_SRC0_BYP( 2, srli, 0x80000001, 31, 0x00000001 )

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( sub, 0x00000000, 0x00000000, 0x00000000 )
        TEST_RR_OP( sub, 0x00000001, 0x00000001, 0x00000000 )
        TEST_RR_OP( sub, 0x00000003, 0x00000007, 0xfffffffc )

        TEST_RR_OP( sub, 0x00000000, 0xffff8000, 0x00008000 )
        TEST_RR_OP( sub, 0x80000000, 0x00000000, 0x80000000 )
        TEST_RR_OP( sub, 0x80000000, 0xffff8000, 0x80008000 )

        TEST_RR_OP( sub, 0x00000000, 0x00007fff, 0xffff8001 )
        TEST_RR_OP( sub, 0x7fffffff, 0x00000000, 0x7fffffff )
        TEST_RR_OP( sub, 0x7fffffff, 0x00007fff, 0x7fff8000 )

        TEST_RR_OP( sub, 0x80000000, 0x00007fff, 0x7fff8001 )
        TEST_RR_OP( sub, 0x7fffffff, 0xffff8000, 0x80007fff )

        TEST_RR_OP( sub, 0x00000000, 0xffffffff, 0x00000001 )
        TEST_RR_OP( sub, 0xffffffff, 0x00000001, 0xfffffffe )
        TEST_RR_OP( sub, 0xffffffff, 0xffffffff, 0x00000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( sub, 13, 11, 2 )
        TEST_RR_SRC1_EQ_DEST( sub, 14, 11, 3 )
        TEST_RR_SRCS_EQ_DEST( sub, 13, 0 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, sub, 13, 11, 2 )
        TEST_RR_DEST_BYP( 1, sub, 14, 11, 3 )
        TEST_RR_DEST_BYP( 2, sub, 15, 11, 4 )

        TEST_RR_SRC01_BYP( 0, 0, sub, 13, 11, 2 )
        TEST_RR_SRC01_BYP( 0, 1, sub, 14, 11, 3 )
        TEST_RR_SRC01_BYP( 0, 2, sub, 15, 11, 4 )
        TEST_RR_SRC01_BYP( 1, 0, sub, 13, 11, 2 )
        TEST_RR_SRC01_BYP( 1, 1, sub, 14, 11, 3 )
        TEST_RR_SRC01_BYP( 2, 0, sub, 15, 11, 4 )

        TEST_RR_SRC10_BYP( 0, 0, sub, 13, 11, 2 )
        TEST_RR_SRC10_BYP( 0, 1, sub, 14, 11, 3 )
        TEST_RR_SRC10_BYP( 0, 2, sub, 15, 11, 4 )
        TEST_RR_SRC10_BYP( 1, 0, sub, 13, 11, 2 )
        TEST_RR_SRC10_BYP( 1, 1, sub, 14, 11, 3 )
        TEST_RR_SRC10_BYP( 2, 0, sub, 15, 11, 4 )

        //-----------------------------------------------------------------
        // Logical tests
        //-----------------------------------------------------------------

        TEST_RR_OP( xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_OP( xor, 0x0ff00ff0, 0xf0f0f0f0, 0xff00ff00 )
        TEST_RR_OP( xor, 0x00ff00ff, 0x0f0f0f0f, 0x0ff00ff0 )
        TEST_RR_OP( xor, 0xf00ff00f, 0xf0f0f0f0, 0x00ff00ff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_SRC1_EQ_DEST( xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_SRCS_EQ_DEST( xor, 0xff00ff00, 0x00000000 ) 

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_DEST_BYP( 1, xor, 0x0ff00ff0, 0xf0f0f0f0, 0xff00ff00 )
        TEST_RR_DEST_BYP( 2, xor, 0x00ff00ff, 0x0f0f0f0f, 0x0ff00ff0 )

        TEST_RR_SRC01_BYP( 0, 0, xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_SRC01_BYP( 0, 1, xor, 0x0ff00ff0, 0xf0f0f0f0, 0xff00ff00 )
        TEST_RR_SRC01_BYP( 0, 2, xor, 0x00ff00ff, 0x0f0f0f0f, 0x0ff00ff0 )
        TEST_RR_SRC01_BYP( 1, 0, xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_SRC01_BYP( 1, 1, xor, 0x0ff00ff0, 0xf0f0f0f0, 0xff00ff00 )
        TEST_RR_SRC01_BYP( 2, 0, xor, 0x00ff00ff, 0x0f0f0f0f, 0x0ff00ff0 )

        TEST_RR_SRC10_BYP( 0, 0, xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_SRC10_BYP( 0, 1, xor, 0x0ff00ff0, 0xf0f0f0f0, 0xff00ff00 )
        TEST_RR_SRC10_BYP( 0, 2, xor, 0x00ff00ff, 0x0f0f0f0f, 0x0ff00ff0 )
        TEST_RR_SRC10_BYP( 1, 0, xor, 0xff00ff00, 0x0f0f0f0f, 0xf00ff00f )
        TEST_RR_SRC10_BYP( 1, 1, xor, 0x0ff00ff0, 0xf0f0f0f0, 0xff00ff00 )
        TEST_RR_SRC10_BYP( 2, 0, xor, 0x00ff00ff, 0x0f0f0f0f, 0x0ff00ff0 )

        //-----------------------------------------------------------------
        // Logical tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( xori, 0xff00ff00, -0x0f1, 0x00ff000f )
        TEST_IMM_OP( xori, 0x0ff00ff0,  0x0f0, 0x0ff00f00 )
        TEST_IMM_OP( xori, 0x00ff00ff, -0x0f1, 0xff00fff0 )
        TEST_IMM_OP( xori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( xori, 0xff00ff00, -0x0f1, 0x00ff000f )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, xori, 0x0ff00ff0,  0x0f0, 0x0ff00f00 )
        TEST_IMM_DEST_BYP( 1, xori, 0x00ff00ff, -0x0f1, 0xff00fff0 )
        TEST_IMM_DEST_BYP( 2, xori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        TEST_IMM_SRC0_BYP( 0, xori, 0x0ff00ff0,  0x0f0, 0x0ff00f00 )
        TEST_IMM_SRC0_BYP( 1, xori, 0x00ff00ff, -0x0f1, 0xff00fff0 )
        TEST_IMM_SRC0_BYP( 2, xori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        TEST_RISCV_END

