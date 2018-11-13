pragma solidity ^0.4.0;

import "../EternalStorage.sol";

library EscrowConfigLib {

    function getPaymentFee(address storageAddress) public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("escrow.config.payment.fee")));
    }

    function setPaymentFee(address storageAddress, uint8 value) public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("escrow.config.payment.fee")), value);
    }

}