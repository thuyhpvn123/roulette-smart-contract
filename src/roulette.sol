// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract RouletteGame {
    address public owner;
    uint256 public minimumBet = 1000;
    uint256 public maximumBet = 10**18;
    uint256 public houseEdge=5; // In percentage (e.g., 5%)
    mapping (address => uint256) winnings;
    uint necessaryBalance;
    uint8[] payouts;

    enum BetType { Split, Street, Corner, SixLine, Single, Trio, RedBlack, Column, Dozen, Eighteen, EvenOdd }
                //   0       1      2        3      4       5       6      7        8       9         10      
    struct Bet {
        address player;
        uint256 amount;
        BetType betType;
        uint256[] numbers;
        bool isWin;
    }
    Bet bet;
    Bet[] private bets;
    struct Spin {
        address player;
        Bet[] betsASpin;
        uint256 winningNumber;
    }
    Spin spin ;
    // mapping(address=>Spin) spinDetail;
    event BetPlaced(address indexed player, uint256 amount, BetType betType, uint256[] numbers);
    event BetResult(address indexed player, uint256 amount, bool isWin);
    /*BetTypes are as follow:
    6: RedBlack
    7: Column
    8: Dozen
    9: Eighteen
    10: EvenOdd
    Depending on the BetType, number will be:
    RedBlack: 0 for black, 1 for red
    Column: 0 for left, 1 for middle, 2 for right
    Dozen: 0 for first, 1 for second, 2 for third
    Eighteen: 0 for low, 1 for high
    EvenOdd: 0 for even, 1 for odd
    */
    constructor()payable {
        owner = msg.sender;
        payouts = [17,11,8,5,35,11,2,3,3,2,2];

    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier validBetAmount(uint256 amount) {
        require(amount >= minimumBet && amount <= maximumBet, "Invalid bet amount");
        _;
    }

    modifier validBetNumbers(BetType betType, uint256[] memory numbers) {
        require(numbers.length > 0 && numbers.length <= 6, "Invalid number of bets");
        require(numbersAreValid(betType, numbers), "Invalid bet numbers");
        _;
    }
    function addEther() payable public {
        winnings[owner]=msg.value;
    }
    // function getSpinDetail(address player) public view returns(Spin memory){
    //     return spinDetail[player];
    // }
    function balanceOf(address player) public view returns(uint){
        return winnings[player];
    }
    function sort(uint256 []  memory numbers) private pure returns(uint256 [] memory){
        require(numbers.length == 4,"not a corner bet");
        for(uint8 i=0;i<3;i++){
            if(numbers[i]>numbers[i+1]){
                uint256 temp;
                temp = numbers[i];
                numbers[i] = numbers[i+1];
                numbers[i+1] = temp;
            }
        }
        return numbers;
    }
    function numbersAreValid(BetType betType, uint256[] memory numbers) private pure returns (bool) {
        if (betType == BetType.Split) {
            return numbers.length == 2 && (numbers[0] + 1 == numbers[1] || numbers[0] - 1 == numbers[1] || numbers[0] + 3 == numbers[1] || numbers[0] - 3 == numbers[1]);
        } else if (betType == BetType.Street) {
            return numbers.length == 3 && (numbers[0] + 1 == numbers[1] && numbers[1] + 1 == numbers[2]);
        } else if (betType == BetType.Corner) {
            uint256[] memory sortedNumbers =sort(numbers);
            return sortedNumbers.length == 4 && (sortedNumbers[0] + 1 == sortedNumbers[1] && sortedNumbers[1] + 2 == sortedNumbers[2] && sortedNumbers[2] + 1 == sortedNumbers[3]);
            // return numbers.length == 4 && ((numbers[0] + 1 == numbers[1] && numbers[1] + 3 == numbers[2] && numbers[2] + 1 == numbers[3]) ||
            //                                (numbers[0] - 1 == numbers[1] && numbers[1] + 3 == numbers[2] && numbers[2] - 1 == numbers[3]) ||
            //                                (numbers[0] + 1 == numbers[1] && numbers[1] - 3 == numbers[2] && numbers[2] + 1 == numbers[3]) ||
            //                                (numbers[0] - 1 == numbers[1] && numbers[1] - 3 == numbers[2] && numbers[2] - 1 == numbers[3]));
        } else if (betType == BetType.SixLine) {
            return numbers.length == 6 && (numbers[0] + 1 == numbers[1] && numbers[1] + 1 == numbers[2] && numbers[2] + 1 == numbers[3] &&
                                           numbers[3] + 1 == numbers[4] && numbers[4] + 1 == numbers[5]);
        } else if (betType == BetType.Single) {
            return numbers.length == 1 && numbers[0] >= 0 && numbers[0] <= 36;
        } else if (betType == BetType.Trio) {
            return numbers.length == 3 && (numbers[0] == 0 && numbers[1] == 1 && numbers[2] == 2);
        } else if (betType == BetType.RedBlack) {
            return numbers.length == 1 && (numbers[0] == 0 || numbers[0] == 1 );
        } else if (betType == BetType.Column) {
            return numbers.length == 1 && (numbers[0] == 0 || numbers[0] == 1 || numbers[0] == 2);
        } else if (betType == BetType.Dozen) {
            return numbers.length == 1 && (numbers[0] == 0 || numbers[0] == 1 || numbers[0] == 2);
        } else if (betType == BetType.Eighteen) {
            return numbers.length == 1 && (numbers[0] == 0 || numbers[0] == 1);
        } else if (betType == BetType.EvenOdd) {
            return numbers.length == 1 && (numbers[0] == 0 || numbers[0] == 1 );
        } else {
            return false;
        }
    }

    function placeBet(BetType betType, uint256[] memory numbers) external payable validBetAmount(msg.value) validBetNumbers(betType, numbers) {
        uint256 payoutForThisBet = calculatePayout(betType, msg.value);

        uint provisionalBalance = necessaryBalance + payoutForThisBet;
        require(provisionalBalance < address(this).balance,"amount bet is too big");           
        necessaryBalance += payoutForThisBet;
        bet.player = msg.sender;
        bet.amount = msg.value;
        bet.betType = betType;
        bet.numbers = numbers;
        bet.isWin = false;
        bets.push(bet);
        // spin.player = msg.sender;
        // spin.betsASpin.push(bet);
        // spin.winningNumber =0;
        // spinDetail[msg.sender] =spin;       
        emit BetPlaced(msg.sender, msg.value, betType, numbers);
    }

    function spinRoulette() public returns(uint winningNumber,uint totalWin) {
        require(bets.length > 0,"need to place a bet before");
        Bet memory lb = bets[bets.length-1];
        winningNumber = uint(keccak256(abi.encodePacked(block.timestamp, lb.betType, lb.player))) % 37;
        for (uint256 i = 0; i < bets.length; i++) {
            // spinDetail[bets[i].player].winningNumber = winningNumber;
            if (betWins(bets[i].betType, bets[i].numbers, winningNumber)) {
                bets[i].isWin = true;
                uint payout = calculatePayout(bets[i].betType, bets[i].amount);
                winnings[bets[i].player] += payout;
                winnings[owner] += bets[i].amount;
                winnings[owner] -= payout;
                totalWin += payout;
                emit BetResult(bets[i].player, payout, true);
            } else {
                emit BetResult(bets[i].player, bets[i].amount, false);
                winnings[owner] += bets[i].amount;
            }
        }
        /* reset necessaryBalance */
        necessaryBalance = 0;

        delete bets;
        return (winningNumber,totalWin);
    }
    function cashOut() public {
        if(msg.sender == owner && bets.length >0){
            revert ("owner can not cashout when there still bets placed");
        }
        address player = msg.sender;
        uint256 amount = winnings[player];
        require(amount > 0);
        require(amount <= address(this).balance);
        winnings[player] = 0;
        payable(player).transfer(amount);
    }

    function calculatePayout(BetType betType, uint256 amount) private view returns (uint256) {
        if (betType == BetType.Split) {
            return amount * 17* (100 - houseEdge)/100;
        } else if (betType == BetType.Street) {
            return amount * 11* (100 - houseEdge)/100;
        } else if (betType == BetType.Corner) {
            return amount * 8* (100 - houseEdge)/100;
        } else if (betType == BetType.SixLine) {
            return amount * 5* (100 - houseEdge)/100;
        } else if (betType == BetType.Single) {
            return amount * 35* (100 - houseEdge)/100;
        } else if (betType == BetType.Trio) {
            return amount * 11* (100 - houseEdge)/100;
        } else if (betType == BetType.Column || betType == BetType.Dozen) {
            return amount * 2* (100 - houseEdge)/100;
        } else if (betType == BetType.Eighteen || betType == BetType.EvenOdd || betType == BetType.RedBlack) {
            return amount * 2* (100 - houseEdge)/100;
        }else{
            return 0;
        }
    }
        // enum BetType { Split, Street, Corner, SixLine, Single, Trio, RedBlack, Column, Dozen, Eighteen, EvenOdd }

function betWins(BetType betType, uint256[] memory numbers, uint256 winningNumber) private pure returns (bool) {
    for (uint256 i = 0; i < numbers.length; i++) {
        uint256 number = numbers[i];

        if (winningNumber == 0) {
            if (betType == BetType.Single && number == 0) {
                return true; // Winning bet on 0
            }
        } else {
            if (betType == BetType.RedBlack) {
                if (number == 0) { // Bet on black
                    if ((winningNumber <= 10 || (winningNumber >= 20 && winningNumber <= 28)) && winningNumber % 2 == 0) {
                        return true; 
                    } 
                    if (!(winningNumber <= 10 || (winningNumber >= 20 && winningNumber <= 28)) && winningNumber % 2 == 1) {
                        return true; 
                    }
                } else { // Bet on red
                    if ((winningNumber <= 10 || (winningNumber >= 20 && winningNumber <= 28)) && winningNumber % 2 == 1) {
                        return true; 
                    } 
                    if (!(winningNumber <= 10 || (winningNumber >= 20 && winningNumber <= 28)) && winningNumber % 2 == 0) {
                        return true; 
                    }
                }
            } else if (betType == BetType.EvenOdd) {
                if ((number == 0 && winningNumber % 2 == 0) || (number == 1 && winningNumber % 2 == 1)) {
                    return true;
                }
            } else if (betType == BetType.Eighteen) {
                if ((number == 0 && winningNumber <= 18) || (number == 1 && winningNumber >= 19)) {
                    return true;
                }
            } else if (betType == BetType.Dozen) {
                if ((number == 0 && winningNumber <= 12) ||
                    (number == 1 && winningNumber > 12 && winningNumber <= 24) ||
                    (number == 2 && winningNumber > 24)) {
                    return true;
                }
            } else if (betType == BetType.Column) {
                if ((number == 0 && winningNumber % 3 == 1) ||
                    (number == 1 && winningNumber % 3 == 2) ||
                    (number == 2 && winningNumber % 3 == 0)) {
                    return true;
                }
            } else {
                if (numbers[i] == winningNumber) {
                    return true;
                }
            }
        }
    }
    return false; // No winning condition met
}

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Owner functions for adjusting betting limits
    function setMinimumBet(uint256 newMinimumBet) external onlyOwner {
        minimumBet = newMinimumBet;
    }

    function setMaximumBet(uint256 newMaximumBet) external onlyOwner {
        maximumBet = newMaximumBet;
    }
        
    // function withdrawFunds() public onlyOwner {
    //     payable(msg.sender).transfer(address(this).balance);
    // }
    function setHouseEdge(uint256 newHouseEdge) external onlyOwner {
        require(newHouseEdge >= 0 && newHouseEdge <= 10, "Invalid house edge value"); // The house edge cannot exceed 10%
        houseEdge = newHouseEdge;
    }
}