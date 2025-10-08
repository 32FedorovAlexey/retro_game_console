          
module sprite #(parameter SIZE = 8, 
                          bit [SIZE-1:0] [SIZE-1:0] MASK = {8'h18, 8'h18, 8'h18, 8'hFF, 8'hFF, 8'h18, 8'h18, 8'h18}
								  								  ) 
                   ( input  [9 : 0] x,
				         input  [9 : 0] y,
				         input  [9 : 0] pos_x,
						   input  [9 : 0] pos_y,
							input  [2 : 0] collor,
							
							output 			r,
                     output 			g,
							output 			b
						 );
			

	wire  on;
	wire  bit_im;                      
	
	assign on = ((x > pos_x) & (x < pos_x + SIZE) & (y > pos_y) & (y < pos_y + SIZE));
   assign bit_im = (on)? MASK [pos_y - y] [x - pos_x]: 1'b0;	
	
	assign r = bit_im & collor[2];
	assign g = bit_im & collor[1];
	assign b = bit_im & collor[0];
	
endmodule