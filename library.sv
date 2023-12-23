module demux #(parameter OUT_WIDTH = 8, IN_WIDTH = 3, DEFAULT = 0)(
   input                      in,
   input [IN_WIDTH-1:0]       sel,
   output logic [OUT_WIDTH-1:0] out);

   always_comb begin
      out = (DEFAULT === 1'b0) ? {OUT_WIDTH {1'b0}} : {OUT_WIDTH {1'b1}};
      out[sel] = in;
   end

endmodule : demux

module Mux4to1
  #(parameter WIDTH = 16)
  (output logic [WIDTH-1:0] Y,
   input logic [WIDTH-1:0] I0, I1, I2, I3,
   input logic [1:0] S);

  always_comb begin
    case(S)
      0: Y = I0;
      1: Y = I1;
      2: Y = I2;
      3: Y = I3;
    endcase
  end
endmodule: Mux4to1

module Register
  #(parameter WIDTH = 8)
  (output logic [WIDTH-1:0] Q,
   input logic [WIDTH-1:0] D,
   input logic en, clear, clock,reset);
  
  always_ff @(posedge clock, posedge reset)
    if(reset)
      Q <= '0;
    else if(en)
      Q <= D;
    else if(clear)
      Q <= '0;
endmodule: Register

module tridrive #(parameter WIDTH = 16) (
   input  logic [WIDTH-1:0] data,
   output logic [WIDTH-1:0] bus,
   input  logic             en);

   assign bus = (en === 1'b1)? data : {WIDTH {1'bz}};
endmodule: tridrive

module Mux2to1
  #(parameter WIDTH = 8)
  (output logic [WIDTH-1:0] Y,
   input logic [WIDTH-1:0] I0, I1,
   input logic S);

  assign Y = S ? I1 : I0;

endmodule: Mux2to1


