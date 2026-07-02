SRC_DIR = src
TB_DIR  = tb
SIM_DIR = sim

VLOG = iverilog
VLOG_FLAGS = -o $(SIM_DIR)/tb_alu
VVP = vvp

all: $(SIM_DIR)/tb_alu
	$(VVP) $(SIM_DIR)/tb_alu

$(SIM_DIR)/tb_alu: $(SRC_DIR)/alu.v $(TB_DIR)/tb_alu.v | $(SIM_DIR)
	$(VLOG) $(VLOG_FLAGS) $^

$(SIM_DIR):
	mkdir -p $(SIM_DIR)

clean:
	rm -rf $(SIM_DIR)

.PHONY: all clean
