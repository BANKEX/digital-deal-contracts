pragma solidity ^0.4.18;

import "./../EternalStorage.sol";

library VoteTokenLib  {

    function getVotes(address storageAddress, address account) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("vote.token.balance", account));
    }

    function increaseVotes(address storageAddress, address account, uint256 diff) public {
        setVotes(storageAddress, account, getVotes(storageAddress, account) + diff);
    }

    function decreaseVotes(address storageAddress, address account, uint256 diff) public {
        setVotes(storageAddress, account, getVotes(storageAddress, account) - diff);
    }

    function setVotes(address storageAddress, address account, uint256 value) public {
        EternalStorage(storageAddress).setUint(keccak256("vote.token.balance", account), value);
    }

}