

/*

I'm sorry, my English is not very good.
*/
//`define DEBUG 
module line(
            input clk,
            input rst,
            input [9:0] x,
            input [9:0] y,
            input [9:0] x1,
            input [9:0] y1,
            input [9:0] x2,
            input [9:0] y2,
            output      white
            );

  logic [9:0] dx, dy, new_x, new_y;
  logic [9:0] x_start, save_start_x;                               // for 4 section 
  logic [9:0] dot_x, dot_y, error, new_error;
  logic [9:0] x1_in, y1_in, x2_in, y2_in;
  
  logic       sector1, sector2, sector3, sector4, run_s4;          // direction selecter 
  logic       strob_x;

 
  wire revers = y1 > y2;
  assign x1_in = revers ? x2 : x1; 
  assign x2_in = revers ? x1 : x2; 
  assign y1_in = revers ? y2 : y1; 
  assign y2_in = revers ? y1 : y2; 
 
  
  `ifdef DEBUG
    wire tmp =  ((error + dx) < dx);
  `endif
 
 
  wire on = (y < y2_in) & (y >= y1_in);
  
 

  assign work = (dot_x == x) & (dot_y == y);
  
  always_comb begin
   new_error =  error;
	 new_y     = dot_y;
	 new_x     = dot_x;
   case ({sector4,sector3,sector2,sector1})
     4'b0001:       begin
	  	                new_y     = ((error + dy) < dx) ? dot_y     : dot_y + 1;
	                    new_error = ((error + dy) < dx) ? error + dy: error + dy - dx; 
	                 end
	  4'b0010:       begin
                      new_x     = ((error + dx) < dy) ? dot_x     : dot_x + 1'b1 ;
	                    new_error = ((error + dx) < dy) ? error + dx: error + dx - dy;
                    end
     4'b0100:       begin
                      new_x     = ((error + dx) < dy) ? dot_x     : dot_x - 1'b1 ;
	                    new_error = ((error + dx) < dy) ? error + dx: error + dx - dy;
                    end
     4'b1000:        begin
	  	               new_y     = ((error + dy) < dx) ? dot_y     : dot_y +  1'd1;
	                   new_error = ((error + dy) < dx) ? error + dy: error + dy - dx; 
                    end
   endcase 
  end

  
  always_ff @(posedge clk) begin
    if (rst) begin
      dot_x <= x1_in;
      dot_y <= y1_in;
      error <='0;
     

      if ((x2_in - x1_in) >= (y2_in - y1_in)  & (x2_in > x1_in)) begin        // sector1 0 - 45   
        sector1 <=1'b1;
        dx <= x2_in - x1_in;
        dy <= {(y2_in - y1_in)};
      end  
      else 
      sector1 <=1'b0;
      
      if ((x2_in - x1_in) < (y2_in - y1_in) & (x2_in >= x1_in)) begin ;       // sector2 45-90
		    //error <= '0;
        sector2 <=1'b1;
        dx <= {(x2_in - x1_in)};
        dy <= (y2_in - y1_in);
       end  
      else 
        sector2 <=1'b0;	

      if ((x1_in - x2_in) <= (y2_in - y1_in) & (x2_in < x1_in)) begin         // sector3 90-135
		    //error <= dx;
        sector3 <=1'b1;
        dx <= {(x1_in - x2_in)};
        dy <= (y2_in - y1_in);
      end  
      else 
        sector3 <=1'b0;
		
      if (((x1_in - x2_in) > (y2_in - y1_in)) & (x2_in < x1_in))  begin        // sector4 135-180
        x_start <= x1_in;
        save_start_x <= x1_in;
        sector4 <=1'b1;
        dx <= x1_in - x2_in;
        dy <= {(y2_in - y1_in)}; 
      end  
      else 
        sector4 <=1'b0;
    end                                                   // end RESET section

    // start WORK section 

    if( work & strob_x & on) 
      begin
        error <= new_error; 
        if (sector1) begin
          dot_y <= new_y;
          dot_x <= dot_x + 1'd1;
        end
        if (sector2 | sector3) begin
          dot_y <= dot_y + 1'd1;
		      dot_x <= new_x;
        end
    end

     if (sector4 &  (y+1 == dot_y  ) & (y < y2_in)) begin  // for sector 4 
       error   <= new_error;                               // Пока идет развертка строки считаем длинну линии 
       x_start <= x_start - 1;
       dot_y   <= new_y; 
     end  
    
     if (sector4 & (x == 640) & strob_x) begin             // в последней точке строки перед строкой с линией
       dot_x <= save_start_x;
       save_start_x <= x_start;                            // сохраняем начало линии      
     end

	  if (sector4 & (x == dot_x) & (dot_y == (y + 1))) dot_x <= x_start;

   end


	
	// выделяем переход к следующей точке
  reg out, save_x;
    always_ff @(posedge clk) begin
      save_x  <= x[0];
      strob_x <= save_x ^ x[0];
      if (save_x ^ x[0]) out <=  work; // & on;                // x,y находятся в границах линии и dot_x == x и dot_y == x 
    end   

    wire out4sec = sector4 & (x > save_start_x) & (x <= dot_x);
  
	assign white = out & (dot_y <= y2_in)   | (out4sec & (x2_in <= x));    // (x2 <= x) костыль , так как из-за ошибок округления можно убежать далеко

 endmodule           
