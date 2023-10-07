// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    enum Choice { None, Rock, Paper, Scissors }
    
    struct Game {
        address player1;
        address player2;
        Choice choice1;
        Choice choice2;
        int8 result; // -1: Loss, 0: Draw, 1: Win
        uint256 bet; // Bet amount in wei
    }

    Game[] public games;

    function createGame() external payable {
        require(msg.value > 0, "Bet amount must be greater than zero.");
        games.push(Game(msg.sender, address(0), Choice.None, Choice.None, 0, msg.value));
    }

    function joinGame(uint256 gameId, Choice choice) external payable {
        Game storage game = games[gameId];
        require(game.player2 == address(0), "Game is full.");
        require(msg.sender != game.player1, "You cannot play against yourself.");
        require(msg.value == game.bet, "Bet amount must match the game's bet.");
        game.player2 = msg.sender;
        game.choice2 = choice;
        game.result = determineWinner(gameId);
        
        // Handle rewards and losses
        if (game.result == 1) {
            payable(game.player1).transfer(2 * game.bet); // Winner gets 2x the bet
            payable(game.player2).transfer(game.bet); // Loser loses 1x the bet
        } else if (game.result == -1) {
            payable(game.player2).transfer(2 * game.bet); // Winner gets 2x the bet
            payable(game.player1).transfer(game.bet); // Loser loses 1x the bet
        } else if (game.result == 0) {
            payable(game.player1).transfer(game.bet); // Draw, both players get their bet back
            payable(game.player2).transfer(game.bet);
        }
    }

    function determineWinner(uint256 gameId) internal view returns (int8) {
        Game storage game = games[gameId];
        if (game.choice1 == game.choice2) {
            return 0; // Draw
        } else if (
            (game.choice1 == Choice.Rock && game.choice2 == Choice.Scissors) ||
            (game.choice1 == Choice.Paper && game.choice2 == Choice.Rock) ||
            (game.choice1 == Choice.Scissors && game.choice2 == Choice.Paper)
        ) {
            return 1; // Player1 wins
        } else {
            return -1; // Player2 wins
        }
    }
}