`include "title_screen.v"
`include "win_screen.v"
`include "game_over.v"


module pic_memory(
	input resetn,
	input clk,
	input frame,
	input enable,
	input [1:0]screen_select,
	
	output drawing,
	output [9:0]x, y,
	output reg[2:0]colour
	);
	
	wire [2:0]title_colour, win_colour, lose_colour;
	wire [14:0]address;
	
	mem_draw md(
		.go(enable),
		.resetn(resetn),
		.clk(clk),
		
		.frame(frame),
		.drawing(drawing),
		.address(address),
		.x(x),
		.y(y)
	);
	
	title_screen title(
		.address(address),
		.clock(clk),
		.data(),
		.wren(1'd0),
		.q(title_colour)
	);
	
	win_screen win(
		.address(address),
		.clock(clk),
		.data(),
		.wren(1'd0),
		.q(win_colour)
	);
	
	game_over lose(
		.address(address),
		.clock(clk),
		.data(),
		.wren(1'd0),
		.q(lose_colour)
	);
	
	always @(posedge clk) begin
		if(!resetn) begin
			colour <= title_colour;
		end
		else begin
			case(screen_select)
				2'd0: colour <= title_colour;
				2'd1: colour <= win_colour;
				2'd2: colour <= lose_colour;
			endcase
		end 
	end
	
endmodule

module mem_draw(
	input go,
	input resetn,
	input clk,
	input frame,
	
	output reg drawing,
	output reg[14:0]address,
	output reg[9:0]x,
	output reg[9:0]y
	);
	
	reg [14:0]address_counter;
	
	always @(posedge clk) begin
		if(!resetn) begin
			drawing <= 1'd0;
			address_counter <= 15'd0;
		end
		else if(drawing) begin
			if(address_counter == (15'd19200 - 15'd1))begin
				drawing <= 1'd0;
				address_counter <= 15'd0;
			end
			else begin
				address_counter <= address_counter + 15'd1;
			end
		end
		else if(go & frame) begin
			drawing <= 1'd1;
		end
	end
	
	always @(*) begin
		address = address_counter;
		x = address_counter % 14'd160;
		y = address_counter / 14'd160;
	end
	
endmodule
