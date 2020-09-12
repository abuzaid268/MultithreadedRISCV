module externalmemory(
input logic clk,ReadAccess,
input logic [7:0] address,
output logic [31:0] datafromexternal,
output logic ReadFromExternal
);

logic [31:0] ExternalRAM [0:63];
initial
$readmemh("D:/Desktop/processorandsram/simulation files/externalram.sv",ExternalRAM);
always_ff @(posedge clk)
begin
if (ReadAccess)
begin
datafromexternal <= ExternalRAM[address];
ReadFromExternal <= 1;
end
else
ReadFromExternal <= 0;
end
endmodule