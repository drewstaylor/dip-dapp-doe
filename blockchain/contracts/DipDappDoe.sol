// contracts/DipDappDoe.sol
pragma solidity ^0.4.24;

import "./LibString.sol";

contract DipDappDoe {
    // DATA
    struct Game {
        uint index;   // position in openGames[]
        uint8[9] cells;  // [123 / 456 / 789] containing [0 => nobody, 1 => X, 2 => O]
        
        // 0 => not started, 1 => player 1, 2 => player 2
        // 10 => draw, 11 => player 1 wins, 12 => player 2 wins
        uint8 status;
        
        uint amount;  // amount of money each user has sent
        uint created; // timestamp

        address[2] players;
        string[2] nicks;
        uint[2] lastTransactions; // timestamp => block number
        bool[2] withdrawn;

        bytes32 creatorHash;
        uint8 guestRandomNumber;
    }
    uint32[] openGames; // list of active games' id's
    mapping(uint32 => Game) gamesData; // data containers
    uint32 lastGameIdx;

    // EVENTS

    event GameCreated(uint32 indexed gameIdx);
    event GameAccepted(uint32 indexed gameIdx);
    event GameStarted(uint32 indexed gameIdx);
    event PositionMarked(uint32 indexed gameIdx);
    event GameEnded(uint32 indexed gameIdx);

    // CALLABLE

    function getOpenGames() public view returns (uint32[]){
        return openGames;
    }

    function getGameInfo(uint32 gameIdx) public view 
    returns (uint8[9] cells, uint8 status, uint amount, string nick1, string nick2) {
        return (
            gamesData[gameIdx].cells,
            gamesData[gameIdx].status,
            gamesData[gameIdx].amount,
            gamesData[gameIdx].nicks[0],
            gamesData[gameIdx].nicks[1]
        );
    }

    function getGameTimestamps(uint32 gameIdx) public view 
    returns (uint created, uint lastTransaction1, uint lastTransaction2) {
        return (
            gamesData[gameIdx].created,
            gamesData[gameIdx].lastTransactions[0],
            gamesData[gameIdx].lastTransactions[1]
        );
    }

    function getGamePlayers(uint32 gameIdx) public view 
    returns (address player1, address player2) {
        return (
            gamesData[gameIdx].players[0],
            gamesData[gameIdx].players[1]
        );
    }

    // OPERATIONS

    function createGame(bytes32 randomNumberHash, string nick) public payable returns (uint32 gameIdx) {
        require(lastGameIdx + 1 > lastGameIdx);

        gamesData[lastGameIdx].index = openGames.length;
        gamesData[lastGameIdx].creatorHash = randomNumberHash;
        gamesData[lastGameIdx].amount = msg.value;
        gamesData[lastGameIdx].created = now;
        gamesData[lastGameIdx].nicks[0] = nick;
        gamesData[lastGameIdx].players[0] = msg.sender;
        gamesData[lastGameIdx].lastTransactions[0] = now;
        openGames.push(lastGameIdx);

        gameIdx = lastGameIdx;
        emit GameCreated(lastGameIdx);
        
        lastGameIdx++;
    }

    function acceptGame(uint32 gameIdx, uint8 randomNumber, string nick) public payable {
        require(gameIdx < lastGameIdx);
        require(gamesData[gameIdx].players[0] != 0x0);
        require(msg.value == gamesData[gameIdx].amount);
        require(gamesData[gameIdx].players[1] == 0x0);
        require(gamesData[gameIdx].status == 0);

        gamesData[gameIdx].guestRandomNumber = randomNumber;
        gamesData[gameIdx].nicks[1] = nick;
        gamesData[gameIdx].players[1] = msg.sender;
        gamesData[gameIdx].lastTransactions[1] = now;

        emit GameAccepted(gameIdx);
    }

    function confirmGame(uint32 gameIdx, uint8 revealedRandomNumber, string revealedSalt) public {
        require(gameIdx < lastGameIdx);
        require(gamesData[gameIdx].players[0] == msg.sender);
        require(gamesData[gameIdx].players[1] != 0x0);
        require(gamesData[gameIdx].status == 0);

        bytes32 computedHash = saltedHash(revealedRandomNumber, revealedSalt);
        if(computedHash != gamesData[gameIdx].creatorHash){
            gamesData[gameIdx].status = 12;
            emit GameEnded(gameIdx);
            return;
        }

        gamesData[gameIdx].lastTransactions[0] = now;

        // Define the starting player
        if((revealedRandomNumber ^ gamesData[gameIdx].guestRandomNumber) % 2 == 0){
            gamesData[gameIdx].status = 1;
            emit GameStarted(gameIdx);
        }
        else {
            gamesData[gameIdx].status = 2;
            emit GameStarted(gameIdx);
        }
    }

    function markPosition(uint32 gameIdx, uint8 cell) public {
        revert();
    }

    function withdraw(uint32 gameIdx) public {
        revert();
    }

    // PUBLIC HELPER FUNCTIONS
    function saltedHash(uint8 randomNumber, string salt) public pure returns (bytes32) {
        return LibString.saltedHash(randomNumber, salt);
    }

    // DEFAULT
    
    function () public payable {
        revert();
    }













    // mapping (address => uint) balances;

    // event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // constructor() public {
    //     balances[msg.sender] = 10000;
    // }

    // function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
    //     if (balances[msg.sender] < amount) return false;
    //     balances[msg.sender] -= amount;
    //     balances[receiver] += amount;
    //     emit Transfer(msg.sender, receiver, amount);
    //     return true;
    // }

    // function getBalanceInEth(address addr) public view returns(uint){
    //     return ConvertLib.convert(getBalance(addr),2);
    // }

    // function getBalance(address addr) public view returns(uint) {
    //     return balances[addr];
    // }
}
