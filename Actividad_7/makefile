# Cantidad de vectores por defecto

N ?= 1000

# Herramientas y banderas
CC       = gcc
GHDL     = ghdl
GHDL_OPT = --std=08

# Archivos del proyecto
C_SRC    = generador_de_vectores.c
C_EXE    = generador_de_vectores.exe
VECTORES = vectores_de_prueba.txt
TOP_TB   = codigo_top

# REGLAS DE EJECUCIÓN

all: simular

# 1. Compilar el generador en C
$(C_EXE): $(C_SRC)
	$(CC) $(C_SRC) -o $(C_EXE)

# 2. Generar el archivo de vectores usando la variable N
$(VECTORES): $(C_EXE)
	./$(C_EXE) $(N)

# 3. Analizar, elaborar y correr la simulación VHDL
simular: $(VECTORES) ALU.vhd lector.vhd comparador.vhd codigo_top.vhd
	$(GHDL) -a $(GHDL_OPT) ALU.vhd
	$(GHDL) -a $(GHDL_OPT) lector.vhd
	$(GHDL) -a $(GHDL_OPT) comparador.vhd
	$(GHDL) -a $(GHDL_OPT) codigo_top.vhd
	$(GHDL) -e $(GHDL_OPT) $(TOP_TB)
	$(GHDL) -r $(GHDL_OPT) $(TOP_TB)

# 4 VISUALIZAR CASOS CRITICOS EN GTKWAVE
prueba_casos_criticos: ALU.vhd ALU_tb.vhd
	@mkdir -p out
	$(GHDL) -a $(GHDL_OPT) ALU.vhd
	$(GHDL) -a $(GHDL_OPT) ALU_tb.vhd
	$(GHDL) -e $(GHDL_OPT) ALU_tb
	$(GHDL) -r $(GHDL_OPT) ALU_tb --wave=out/ALU_tb_criticos.ghw
	gtkwave out/ALU_tb_criticos.ghw &

# Limpiar archivos generados y temporales
clean:
	rm -f $(C_EXE) $(VECTORES) *.o *.cf *.exe