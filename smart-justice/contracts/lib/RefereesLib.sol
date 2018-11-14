pragma solidity ^0.4.24;

import "../EternalStorage.sol";
import "./VoteTokenLib.sol";
import "./Utils.sol";

library RefereesLib {

    struct Referees {
        address[] addresses;
    }

    function addReferee(address storageAddress, address referee) public {
        uint id = getRefereeCount(storageAddress);
        setReferee(storageAddress, referee, id, true);
        setRefereeCount(storageAddress, id + 1);
    }

    function getRefereeCount(address storageAddress) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("referee.count"));
    }

    function setRefereeCount(address storageAddress, uint value) public {
        EternalStorage(storageAddress).setUint(keccak256("referee.count"), value);
    }

    function setReferee(address storageAddress, address referee, uint id, bool applied) public {
        EternalStorage st = EternalStorage(storageAddress);
        st.setBool(keccak256("referee.applied", referee), applied);
        st.setAddress(keccak256("referee.address", id), referee);
    }

    function isRefereeApplied(address storageAddress, address referee) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("referee.applied", referee));
    }

    function setRefereeApplied(address storageAddress, address referee, bool applied) public {
        EternalStorage(storageAddress).setBool(keccak256("referee.applied", referee), applied);
    }

    function getRefereeAddress(address storageAddress, uint id) public view returns(address) {
        return EternalStorage(storageAddress).getAddress(keccak256("referee.address", id));
    }
    
    function getRandomRefereesToCase(address storageAddress, address applicant, address respondent, uint256 targetCount) 
    public view returns(address[] foundReferees)  {
        uint refereesCount = getRefereeCount(storageAddress);
        require(refereesCount >= targetCount);
        foundReferees = new address[](targetCount);
        uint id = Utils.almostRnd(0, refereesCount);
        uint found = 0;
        for (uint i = 0; i < refereesCount; i++) {
            address referee = getRefereeAddress(storageAddress, id);
            id = id + 1;
            id = id % refereesCount;
            uint voteBalance = VoteTokenLib.getVotes(storageAddress, referee);
            if (referee != applicant && referee != respondent && voteBalance > 0) {
                foundReferees[found] = referee;
                found++;
            }
            if (found == targetCount) {
                break;
            }
        }
        require(found == targetCount);
    }
}