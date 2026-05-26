// SAMUL Complete Synthesizable RTL

module HA(input A, B, output Sum, Carry);
    assign Sum   = A ^ B;
    assign Carry = A & B;
endmodule

module FA(input A, B, Cin, output Sum, Carry);
    assign Sum   = A ^ B ^ Cin;
    assign Carry = (A & B) | (B & Cin) | (A & Cin);
endmodule

module AHA(input A, B, output Sum, Carry);
    assign Sum   = A | B;
    assign Carry = A & B;
endmodule

module AFA(input A, B, Cin, output Sum, Carry);
    assign Sum   = A ^ B;
    assign Carry = A & B;
endmodule

module comp(input A, B, C, D, Cin, output Sum, Carry);
    assign Sum   = A ^ B ^ C ^ D ^ Cin;
    assign Carry = (A & B) | (C & D);
endmodule

module FEMUL(input [3:0] A, B, output [7:0] P);
    wire [3:0] pp0, pp1, pp2, pp3;
    assign pp0 = A & {4{B[0]}};
    assign pp1 = A & {4{B[1]}};
    assign pp2 = A & {4{B[2]}};
    assign pp3 = A & {4{B[3]}};

    wire s1,c1,s2,c2,s3,c3,s4,c4,s5,c5,s6,c6,s7,c7,s8,c8,s9,c9;

    assign P[0] = pp0[0];

    HA h1(pp0[1], pp1[0], s1, c1);
    assign P[1] = s1;

    FA f1(pp0[2], pp1[1], c1, s2, c2);
    HA h2(s2, pp2[0], s3, c3);
    assign P[2] = s3;

    FA f2(pp0[3], pp1[2], c2, s4, c4);
    FA f3(s4, pp2[1], c3, s5, c5);
    HA h3(s5, pp3[0], s6, c6);
    assign P[3] = s6;

    FA f4(pp1[3], pp2[2], c4, s7, c7);
    FA f5(s7, pp3[1], c5, s8, c8);
    assign P[4] = s8;

    FA f6(pp2[3], pp3[2], c7, s9, c9);
    assign P[5] = s9;

    FA f7(pp3[3], c9, c8, P[6], P[7]);
endmodule

module FAMUL(input [3:0] A, B, output [7:0] P);
    wire [3:0] pp0, pp1, pp2, pp3;
    assign pp0 = A & {4{B[0]}};
    assign pp1 = A & {4{B[1]}};
    assign pp2 = A & {4{B[2]}};
    assign pp3 = A & {4{B[3]}};

    wire s2,c2,s3,c3,s4,c4,s5,c5,s6,c6,s7,c7;

    assign P[0] = 1'b0;
    assign P[1] = pp0[1] ^ pp1[0];

    AHA h1(pp0[2], pp1[1], s2, c2);
    AFA f1(s2, c2, pp2[0], s3, c3);
    assign P[2] = s3;

    comp c1(pp0[3], pp1[2], pp2[1], pp3[0], c3, s4, c4);
    assign P[3] = s4;

    FA f2(pp1[3], pp2[2], c4, s5, c5);
    FA f3(s5, pp3[1], c5, s6, c6);
    assign P[4] = s6;

    FA f4(pp2[3], pp3[2], c6, s7, c7);
    assign P[5] = s7;

    FA f5(pp3[3], c7, 1'b0, P[6], P[7]);
endmodule

module EEMUL(input [7:0] A, B, output [15:0] P);
    wire [7:0] p0, p1, p2, p3;

    FEMUL m0(A[3:0], B[3:0], p0);
    FEMUL m1(A[7:4], B[3:0], p1);
    FEMUL m2(A[3:0], B[7:4], p2);
    FEMUL m3(A[7:4], B[7:4], p3);

    assign P = {p3,8'b0} + {4'b0,p2,4'b0} + {4'b0,p1,4'b0} + {8'b0,p0};
endmodule

module EAMUL(input [7:0] A, B, output [15:0] P);
    wire [15:0] P0, P1, P2, P3;

    FEMUL m1(A[3:0], B[3:0], P0[7:0]);
    FEMUL m4(A[7:4], B[7:4], P3[7:0]);

    FAMUL m2(A[7:4], B[3:0], P1[7:0]);
    FAMUL m3(A[3:0], B[7:4], P2[7:0]);

    assign P = (P3 << 8) + (P2 << 4) + (P1 << 4) + P0;
endmodule

module SAMUL (
    input  [15:0] A,
    input  [15:0] B,
    output [31:0] P
);

    wire [15:0] P0, P1, P2, P3;
    wire [16:0] mid_sum;

    EEMUL M1 (.A(A[7:0]),  .B(B[7:0]),  .P(P0));
    EAMUL M2 (.A(A[15:8]), .B(B[7:0]),  .P(P1));
    EAMUL M3 (.A(A[7:0]),  .B(B[15:8]), .P(P2));
    EEMUL M4 (.A(A[15:8]), .B(B[15:8]), .P(P3));

    assign mid_sum = P1 + P2;
    assign P = (P3 << 16) + (mid_sum << 8) + P0;

endmodule
