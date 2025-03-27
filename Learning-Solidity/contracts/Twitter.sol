// SPDX-License-Identifier: MIT
 
 // Define la versión de Solidity que puede compilar el contrato.
 pragma solidity >=0.8.2 <0.9.0;

 contract Twitter {

    // definir el struct
    struct Tweet {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    // estructura de datos llamada mapping, que es similar a un diccionario 
    //en otros lenguajes
    mapping (address => Tweet[] ) public tweets;

    // Se usa memory porque es un tipo de dato dinámico 
    // (no puede almacenarse directamente en la Blockchain sin especificar storage o memory).
    function createTweet( string memory _tweet) public {
        /* 
        CODIGO ANTERIOR
        msg.sender: Se refiere a la dirección de la cuenta que llama a la función. 
        Es decir, el usuario que interactúa con el contrato. 

        tweets[msg.sender] = _tweet;: Guarda el tweet en el mapping, 
        asociando el mensaje con la dirección del usuario.
        */

        // instanciar un Tweet
        Tweet memory newTweet = Tweet({
            author:msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        // añadir el tweet al array en la posicion del owner address
        tweets[msg.sender].push(newTweet);
    }

    // recuperar un tweet específico los de un address
    function getTweet(address _owner, uint _i) public view returns (Tweet memory){
        return tweets[_owner][_i];
    }

    // recuperar todos los tweets de un address
    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }
 }