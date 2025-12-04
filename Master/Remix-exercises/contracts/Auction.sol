// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// "is" para heredar del import 
contract Auction is Ownable, Pausable, AccessControl{

    /**
    Cada rol tiene un identificador único (imposible de colisionar en práctica).
    El rol ocupa exactamente 32 bytes, que es el tipo requerido internamente por AccessControl.
    El nombre del rol ("WRITER_ROLE") es legible para humanos, pero el contrato trabaja con el hash.
    **/

    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 public constant READER_ROLE = keccak256("READER_ROLE");

    uint256 private highest_bid = 0; // la puja más alta
    address private highest_bidder; // el mayor postor
    bool private locked; // Una variable booleana interna para el semáforo del reentrancy guard.

    // mapping de fondos pendientes 
    mapping(address => uint256) public pendingReturns;

    // EVENTOS 
    event NewBid(uint256 indexed bid, address indexed by); // puja emitida
    event AuctionPaused(address indexed by); // saber quien ha pausado la subasta
    event AuctionUnpaused( address indexed by); // saber quien ha reanudado la subasta
    event Withdrawn(address indexed by, uint256 amount); // quien ha retirado y cuanto
    event AuctionEnded(address indexed by, uint256 amount); // quien ha terminado y por cuanto la subasta

    // ERRORES
    error InsuficientBidAmount(); // puja por debajo de la más alta
    error InsuficientBalance(); 
    error TransferFailed();


    constructor() Ownable(msg.sender) { // Esto le dice a Ownable que msg.sender será el owner.

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // permite: otorgar roles, revocar roles, administrar permisos | Es, literalmente, el “dueño” del sistema de roles.
        _grantRole(WRITER_ROLE, msg.sender); // podrá escribir/actualizar lo que tú definas bajo ese rol y también podrá asignar ese rol a otros, porque tiene el rol admin 

    }

    /**
         --- MODIFIERS ---
        Los modifiers en Solidity funcionan como “envoltorios” que puedes aplicar a una función 
        para ejecutar cierta lógica antes, después, o a ambos lados del cuerpo real de la función.
        - No pueden devolver valores.
        - No pueden tener variables “persistentes” como un constructor.
        - No pueden ser usados sin el _.
    **/
    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call"); // Antes de entrar en la función → exige que locked == false
        locked = true; // Activar el candado
        _; // Ejecutar la función
        locked = false; // Liberar candado
    }

    // --- CIRCUIT BREAKER ---
    function pauseAuction() external onlyOwner {
        _pause(); // proviene de Pausable
        emit AuctionPaused(msg.sender);
    }

    function unpauseAuction() external onlyOwner {
        _unpause(); // proviene de Pausable
        emit AuctionUnpaused(msg.sender);
    }

    // hacer una puja
    function placeBid() external payable whenNotPaused {

        // si la puja esta activa IF

        
        // la puja es mayor?
        if (msg.value <= highest_bid) {
            revert InsuficientBidAmount(); // puja inferior a la mayor
        }

        // Si existe un mayor postor anterior, guardar oferta
        if (highest_bidder != address(0)) {
            pendingReturns[highest_bidder] += highest_bid;
        }

        // Actualizar la puja mayor
        highest_bid = msg.value; // asignar nueva puja mayor
        highest_bidder = msg.sender;

        emit NewBid(highest_bid, highest_bidder); // emitir evento de puja mayor hecha
    }

    function withdraw(uint256 amount) external whenNotPaused{

        uint256 userBalance = pendingReturns[msg.sender];

        // comprobar que el usuario tiene la cantidad que quiere retirar
        if (userBalance < amount) {
            revert InsuficientBalance();
        }

        pendingReturns[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");

        if (!success) {
            revert TransferFailed();
        }

        emit Withdrawn(msg.sender, amount);
    }

    function endAuction() external onlyOwner nonReentrant {
        
        // Pausar la subasta
        _pause();

        if (highest_bid <= 0) {
            revert InsuficientBidAmount();
        }

        // Guardar datos del ganador y cantidad
        uint256 amount = highest_bid;
        address winner = highest_bidder;

        // Resetear variables
        highest_bid = 0;
        highest_bidder = address(0);

        // Transferir la puja ganadora al owner

        (bool success, ) = owner().call{value: highest_bid}("");

        if (!success) {
            revert TransferFailed();
        }

        emit AuctionEnded(winner, amount);
    }

}