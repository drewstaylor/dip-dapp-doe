// test/TestDipDappDoe.sol
pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DipDappDoe.sol";

contract TestDipDappDoe4 {
    DipDappDoe gamesInstance;
    uint public initialBalance = 1 ether;

    constructor() public {
        gamesInstance = DipDappDoe(DeployedAddresses.DipDappDoe());
    }

    function testWinnerWithdrawal() public {
        uint8[9] memory cells;
        uint8 status;
        uint amount;
        string memory nick1;
        string memory nick2;

        bytes32 hash = gamesInstance.saltedHash(100, "my salt goes here");
        uint32 gameIdx = gamesInstance.createGame.value(0.01 ether)(hash, "John");
        gamesInstance.acceptGame.value(0.01 ether)(gameIdx, 234, "Mary");
        gamesInstance.confirmGame(gameIdx, 100, "my salt goes here");

        // we are both players in this game
        gamesInstance.markPosition(gameIdx, 0); // player 1
        gamesInstance.markPosition(gameIdx, 2); // player 2
        gamesInstance.markPosition(gameIdx, 3); // player 1
        gamesInstance.markPosition(gameIdx, 4); // player 2
        gamesInstance.markPosition(gameIdx, 6); // player 1

        (cells, status, amount, nick1, nick2) = gamesInstance.getGameInfo(gameIdx);
        Assert.equal(uint(status), 11, "The game should be won by player 1");

        uint balancePre = address(this).balance;
        gamesInstance.withdraw(gameIdx);
        uint balancePost = address(this).balance;

        Assert.equal(balancePre + 0.02 ether, balancePost, "Withdrawal should have transfered 0.02 ether");
    }

    function testDrawWithdrawal() public {
        uint8[9] memory cells;
        uint8 status;
        uint amount;
        string memory nick1;
        string memory nick2;
        bool withdrawn1;
        bool withdrawn2;

        bytes32 hash = gamesInstance.saltedHash(100, "my salt goes here");
        uint32 gameIdx = gamesInstance.createGame.value(0.01 ether)(hash, "John");
        gamesInstance.acceptGame.value(0.01 ether)(gameIdx, 234, "Mary");
        gamesInstance.confirmGame(gameIdx, 100, "my salt goes here");
        
        // we are both players in this game

        gamesInstance.markPosition(gameIdx, 0); // player 1
        gamesInstance.markPosition(gameIdx, 2); // player 2
        gamesInstance.markPosition(gameIdx, 4); // player 1
        gamesInstance.markPosition(gameIdx, 8); // player 2
        gamesInstance.markPosition(gameIdx, 5); // player 1
        gamesInstance.markPosition(gameIdx, 3); // player 2
        gamesInstance.markPosition(gameIdx, 7); // player 1
        gamesInstance.markPosition(gameIdx, 1); // player 2
        gamesInstance.markPosition(gameIdx, 6); // player 1

        (cells, status, amount, nick1, nick2) = gamesInstance.getGameInfo(gameIdx);
        Assert.equal(uint(status), 10, "The game should end in draw");

        (withdrawn1, withdrawn2) = gamesInstance.getGameWithdrawals(gameIdx);
        Assert.equal(withdrawn1, false, "Player 1 should not have withdrawn any money yet");
        Assert.equal(withdrawn2, false, "Player 2 should not have withdrawn any money yet");

        uint balancePre = address(this).balance;
        gamesInstance.withdraw(gameIdx);
        uint balancePost = address(this).balance;

        Assert.equal(balancePre + 0.01 ether, balancePost, "Withdrawal should have transfered 0.01 ether");

        (withdrawn1, withdrawn2) = gamesInstance.getGameWithdrawals(gameIdx);
        Assert.equal(withdrawn1, true, "Player 1 should have withdrawn the money");
        Assert.equal(withdrawn2, false, "Player 2 should not have withdrawn any money yet");
    }

    function() public payable {}
}
