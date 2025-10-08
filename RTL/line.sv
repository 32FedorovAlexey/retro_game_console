module line(
            input clk,
            input [9:0] x,
            input [9:0] y,
            input [9:0] x1,
            input [9:0] y1,
            input [9:0] x2,
            input [9:0] y2,
            output      white
            );

	
  
  logic [9:0] dx, dy, new_x, new_y, dot_x, dot_y, error, new_error;
  logic start; 
  logic on, work;

  logic clk_2 = 0;                                                 

  assign start = (x == 10'd1000 ) & (y == 10'd480);               // сигнал инициализации, сбрасываем настройки в "0" после отрисовки кадра   
  
  assign dx = x2 - x1;
  assign dy = y2 - y1;
  assign work = ((dot_x == x) & (dot_y == y)) ;                    // сигнал разрешающий вычисления  
  assign on = (x < x2) & (x > x1);                                 // сигнал разрешающий вывод изображения
  
  always_comb begin
    new_error = ((error + dy) < dx)? error + dy: error + dy - dx; 
    new_y     = ((error + dy) < dx)? dot_y + 1'b1: dot_y; 
  end

  
  
  always_ff @(posedge clk)                                         // костыль вызван тем что тактовая частот в два раза частоты вывода пикселей 
  clk_2 <= ~clk_2;
              

  always_ff @(posedge clk_2) begin
    if (start) begin
      dot_x <= x1;
      dot_y <= y1;
      error <= dy;
    end 
    if( work) 
     begin
      error <= new_error; 
      dot_y <= new_y;
      dot_x <= dot_x + 1;
    end
   end

   assign white = on & (x == dot_x) & (y == dot_y);
	
 endmodule           
