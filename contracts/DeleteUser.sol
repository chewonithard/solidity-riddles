pragma solidity 0.8.15;

/**
 * This contract starts with 1 ether.
 * Your goal is to steal all the ether in the contract.
 *
 */

 import "hardhat/console.sol";

contract DeleteUser {
    struct User {
        address addr;
        uint256 amount;
    }

    User[] public users;

    function deposit() external payable {
        users.push(User({addr: msg.sender, amount: msg.value}));
    }

    function withdraw(uint256 index) external {
        User storage user = users[index];
        require(user.addr == msg.sender);
        uint256 amount = user.amount;

        // @solution: should have done this instead:
        // users[index] = users[users.length - 1];
        user = users[users.length - 1];
        users.pop();

        msg.sender.call{value: amount}("");
    }
}
