
`timescale 1ns/1ps

module tb_verificador_legajo;
    parameter CLK_PERIOD = 20;
    reg        clk,
    reg        arst,
    reg        start,
    reg        valid,
    reg [3:0]  dato,
    wire        busy,
    wire        done,
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

        reg [3:0] digitos [0:5];        //seis dígitos en 4 bits cada uno
        integer i;

        begin
            // Asignamos los parámetros al arreglo local
            digitos[0] = digit_1;
            digitos[1] = digit_2;
            digitos[2] = digit_3;
            digitos[3] = digit_4;
            digitos[4] = digit_5;
            digitos[5] = digit_6;
        
            while (busy) @(negedge clk);

            #(CLK_PERIOD);
            start = 1'b1;
            #(CLK_PERIOD);
            start = 1'b0;

            valid = 1'b1;
            for (i = 0; i < 6; i = i + 1) begin
                dato = digitos[i];
                @(posedge clk); // Espera el flanco ascendente donde el hardware lee el dato
            end
            
            valid = 1'b0;
            dato = 4'b0000; // Limpiamos el dato después de enviar los 6 dígitos
            
            @(posedge done);
            #1;

            if (v_esperado === verificador) begin
                $display("[OK] Legajo: %0d%0d%0d.%0d%0d%0d | Esperado: %0d | Obtenido: %0d", digit_1, digit_2, digit_3, digit_4, digit_5, digit_6, v_esperado, verificador);
            end else begin
                $display("[Err] Legajo: %0d%0d%0d.%0d%0d%0d | Esperado: %0d | Obtenido: %0d", digit_1, digit_2, digit_3, digit_4, digit_5, digit_6, v_esperado, verificador);
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


// module tb_verificador_legajo;

//     // Declaro las señales que van a las entradas del módulo como reg
//     reg clk;
//     reg arst;
//     reg start;
//     reg valid;
//     reg [3:0] a;

//     // Declaro las señales que vienen de las salidas del módulo (tipo wire)
//     wire [3:0] digito; 
//     wire busy;
//     wire done;

//     // Instancio el módulo a probar
//     verificador_legajo UUT ( 
//         .clk(clk), 
//         .arst(arst),
//         .start(start),  
//         .valid(valid),
//         .dato(a), 
//         .busy(busy), 
//         .done(done), 
//         .verificador(digito)
//     ); 

//     // Genero clock invierto clk cada 10 unidades de tiempo
//     always #10 clk = ~clk; // es decir que un ciclo completo es de 20 unidades, como dice la consigna

//     initial begin
//         // Configuración para GTKWave
//         $dumpfile("tb_verificador_legajo.vcd");
//         $dumpvars(0, tb_verificador_legajo);

//         // Estado inicial de las entradas
//         clk=1'b0;
//         arst=1'b0;
//         start=1'b0;
//         valid=1'b0;
//         a=4'd0;

//         // Espera con reset activo
//         #40;
//         arst = 1'b1;
//         #20;
//         arst=1'b0;
//         start=1'b1; // Pulsp de start
//         #20;
//         start=1'b0;
//         #20;
//         valid = 1'b1; //  Dejo valid en 1 así toma todos los dígitos de una para ahorrar espacio,
//         start = 1'b0; // ya probé con pulsos de start fuera de lugar y espacios entre valid y funciona.

//         /* 
//          Quise hacer un for con registros en hexa pero esta forma de acomodarla implica pensar menos.
      
//          Realizo tres ejemplos, uno con resto 10, uno con resto 0 y otro con dígito distinto de 0.
//          Aprovecho que mi legajo es un caso de resto 10 en el que el circuito hace la selección de pasarlo a 0
        
//         */
        
//         //171.465-0 es mi legajo
//         //   1          7          1          4          6          5
//         a=4'd1;#20;a=4'd7;#20;a=4'd1;#20;a=4'd4;#20;a=4'd6;#20;a=4'd5;#20;
//         valid = 1'b0;
//         // Espero a que la FSM termine y levante ready
//         wait(done == 1'b1);
//         // Espero un instante para leer el dato estable
//         #30;

//         start=1'b1;#20;start=1'b0;#20;valid=1'b1;start=1'b0;  // Pulso de start sin reset para ver si la mde limpia los registros
        
//         //123-456-0 ejemplo 1 de la tarea
//         //   1          2          3          4          5          6
//         a=4'd1;#20;a=4'd2;#20;a=4'd3;#20;a=4'd4;#20;a=4'd5;#20;a=4'd6;#20;
//         valid = 1'b0;wait(done == 1'b1);#30;

//         start=1'b1;#20;start=1'b0;#20;valid=1'b1;start=1'b0;

//         //111.111-5 ejemplo 3 de la tarea
//         //   1          1          1          1          1          1
//         a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;a=4'd1;#20;
//         valid = 1'b0;wait(done == 1'b1);#30;

//         $finish;
//     end
// endmodule
