module picocpu (
    input           clk,
    input           rst_n,

    input           rx,
    output          tx,

    output [7:0]    led
);

    wire tx_value;

    assign tx = tx_value;

    pico_qsys u0 (
        .clk_clk       (clk),       //   clk.clk
        .reset_reset_n (rst_n),     // reset.reset_n
        .uart_rxd      (rx),        //  uart.rxd
        .uart_txd      (tx_value),  //      .txd
        .led_export    (led)
    );

endmodule
