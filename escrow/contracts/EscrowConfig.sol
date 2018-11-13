pragma solidity ^0.4.22;

import "./zeppelin/Ownable.sol";
import "./lib/EscrowConfigLib.sol";

contract EscrowConfig is Ownable {

    using EscrowConfigLib for address;

    address public config;

    constructor(address storageAddress) public {
        config = storageAddress;
    }

    function resetValuesToDefault() external onlyOwner {
        config.setPaymentFee(2);//%
    }

    function setStorageAddress(address storageAddress) external onlyOwner {
        config = storageAddress;
    }

    function getPaymentFee() external view returns (uint8) {
        return config.getPaymentFee();
    }

    //value - % of payment amount
    function setPaymentFee(uint8 value) external onlyOwner {
        require(value >= 0 && value < 100, "Fee in % of payment amount must be >= 0 and < 100");
        config.setPaymentFee(value);
    }
}