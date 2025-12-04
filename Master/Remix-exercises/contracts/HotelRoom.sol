// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract HotelRoom is Ownable{

    Room public room;

    event RoomReserved(uint256 price, State State);

    error RoomNotAvailable();
    error InsuficientBalance();
    error FailedToSendEther();
    error FailedToRefund();

    /** 
        Llama al constructor del contrato padre Ownable
        Le pasa msg.sender como parámetro
        Ese msg.sender es la persona que hace el deploy del contrato
        Así que el deployer queda registrado como el owner
    **/
    constructor() Ownable(msg.sender) {

        // Estado inicial de la habitación: Libre
        room = Room({ price: 1 ether, state: State.libre });
    }
    
    // Enum = una lista de estados posibles (nombres) que internamente son números.
    // Estados de la habitación
    enum State {libre, ocupado}

    struct Room {
        uint256 price;
        State state;
    }

    function ReserveRoom() external payable {
        
        // comprobar si tiene saldo suficiente
        if (msg.value < room.price) {
            revert InsuficientBalance();
        }

        // comprobar si está ocupada
        if (room.state != State.libre) {
            revert RoomNotAvailable();
        }

        // poner como ocupada
        room.state = State.ocupado;

        // tranferir Ethers a owner
        (bool status, ) = owner().call{value: msg.value}("");

        // manejo de error por si falla la transacción
        if (!status) {
            revert FailedToSendEther();
        }

        // calcula si se envía un exceso de Ethers y lo devuelve 
        uint256 excess = msg.value - room.price;
        if (excess > 0) {
            (bool refund, )  = msg.sender.call{value: excess}("");

            if (!refund) {
                revert FailedToRefund();
            }
        }
        
        emit RoomReserved(room.price, room.state);

    }

    // permite marcar la habitación como disponible al owner
    function MakeRoomAvailable() external onlyOwner  {
        room.state = State.libre;
    }
    

}