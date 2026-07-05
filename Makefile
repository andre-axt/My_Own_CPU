SRCDIR = src
TBDIR  = tb
SIMDIR = sim

MODULES = alu memory program_counter registers

TB_EXES = $(addprefix $(SIMDIR)/tb_, $(MODULES))

all: $(TB_EXES)

# Rule to build a testbench executable
# $@ = sim/tb_<module>, $^ = src/<module>.v + tb/tb_<module>.v
$(SIMDIR)/tb_%: $(SRCDIR)/%.v $(TBDIR)/tb_%.v
	@mkdir -p $(SIMDIR)
	iverilog -o $@ $^

# Run a single testbench (e.g., make run-alu)
run-%: $(SIMDIR)/tb_%
	cd $(SIMDIR) && ./tb_$*

# Run all testbenches
run-all: $(TB_EXES)
	@for exe in $(TB_EXES); do \
		echo "Running $$(basename $$exe) ..."; \
		(cd $(SIMDIR) && ./$$(basename $$exe)); \
	done

# Clean up: remove the entire sim directory
clean:
	rm -rf $(SIMDIR)

.PHONY: all clean run-all
