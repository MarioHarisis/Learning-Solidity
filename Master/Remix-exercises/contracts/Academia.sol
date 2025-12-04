// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Academia {

    uint256 number;

    struct Estudiante {
        string nombre;
        uint8 edad;
        string carrera;
        //address cuenta; dirección del estudiante
    }

    // Lista de estudiantes
    Estudiante [] public estudiantes;


    // Agregar nuevos estudiantes
    function addEstudiante (string memory _nombre, uint8 _edad, string memory _carrera) public returns (bool){

        estudiantes.push(Estudiante(_nombre, _edad, _carrera));
        return true;
    }

    // todos los estudiantes
    function verEstudiantes() public view returns(Estudiante [] memory) {
        return estudiantes;
    }

    
}