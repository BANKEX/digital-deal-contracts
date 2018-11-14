pragma solidity ^0.4.18;

//zeppelin contracts are copied from original due to vscode solidity plugin can not define them from node_modules 
// and thus doesn't validate the rest of the file at all.
import "./zeppelin/Ownable.sol";
import "./lib/CasesLib.sol";
import "./lib/RefereesLib.sol";
import "./lib/RefereeCasesLib.sol";
import "./lib/VoteTokenLib.sol";

/*
    Read only contract for board entities
*/
contract BoardRepository is Ownable {

    using CasesLib for address;
    using RefereesLib for address;
    using RefereeCasesLib for address;
    using VoteTokenLib for address;

    address public lib;
    uint public version;

    modifier onlyRespondent(bytes32 caseId) {
        require(msg.sender == lib.getRespondent(caseId));
        _;
    }

    function BoardRepository(address storageAddress) public {
        version = 1;
        lib = storageAddress;
    }

    function setStorageAddress(address storageAddress) public onlyOwner returns(bool) {
        lib = storageAddress;
        return true; 
    }

    function getCase(bytes32 caseId)
    public view returns (
        address applicant, address respondent,
        bytes32 deal, uint amount,
        uint refereeAward,
        bytes32 title, uint8 status, uint8 canceledCode,
        bool won, bytes32 applicantDescriptionHash,
        bytes32 respondentDescriptionHash, bool isEthRefereeAward
    ){
        return lib.getCase(caseId);
    }

    function getCaseDates(bytes32 caseId)
    public view returns (
        uint date, uint votingDate, uint revealingDate, uint closeDate
    ){
        return lib.getCaseDates(caseId);
    }
    
    function getCaseReferees(bytes32 caseId) external onlyOwner view returns(address[]){
        return getRefereesByCase(caseId);
    }

    function getRefereeCount() external view returns(uint) {
        return lib.getRefereeCount();
    }

    function getRefereeVoteBalance(address referee) external view returns(uint) {
        return lib.getVotes(referee);
    }

    function getRefereeVoteBalance() external view returns(uint) {
        return lib.getVotes(msg.sender);
    }

    function getRefereesByCase(bytes32 caseId) private view returns (address[]) { 
        uint n = lib.getRefereeCountByCase(caseId);
        address[] memory referees = new address[](n);
        for (uint i = 0; i < n; i++) {
            referees[i] = lib.getRefereeByCase(caseId, i);
        }
        return referees;
    }

}