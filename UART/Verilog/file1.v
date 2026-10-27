`timescale 1ns / 1ps

module sine_rom (
    input  wire [7:0] addr,
    output reg  [7:0] sine_out
);
    // 256-entry ROM scaled to [0, 254] so 0xFF is never produced
    always @(*) begin
        case (addr)
            8'h00: sine_out = 8'd127; 8'h01: sine_out = 8'd130; 8'h02: sine_out = 8'd133; 8'h03: sine_out = 8'd136;
            8'h04: sine_out = 8'd139; 8'h05: sine_out = 8'd142; 8'h06: sine_out = 8'd145; 8'h07: sine_out = 8'd148;
            8'h08: sine_out = 8'd151; 8'h09: sine_out = 8'd154; 8'h0A: sine_out = 8'd157; 8'h0B: sine_out = 8'd160;
            8'h0C: sine_out = 8'd163; 8'h0D: sine_out = 8'd166; 8'h0E: sine_out = 8'd169; 8'h0F: sine_out = 8'd172;
            8'h10: sine_out = 8'd175; 8'h11: sine_out = 8'd178; 8'h12: sine_out = 8'd181; 8'h13: sine_out = 8'd183;
            8'h14: sine_out = 8'd186; 8'h15: sine_out = 8'd189; 8'h16: sine_out = 8'd191; 8'h17: sine_out = 8'd194;
            8'h18: sine_out = 8'd196; 8'h19: sine_out = 8'd199; 8'h1A: sine_out = 8'd201; 8'h1B: sine_out = 8'd203;
            8'h1C: sine_out = 8'd206; 8'h1D: sine_out = 8'd208; 8'h1E: sine_out = 8'd210; 8'h1F: sine_out = 8'd212;
            8'h20: sine_out = 8'd214; 8'h21: sine_out = 8'd216; 8'h22: sine_out = 8'd218; 8'h23: sine_out = 8'd220;
            8'h24: sine_out = 8'd222; 8'h25: sine_out = 8'd223; 8'h26: sine_out = 8'd225; 8'h27: sine_out = 8'd227;
            8'h28: sine_out = 8'd228; 8'h29: sine_out = 8'd230; 8'h2A: sine_out = 8'd231; 8'h2B: sine_out = 8'd232;
            8'h2C: sine_out = 8'd234; 8'h2D: sine_out = 8'd235; 8'h2E: sine_out = 8'd236; 8'h2F: sine_out = 8'd237;
            8'h30: sine_out = 8'd238; 8'h31: sine_out = 8'd239; 8'h32: sine_out = 8'd240; 8'h33: sine_out = 8'd240;
            8'h34: sine_out = 8'd241; 8'h35: sine_out = 8'd242; 8'h36: sine_out = 8'd242; 8'h37: sine_out = 8'd242;
            8'h38: sine_out = 8'd242; 8'h39: sine_out = 8'd242; 8'h3A: sine_out = 8'd242; 8'h3B: sine_out = 8'd242;
            8'h3C: sine_out = 8'd241; 8'h3D: sine_out = 8'd240; 8'h3E: sine_out = 8'd240; 8'h3F: sine_out = 8'd239;
            8'h40: sine_out = 8'd238; 8'h41: sine_out = 8'd237; 8'h42: sine_out = 8'd236; 8'h43: sine_out = 8'd235;
            8'h44: sine_out = 8'd234; 8'h45: sine_out = 8'd232; 8'h46: sine_out = 8'd231; 8'h47: sine_out = 8'd230;
            8'h48: sine_out = 8'd228; 8'h49: sine_out = 8'd227; 8'h4A: sine_out = 8'd225; 8'h4B: sine_out = 8'd223;
            8'h4C: sine_out = 8'd222; 8'h4D: sine_out = 8'd220; 8'h4E: sine_out = 8'd218; 8'h4F: sine_out = 8'd216;
            8'h50: sine_out = 8'd214; 8'h51: sine_out = 8'd212; 8'h52: sine_out = 8'd210; 8'h53: sine_out = 8'd208;
            8'h54: sine_out = 8'd206; 8'h55: sine_out = 8'd203; 8'h56: sine_out = 8'd201; 8'h57: sine_out = 8'd199;
            8'h58: sine_out = 8'd196; 8'h59: sine_out = 8'd194; 8'h5A: sine_out = 8'd191; 8'h5B: sine_out = 8'd189;
            8'h5C: sine_out = 8'd186; 8'h5D: sine_out = 8'd183; 8'h5E: sine_out = 8'd181; 8'h5F: sine_out = 8'd178;
            8'h60: sine_out = 8'd175; 8'h61: sine_out = 8'd172; 8'h62: sine_out = 8'd169; 8'h63: sine_out = 8'd166;
            8'h64: sine_out = 8'd163; 8'h65: sine_out = 8'd160; 8'h66: sine_out = 8'd157; 8'h67: sine_out = 8'd154;
            8'h68: sine_out = 8'd151; 8'h69: sine_out = 8'd148; 8'h6A: sine_out = 8'd145; 8'h6B: sine_out = 8'd142;
            8'h6C: sine_out = 8'd139; 8'h6D: sine_out = 8'd136; 8'h6E: sine_out = 8'd133; 8'h6F: sine_out = 8'd130;
            8'h70: sine_out = 8'd127; 8'h71: sine_out = 8'd124; 8'h72: sine_out = 8'd121; 8'h73: sine_out = 8'd118;
            8'h74: sine_out = 8'd115; 8'h75: sine_out = 8'd112; 8'h76: sine_out = 8'd109; 8'h77: sine_out = 8'd106;
            8'h78: sine_out = 8'd103; 8'h79: sine_out = 8'd100; 8'h7A: sine_out = 8'd97;  8'h7B: sine_out = 8'd94;
            8'h7C: sine_out = 8'd91;  8'h7D: sine_out = 8'd88;  8'h7E: sine_out = 8'd85;  8'h7F: sine_out = 8'd82;
            8'h80: sine_out = 8'd79;  8'h81: sine_out = 8'd76;  8'h82: sine_out = 8'd73;  8'h83: sine_out = 8'd71;
            8'h84: sine_out = 8'd68;  8'h85: sine_out = 8'd65;  8'h86: sine_out = 8'd63;  8'h87: sine_out = 8'd60;
            8'h88: sine_out = 8'd58;  8'h89: sine_out = 8'd55;  8'h8A: sine_out = 8'd53;  8'h8B: sine_out = 8'd51;
            8'h8C: sine_out = 8'd48;  8'h8D: sine_out = 8'd46;  8'h8E: sine_out = 8'd44;  8'h8F: sine_out = 8'd42;
            8'h90: sine_out = 8'd40;  8'h91: sine_out = 8'd38;  8'h92: sine_out = 8'd36;  8'h93: sine_out = 8'd34;
            8'h94: sine_out = 8'd32;  8'h95: sine_out = 8'd31;  8'h96: sine_out = 8'd29;  8'h97: sine_out = 8'd27;
            8'h98: sine_out = 8'd26;  8'h99: sine_out = 8'd24;  8'h9A: sine_out = 8'd23;  8'h9B: sine_out = 8'd22;
            8'h9C: sine_out = 8'd20;  8'h9D: sine_out = 8'd19;  8'h9E: sine_out = 8'd18;  8'h9F: sine_out = 8'd17;
            8'hA0: sine_out = 8'd16;  8'hA1: sine_out = 8'd15;  8'hA2: sine_out = 8'd14;  8'hA3: sine_out = 8'd14;
            8'hA4: sine_out = 8'd13;  8'hA5: sine_out = 8'd12;  8'hA6: sine_out = 8'd12;  8'hA7: sine_out = 8'd12;
            8'hA8: sine_out = 8'd12;  8'hA9: sine_out = 8'd12;  8'hAA: sine_out = 8'd12;  8'hAB: sine_out = 8'd12;
            8'hAC: sine_out = 8'd13;  8'hAD: sine_out = 8'd14;  8'hAE: sine_out = 8'd14;  8'hAF: sine_out = 8'd15;
            8'hB0: sine_out = 8'd16;  8'hB1: sine_out = 8'd17;  8'hB2: sine_out = 8'd18;  8'hB3: sine_out = 8'd19;
            8'hB4: sine_out = 8'd20;  8'hB5: sine_out = 8'd22;  8'hB6: sine_out = 8'd23;  8'hB7: sine_out = 8'd24;
            8'hB8: sine_out = 8'd26;  8'hB9: sine_out = 8'd27;  8'hBA: sine_out = 8'd29;  8'hBB: sine_out = 8'd31;
            8'hBC: sine_out = 8'd32;  8'hBD: sine_out = 8'd34;  8'hBE: sine_out = 8'd36;  8'hBF: sine_out = 8'd38;
            8'hC0: sine_out = 8'd40;  8'hC1: sine_out = 8'd42;  8'hC2: sine_out = 8'd44;  8'hC3: sine_out = 8'd46;
            8'hC4: sine_out = 8'd48;  8'hC5: sine_out = 8'd51;  8'hC6: sine_out = 8'd53;  8'hC7: sine_out = 8'd55;
            8'hC8: sine_out = 8'd58;  8'hC9: sine_out = 8'd60;  8'hCA: sine_out = 8'd63;  8'hCB: sine_out = 8'd65;
            8'hCC: sine_out = 8'd68;  8'hCD: sine_out = 8'd71;  8'hCE: sine_out = 8'd73;  8'hCF: sine_out = 8'd76;
            8'hD0: sine_out = 8'd79;  8'hD1: sine_out = 8'd82;  8'hD2: sine_out = 8'd85;  8'hD3: sine_out = 8'd88;
            8'hD4: sine_out = 8'd91;  8'hD5: sine_out = 8'd94;  8'hD6: sine_out = 8'd97;  8'hD7: sine_out = 8'd100;
            8'hD8: sine_out = 8'd103; 8'hD9: sine_out = 8'd106; 8'hDA: sine_out = 8'd109; 8'hDB: sine_out = 8'd112;
            8'hDC: sine_out = 8'd115; 8'hDD: sine_out = 8'd118; 8'hDE: sine_out = 8'd121; 8'hDF: sine_out = 8'd124;
            default: sine_out = 8'd127;
        endcase
    end
endmodule
