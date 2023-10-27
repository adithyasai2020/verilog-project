module backend(
    input i_resetbAll,
    input i_clk,
    input i_sclk,
    input i_sdin,
    input i_clk_vco1,
    input i_clk_vco2,
    output reg o_ready,
    output reg o_vco1_fast,
    output reg o_resetb1,
    output reg [2:0] o_gainA1,
    output reg o_resetb2,
    output reg [1:0] o_gainA2,
    output reg o_resetbvco1,
    output reg o_resetbvco2
);

reg [4:0] counter1;
reg [4:0] counter2;
reg vco1_faster;
reg [4:0] startup_state;
reg [4:0] shift_register;
reg data_received;
reg prev_isclk;

always @(posedge i_clk or negedge i_resetbAll) begin
    if (!i_resetbAll) begin
        // Reset the entire backend
        counter1 <= 0;
        counter2 <= 0;
        vco1_faster <= 0;
        startup_state <= 0;
        shift_register <= 0;
        data_received <= 0;
        o_resetb1 <= 1'b0;
        o_resetb2 <= 1'b0;
        o_gainA1 <= 3'b000;
        o_gainA2 <= 2'b00;
        o_resetbvco1 <= 1'b0;
        o_resetbvco2 <= 1'b0;
        o_ready <= 1'b0;
        prev_isclk <= 1'b1;
    end else begin
        // State machine for the startup sequence
        case(startup_state)
            0: begin
                if (counter1 < 5) begin
                    if(i_sclk&&!prev_isclk)begin
                        shift_register[4-counter1] <=i_sdin;
                        counter1 <= counter1 +1;
                    end
                end else begin
                    counter1 <= 0;
                    startup_state <= 1;
                end
                prev_isclk <= i_sclk;
            end
            1: begin
                // Wait for five clock cycles
                if (counter1 < 4) begin
                    counter1 <= counter1 + 1;
                end else begin
                    counter1 <= 0;
                    data_received <= 1;
                    startup_state <= 2;
                end
            end
            2: begin
                // Set o_resetbvco1 and o_resetbvco2
                o_resetbvco1 <= 1'b1;
                o_resetbvco2 <= 1'b1;
                startup_state <= 3;
            end
            3: begin
                // Wait for 20 clock cycles
                if (counter2 < 20) begin
                    counter2 <= counter2 + 1;
                end else begin
                    counter2 <= 0;
                    startup_state <= 4;
                end
            end
            4: begin
                // Set o_resetb1 and o_resetb2
                o_resetb1 <= 1'b1;
                o_resetb2 <= 1'b1;
                startup_state <= 5;
            end
            5: begin
                // Wait for 10 clock cycles
                if (counter1 < 10) begin
                    counter1 <= counter1 + 1;
                end else begin
                    startup_state <= 6;
                    counter1 <= 0;
                end
            end
            6: begin
                // Determine the faster VCO
                if (counter1 <= counter2 + 5 && counter1 >= counter2 - 5) begin
                    vco1_faster <= 1;
                end else begin
                    vco1_faster <= 0;
                end
                startup_state <= 7;
            end
            7: begin
                // Set o_ready
                o_ready <= 1'b1;
                startup_state <= 8;
            end
            default: begin
                // No more actions required, hold values
            end
        endcase

        // Logic for o_gainA1 and o_gainA2 based on shifted data
        if (data_received) begin
            o_gainA1 <= shift_register[2:0];
            o_gainA2 <= shift_register[4:3];
        end

        // Logic for o_vco1_fast
        if (startup_state == 7) begin
            o_vco1_fast <= vco1_faster;
        end
    end
end

endmodule
