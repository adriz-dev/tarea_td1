
`timescale 1ns/1ps

module tb_verificador_legajo;
    parameter CLK_PERIOD = 20;
    reg        clk;
    reg        arst;
    reg        start;
    reg        valid;
    reg [3:0]  dato;
    wire        busy;
    wire        done;
    wire [3:0]  verificador;

    verificador_legajo uut (
        .clk(clk),
        .arst(arst),
        .start(start),
        .valid(valid),
        .dato(dato),
        .busy(busy),
        .done(done),
        .verificador(verificador)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    task cargar_legajo;
        input [3:0] digit_1;
        input [3:0] digit_2;
        input [3:0] digit_3;
        input [3:0] digit_4;
        input [3:0] digit_5;
        input [3:0] digit_6;
        input [3:0] v_esperado;

        reg [3:0] digitos [0:5];        //seis dígitos del legajoen 4 bits cada uno
        integer i;

        begin
            // Asignamos los parámetros al arreglo local
            digitos[0] = digit_1;
            digitos[1] = digit_2;
            digitos[2] = digit_3;
            digitos[3] = digit_4;
            digitos[4] = digit_5;
            digitos[5] = digit_6;
            //digitos[6] = v_esperado;       

            #(CLK_PERIOD);
            start = 1'b1;
            #(CLK_PERIOD);
            start = 1'b0;

            valid = 1'b1;
            for (i = 0; i < 6; i = i + 1) begin
                dato = digitos[i];
                @(posedge clk); 
            end
            
            valid = 1'b0;
            dato = 4'b0000;
            @(posedge done);
            #1;

            if (v_esperado === verificador) begin
                $display("[OK] Legajo: %d%d%d.%d%d%d | Esperado: %d | Obtenido: %d", digit_1, digit_2, digit_3, digit_4, digit_5, digit_6, v_esperado, verificador);
            end else begin
                $display("[Err] Legajo: %d%d%d.%d%d%d | Esperado: %d | Obtenido: %d", digit_1, digit_2, digit_3, digit_4, digit_5, digit_6, v_esperado, verificador);
            end
            #(CLK_PERIOD * 2);
        end
    endtask

    initial begin

        $dumpfile("tb_verificador_legajo.vcd");
        $dumpvars(0, tb_verificador_legajo);
        
        clk= 1'b0;
        arst = 1'b0; 
        start = 1'b0; 
        valid = 1'b0;
        dato= 4'b0000;

        #(CLK_PERIOD*2);
        arst = 1;
        #(CLK_PERIOD);
        arst = 0;
        #(CLK_PERIOD);

        // cargar_legajo(123456, 0);
        // cargar_legajo(654321, 2);
        // cargar_legajo(111111, 5);
        // cargar_legajo(100007, 0);
        // cargar_legajo(000000, 0);
        // cargar_legajo(999999, 1);        
        // cargar_legajo(160029, 1);
        cargar_legajo(1,2,3,4,5,6, 0);
        cargar_legajo(6,5,4,3,2,1, 2);
        cargar_legajo(1,1,1,1,1,1, 5);
        cargar_legajo(1,0,0,0,0,7, 0);
        cargar_legajo(0,0,0,0,0,0, 0);
        cargar_legajo(9,9,9,9,9,9, 1);
        cargar_legajo(1,6,0,0,2,9, 1);

        #(CLK_PERIOD*2);
        $display("--- Fin de Pruebas ---");
        $finish;
    end
endmodule
