
module dp_operaciones
(    
    input  wire         clk,
    input  wire         arst,
    input  wire [3:0]   dato_in,        //Dígitos q recibo del legajo
    output reg  [3:0]   verificador,    //Dígito verificador calculado 
    input  wire         ld_digit,       //señal para cargar el dígito en el dp
    input  wire         ld_acum,        //señal para operar con el acum en el dp
    input  wire         ld_clr,         //señal para borrar el acum en el dp        
    output wire         seis_digitos,   //flag que indica que se recibieron 6 dígitos dsd el dp
    output wire         acum_menor_11  //flag que indica que el acumulador es menor a 11 dsd el dp

);
/*------------------------------------------------------------------------------------------------*/
    reg [3:0] peso_actual;  
    reg [2:0] digito;    

    //Contador de dígitos (0 a 5)
    always @(posedge clk or posedge arst) begin
        if (arst | ld_clr) begin
            digito <= 3'b000;   
        end else if (ld_digit) begin
            digito <= digito + 1'b1; 
        end
    end

    //Bloque para asignar el peso correspondiente al dígito actual
    always @(*) begin
        case (digito)
            3'b000: peso_actual = 4'b0111;
            3'b001: peso_actual = 4'b0110;
            3'b010: peso_actual = 4'b0101;
            3'b011: peso_actual = 4'b0100;
            3'b100: peso_actual = 4'b0011;
            3'b101: peso_actual = 4'b0010;
            default: peso_actual = 4'b0000;
        endcase
    end

   assign seis_digitos = (digito == 3'b110) ? 1'b1 : 1'b0;

/*------------------------------------------------------------------------------------------------*/
    reg [7:0] acumulador;                   //Suma ponderada de los dígitos
    wire [7:0] producto;
    wire [7:0] acum_next;                   //Suma ponderada parcial de los dígitos

    assign producto = dato_in * peso_actual;
    assign acum_next = (!seis_digitos) ? (acumulador + producto) : (acumulador - 8'b00001011);  //Mux para decidir si acumulo o si resto 11

   //Registro para operar con el acumulador
        always @(posedge clk or posedge arst) begin
            if (arst | ld_clr)
                acumulador <= 8'b00000000;
            else if (ld_acum)                                                                   //Según este flag cargo la suma o resto
                acumulador <= acum_next;
        end
    
    //Comparador para el cálculo de resto
    assign acum_menor_11 = (acumulador < 8'b00001011) ? 1'b1 : 1'b0;

    //Registro para convierte 10 en 0, del Verificador
    always @(posedge clk or posedge arst) begin
        if (arst)
            verificador <= 4'b0000;
        else if (acum_menor_11 && seis_digitos) begin                                           //Para no interferir con el cálculo de la suma
            if (acumulador[3:0] == 4'b1010)
                verificador <= 4'b0000;
            else
                verificador <= acumulador[3:0];
        end
    end
/*------------------------------------------------------------------------------------------------*/

