pragma solidity ^0.4.18;

import "./EIP20.sol";

contract BkxToken is EIP20 {
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function decreaseApproval (address _spender, uint _subtractedValue)public returns (bool success);
}