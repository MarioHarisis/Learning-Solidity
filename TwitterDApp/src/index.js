import Web3 from "web3";
// Ahora podemos usar Web3 y MetaMask SDK
import contractABI from "./abi.json";

// esta direccion solo se obtiene despues de public el smart contract en la blockchain
// 2️⃣ Set your smart contract address 👇
const contractAddress = "0x3d2d77c836549741a312d32E27Dd536a76556851";

let web3 = new Web3(window.ethereum);
// 3️⃣ connect to the contract using web3
// HINT: https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#new-contract
/*
- web3.eth.Contract: Es el constructor de Web3.js que te permite crear una instancia de un contrato.

- contractABI: Es la interfaz ABI (Application Binary Interface) del contrato. 
  Describe las funciones, eventos y estructuras de datos del contrato.

  - contractAddress: Es la dirección real en la blockchain donde está desplegado el contrato. 
  Sin esta dirección, no se puede interactuar con el contrato.
 */
let contract = new web3.eth.Contract(contractABI, contractAddress);

// agregar el listener del evento connectWallet
document.getElementById("connectWalletBtn").addEventListener("click", connectWallet);

// conectar con la wallet del usuario
async function connectWallet() {
  // HINT: https://docs.metamask.io/wallet/tutorials/javascript-dapp-simple/#1-set-up-the-project
  if (window.ethereum) {
    // comprueba si window.ethereum está disponible en el navegador.

    //solicita a MetaMask las cuentas disponibles del usuario y almacenamos en accounts
    const accounts = await window.ethereum
      .request({ method: "eth_requestAccounts" })
      .catch((err) => {
        // Si ocurre un error al intentar obtener las cuentas, lo maneja este catch
        if (err.code === 4001) {
          // error es 4001, esto significa que el usuario ha rechazado la solicitud de conexión.
          // EIP-1193 userRejectedRequest error.
          console.log("Please connect to MetaMask.");
        } else {
          console.error(err);
        }
      });
    // si conectamos con acceso asignamos la primera cuenta que recibamos a 'account'
    const account = accounts[0];
    document.getElementById("userAddress").innerHTML = account;

    // mostrar en el DOM el address de la cuenta conectada
    setConnected(accounts[0]);
    console.log(account);
  } else {
    console.error("No web3 provider detected");
    document.getElementById("connectMessage").innerText =
      "No web3 provider detected. Please install MetaMask.";
  }
}

async function createTweet(content) {
  const accounts = await web3.eth.getAccounts();
  try {
    // 4️⃣ call the contract createTweet method in order to crete the actual TWEET
    // HINT: https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#methods-mymethod-send
    // use the "await" feature to wait for the function to finish execution
    /*
    con el objeto contract, accedemos a los métodos del contrato,
    por lo tanto usamos ccreateTweet del smartcontract, le pasamos los argumentos 
    correspondientes que hayamos definido en el mismo.

    send() es un método de Web3.js que se usa para enviar transacciones a la blockchain.
    Se está enviando la transacción para ejecutar la función createTweet en la blockchain.
    El objeto { from: accounts[0] } le indica a Web3 que la transacción será enviada desde la dirección 
    accounts[0](la primera cuenta con la que conecte)
    */
    await contract.methods.createTweet(content).send({ from: accounts[0] });
    document.getElementById("tweetContent").value = "";

    // 7️⃣ Implement displayTweets function! PRETTY EASY 🔥
    // GOAL: reload tweets after creating a new tweet
    displayTweets(accounts[0]);
  } catch (error) {
    console.error("User rejected request:", error);
  }
}

async function displayTweets(userAddress) {
  const tweetsContainer = document.getElementById("tweetsContainer");
  let tempTweets = [];
  tweetsContainer.innerHTML = "";
  // 5️⃣ call the function getAllTweets from smart contract to get all the tweets
  // HINT: https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#methods-mymethod-call
  tempTweets = await contract.methods.getAllTweets(userAddress).call();

  // we do this so we can sort the tweets by timestamp
  const tweets = [...tempTweets];
  tweets.sort((a, b) => Number(b.timestamp) - Number(a.timestamp));
  for (let i = 0; i < tweets.length; i++) {
    const tweetElement = document.createElement("div");
    tweetElement.className = "tweet";

    const userIcon = document.createElement("img");
    userIcon.className = "user-icon";
    userIcon.src = "./images/user.png";
    userIcon.alt = "User Icon";

    tweetElement.appendChild(userIcon);

    const tweetInner = document.createElement("div");
    tweetInner.className = "tweet-inner";

    tweetInner.innerHTML += `
        <div class="author">${shortAddress(tweets[i].author)}</div>
        <div class="content">${tweets[i].content}</div>
    `;

    const likeButton = document.createElement("button");
    likeButton.className = "like-button";
    likeButton.innerHTML = `
        <i class="far fa-heart"></i>
        <span class="likes-count">${tweets[i].likes}</span>
    `;
    likeButton.setAttribute("data-id", tweets[i].id);
    likeButton.setAttribute("data-author", tweets[i].author);

    addLikeButtonListener(likeButton, userAddress, tweets[i].id, tweets[i].author);
    tweetInner.appendChild(likeButton);
    tweetElement.appendChild(tweetInner);

    tweetsContainer.appendChild(tweetElement);
  }
}

function addLikeButtonListener(likeButton, address, id, author) {
  likeButton.addEventListener("click", async (e) => {
    e.preventDefault();

    e.currentTarget.innerHTML = '<div class="spinner"></div>';
    e.currentTarget.disabled = true;
    try {
      await likeTweet(author, id);
      displayTweets(address);
    } catch (error) {
      console.error("Error liking tweet:", error);
    }
  });
}

function shortAddress(address, startLength = 6, endLength = 4) {
  return `${address.slice(0, startLength)}...${address.slice(-endLength)}`;
}

async function likeTweet(author, id) {
  // obtener la cuenta desde donde damos like
  const accounts = await web3.eth.getAccounts();
  try {
    // 8️⃣ call the likeTweet function from smart contract
    // INPUT: author and id
    // GOAL: Save the like in the smart contract
    // HINT: don't forget to use await 😉 👇
    await contract.methods.likeTweet(author, id).send({ from: accounts[0] });
  } catch (error) {
    console.error("User rejected request:", error);
  }
}

function setConnected(address) {
  document.getElementById("userAddress").innerText =
    "Connected: " + shortAddress(address);
  document.getElementById("connectMessage").style.display = "none";
  document.getElementById("tweetForm").style.display = "block";

  // 6️⃣ Call the displayTweets function with address as input
  // This is the function in the javascript code, not smart contract 😉
  // GOAL: display all tweets after connecting to metamask
  displayTweets(address);
}

document.getElementById("connectWalletBtn").addEventListener("click", connectWallet);

document.getElementById("tweetForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const content = document.getElementById("tweetContent").value;
  const tweetSubmitButton = document.getElementById("tweetSubmitBtn");
  tweetSubmitButton.innerHTML = '<div class="spinner"></div>';
  tweetSubmitButton.disabled = true;
  try {
    await createTweet(content);
  } catch (error) {
    console.error("Error sending tweet:", error);
  } finally {
    // Restore the original button text
    tweetSubmitButton.innerHTML = "Tweet";
    tweetSubmitButton.disabled = false;
  }
});
