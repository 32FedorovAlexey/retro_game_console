`include "sprite.vh"
//`define GAME
`define PYRAMID
//`define ROTATE_LINE
module retro_game  ( 
                    input  clk,
						  input  key_right,
						  input  key_left,
						  input  key_fire,
						  output v_sync,
						  output h_sync,
						  output r_pin,
						  output g_pin,
						  output b_pin
						 );
						 
						 
         vga  vga_i
                   ( 
						  .clk(clk),
						  .clk_pix(clk_pix),
                    .rst(1'b0),                            // сигнал нужен для моделирования при имплементации можно установить в "0" 
                    .h_sync(h_sync),
                    .v_sync(v_sync),
                    .x(x),
                    .y(y)
          );						 
	
	wire [9:0] x,y,clk_pix;
	wire game_out_r, game_out_g,game_out_b;
	logic tik;
	
	// задаем частоту просчета сцены
	
	 low_clock  #(.F_CLK_SLOW(20))

        low_clock_i 
                    (
						  .clk(clk),
                    .rst(1'b0),
                    .clk_slow(),
                    .one_pulse(tik)
                    );

	`ifdef GAME
	
	 localparam  speed_fly    = 10'd5;
	 localparam  speed_plane  = 10'd2;
	 localparam  speed_bullet = 10'd7;
	 
	 
   
	 reg        r,g,b;
	 reg  [7:0] count_1, count_2;
	 
	 
// триггер попаданий
	 reg        was_hit;  
	 wire  crash = flyer_g & bullet_r ;
	
   always_ff @(posedge clk) 
	  if (tik) was_hit <= 1'b0;
	  else if (crash) was_hit <= 1'b1;
 	
	// главный цикл геймплея
	  
	 always_ff @(posedge clk)
	 if(tik)
	   begin
		// движение коробля пришельцнв 
         f_x_pos   <= (f_dir_mov)?  f_x_pos - speed_fly : f_x_pos + speed_fly;
	      if (f_x_pos < 10'd6)   f_dir_mov <= 1'b0;	
	      if (f_x_pos > 10'd600) f_dir_mov <= 1'b1;	
      	
	
   	// движение самолета  
        if (( ~key_left ) & ( p_x_pos > 11'd1))   p_x_pos <= p_x_pos - speed_plane;
		  if (( ~key_right) & ( p_x_pos < 11'd608)) p_x_pos <= p_x_pos + speed_plane;

	   	// движение снаряда
	     if (~key_fire & ~bullet_mov) begin                // нажали кнопку fire
		    bullet_mov <=1'b1;	
          count_1 <= count_1 + 1'd1;	
	       if (count_1[3:0] == 4'h9)
			    count_1<= count_1 + 4'h7;		                // двоично-десятичная корекция 
			end
		   //else 
			
			if (was_hit & bullet_mov) begin                  //снаряд встретился с кораблем пришельцев 
			   count_2 <= count_2 + 1'd1;
				if (count_2[3:0] == 4'h9)
			     count_2<= count_2 + 4'h7;	                // двоично-десятичная корекция 
			end 			  
			
		  if ((bullet_y < 20) | was_hit) begin               // вышли за пределы экрана или встретились с кораблем пришельцев
		    bullet_mov <= 1'b0;
  
		  end

		  if (bullet_mov) 
		    bullet_y <= bullet_y - speed_bullet;             // движение снаряда
		  else begin  
		  	 bullet_y <= p_y_pos ;                            // возвращаем  снаряд на корабль
			 bullet_x <= p_x_pos + 4'd12;
		  end
	  
	   end 	 

		
     // wire r_sqr = ((x > 13) & (x < 18) & (y > 80) & (y < 130)) ? 1'b1 : 1'b0 ; // красный квадрат
	  
	// счетчик выстрелов 
 logic shot_r,shot_g, shot_b;
    numbers  shot	 
           ( .x(x),
             .y(y),
				 .data({count_1[3:0],count_1[7:4]}),                               //  выводимые цифры  
             .pos_x(10'd600),
             .pos_y(10'd30),
             .collor(3'b011),
             
             .r(shot_r), 
             .g(shot_g), 
             .b(shot_b)
            );	
	 
	 // надпись "SHOT"
	 	logic text1_r,text1_g,text1_b;
    
	 text #(.L(5), 
         .data({8'd53, 8'd42, 8'd49, 8'd54, 8'd28 })
        )
            text_shot (
                    .x(x),
				        .y(y),
				        .pos_x(10'd520),  
						  .pos_y(10'd30),
						  .collor(3'b011),
						  .r(text1_r),
                    .g(text1_g),
						  .b(text1_b)

						  );			
 

	 
	 // счетчик попаданий
	 logic hit_r,hit_g,hit_b;
    numbers  hit	 
           ( .x(x),
             .y(y),
				 .data({count_2[3:0],count_2[7:4]}),                               // выводимые цифры  
             .pos_x(10'd600),
             .pos_y(10'd46),
             .collor(3'b100),
             
             .r(hit_r), 
             .g(hit_g), 
             .b(hit_b)
            );				
	
	
 
	 // надпись "HIT"
	 logic text2_r,text2_g,text2_b;	
     text #(.L(4), 
         .data({8'd42, 8'd43, 8'd54, 8'd28 })
        )
            text_hit (
                    .x(x),
				        .y(y),
				        .pos_x(10'd536),  
						  .pos_y(10'd46),
						  .collor(3'b100),
						  .r(text2_r),
                    .g(text2_g),
						  .b(text2_b)
						  );			

	 
	 logic       plane_r,plane_g,plane_b;
	 logic [9:0] p_x_pos = 10'd320;
	 logic [9:0] p_y_pos = 10'd440;
	       

    sprite  #(.SIZE(32), 
	           .MASK( PLANE1))
	           plane(
	                 .x(x),
				        .y(y),
				        .pos_x(p_x_pos),
						  .pos_y(p_y_pos),
						  .collor(3'b100),
						  .r(plane_r),
                    .g(plane_g),
						  .b(plane_b)
						 );	
						 
			logic [9:0] bullet_x, bullet_y;
			logic       bullet_mov, bullet_r,bullet_g,bullet_b;
			
	sprite  #(.SIZE(8), 
	           .MASK(BULLET ))
						  
	           bullet(
	                 .x(x),
				        .y(y),
				        .pos_x(bullet_x),
						  .pos_y(bullet_y),
						  .collor(3'b100),
						  .r(bullet_r),
                    .g(bullet_g),
						  .b(bullet_b)
						 );	
						 					 
						 
				logic       flyer_r,flyer_g,flyer_b;
	         logic [9:0] f_x_pos;                                 // координата х корабля пришельцев
            logic       f_dir_mov;                               // Нарпавление движения 0 в право 1 в лево     
   			
				sprite  #(.SIZE(32), 
	           .MASK( FLY     ))
						  
	           flyer(
	                 .x(x),
				        .y(y),
				        .pos_x(f_x_pos),
						  .pos_y(80),
						  .collor(3'b010),
						  .r(flyer_r),
                    .g(flyer_g),
						  .b(flyer_b)
						 );	
 						 
					 
/*	logic text_r, text_g, text_b;
	
  text #(.L(14), 
         .data({8'd35, 8'd46, 8'd39, 8'd58, 8'd39, 8'd59, 8'd2, 8'd40, 8'd39, 8'd38, 8'd49, 8'd52, 8'd49, 8'd56})
        )
            text_1 (
                    .x(x),
				        .y(y),
				        .pos_x(250), //250
						  .pos_y(50),
						  .collor(3'b111),
						  .r(text_r),
                    .g(text_g),
						  .b(text_b)

						  );			
						  
*/
    assign game_out_r = plane_r | flyer_r | bullet_r | shot_r | hit_r  | text1_r | text2_r ;
	 assign game_out_g = plane_g | flyer_g | bullet_g | shot_g | hit_g  | text1_g | text2_g ;
	 assign game_out_b = plane_b | flyer_b | bullet_b | shot_b | hit_b  | text1_b | text2_b ;
	 
 `endif	
   
	wire   start_f = (x==0) & (y==0); 
	
// rotate line 
	
	logic lw1;
   logic signed [9 : 0] x1_d, x1 = 10'd100;
	logic signed [9 : 0] y1_d, y1 = 10'd000;
   logic [2 : 0] count_tik; 
   localparam n_tik = 2;	
 
    rotate rotate_5(
	                  .x_i(x1),
	                  .y_i(y1),
	                  .x_o(x1_d),
	                  .y_o(y1_d),
							);
	 
   always_ff @(posedge clk)
     if (tik) 
	    if (count_tik == 0 ) begin
		   count_tik <= n_tik;
			x1 <= x1_d;
			y1 <= y1_d;
		 end 	
		 else count_tik <= count_tik - 1'b1;  
	
	`ifdef ROTATE_LINE  
 
	line line_1(
	            .clk(clk),
					.rst(start_f),
					.x(x),
					.y(y),
					.x1(10'd150 ),
					.x2(x1 + 10'd150),
					.y1(10'd150),
					.y2(y1 + 10'd150),
					.white(lw1)
					);					  
 
    `endif
					  
    logic pyrm;
	 
	 `ifdef PYRAMID
	 
    pyramid pyramid_1 (
	                    .clk(clk),
							  .x(x),
							  .y(y),
							  .start_t((count_tik == 0)),
							  .white(pyrm)
	                    );
  
	 `endif

   assign r_pin = game_out_r | lw1 | pyrm; 
   assign g_pin = game_out_g | lw1 | pyrm; 
   assign b_pin = game_out_b | lw1 | pyrm; 
  
 //  assign r_pin =  pyrm | flyer_r; 
 //  assign g_pin =  pyrm | flyer_g; 
 //  assign b_pin =  pyrm | flyer_b; 
  
  
  
endmodule 
						 