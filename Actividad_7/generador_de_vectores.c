#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <inttypes.h>

// salidas de la ALU
typedef struct {
    uint32_t Y; // Resultado de 32 bits
    uint8_t  Z; // indicador booleano de cero 
} ALU_Output;


// Generador de números aleatorios de 32 bits

uint32_t rand32(void) {
    uint32_t r1 = (uint32_t)rand() & 0xFFFF;
    uint32_t r2 = (uint32_t)rand() & 0xFFFF;
    return (r1 << 16) | r2;
}

// Modelo de Referencia de la ALU de 32 Bits en C

ALU_Output evaluar_alu32(uint32_t A, uint32_t B, uint8_t sel_fn) {
    sel_fn &= 0x0F; // solo se usan los 4 bits para el selector
    uint32_t res = 0;
    
    // para 32 bits, los desplazamientos se reducen a los 5 bits menos significativos
    uint32_t shift_amount = B & 0x1F;

    switch (sel_fn) {
        // 0000: Suma (A + B)
        case 0x0:
            res = A + B;
            break;

        // 0001: Resta (A - B)
        case 0x1:
            res = A - B;
            break;

        // 001-: Desplazamiento a la Izquierda (A << B)
        case 0x2:
        case 0x3:
            res = A << shift_amount;
            break;

        // 010-: Comparación Menor Que en Complemento a 2 (Signed: A < B)
        case 0x4:
        case 0x5:
            res = ((int32_t)A < (int32_t)B) ? 1 : 0;
            break;

        // 011-: Comparación Menor Que en Binario Natural (Unsigned: A < B)
        case 0x6:
        case 0x7:
            res = (A < B) ? 1 : 0;
            break;

        // 100-: XOR bit a bit (A ^ B)
        case 0x8:
        case 0x9:
            res = A ^ B;
            break;

        // 1010: Desplazamiento a la Derecha Lógico (SRL: A >> B)
        case 0xA:
            res = A >> shift_amount;
            break;

        // 1011: Desplazamiento a la Derecha Aritmético (SRA: Mantiene el signo)
        case 0xB:
            res = (uint32_t)((int32_t)A >> shift_amount);
            break;

        // 110-: OR bit a bit (A | B)
        case 0xC:
        case 0xD:
            res = A | B;
            break;

        // 111-: AND bit a bit (A & B)
        case 0xE:
        case 0xF:
            res = A & B;
            break;

        default:
            res = 0;
            break;
    }

    ALU_Output out;
    out.Y = res;
    out.Z = (out.Y == 0) ? 1 : 0;
    return out;
}


// Programa

int main(int argc, char *argv[]) {
    int N = 1000; // Número de vectores para generar

    if (argc > 1) {
        N = atoi(argv[1]);
        if (N <= 0) N = 100;
    }

    // generacion aleatoria
    srand((unsigned int)time(NULL));

    const char *filename = "vectores_de_prueba.txt";
    FILE *file = fopen(filename, "w");

    if (file == NULL) {
        fprintf(stderr, "Error al crear el archivo %s\n", filename);
        return 1;
    }

    printf("Generando %d vectores de prueba aleatorios de 32 bits...\n", N);

    for (int i = 0; i < N; i++) {
        uint32_t A = rand32();
        uint32_t B = rand32();
        uint8_t sel_fn = (uint8_t)(rand() % 16); // 0 a 15 (4 bits)

        // Caso de borde forzado
        if (i % 20 == 0) {
            B = A;
            sel_fn = 0x1; // Forzar Resta A - A -> Y = 0, Z = 1
        }

        ALU_Output out = evaluar_alu32(A, B, sel_fn);

        // Formato de exportación al archivo de texto
        fprintf(file, "%08" PRIX32 " %08" PRIX32 " %X %08" PRIX32 " %d\n",
                A, B, sel_fn, out.Y, out.Z);
    }

    fclose(file);
    printf("Archivo '%s' generado, con %d paquetes de datos\n", filename, N);

    return 0;
}