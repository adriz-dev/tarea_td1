module verificador_legajo (
    input  wire        clk,
    input  wire        arst,
    input  wire        start,
    input  wire        valid,
    input  wire [3:0]  dato,
    output wire        busy,
    output wire        done,
    output wire [3:0]  verificador
);

    wire       seis_digitos;
    wire       acum_menor_11;
    wire       ld_acum;
    wire       ld_digit;
    wire       ld_clr;  

    //Unidad de Control
    uc_fsm u_control (
        .clk(clk),
        .arst(arst),
        .start(start),
        .valid(valid),
        .seis_digitos(seis_digitos),   //flag que indica que se recibieron 6 dígitos dsd el dp
        .acum_menor_11(acum_menor_11),  //flag que indica que el acumulador es menor a 11 dsd el dp
        .ld_acum(ld_acum),        //señal para operar con el acum en el dp
        .ld_digit(ld_digit),       //señal para cargar el dígito en el dp
        .ld_clr(ld_clr),         //señal para borrar el acum en el dp
        .busy(busy),
        .done(done)
    );

    //Camino de Datos
    dp_operaciones u_datapath (
        .clk(clk),
        .arst(arst),
        .dato_in(dato),
        .ld_acum(ld_acum),
        .ld_digit(ld_digit),
        .ld_clr(ld_clr),
        .seis_digitos(seis_digitos),
        .acum_menor_11(acum_menor_11),
        .verificador(verificador)
    );

endmodule