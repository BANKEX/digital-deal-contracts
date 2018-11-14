
pragma solidity ^0.4.18;

//zeppelin contracts are copied from original due to vscode solidity plugin can not define them from node_modules 
// and thus doesn't validate the rest of the file at all.
import "../zeppelin/Ownable.sol";
import "./BkxToken.sol";
import "./IBoardConfig.sol";

/**
* voteOption: 0 - applicant, 1 - respondent
*/
contract IBoard is Ownable {

    event CaseOpened(bytes32 caseId, address applicant, address respondent, bytes32 deal, uint amount, uint refereeAward, bytes32 title, string applicantDescription, uint[] dates, uint refereeCountNeed, bool isEthRefereeAward);
    event CaseCommentedByRespondent(bytes32 caseId, address respondent, string comment);
    event CaseVoting(bytes32 caseId);
    event CaseVoteCommitted(bytes32 caseId, address referee, bytes32 voteHash);
    event CaseRevealingVotes(bytes32 caseId);
    event CaseVoteRevealed(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt);
    event CaseClosed(bytes32 caseId, bool won);
    event CaseCanceled(bytes32 caseId, uint8 causeCode);

    event RefereesAssignedToCase(bytes32 caseId, address[] referees);
    event RefereeVoteBalanceChanged(address referee, uint balance);
    event RefereeAwarded(address referee, bytes32 caseId, uint award);

    address public lib;
    uint public version;
    IBoardConfig public config;
    BkxToken public bkxToken;
    address public admin;
    address public paymentHolder;

    modifier onlyOwnerOrAdmin() {
        require(msg.sender == admin || msg.sender == owner);
        _;
    }

    function withdrawEth(uint value) external;

    function withdrawBkx(uint value) external;

    function setStorageAddress(address storageAddress) external;

    function setConfigAddress(address configAddress) external;

    function setBkxToken(address tokenAddress) external;

    function setPaymentHolder(address paymentHolder) external;

    function setAdmin(address admin) external;

    function applyForReferee() external payable;

    function addVoteTokens(address referee) external;

    function openCase(address respondent, bytes32 deal, uint amount, uint refereeAward, bytes32 title, string description) external payable;

    function setRespondentDescription(bytes32 caseId, string description) external;

    function startVotingCase(bytes32 caseId) external;

    function createVoteHash(uint8 voteOption, bytes32 salt) public view returns(bytes32);

    function commitVote(bytes32 caseId, bytes32 voteHash) external;

    function verifyVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt) public view returns(bool);

    function startRevealingVotes(bytes32 caseId) external;

    function revealVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt) external;

    function revealVotes(bytes32 caseId, address[] referees, uint8[] voteOptions, bytes32[] salts) external;

    function verdict(bytes32 caseId) external;
}