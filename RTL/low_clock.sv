module low_clock #(parameter F_CLK = 50000000, F_CLK_SLOW = 1)
   (
    input clk,
    input rst,
    output clk_slow,
    output one_pulse
    );
    
    localparam N = F_CLK / F_CLK_SLOW;
    localparam W = $clog2(N);
    
    reg [W-1 : 0] counter;
    reg           slow, tik;
    always_ff @(posedge clk)
    if (rst) begin
      counter <= N / 2;
      slow    <= 0;
    end  
    else begin 
      if (counter == 0) begin
        counter <= N / 2'd2;
        slow <= ~slow;
        if (slow == 0) tik <= 1'b1;
     end  
      else begin 
        counter <= counter - 1'd1;
        tik <= 1'b0;
      end  
     end
    assign clk_slow = slow;
    assign one_pulse  = tik;
endmodule
