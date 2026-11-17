
module uc_fsm 
(    
    input  wire         clk,
    input  wire         arst,
    input  wire         start,
    input  wire         valid,
    input  wire         seis_digitos,   //flag que indica que se recibieron 6 dígitos dsd el dp
    input  wire         acum_menor_11,  //flag que indica que el acumulador es menor a 11 dsd el dp
    output reg          ld_acum,        //señal para operar con el acum en el dp
    output reg          ld_digit,       //señal para cargar el dígito en el dp
    output reg          ld_clr,         //señal para borrar el acum en el dp
    output reg          busy,
    output reg          done

);
    //Defino constantes con los estados
    parameter[1:0]      S_IDLE = 2'b00,
                        S_READ = 2'b01,
                        S_WORK = 2'b10,
                        S_DONE = 2'b11;

    reg [1:0]  estado_actual, estado_futuro;

    //Bloque secuencial FF con reset asincrónico
    always @(posedge clk or posedge arst) begin
        if (arst) begin
            estado_actual <= S_IDLE;
        end else begin
            estado_actual <= estado_futuro;
        end
    end

    //Lógica de estado futuro (combinacional)
    always @(*) begin
        busy    = 1'b0;
        done    = 1'b0;
        ld_acum = 1'b0;     
        ld_digit = 1'b0;   
        ld_clr = 1'b0;
        case (estado_actual)
            S_IDLE: begin
                if(start) begin
                    estado_futuro = S_READ;
                    ld_clr = 1'b1;      //orden para inicializar el acum en cero
                end else begin
                    estado_futuro = S_IDLE;
                    busy    = 1'b0;
                end
            end
            S_READ: begin
                busy = 1'b1;
                if(valid) begin    
                    ld_digit = 1'b1;
                    ld_acum = 1'b1;             //acumulo sumas
                end   
                if (seis_digitos) begin
                    estado_futuro = S_WORK;
                end               
            end
            S_WORK: begin  
                busy = 1'b1;  
                if(acum_menor_11) begin 
                    estado_futuro = S_DONE;
                    ld_acum = 1'b0;             //ya no resto más
                end else  begin
                    estado_futuro = S_WORK;                   
                    ld_acum = 1'b1;             //repito restas
                end
            end
            S_DONE: begin                
                busy    = 1'b0;
                done    = 1'b1;
                estado_futuro = S_IDLE;
            end
            default: begin
                estado_futuro = S_IDLE;
            end
        endcase
    end
endmodule
