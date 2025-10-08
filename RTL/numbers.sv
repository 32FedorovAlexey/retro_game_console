`include "letter.vh"

module numbers #(parameter L = 2)                          // длинна строки
            
           ( input           [9 : 0] x,
             input           [9 : 0] y,
				 input [L-1 : 0] [3 : 0] data,                 // выводимые цифры  
             input           [9 : 0] pos_x,
             input           [9 : 0] pos_y,
             input           [2 : 0] collor,
             
             output      r, 
             output      g, 
             output      b
            );
            
      localparam SIZE = 16;                                  //размер шрифта  в пикселях
	 
	  
      localparam logic [0:9][15:0][15:0] bitmap_n = {`LETTER_48,`LETTER_49,`LETTER_50,`LETTER_51,`LETTER_52,`LETTER_53,`LETTER_54,`LETTER_55,`LETTER_56,`LETTER_57};   
      
      
      wire              on;                                
      wire  [2:0]       pos_char;                          // номер символа в строке который выводится в данный момент       
      wire  [3:0]       char_code;     
      wire              bit_im; 
   
      assign on        = ((x > pos_x) & (x < pos_x + SIZE * L) & (y > pos_y) & (y < pos_y + SIZE));
      assign pos_char  = (on)? ((x - pos_x ) / SIZE) : '0; // вычисляем позицию символа которого выводим в текущий момент 
      assign char_code = data[pos_char];                   // вычисляем позицию символа в кодовой странице   
      assign bit_im    = (on) ? bitmap_n[char_code][pos_y - y][x - pos_x] : 1'b0;    
      
      assign r = bit_im & collor[0];
      assign g = bit_im & collor[1];
      assign b = bit_im & collor[2];
      
endmodule   