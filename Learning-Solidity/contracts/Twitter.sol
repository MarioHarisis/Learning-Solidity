// SPDX-License-Identifier: MIT
 
 // Define la versión de Solidity que puede compilar el contrato.
 pragma solidity >=0.8.2 <0.9.0;

 contract Twitter {

    uint16 constant MAX_tWEET_LENGTH = 280;

    // definir el struct(como crear un objeto)
    struct Tweet {
        uint256 id;
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

        require(bytes(_tweet).length <= MAX_tWEET_LENGTH, "Tweet is too long");

        // instanciar un Tweet
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length ,
            author:msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        // añadir el tweet al array en la posicion del owner address
        tweets[msg.sender].push(newTweet);
    }

    // añadir likes a los tweet
    function likeTweet(address author, uint256 id) external {

        // comprobar si el tweet existe antes de agregar el like
        require(tweets[author][id].id == id, "El tweet no existe");
        tweets[author][id].likes++; // sumar un like al tweet
    }

    // quitar likes de los tweet
    function unLikeTweet(address author, uint256 id) external {
        // comprobar si el tweet existe antes de quitar el like
        require(tweets[author][id].id == id, "Este tweet no existe");

        // comprobar que el tweet no tenga 0 likes
        require(tweets[author][id].likes > 0, "Este tweet no tiene likes");

        tweets[author][id].likes--; // quitar like al tweet
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