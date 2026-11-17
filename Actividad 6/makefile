
# MAKEFILE - CONTROLADOR DE SEMÁFORO

GHDL     = ghdl
GHDL_OPT = --std=08

# Archivos fuente del semáforo ordenados por jerarquía
FILES = cruce_peaton.vhd \
        preescaler.vhd \
        temporizador.vhd \
        control_sem.vhd \
        semaforo.vhd \
        semaforo_tb.vhd

TOP_TB = semaforo_tb

all: wave

compilar: $(FILES)
	@mkdir -p out
	for f in $(FILES); do \
		$(GHDL) -a $(GHDL_OPT) $$f; \
	done
	$(GHDL) -e $(GHDL_OPT) $(TOP_TB)

# 2. Ejecutar la simulación y abrir GTKWave automáticamente
wave: compilar
	$(GHDL) -r $(GHDL_OPT) $(TOP_TB) --wave=out/semaforo_tb.ghw
	gtkwave out/semaforo_tb.ghw &

# 3. Limpiar todos los archivos temporales, binarios y ejecutables
clean:
	rm -f *.o *.cf *.exe out/*.ghw
	rm -rf out