pragma solidity ^0.4.18;

import "../zeppelin/Ownable.sol";
import "../interface/Token.sol";

contract Withdrawable is Ownable {
    function withdrawEth(uint value) external onlyOwner {
        require(address(this).balance >= value);
        msg.sender.transfer(value);
    }

    function withdrawToken(address token, uint value) external onlyOwner {
        require(Token(token).balanceOf(address(this)) >= value, "Not enough tokens");
        require(Token(token).transfer(msg.sender, value));
    }
}
