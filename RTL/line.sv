module line
# (
    parameter  clk_mhz       = 50,
               screen_width  = 640,
               screen_height = 480,
               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)

(
               input                        clk,
               input                        start_frame,  
               input        [w_x     - 1:0] x,
               input        [w_y     - 1:0] y,
               input        [w_x     - 1:0] x1,
               input        [w_y     - 1:0] y1,
               input        [w_x     - 1:0] x2,
               input        [w_y     - 1:0] y2,
               output                       out

);

   logic [w_x     - 1:0]  in_x1, in_x2,  dot_x, new_x;
   logic signed [w_x     - 1:0] dx;
   logic signed [w_y     - 1:0] dy;
   logic [w_y     - 1:0]        in_y1, in_y2,  dot_y, new_y;
   logic                        pred_x, strobe_x;
   logic [w_x     - 1:0]        error, new_error;
   logic                        en1,en2,en3,en4;
   logic                        line_out;
   logic                        s1,s2,s3,s4;

   logic [w_x - 1:0]           x_st, x_end;

   
   //highlighting a change in the x value
 
   always_ff @(posedge clk)
     pred_x <= x[0];
   assign strobe_x = x ^ pred_x;
    
  // work permit
  
  assign en1 =  (y == dot_y) & (x == dot_x) & (x <= in_x2) & s1;
  assign en2 =  (y == dot_y) & (x == dot_x) & (x <= in_x2) & (y <= in_y2) & s2;
  assign en3 =  (y == dot_y) & (x == dot_x) & (x >  in_x2) & s3;
  assign en4 =  (y + 1 >= in_y1) & (y < in_y2)  & s4;
 
  // initializing variables 
  
   wire revers = y1 > y2;
   assign in_x1 = revers ? x2 : x1; 
   assign in_x2 = revers ? x1 : x2; 
   assign in_y1 = revers ? y2 : y1; 
   assign in_y2 = revers ? y1 : y2; 

   assign dx = (s1 | s2) ? (in_x2 - in_x1)  : (in_x1 - in_x2) ;
   assign dy = (in_y2 - in_y1) + 1 ;                                 // 
   
   // identification sectors
   always_comb begin
     s1 = 1'b0;
     s2 = 1'b0;
     s3 = 1'b0;
     s4 = 1'b0;
     if (in_x2 >= in_x1)
       if ((in_x2 - in_x1) > (in_y2 - in_y1)) s1 = 1'b1;     // x2 >= x1
       else                                   s2 = 1'b1; 
      else 
       if ((in_x1 - in_x2) < (in_y2 - in_y1)) s3 = 1'b1;     // x2 < x1
       else                                   s4 = 1'b1;                       
   end  

   // calculate error and new dot 
   always_comb begin
      new_y = dot_y;
      new_x = dot_x;
      new_error = error;
      case ({s4,s3,s2,s1})
      4'b0001:             if ((error + dy) > dx) begin             // sector 1
                             new_error = error + dy -  dx;
                             new_y     = dot_y + 1; 
                           end  
                           else 
                             new_error = error + dy;
                       
      4'b0010,
      4'b0100:            if ((error + dx) > dy) begin            // sectors 2, 3
                             new_error = error + dx -  dy ;
                             if(s2)
                                new_x     = dot_x + 1;
                             else 
                                new_x     = dot_x - 1;
                           end  
                           else 
                             new_error = error + dx;

    4'b1000:              new_error = error + dy;                // sector 4
                          
     endcase                            
   end

   always_ff @(posedge clk)
     if (start_frame) begin
       dot_x <= in_x1;
       dot_y <= in_y1;
       error <= '0;
       x_end <= in_x1;                                         // for 4 sector 
     end 
     else begin
      // sector 1 
     if (en1) begin
       dot_x <= dot_x + 1;
       dot_y <= new_y;
       error <= new_error; 
      end
     // sectors 2,3 
      if (en2 | en3) begin
        dot_x <= new_x;
        dot_y <= dot_y + 1 ;
        error <= new_error; 
      end
    // sector 4
      if (en4) begin
        if (error <= dx ) begin 
          dot_x <= dot_x - 1;
          error <= new_error;
        end  
        else if (x == screen_width) begin   
         x_st  <= dot_x;
         if (y + 1 == in_y1  )
           x_end <= in_x1;
         else 
           x_end <= x_st;  
         error <= error - dx ;      
       end  
    end
   end 

   always @(posedge clk)
   if (strobe_x) line_out <= (x == dot_x) & (y == dot_y); 
   
   wire out4 = (x > x_st) & (x <= x_end) & (y >= in_y1) & (y <= in_y2);            

   assign out = (s4)? out4 : line_out ;

endmodule

