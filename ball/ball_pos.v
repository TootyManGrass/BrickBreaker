`include "macros.v"

module ball_pos(
	input enable,
	input clk,
	input resetn,
	
	input x_du,
	input y_du,
	
	input [9:0]platx,
	input plat_col,
	
	output [9:0]x,
	output [9:0]y
	);
	
	
	
	wire [19:0]full_x, full_y;
//	wire [19:0]xchange, ychange;
	
	assign x = full_x[19:10];
	assign y = full_y[19:10];
	
//	xy_changer xychanger(
//		.resetn(resetn),
//		.clk(clk),
//		
//		.x(x),
//		.platx(platx),
//		.plat_col(plat_col),
//		.xchange(xchange),
//		.ychange(ychange)
//	);
	
	x_counter xc(
		.enable(enable),
		.clk(clk),
		.resetn(resetn),
		
		.change(20'b00000000010000000000),
		.updown(x_du),
		.c_x(full_x)
	);
	
	y_counter yc(
		.enable(enable),
		.clk(clk),
		.resetn(resetn),
		
		.change(20'b00000000010000000000),
		.updown(y_du),
		.c_y(full_y)
		);
	
endmodule

module xy_changer(
	input resetn,
	input clk,
	
	input [9:0]x,
	input [9:0]platx,
	input plat_col,
	
	output reg [19:0]xchange,
	output reg [19:0]ychange
	);
	wire [9:0]plathalf, difx, speed;
	wire [19:0] newchange;
	
	reg [19:0]calcchange, newychange;
	
	assign plathalf = platx + `PLATHALF;
	assign difx = (x > plathalf) ? (x - plathalf) : (plathalf - x);
	assign newchange = (difx << 10'd10) / `PLATSIZE;
	
	reg done;
	
	always @(posedge clk, negedge resetn)begin
		if(!resetn)begin
			xchange <= 20'b00000000010000000000;
			ychange <= 20'b00000000010000000000;
			done <= 1;
			calcchange <= 0;
			newychange <= 0;
		end
		else begin
			if(plat_col)begin
				xchange <= newchange;
				calcchange <= 20'b00000000010000000000 - (newchange * newchange);
				done <= 0;
				newychange <= 0;
			end
			else if(!done) begin
				if((newychange * newychange) >= calcchange)begin
					done <= 1;
					ychange <= newychange;
				end
				else begin
					newychange <= newychange + 1;
				end
			end
		end
	end
	
endmodule

module x_counter(
	input enable,
	input clk,
	input resetn,
	input updown,
	input [19:0]change,
	
	output reg [19:0]c_x
	);
	
	
	always @ (posedge clk) begin
		if(!resetn)
			c_x <= `BALLX << 10'd10;
			
		else begin
			if(enable)begin 
				if(updown)
					c_x <= c_x + change;
				else
					c_x <= c_x - change;
			end
		end
	end

endmodule

module y_counter(
	input enable,
	input resetn,
	input clk,
	input updown,
	input [19:0]change,
	
	output reg [19:0]c_y
	);
	
	always @ (posedge clk) begin
		if(!resetn)
			c_y <= `BALLY << 10'd10;
			
		else begin
			if(enable)begin 
				if(updown)
					c_y <= c_y + change;
				else
					c_y <= c_y - change;
			end
		end
	end

endmodule
