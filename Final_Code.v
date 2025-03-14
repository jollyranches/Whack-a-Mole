// This is a Verilog code file I developed for an FPGA Whack-a-Mole simulation, to be ran on the Nexys A7 board.
// Upon game start, the player will flip one of 16 switches to a corresponding lit light, in which the player's score will increase.
// Time to flip switch will decrease until the player loses.

`timescale 1ns / 1ps

module Final_Code(input clk, input start, input reset, input [15:0] sw, output reg [15:0] led, output reg [6:0] seg0, 
                  output reg [7:0] AN);

    // integer game_time = 15_000_000;
    parameter light_choose = 1, flip_switch = 2, game_end = 3;
    reg [63:0] count = 0;
    reg [6:0] score = 0, high_score = 0;
    reg [5:0] state = light_choose, next_state;
    reg [3:0] random = 0, random_temp, score_0 = 0, score_1 = 0, highscore_0 = 0, highscore_1 = 0, div_clock;
    reg [1:0] digit_select = 0;
    reg score_check;
    wire clock;
    
    clk_wiz_0 instance_name (.clk_out1(clock), .reset(reset), .locked(), .clk_in1(clk));
    
    always @ (posedge clk or posedge reset) begin  // clocking & reset loop
        if (reset) begin
            count <= 0;
            score <= 0;
            high_score <= 0;
            random <= 0;
            digit_select <= 0;
            state <= light_choose;
            next_state <= light_choose;
            div_clock <= 0;
        end 
        else begin
            random <= random + 1;
            if (count == 2_000_000_000) begin
                div_clock <= div_clock + 1;
                count <= 0;
            end
            else begin
                count <= count + 1;
                digit_select <= count[14:13];
            end
        end
    end
    
    always @ (posedge div_clock) begin
        if (div_clock == 15)
            state <= next_state;
    end
    
    /* always @ (state) begin // game time loop (time to whack mole decreases exponentially as game progresses)
        case (state)
            light_choose: begin
                if (game_time > 500_000)
                    game_time = game_time * 95 / 100;
            end
            game_end: game_time = 15_000_000;
        endcase
    end */
    
    always @ (state or sw) begin
        case (state)
            light_choose: begin 
                led = 16'b0;
                if (score_check) begin
                    score = score + 1;
                    score_check = 0;
                end
                random_temp = random;
                next_state = flip_switch;
            end
            flip_switch: begin
                led = 16'b0;
                led[random_temp] = 1;
                if (sw == led) begin
                    score_check = 1;
                    next_state = light_choose;
                end
                else begin
                    score_check = 0;
                    next_state = game_end;
                end
            end
            game_end: begin
                led = 16'hFFFF;
                score = 0;
                next_state = light_choose;
            end
        endcase
    end
    
    always @ (score) begin // output loop (for score and highscore, to be passed onto seven seg)
        score_0 = score % 10;
        score_1 = (score - score_0) / 10;
        if (score > high_score) begin
            high_score = score;
            highscore_0 = score_0;
            highscore_1 = score_1;
        end
    end
    
    always @ (digit_select) begin // seven seg loop
        case (digit_select)
            2'b00: begin
                AN = 8'b11111110;
                case (score_0)
                    0: seg0 = 7'b0000001;
                    1: seg0 = 7'b1001111;
                    2: seg0 = 7'b0010010;
                    3: seg0 = 7'b0000110;
                    4: seg0 = 7'b1001100;
                    5: seg0 = 7'b0100100;
                    6: seg0 = 7'b0100000;
                    7: seg0 = 7'b0001111;
                    8: seg0 = 7'b0000000;
                    9: seg0 = 7'b0000100;
                    default: seg0 = 7'bxxxxxxx;
                endcase
            end
            2'b01: begin
                AN = 8'b11111101;
                case (score_1)
                    0: seg0 = 7'b0000001;
                    1: seg0 = 7'b1001111;
                    2: seg0 = 7'b0010010;
                    3: seg0 = 7'b0000110;
                    4: seg0 = 7'b1001100;
                    5: seg0 = 7'b0100100;
                    6: seg0 = 7'b0100000;
                    7: seg0 = 7'b0001111;
                    8: seg0 = 7'b0000000;
                    9: seg0 = 7'b0000100;
                    default: seg0 = 7'bxxxxxxx;
                endcase
            end
            2'b10: begin
                AN = 8'b10111111;
                case (highscore_0)
                    0: seg0 = 7'b0000001;
                    1: seg0 = 7'b1001111;
                    2: seg0 = 7'b0010010;
                    3: seg0 = 7'b0000110;
                    4: seg0 = 7'b1001100;
                    5: seg0 = 7'b0100100;
                    6: seg0 = 7'b0100000;
                    7: seg0 = 7'b0001111;
                    8: seg0 = 7'b0000000;
                    9: seg0 = 7'b0000100;
                    default: seg0 = 7'bxxxxxxx;
                endcase
            end
            2'b11: begin
                AN = 8'b01111111;
                case (highscore_1)
                    0: seg0 = 7'b0000001;
                    1: seg0 = 7'b1001111;
                    2: seg0 = 7'b0010010;
                    3: seg0 = 7'b0000110;
                    4: seg0 = 7'b1001100;
                    5: seg0 = 7'b0100100;
                    6: seg0 = 7'b0100000;
                    7: seg0 = 7'b0001111;
                    8: seg0 = 7'b0000000;
                    9: seg0 = 7'b0000100;
                    default: seg0 = 7'bxxxxxxx;
                endcase
            end
        endcase
    end

endmodule
