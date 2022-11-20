async function signMessage() {
    if (!window.ethereum) return alert("Please Install Metamask");

    // connect and get metamask account
    const accounts = await ethereum.request({ method: "eth_requestAccounts" });

    // message to sign
    const message = "hello";
    console.log({ message });

    // hash message
    const hashedMessage = Web3.utils.sha3(message);
    console.log({ hashedMessage });

    // sign hashed message
    const signature = await ethereum.request({
        method: "personal_sign",
        params: [hashedMessage, accounts[0]],
    });
    console.log({ signature });

    // split signature
    const r = signature.slice(0, 66);
    const s = "0x" + signature.slice(66, 130);
    const v = parseInt(signature.slice(130, 132), 16);
    console.log({ r, s, v });
}