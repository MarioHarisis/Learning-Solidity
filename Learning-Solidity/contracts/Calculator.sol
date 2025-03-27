// SPDX-License-Identifier: MIT
 
 // Define la versión de Solidity que puede compilar el contrato.
 pragma solidity >=0.8.2 <0.9.0;
 
 contract Calculator {
 
     uint256 result = 0;
 
     function add(uint256 num) public{
         result += num;
     }
 
     function subtract(uint256 num) public {
         result -= num;
     }
 
     function multiply(uint256 num) public {
         result *= num;
     }
 
     /*
     view → 
     
     - Se usa en funciones que solo leen datos y no los modifican.
 
     - No consume gas si se llama externamente (ejemplo: desde un frontend).
 
     - Si se usa en una transacción, sigue consumiendo gas porque se ejecuta
         en un nodo de la blockchain.
     */ 
     function getResult() public view returns (uint256) {
         return result;
     }
 }