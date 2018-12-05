pragma solidity ^0.4.22;

import "../EternalStorage.sol";

library FeeLib {

    function getTotalFee(address storageAddress, address token)
    public view returns(uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.fee.total", token)));
    }

    function setTotalFee(address storageAddress, uint256 value, address token)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.fee.total", token)), value);
    }

    function addFee(address storageAddress, uint256 value, address token)
    public {
        uint256 newTotalFee = getTotalFee(storageAddress, token) + value;
        setTotalFee(storageAddress, newTotalFee, token);
    }

    
}