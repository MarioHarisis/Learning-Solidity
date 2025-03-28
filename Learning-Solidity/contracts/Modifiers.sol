// SPDX-License-Identifier: MIT
 
 // Define la versión de Solidity que puede compilar el contrato.
 pragma solidity >=0.8.2 <0.9.0;

 contract PausableToken {

    address public owner; // La dirección que despliega el contrato se establece como el propietario
    bool public paused;
    mapping (address => uint) public balances;

    constructor() {
        owner = msg.sender;
        paused = false;
        balances[owner] = 1000;
    }

    /*
    modifier es una especie de "decorador" que se utiliza para agregar restricciones 
    o reglas adicionales a las funciones del contrato, sin necesidad de repetir 
    el mismo código dentro de cada función. 
    
    Los modifiers se definen una vez y luego se aplican a las funciones a 
    las que se quiere agregar la lógica del modifier.

    EJEMPLO:

    modifier modifierName() {
    // Lógica a ejecutar antes de la función
    _;
    // Lógica a ejecutar después de la función (opcional)
    }

    - La palabra clave _; es un marcador de posición que representa la ejecución de la función 
    a la que el modifier se aplica.
    */

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier notPaused() {
        require(paused == false, "The contract is paused");
        _;
    }

    // permite SOLO al propietario pausar el contrato meidante el modifier onlyOwner
    function pause() public onlyOwner {
        paused = true;
    }

    // permite SOLO al propietario reanudar el contrato meidante el modifier onlyOwner
    function unpause() public onlyOwner {
        paused = false;
    }

    // permite que se ejecute la funcion transfer, SOLO cuando se cumple el modifier notPaused
    function transfer(address to, uint amount) public notPaused{
        // comprobar que el emisor no es el mismo que el receptor
        require(msg.sender != to, "You cant transact with yourself");
        require(balances[msg.sender] >= amount, "Insuficient balance");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
 }