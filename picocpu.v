module picocpu (
    input           clk,
    input           rst_n,

    input           rx,
    output          tx,

    output [7:0]    led,

    output          sdram_0_clk,
    output [11:0]   sdram_0_addr,
    output [1:0]    sdram_0_ba,
    output          sdram_0_cas_n,
    output          sdram_0_cke,
    output          sdram_0_cs_n,
    inout  [15:0]   sdram_0_dq,
    output [1:0]    sdram_0_dqm,
    output          sdram_0_ras_n,
    output          sdram_0_we_n
);

    wire tx_value;

    wire cpu_clk;
    //wire sdram_clk;
    wire clocked;
    reg  sdram_clk_reg;

    assign tx = tx_value;

    pll pll (
        .areset   (~rst_n),
        .inclk0   (clk),
        .c0       (cpu_clk),
        .c1       (sdram_0_clk),
        .locked   (locked)
    );

    pico_qsys u0 (
        .clk_clk       (cpu_clk),       //   clk.clk
        .reset_reset_n (rst_n),         // reset.reset_n
        .uart_rxd      (rx),            //  uart.rxd
        .uart_txd      (tx_value),      //      .txd
        .led_export    (led),           // led
        .sdram_addr    (sdram_0_addr),  // sdram.addr
        .sdram_ba      (sdram_0_ba),    //      .ba
        .sdram_cas_n   (sdram_0_cas_n), //      .cas_n
        .sdram_cke     (sdram_0_cke),   //      .cke
        .sdram_cs_n    (sdram_0_cs_n),  //      .cs_n
        .sdram_dq      (sdram_0_dq),    //      .dq
        .sdram_dqm     (sdram_0_dqm),   //      .dqm
        .sdram_ras_n   (sdram_0_ras_n), //      .ras_n
        .sdram_we_n    (sdram_0_we_n)   //      .we_n
    );

endmodule
