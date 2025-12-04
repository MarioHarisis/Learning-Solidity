// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Banco {

    mapping(address => uint256) public saldos;

    // Evento para registrar depósitos
    event Depositado(address indexed usuario, uint256 monto);

    // agregar saldo
    function deposit(uint256 _cantidad) public returns (bool){

        saldos[msg.sender] += _cantidad;
        
        if (_cantidad <= 0){
            return false;
        }
        return true;
    }

        // Función para depositar Ether
    function deposit() external payable {
        // 1️⃣ Validar que envíe más de 0 Ether
        require(msg.value > 0, "Debes enviar mas de 0 Ether");

        // 2️⃣ Incrementar el saldo interno
        saldos[msg.sender] += msg.value;

        // 3️⃣ Emitir evento
        emit Depositado(msg.sender, msg.value);
    }

    /* function withdraw() public {
        require(msg.value)
    } */

        // Consultar saldo interno de un usuario
    function miSaldo() external view returns (uint256) {
        return saldos[msg.sender];
    }
} 
