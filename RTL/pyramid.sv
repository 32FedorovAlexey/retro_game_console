/*
 При некоторых значениях угла поворота некоторые точки основания начинают вращаться быстрее остальных 
 Например при угле поворота 7 градусов последняя точка за ~ 16 оборотов достигает свою соседку потом следующую где то 
 чере 50-70 обоповоров  фигура восстаноавливается. При угле поворота 10 градусов вращение стабильное. 
 
 */
         
module pyramid (
                input         clk,
					 input [9:0]   x,
					 input [9:0]   y,
					 input         start_t,
					 output        white
					 
					 );

	localparam SHIFT_X = 10'd320;
	localparam SHIFT_Y = 10'd340;
	localparam N = 4;
	
  
		 
 // a tree-sided pyramid 
 // logic signed [0 : N] [9:0] d3_x ={ 10'd096, -10'd70, -10'd25,  10'd0}; 
 // logic signed [0 : N] [9:0] d3_y ={-10'd025, -10'd70,  10'd96,  10'd0}; 
 // logic signed [0 : N] [9:0] d3_z ={ 10'd000, -10'd00,  10'd00, -10'd180};	
  
  // a four-sided pyramid 
  logic signed [0 : N] [9:0] d3_x ={ 10'd050, -10'd050, -10'd50,  10'd050,  10'd0    }; 
  logic signed [0 : N] [9:0] d3_y ={ 10'd050,  10'd050, -10'd50, -10'd050,  10'd0    }; 
  logic signed [0 : N] [9:0] d3_z ={ 10'd000,  10'd000,  10'd00,  10'd00,  -10'd180  };	
	

  // a six-sided pyramid 
  //logic signed [0 : N] [9:0] d3_x ={ 10'd100,  10'd050, -10'd50, -10'd100, -10'd50,  10'd50,   10'd0  }; 
  //logic signed [0 : N] [9:0] d3_y ={ 10'd000, -10'd86,  -10'd86,  10'd000,  10'd86,  10'd86,   10'd0  }; 
  //logic signed [0 : N] [9:0] d3_z ={ 10'd000,  10'd00,   10'd00,  10'd00,   10'd00,  10'd00,  -10'd180};	
	
  
  logic signed [0 : N+1] [9:0] d2_x ; 
  logic signed [0 : N+1] [9:0] d2_y ; 
  
  logic        [0 : 2*N-1]     out;
  
  // driwing a pyramid
  
  generate
    genvar i;
    for(i = 0; i < N ; i = i+1)begin:M 
    // the edges   
	line line_h(
                .clk(clk),
		          .start_frame((x==0) & (y==0)),
			       .x(x),
			       .y(y),
			       .x1(d2_x[i]),
                .y1(d2_y[i]),
                .x2(d2_x[N]),
                .y2(d2_y[N]),
				    .out(out[i+N])
				   );			
					
    // the base Of the pyramid 
	 if (i< N - 1) 
    line line_i(
                .clk(clk),
		          .start_frame((x==0) & (y==0)),
			       .x(x),
			       .y(y),
			       .x1(d2_x[i]),
                .y1(d2_y[i]),
                .x2(d2_x[i+1]),
                .y2(d2_y[i+1]),
				    .out(out[i])
				   );
						
		else 
    line line_i(
                .clk(clk),
		          .start_frame((x==0) & (y==0)),
			       .x(x),
			       .y(y),
			       .x1(d2_x[i]),
                .y1(d2_y[i]),
                .x2(d2_x[0]),
                .y2(d2_y[0]),
				    .out(out[i])
				   );
		
     end				   	  
  endgenerate

  assign white =  |out;
  
  // making modification
 
   rotate #(.SIN(178), .COS(1008) ) //  angle of rotation - 10 grad SIN = 178 COS = 1008;  15 grad SIN = 265 COS = 989
	       rotate_p(
                   .x_i(d3_x[k]),
						 .y_i(d3_y[k]),
						 .x_o(x_d),
						 .y_o(y_d)
                   );
   isomet isomet_i(
	                .x_i(x_d),
						 .y_i(y_d),
						 .z_i(d3_z[k]),
						 .x_o(xi_d),
						 .y_o(yi_d)
						 
	                );
	
  localparam WIDTH_N = $clog2(N); 
  logic [WIDTH_N : 0] k ;
  logic [9:0] x_d, y_d ;
  logic [9:0] xi_d, yi_d;
  
  always_ff @(posedge clk)
    if (start_t) k <= '0;  
    else 
 	   
		if(k < N + 1) begin
      k <= k + 1'b1;	 
	   d3_x[k] <= x_d;
		d3_y[k] <= y_d;
		
		d2_x[k] <= xi_d + SHIFT_X;
		d2_y[k] <= yi_d + SHIFT_Y;
		end
	   
  
  
endmodule 