const Web3 = require('web3');
const MyContract = require('./build/contracts/MyContract.json');

const init = async() => {
    const web3 = new Web3('https://speedy-nodes-nyc.moralis.io/a6337466d935298f94978acf/bsc/testnet');

    const id = await web3.eth.net.getId();
    const deployedNetwork = MyContract.networks[id];

    const contract = new web3.eth.contract(
        MyContract.abi,
        deployedNetwork.address
    );

    const Result = await contract.method.GetData().call()
    console.log(Result);
}

init();