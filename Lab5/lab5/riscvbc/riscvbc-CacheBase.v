//=========================================================================
// Cache Base Design
//=========================================================================

`ifndef RISCV_CACHE_BASE_V
`define RISCV_CACHE_BASE_V

module riscv_CacheBase (
    input clk,
    input reset,


    // imem
    input                                  memreq_val,
    output                                 memreq_rdy,
    input  [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] memreq_msg,

    output                               memresp_val,
    input                                memresp_rdy,
    output [`VC_MEM_RESP_MSG_SZ(32)-1:0] memresp_msg,

    //cache
    output                                 cachereq_val,
    input                                  cachereq_rdy,
    output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] cachereq_msg,

    input                                cacheresp_val,
    output                               cacheresp_rdy,
    input  [`VC_MEM_RESP_MSG_SZ(32)-1:0] cacheresp_msg,


    // flush
    input  flush,
    output flush_done
);

endmodule


`endif  /* RISCV_CACHE_BASE_V */
