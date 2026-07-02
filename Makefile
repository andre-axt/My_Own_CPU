SRC_DIR = src
TB_DIR  = tb
SIM_DIR = sim

VLOG = iverilog
VLOG_FLAGS = -o $(SIM_DIR)/tb_alu
VVP = vvp

all: compile run

compile:
	$(VLOG) $(VLOG_FLAGS) $(SRC_DIR)/alu.v $(TB_DIR)/tb_alu.v

run:
	$(VVP) $(SIM_DIR)/tb_alu

clean:
	rm -f $(SIM_DIR)/tb_alu $(SIM_DIR)/tb_alu.vcd
