// модуль генерации сигналов для монитора vga 640 x 480 x 60
// модуль рассчитан на входную частоту сигнала CLK - 50 МГц
// 
 
//`define debug
module vga
          ( input clk,
            input rst,        // сигнал нужен для моделирования при имплементации можно установить в "0" 
				output clk_pix,
            output h_sync,
				output v_sync,
				output [9:0] x,
            output [8:0] y
				
          );

  reg   pix_clk = 1'b0;
  logic vl, vf;
  logic [9:0] pos_x, pos_y;

 `ifdef  debug                                     // вспомогательная секция для отладки 
    logic [9:0] tmp_count; 
    always_ff @(posedge pix_clk) 
      if (rst)
        tmp_count <= '0;
      else if (~h_sync) tmp_count <= tmp_count + 1;
           else tmp_count <= '0;
 `endif
  
  always_ff @(posedge clk)
    pix_clk = ~pix_clk;                            // формируем частоту кикселей pix_clk =  clk /2 т.е. 25 МГц 

  always_ff @(posedge pix_clk)
    if (rst)  begin
      pos_x <= 10'd975;                             // загружаем "волшебные" цифры. Это необходимио для формирования  
      pos_y <= 10'd990;                             //  паузы между фронтом синхросигнала и началом видимого поля
    end  
    else if (~(pos_x == 10'd752)) 
        pos_x <= pos_x + 1'b1;
      else begin
        pos_x <= pos_x + 10'd223;
        if (pos_y == 10'd492)
          pos_y <= pos_y + 10'd499;
        else pos_y <= pos_y + 1'b1;  
      end  

    assign h_sync = ((pos_x < 10'd975) & (pos_x > 10'd656))? 1'b0 : 1'b1;
     
  
    assign v_sync = ((pos_y < 991) & (pos_y > 490))? 1'b0 : 1'b1;
    
        
     `ifdef  debug                                   // вспомогательная секция для отладки 
    logic v_sync_tmp;
    assign v_sync_tmp =  (pos_y > 10'd49) ? 1'b0 : 1'b1;
    
    `endif
	 
    assign x = pos_x;
    assign y = pos_y;
	 assign clk_pix = pix_clk;
  
endmodule