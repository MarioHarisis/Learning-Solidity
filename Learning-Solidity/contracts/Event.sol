// SPDX-License-Identifier: MIT
 
 // Define la versión de Solidity que puede compilar el contrato.
 pragma solidity >=0.8.2 <0.9.0;

 contract Event {

    /* 
    EVENTS:
    Los eventos permiten registrar información en los logs de la blockchain, 
    lo que facilita la comunicación entre el contrato y el mundo exterior. 

    - NewUserRegistered: 
    Es el nombre del evento.
    Se puede invocar cuando ocurre cierta acción, como el registro de un usuario.

    - address indexed user: 
    Declara un parámetro de tipo address, que almacena una dirección de Ethereum.
    La palabra clave indexed permite que este parámetro sea filtrable cuando los logs 
    se almacenan en la blockchain.
    Puedes buscar eventos específicos por este parámetro, lo que lo hace muy útil 
    para rastrear acciones de direcciones concretas.

    - string username:
    Es otro parámetro del evento, pero en este caso no está indexado.
    Almacena el nombre de usuario en formato de cadena de texto.
    Los parámetros que no están indexados no se pueden filtrar directamente 
    cuando se buscan eventos en la blockchain.
    */
    event NewUserRegistered(address indexed user, string username);

    // definir el struct(como crear un objeto)
    struct User {
        string username;
        uint256 age;
    }

    // estructura de datos llamada mapping, que es similar a un diccionario 
    //en otros lenguajes
    mapping(address => User) public users;

    // registrar el usuario
    function registerUser(string memory _username, uint256 _age) public {

        // crear una instancia(un nuevo usuario) 
        User storage newUser = users[msg.sender];
        // asignarle los valores recibidos en params
        newUser.username = _username;
        newUser.age = _age;

        /* EMIT:
        emitimos un evento cuando queramos guardar un registro 
        en los logs de la transacción en la blockchain.

        ¿Para que sirve y cuando usarlo?
        - Cuando quieras notificar a aplicaciones externas sobre un cambio de estado.
        - Para auditoría y registro de sucesos importantes.
        - Para rastreo de transacciones o acciones clave en contratos complejos.

        ¿Cuándo NO usarlos?
        - Para datos internos irrelevantes que no necesitan ser registrados públicamente.
        - Si el contrato está diseñado para ser lo más económico posible y el registro 
        no es necesario.
        */
        emit NewUserRegistered(msg.sender, _username);

    }

 }