`default_nettype none
//11/30/2023-Isaiah Weekes

module URISC
  (output logic update,
   input logic clock, reset);

  logic [7:0] accum_out, accum_in, pc_out, pc_in, addr_out, addr_mux_out;
  logic accum_en, accum_clear, pc_en, pc_clear, addr_en;
  logic [7:0] mux_out, mem_out, mem_in, pc_add, pc_mux_out, pc_mux_out2;
  logic isNeg, re, we, negVal, addr_sel;
  logic [1:0] data_sel;
  wire [7:0] bus;
 assign pc_mux_out2 = pc_clear ? 8'd0 : pc_mux_out; 
//Control Points: accum_en, accum_clear, pc_en, pc_clear, re, we
//Status Points: isNeg, data_sel
  ControlPath fsm(.accum_en, .accum_clear, .pc_en, .pc_clear, .re, .we, .isNeg,
                  .data_sel, .clock, .reset, .addr_en, .addr_sel);
//Accumulator
  Register #(8) ac(.Q(accum_out), .D(accum_in), .en(accum_en), 
                    .clear(accum_clear), .clock, .reset);
//Program Counter
  Register #(8) pc(.Q(pc_out), .D(pc_mux_out2), .en(pc_en), 
                    .clear(1'b0), .clock, .reset);
//Temp address register
  Register #(8) ad(.Q(addr_out), .D(bus), .en(addr_en), .clear(1'b0),
                   .clock, .reset);
//Negative Flag
  Register #(1) neg(.Q(negVal), .D(isNeg), .en(accum_en),.clear(accum_clear),
                    .clock, .reset);
//"ALU" (Actually just combinational subtractor)
  ALU alu(.out(accum_in), .isNeg, .in(mux_out), .accum(accum_out));
//Memory System
  memorySystem mem(.data(bus), .address(addr_mux_out), .we, .re, .clock);
//Read and write tri-state drivers
  tridrive #(8) r(.data(bus), .bus(mem_out), .en(re));
  tridrive #(8) w(.data(accum_out), .bus(bus), .en(we));
//Selects input for ALU
  Mux4to1 #(8) aluMux(.Y(mux_out), .I0(pc_out), .I1(accum_out), .I2(16'b0), 
                       .I3(mem_out), .S(data_sel));
//Selects between skipping next instruction or not
  Mux2to1 #(8) pcmux(.Y(pc_mux_out), .I0(pc_in), .I1(pc_add), .S(negVal));
  Mux2to1 #(8) addrmux(.Y(addr_mux_out), .I0(pc_out), .I1(addr_out), 
                       .S(addr_sel));
  always_comb begin
    case(addr_out)
      0: data_sel = 0; //pc
      1: data_sel = 1; //accum
      2: data_sel = 2; //zero
      default: data_sel = 3; //mem
    endcase
    //If pc is pointing to 0, use accum, else loop in on itself
    pc_in = (data_sel == 0) ? accum_out : pc_out;
    //Incrementing pc
    pc_in = pc_in + 1; 
    //Incrementing pc to skip instruction
    pc_add = pc_in + 1;
  end

// //Testbench for simulation
//   initial begin 
//     clock = 0;
//     forever #5 clock = ~clock;
//   end
//   integer cycle;
//   string hoo;
//   initial begin 
//     cycle = 0;
//     hoo = "";
//     reset = 1;
//     @(posedge clock)
//     reset = 0;
//   end
//     always @(negedge clock) begin
//         $display("cycle %d", cycle);
//         $display(" PC = %h", pc_out);
//         $display( "Accum = %h", accum_out);
//         $display(" state = %s", fsm.state.name);
//         $display("bus = %h", bus);
//         $display("we %b, re %b", we, re);
//         $display("data_sel = %d", data_sel);
//         $display("alu_out = %h", accum_in);
//         $display("adrr_out %h", addr_out);
//         $display("isNeg %d", negVal);
//         $display("==================================================");
//         cycle = cycle + 1;
//         if (cycle > 20)
//           $finish;
//     end

endmodule: URISC

module ControlPath
  (output logic accum_en, accum_clear, pc_en, pc_clear, re, we, addr_en, addr_sel,
   input logic isNeg, reset, clock,
   input logic [1:0] data_sel);

  enum logic[1:0] {res, read, read2, write} state, nextState;

  always_comb begin
    accum_en=0;accum_clear=0;pc_en=0;pc_clear=0;re=0;we=0;addr_en=0;addr_sel=0;
    case(state)
      res: begin
        accum_clear=1; pc_en=1; pc_clear=1; //Clear Registers
        nextState = read; //Begin Computation
      end
      read: begin
        //Read instruction from memory
        re=1;
        addr_en=1; 
        nextState = read2;
      end
        //Read value from address in instruction
      read2: begin
        re=1;
        addr_sel=1;
        accum_en=1;
        nextState = write;
      end
      write: begin 
        //Write to accumulator and memory
        we=1; //If PC is point to memory, write
        pc_en = 1;//load accum or increment pc if applicable
        nextState = read;
        addr_sel = 1;
      end
    endcase
  end

  always_ff @(posedge clock, posedge reset)
    if(reset)
      state <= res;
    else
      state <= nextState;
endmodule: ControlPath

module ALU
  (output logic [7:0] out,
   output logic isNeg, 
   input logic [7:0] in, accum);

  assign out = in - accum;
  assign isNeg = out[7];

endmodule: ALU

