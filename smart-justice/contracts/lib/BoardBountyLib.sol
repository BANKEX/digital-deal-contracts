pragma solidity ^0.4.0;

import "../EternalStorage.sol";

library BoardBountyLib {
    
    function isRefereeObtainedTokens(address storageAddress, address referee) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("board.bounty.referee.obtained", referee));
    }

    function setRefereeObtainedTokens(address storageAddress, address referee, bool value) public {
        EternalStorage(storageAddress).setBool(keccak256("board.bounty.referee.obtained", referee), value);
    }

}