module isomet ( 
                input  signed [9 : 0] x_i,
                input  signed [9 : 0] y_i,
                input  signed [9 : 0] z_i,
                output signed [9 : 0] x_o,
                output signed [9 : 0] y_o
					);
		
		 localparam signed K = 10'd724;

		 wire signed [19:0] tmp = y_i * K; 			
					
       assign x_o = x_i + tmp[19:10];
       assign y_o = z_i + tmp[19:10];
		 
endmodule