`timescale 1ns/1ps

//==============================================================
// DAY 16 - VENDING MACHINE CONTROLLER
// Digital VLSI / Verilog RTL Training
//
// Product Price : Rs.15
//
// Accepted Coins:
//   coin_5  = Rs.5
//   coin_10 = Rs.10
//
// States:
//   S0  = Rs.0
//   S5  = Rs.5
//   S10 = Rs.10
//
// Transactions:
//   Rs.5 + Rs.5 + Rs.5  -> DISPENSE
//   Rs.10 + Rs.5         -> DISPENSE
//   Rs.10 + Rs.10        -> DISPENSE + Rs.5 CHANGE
//
// Both coin inputs HIGH = INVALID
//
// Hierarchy:
//   Basic Gates
//       |
//       v
//   NAND / NOR
//       |
//       v
//   2-bit Equality Comparator
//       |
//       v
//   DFF
//       |
//       v
//   2-bit State Register
//       |
//       v
//   Next-State Logic
//       |
//       v
//   Output Decoder
//       |
//       v
//   Structural Vending Machine
//       |
//       v
//   Behavioral RTL
//       |
//       v
//   Top Module
//==============================================================


//==============================================================
// 1. BASIC GATES
//==============================================================

module not_gate(
    input A,
    output Y
);
    assign Y = ~A;
endmodule


module and_gate(
    input A,
    input B,
    output Y
);
    assign Y = A & B;
endmodule


module or_gate(
    input A,
    input B,
    output Y
);
    assign Y = A | B;
endmodule


module xor_gate(
    input A,
    input B,
    output Y
);
    assign Y = A ^ B;
endmodule


//==============================================================
// 2. NAND / NOR GATES
//==============================================================

module nand_gate(
    input A,
    input B,
    output Y
);
    assign Y = ~(A & B);
endmodule


module nor_gate(
    input A,
    input B,
    output Y
);
    assign Y = ~(A | B);
endmodule


//==============================================================
// 3. 2-BIT EQUALITY COMPARATOR
//==============================================================

module equality_2bit(
    input  [1:0] A,
    input  [1:0] B,
    output       equal
);

    wire X0;
    wire X1;
    wire E0;
    wire E1;

    xor_gate XG0(
        .A(A[0]),
        .B(B[0]),
        .Y(X0)
    );

    xor_gate XG1(
        .A(A[1]),
        .B(B[1]),
        .Y(X1)
    );

    not_gate NG0(
        .A(X0),
        .Y(E0)
    );

    not_gate NG1(
        .A(X1),
        .Y(E1)
    );

    and_gate AG0(
        .A(E0),
        .B(E1),
        .Y(equal)
    );

endmodule


//==============================================================
// 4. D FLIP-FLOP WITH SYNCHRONOUS RESET
//==============================================================

module dff_sync_reset(
    input       clk,
    input       reset,
    input       D,
    output reg  Q
);

    always @(posedge clk) begin

        if (reset)
            Q <= 1'b0;

        else
            Q <= D;

    end

endmodule


//==============================================================
// 5. 2-BIT STATE REGISTER
//==============================================================

module state_register_2bit(
    input        clk,
    input        reset,
    input  [1:0] next_state,
    output [1:0] state
);

    dff_sync_reset FF0(
        .clk(clk),
        .reset(reset),
        .D(next_state[0]),
        .Q(state[0])
    );

    dff_sync_reset FF1(
        .clk(clk),
        .reset(reset),
        .D(next_state[1]),
        .Q(state[1])
    );

endmodule


//==============================================================
// 6. NEXT-STATE LOGIC
//==============================================================

module vending_next_state(
    input  [1:0] state,
    input        coin_5,
    input        coin_10,
    output reg [1:0] next_state
);

    localparam S0  = 2'b00;
    localparam S5  = 2'b01;
    localparam S10 = 2'b10;

    always @(*) begin

        // Safe default
        next_state = S0;

        case (state)

            //--------------------------------------------------
            // S0 = Rs.0
            //--------------------------------------------------
            S0: begin

                if (coin_5 && !coin_10)
                    next_state = S5;

                else if (!coin_5 && coin_10)
                    next_state = S10;

                else
                    next_state = S0;

            end


            //--------------------------------------------------
            // S5 = Rs.5
            //--------------------------------------------------
            S5: begin

                if (coin_5 && !coin_10)
                    next_state = S10;

                else if (!coin_5 && coin_10)
                    next_state = S0;

                else
                    next_state = S5;

            end


            //--------------------------------------------------
            // S10 = Rs.10
            //--------------------------------------------------
            S10: begin

                if (coin_5 || coin_10)
                    next_state = S0;

                else
                    next_state = S10;

            end


            //--------------------------------------------------
            // INVALID STATE
            //--------------------------------------------------
            default:
                next_state = S0;

        endcase

    end

endmodule


//==============================================================
// 7. OUTPUT DECODER
//==============================================================
//
// Mealy FSM
//
// Output depends on:
//   CURRENT STATE + CURRENT COIN
//
// S0  + coin       -> no dispense
// S5  + Rs.10      -> dispense
// S10 + Rs.5       -> dispense
// S10 + Rs.10      -> dispense + Rs.5 change
//
// Invalid two-coin input -> no output
//==============================================================

module vending_output_decoder(
    input        [1:0] state,
    input              coin_5,
    input              coin_10,
    output reg         dispense,
    output reg         change_5
);

    localparam S0  = 2'b00;
    localparam S5  = 2'b01;
    localparam S10 = 2'b10;

    always @(*) begin

        // Safe default
        dispense = 1'b0;
        change_5 = 1'b0;

        case (state)

            //--------------------------------------------------
            // S0 = Rs.0
            //--------------------------------------------------
            S0: begin

                dispense = 1'b0;
                change_5 = 1'b0;

            end


            //--------------------------------------------------
            // S5 = Rs.5
            //
            // Rs.5 + Rs.10 = Rs.15
            //--------------------------------------------------
            S5: begin

                if (!coin_5 && coin_10) begin

                    dispense = 1'b1;
                    change_5 = 1'b0;

                end

            end


            //--------------------------------------------------
            // S10 = Rs.10
            //
            // Rs.10 + Rs.5  = Rs.15
            // Rs.10 + Rs.10 = Rs.20
            //                  Rs.5 change
            //--------------------------------------------------
            S10: begin

                if (coin_5 && !coin_10) begin

                    dispense = 1'b1;
                    change_5 = 1'b0;

                end

                else if (!coin_5 && coin_10) begin

                    dispense = 1'b1;
                    change_5 = 1'b1;

                end

            end


            //--------------------------------------------------
            // INVALID STATE
            //--------------------------------------------------
            default: begin

                dispense = 1'b0;
                change_5 = 1'b0;

            end

        endcase

    end

endmodule


//==============================================================
// 8. STRUCTURAL VENDING MACHINE
//==============================================================

module vending_machine_structural(
    input        clk,
    input        reset,
    input        coin_5,
    input        coin_10,

    output       dispense,
    output       change_5,

    output [1:0] state,
    output [1:0] next_state
);

    //==========================================================
    // STATE REGISTER
    //==========================================================

    state_register_2bit STATE_REG(

        .clk(clk),
        .reset(reset),
        .next_state(next_state),
        .state(state)

    );


    //==========================================================
    // NEXT-STATE LOGIC
    //==========================================================

    vending_next_state NEXT_LOGIC(

        .state(state),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .next_state(next_state)

    );


    //==========================================================
    // OUTPUT DECODER
    //==========================================================

    vending_output_decoder OUTPUT_LOGIC(

        .state(state),
        .coin_5(coin_5),
        .coin_10(coin_10),

        .dispense(dispense),
        .change_5(change_5)

    );

endmodule


//==============================================================
// 9. BEHAVIORAL RTL VENDING MACHINE
//==============================================================

module vending_machine_rtl(
    input       clk,
    input       reset,
    input       coin_5,
    input       coin_10,

    output reg  dispense,
    output reg  change_5
);

    localparam S0  = 2'b00;
    localparam S5  = 2'b01;
    localparam S10 = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;


    //==========================================================
    // STATE REGISTER
    //==========================================================

    always @(posedge clk) begin

        if (reset)
            state <= S0;

        else
            state <= next_state;

    end


    //==========================================================
    // NEXT-STATE LOGIC
    //==========================================================

    always @(*) begin

        // Safe default
        next_state = S0;

        case (state)

            //--------------------------------------------------
            // S0 = Rs.0
            //--------------------------------------------------
            S0: begin

                if (coin_5 && !coin_10)
                    next_state = S5;

                else if (!coin_5 && coin_10)
                    next_state = S10;

                else
                    next_state = S0;

            end


            //--------------------------------------------------
            // S5 = Rs.5
            //--------------------------------------------------
            S5: begin

                if (coin_5 && !coin_10)
                    next_state = S10;

                else if (!coin_5 && coin_10)
                    next_state = S0;

                else
                    next_state = S5;

            end


            //--------------------------------------------------
            // S10 = Rs.10
            //--------------------------------------------------
            S10: begin

                if (coin_5 || coin_10)
                    next_state = S0;

                else
                    next_state = S10;

            end


            //--------------------------------------------------
            // INVALID STATE
            //--------------------------------------------------
            default:
                next_state = S0;

        endcase

    end


    //==========================================================
    // OUTPUT LOGIC
    //==========================================================

    always @(*) begin

        // Safe default
        dispense = 1'b0;
        change_5 = 1'b0;

        case (state)

            //--------------------------------------------------
            // S0
            //--------------------------------------------------
            S0: begin

                dispense = 1'b0;
                change_5 = 1'b0;

            end


            //--------------------------------------------------
            // S5
            //--------------------------------------------------
            S5: begin

                if (!coin_5 && coin_10) begin

                    dispense = 1'b1;
                    change_5 = 1'b0;

                end

            end


            //--------------------------------------------------
            // S10
            //--------------------------------------------------
            S10: begin

                if (coin_5 && !coin_10) begin

                    dispense = 1'b1;
                    change_5 = 1'b0;

                end

                else if (!coin_5 && coin_10) begin

                    dispense = 1'b1;
                    change_5 = 1'b1;

                end

            end


            //--------------------------------------------------
            // INVALID STATE
            //--------------------------------------------------
            default: begin

                dispense = 1'b0;
                change_5 = 1'b0;

            end

        endcase

    end

endmodule


//==============================================================
// 10. TOP MODULE
//==============================================================

module vending_machine_top(
    input  clk,
    input reset,
    input coin_5,
    input coin_10,

    output dispense,
    output change_5
);

    wire [1:0] state;
    wire [1:0] next_state;


    vending_machine_structural DUT(

        .clk(clk),
        .reset(reset),

        .coin_5(coin_5),
        .coin_10(coin_10),

        .dispense(dispense),
        .change_5(change_5),

        .state(state),
        .next_state(next_state)

    );

endmodule