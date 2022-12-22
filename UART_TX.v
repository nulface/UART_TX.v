module UART_FSM_TX
#(
    parameter baud 				    = 9_600,
    parameter clock_speed 		= 16_000_000,
)
(
    //output wire LED,
    input wire clk,
    input wire CLR,
    input tx_sig,
    input wire [7:0] data_in,
    output reg data_out
);

localparam bit_width = (clock_speed / baud) /2;
localparam counter_width = $clog2(bit_width);

localparam
DATA_BIT0 = 0,
DATA_BIT1 = 1,
DATA_BIT2 = 2,
DATA_BIT3 = 3,
DATA_BIT4 = 4,
DATA_BIT5 = 5,
DATA_BIT6 = 6,
DATA_BIT7 = 7,
IDLE_BIT  = 8,
START_BIT = 9,
LAST_BIT  = 10;

localparam DATA0  = 1 << DATA_BIT0;
localparam DATA1  = 1 << DATA_BIT1;
localparam DATA2  = 1 << DATA_BIT2;
localparam DATA3  = 1 << DATA_BIT3;
localparam DATA4  = 1 << DATA_BIT4;
localparam DATA5  = 1 << DATA_BIT5;
localparam DATA6  = 1 << DATA_BIT6;
localparam DATA7  = 1 << DATA_BIT7;
localparam IDLE   = 1 << IDLE_BIT;
localparam START  = 1 << START_BIT;
localparam LAST   = 1 << LAST_BIT;

initial data_out = 1;

reg [10:0] state;
reg [10:0] next_state;

initial state 		= IDLE;
initial next_state 	= IDLE;

reg [counter_width:0] counter;
initial counter = 0;

always @ (posedge clk or posedge CLR) begin : next_state_ff
	if(CLR) begin
		state <= IDLE;
		counter <= 0;
	end else begin
		if(counter < (bit_width - 1) ) begin
			counter <= counter + 1;
			state <= state;
		end else begin
			counter <= 0;
			state <= next_state;
		end
	end
end

always @ * begin : output_decoder

case(state)

	DATA0:      data_out = data_in[0];
	DATA1:      data_out = data_in[1];
	DATA2:      data_out = data_in[2];
	DATA3:      data_out = data_in[3];
	DATA4:      data_out = data_in[4];
	DATA5:      data_out = data_in[5];
	DATA6:      data_out = data_in[6];
	DATA7:      data_out = data_in[7];
	IDLE:       data_out = 1;
	START:      data_out = 0;
	LAST:       data_out = 1;

endcase

end

always @ * begin : state_decoder

case(state)

	DATA0: 		next_state = DATA1;
	DATA1: 		next_state = DATA2;
	DATA2: 		next_state = DATA3;
	DATA3: 		next_state = DATA4;
	DATA4: 		next_state = DATA5;
	DATA5: 		next_state = DATA6;
	DATA6: 		next_state = DATA7;
	DATA7: 		next_state = LAST;
	IDLE:  		next_state = tx_sig ? START : IDLE;
	START: 		next_state = DATA0;
  LAST:  		next_state = tx_sig ? START : IDLE;

endcase

end

endmodule
