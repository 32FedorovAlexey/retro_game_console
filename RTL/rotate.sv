module rotate  #(parameter SIN = 89 , COS = 1020)
              ( input  signed [9 : 0] x_i,
                input  signed [9 : 0] y_i,
                output signed [9 : 0] x_o,
                output signed [9 : 0] y_o
              );

      wire signed [19:0] new_x = x_i * COS + y_i * SIN;
      wire signed [19:0] new_y = y_i * COS - x_i * SIN;
     
      assign x_o = new_x[19 : 10] ;
      assign y_o = new_y[19 : 10] ;
	

endmodule  