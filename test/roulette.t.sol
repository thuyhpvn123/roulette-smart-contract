// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RouletteGame} from "../src/roulette.sol";

contract CounterTest is Test {
    RouletteGame public ROU;
    address public Deployer = address(0x1);
    address player1 = address(0x2);

    constructor(){
        vm.startPrank(Deployer);
        ROU = new RouletteGame();
        vm.deal(Deployer, 1 ether);
        vm.deal(player1, 1 ether);
        ROU.addEther{value:1 ether}();
        vm.stopPrank();
    }

    function test_spin() public {
        vm.startPrank(player1);
        //place bet all case of Corner bet
        uint256 amount = 2000;
        RouletteGame.BetType betType = RouletteGame.BetType.Corner;
        uint[][] memory numbersArr = getCornerBets();
        uint count = numbersArr.length;
        bytes memory bytesCodeCall;
        for(uint256 i; i<count ;i++){
            ROU.placeBet{value : amount}(betType, numbersArr[i]);
            bytesCodeCall = abi.encodeCall(
            ROU.placeBet,
            (
                betType,
                numbersArr[i]
            )
        );
        // console.log("placeBet:");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );  

        }
        console.log("bal player:",player1.balance);
        assertEq(player1.balance,1 ether - count*amount,"should be equal");
        //spin
        (uint winningNumber,uint totalWin) = ROU.spinRoulette();
        // bytesCodeCall = abi.encodeCall(
        //     ROU.spinRoulette,()
        // );
        // console.log("spinRoulette:");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );  

        console.log("winningNumber:",winningNumber);
        console.log("totalWin:",totalWin);
        assertEq(totalWin,amount*8*(100-5)/100*2,"should be equal");
        uint256 bal = ROU.balanceOf(player1);
        // bytes memory bytesCodeCall = abi.encodeCall(
        //     ROU.balanceOf,
        //     (
        //         0x1e9Cb41f602FFAF37A138667709914089e8A7595
        //     )
        // );
        // console.log("balanceOf:");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );  

        assertEq(bal,totalWin,"should be equal");
        ROU.cashOut();
        bal = ROU.balanceOf(player1);
        assertEq(bal,0,"should be equal");
        assertEq(player1.balance,1 ether - count*amount + totalWin,"should be equal");
        vm.stopPrank();

    }
     function getCornerBets() public pure returns(uint[][] memory)  {
         // We first need to count how many corner bets are possible
        uint256 cornerCount = 0;
        
        // Count valid corners
        for (uint i = 1; i <= 36; i++) {
            if (i % 3 != 0 && i <= 33) {
                cornerCount++;
            }
        }
        // uint8[] public singleCorner; // 54 possible corner bets
        uint[][] memory corners = new uint[][](cornerCount);
        uint256 index;
        // Iterate through numbers 1 to 36
        for (uint8 i = 1; i <= 36; i++) {
            uint[] memory singleCorner = new uint[](4);
            // Check if this number can form a corner bet
            if (i % 3 != 0 && i <= 33) {
                singleCorner[0] = i;         // Top-left
                singleCorner[1] = i + 1;     // Top-right
                singleCorner[2] = i + 3;     // Bottom-left
                singleCorner[3] = i + 4;     // Bottom-right
                corners[index] = singleCorner; // Add the corner to the array
                index++;
            }
        }
        return corners;

    }

}
/*Coner bet
 [1, 2, 4, 5],
  [2, 3, 5, 6],
  [4, 5, 7, 8],
  [5, 6, 8, 9],
  [7, 8, 10, 11],
  [8, 9, 11, 12],
  [10, 11, 13, 14],
  [11, 12, 14, 15],
  [13, 14, 16, 17],
  [14, 15, 17, 18],
  [16, 17, 19, 20],
  [17, 18, 20, 21],
  [19, 20, 22, 23],
  [20, 21, 23, 24],
  [22, 23, 25, 26],
  [23, 24, 26, 27],
  [25, 26, 28, 29],
  [26, 27, 29, 30],
  [28, 29, 31, 32],
  [29, 30, 32, 33],
  [31, 32, 34, 35],
  [32, 33, 35, 36]
*/