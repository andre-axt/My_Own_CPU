SRCDIR = src
TBDIR  = tb
SIMDIR = sim

MODULES = alu memory program_counter registers control_unit cpu system

SRC_FILES = $(wildcard $(SRCDIR)/*.v)
TB_EXES   = $(addprefix $(SIMDIR)/tb_, $(MODULES))

all: $(TB_EXES)

$(SIMDIR)/tb_%: $(SRC_FILES) $(TBDIR)/tb_%.v
	@mkdir -p $(SIMDIR)
	iverilog -o $@ $(SRC_FILES) $(TBDIR)/tb_$*.v

run-%: $(SIMDIR)/tb_%
	cd $(SIMDIR) && ./tb_$*

run-all: $(TB_EXES)
	@for exe in $(TB_EXES); do \
		echo "Running $$(basename $$exe) ..."; \
		(cd $(SIMDIR) && ./$$(basename $$exe)); \
	done

clean:
	rm -rf $(SIMDIR)

.PHONY: all clean run-all
