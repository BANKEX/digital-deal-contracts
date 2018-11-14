pragma solidity ^0.4.24;

import "./../EternalStorage.sol";

library RefereeCasesLib {

    function setRefereesToCase(address storageAddress, address[] referees, bytes32 caseId) public {
        for (uint i = 0; i < referees.length; i++) {
            setRefereeToCase(storageAddress, referees[i], caseId, i);
        }
        setRefereeCountForCase(storageAddress, caseId, referees.length);
    }

    function isRefereeVoted(address storageAddress, address referee, bytes32 caseId) public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256("case.referees.voted", caseId, referee));
    }

    function setRefereeVote(address storageAddress, bytes32 caseId, address referee, bool forApplicant) public {
        uint index = getRefereeVotesFor(storageAddress, caseId, forApplicant);
        EternalStorage(storageAddress).setAddress(keccak256("case.referees.vote", caseId, forApplicant, index), referee);
        setRefereeVotesFor(storageAddress, caseId,  forApplicant, index + 1);
    }

    function getRefereeVoteForByIndex(address storageAddress, bytes32 caseId, bool forApplicant, uint index) public view returns (address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.referees.vote", caseId, forApplicant, index));
    }

    function getRefereeVotesFor(address storageAddress, bytes32 caseId, bool forApplicant) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referees.votes.count", caseId, forApplicant));
    }

    function setRefereeVotesFor(address storageAddress, bytes32 caseId, bool forApplicant, uint votes) public {
        EternalStorage(storageAddress).setUint(keccak256("case.referees.votes.count", caseId, forApplicant), votes);
    }

    function getRefereeCountByCase(address storageAddress, bytes32 caseId) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referees.count", caseId));
    }

    function setRefereeCountForCase(address storageAddress, bytes32 caseId, uint value) public {
        EternalStorage(storageAddress).setUint(keccak256("case.referees.count", caseId), value);
    }

    function getRefereeByCase(address storageAddress, bytes32 caseId, uint index) public view returns (address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.referees", caseId, index));
    }

    function isRefereeSetToCase(address storageAddress, address referee, bytes32 caseId) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("case.referees", caseId, referee));
    }
    
    function setRefereeToCase(address storageAddress, address referee, bytes32 caseId, uint index) public {
        EternalStorage st = EternalStorage(storageAddress);
        st.setAddress(keccak256("case.referees", caseId, index), referee);
        st.setBool(keccak256("case.referees", caseId, referee), true);
    }

    function getRefereeVoteHash(address storageAddress, bytes32 caseId, address referee) public view returns (bytes32) {
        return EternalStorage(storageAddress).getBytes32(keccak256("case.referees.vote.hash", caseId, referee));
    }

    function setRefereeVoteHash(address storageAddress, bytes32 caseId, address referee, bytes32 voteHash) public {
        uint caseCount = getRefereeVoteHashCount(storageAddress, caseId);
        EternalStorage(storageAddress).setBool(keccak256("case.referees.voted", caseId, referee), true);
        EternalStorage(storageAddress).setBytes32(keccak256("case.referees.vote.hash", caseId, referee), voteHash);
        EternalStorage(storageAddress).setUint(keccak256("case.referees.vote.hash.count", caseId), caseCount + 1);
    }

    function getRefereeVoteHashCount(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referees.vote.hash.count", caseId));
    }

    function getRefereesFor(address storageAddress, bytes32 caseId, bool forApplicant)
    public view returns(address[]) {
        uint n = getRefereeVotesFor(storageAddress, caseId, forApplicant);
        address[] memory referees = new address[](n);
        for (uint i = 0; i < n; i++) {
            referees[i] = getRefereeVoteForByIndex(storageAddress, caseId, forApplicant, i);
        }
        return referees;
    }

    function getRefereesByCase(address storageAddress, bytes32 caseId)
    public view returns (address[]) {
        uint n = getRefereeCountByCase(storageAddress, caseId);
        address[] memory referees = new address[](n);
        for (uint i = 0; i < n; i++) {
            referees[i] = getRefereeByCase(storageAddress, caseId, i);
        }
        return referees;
    }

}