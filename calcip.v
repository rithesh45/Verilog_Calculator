module calcip(a, b, opc, clk, result);
input [3:0] a, b;
input [1:0] opc;
input clk;
output reg [7:0] result;

wire [7:0] sum, diff, prod, quot; 
// Addition using half and full adders
wire c1, c2, c3, c4; // Carry bits 
half_adder ha1(a[0], b[0], sum[0], c1);
full_adder fa1(a[1], b[1], c1, sum[1], c2);
full_adder fa2(a[2], b[2], c2, sum[2], c3);
full_adder fa3(a[3], b[3], c3, sum[3], c4);

assign sum[4] = c4;  
assign sum[7:5] = 3'b000;  // The remaining upper bits are zero

// Subtraction using XOR and full adders
wire [3:0] b_neg;
assign b_neg = ~b;
wire borrow1, borrow2, borrow3, borrow4;
full_adder fa4(a[0], b_neg[0], 1'b1, diff[0], borrow1);  // Adding 1 for two's complement
full_adder fa5(a[1], b_neg[1], borrow1, diff[1], borrow2);
full_adder fa6(a[2], b_neg[2], borrow2, diff[2], borrow3);
full_adder fa7(a[3], b_neg[3], borrow3, diff[3], borrow4);

assign diff[7:4] = 4'b0000; 

    multiplier m1(a, b, clk, prod);  // Multiplication module instantiation

// Division with error handling (division by 0)
assign quot = (b != 0) ? a / b : 8'b00000000;


always @(posedge clk) begin
    case(opc)
        2'b00: result <= sum;
        2'b01: result <= diff;
        2'b10: result <= prod;
        2'b11: result <= quot;
        default: result <= 8'b00000000;
    endcase
end

endmodule

// HALF-ADDER MODULE
module half_adder(a, b, sum, carry);
input a, b;
output sum, carry;
xor(sum, a, b);
and(carry, a, b);
endmodule

// FULL-ADDER MODULE
module full_adder(a, b, cin, sum, cout);
input a, b, cin;
output sum, cout;
wire t1, t2, t3;
half_adder ha1(a, b, t1, t2);
half_adder ha2(t1, cin, sum, t3);
or (cout, t2, t3);
endmodule

// MULTIPLICATION 
module multiplier(a, b, clk, prod);
    input [3:0] a, b;
    input clk;
    output reg [7:0] prod;

    reg [7:0] p0, p1, p2, p3; 
    reg [7:0] temp_sum1, temp_sum2;

    always @(posedge clk) begin
      
        p0 = {4'b0000, a & {4{b[0]}}};  
        p1 = {3'b000, a & {4{b[1]}}, 1'b0};  
        p2 = {2'b00, a & {4{b[2]}}, 2'b00};  
        p3 = {1'b0, a & {4{b[3]}}, 3'b000};  

       
        temp_sum1 = p0 + p1;  
        temp_sum2 = p2 + p3;  

        prod <= temp_sum1 + temp_sum2;  
    end
endmodule



