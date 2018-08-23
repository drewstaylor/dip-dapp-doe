const fs = require("fs")
const path = require("path")
const Web3 = require("web3")
const HDWalletProvider = require("truffle-hdwallet-provider")

const { PROVIDER_URI, WALLET_MNEMONIC } = require("../env.json")
const provider = new HDWalletProvider(WALLET_MNEMONIC, PROVIDER_URI)
const web3 = new Web3(provider)

async function startGame() {
    const accounts = await web3.eth.getAccounts()

    const dipDappDoeAbi = fs.readFileSync(path.resolve(__dirname, "..", "build", "__contracts_DipDappDoe_sol_DipDappDoe.abi")).toString()

    try {
        const dipDappDoeInstance = new web3.eth.Contract(JSON.parse(dipDappDoeAbi), "0xfCF380b4D6Addd35c53d14DF17D4e75d8f58feE5")

        const hash = await dipDappDoeInstance.methods.saltedHash(100, "initial salt").call()
        const tx = await dipDappDoeInstance.methods.createGame(hash, "James").send({ from: accounts[0], value: web3.utils.toWei("0.001", "ether") })
        const gameIdx = tx.events.GameCreated.returnValues.gameIdx
        console.log("GAME CREATED", gameIdx)
        console.log(await dipDappDoeInstance.methods.getGameInfo(gameIdx).call())
    }
    catch (err) {
        console.error("\nUnable to deploy:", err.message, "\n")
        process.exit(1)
    }
    process.exit()
}

startGame()
