
pragma solidity ^0.4.24;

//zeppelin contracts are copied from original due to vscode solidity plugin can not define them from node_modules
// and thus doesn't validate the rest of the file at all.
import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";
import "./lib/VoteTokenLib.sol";
import "./lib/CasesLib.sol";
import "./lib/RefereesLib.sol";
import "./lib/RefereeCasesLib.sol";
import "./interface/BkxToken.sol";
import "./interface/IBoard.sol";
import "./interface/IBoardConfig.sol";
import "./PaymentHolder.sol";


/*
    This is hard.
    This is solidity.
    Fuck off readability.
    And estimate your GAS availability.
*/
/*
    voteOption: 0 - respondent, 1 - applicant
*/
contract Board is IBoard {

    using SafeMath for uint;
    using VoteTokenLib for address;
    using CasesLib for address;
    using RefereesLib for address;
    using RefereeCasesLib for address;

    modifier onlyRespondent(bytes32 caseId) {
        require(msg.sender == lib.getRespondent(caseId));
        _;
    }

    modifier hasStatus(bytes32 caseId, CasesLib.CaseStatus state) {
        require(state == lib.getCaseStatus(caseId));
        _;
    }

    modifier before(uint date) {
        require(now <= date);
        _;
    }

    modifier laterOn(uint date) {
        require(now >= date);
        _;
    }

    function Board(address storageAddress, address configAddress, address _paymentHolder) public {
        version = 2;
        config = IBoardConfig(configAddress);
        lib = storageAddress;
        //check real BKX address https://etherscan.io/token/0x45245bc59219eeaAF6cD3f382e078A461FF9De7B
        bkxToken = BkxToken(0x45245bc59219eeaAF6cD3f382e078A461FF9De7B);
        admin = 0xE0b6C095D722961C2C11E55b97fCd0C8bd7a1cD2;
        paymentHolder = _paymentHolder;
    }

    function withdrawEth(uint value) external onlyOwner {
        require(address(this).balance >= value);
        msg.sender.transfer(value);
    }

    function withdrawBkx(uint value) external onlyOwner {
        require(bkxToken.balanceOf(address(this)) >= value);
        require(bkxToken.transfer(msg.sender, value));
    }

    /* configuration */
    function setStorageAddress(address storageAddress) external onlyOwner {
        lib = storageAddress;
    }

    function setConfigAddress(address configAddress) external onlyOwner {
        config = IBoardConfig(configAddress);
    }

    /* dependency tokens */
    function setBkxToken(address tokenAddress) external onlyOwner {
        bkxToken = BkxToken(tokenAddress);
    }

    function setPaymentHolder(address _paymentHolder) external onlyOwner {
        paymentHolder = _paymentHolder;
    }

    function setAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
    }

    function applyForReferee() external payable {
        uint refereeFee = msg.value == 0 ? config.getRefereeFee() : config.getRefereeFeeEth();
        withdrawPayment(refereeFee);
        addVotes(msg.sender);
    }

    function addVoteTokens(address referee) external onlyOwnerOrAdmin {
        addVotes(referee);
    }

    function addVotes(address referee) private {
        uint refereeTokens = config.getVoteTokensPerRequest();
        if (!lib.isRefereeApplied(referee)) {
            lib.addReferee(referee);
        }
        uint balance = refereeTokens.add(lib.getVotes(referee));
        lib.setVotes(referee, balance);
        emit RefereeVoteBalanceChanged(referee, balance);
    }

    function openCase(address respondent, bytes32 deal, uint amount, uint refereeAward, bytes32 title, string description)
    external payable {
        require(msg.sender != respondent);
        withdrawPayment(refereeAward);
        uint[] memory dates = config.getCaseDatesFromNow();
        uint refereeCountNeed = config.getRefereeNeedCountPerCase();
        bytes32 caseId = lib.addCase(msg.sender, respondent, deal, amount, refereeAward, title, description, dates, refereeCountNeed, msg.value != 0);
        emit CaseOpened(caseId, msg.sender, respondent, deal, amount, refereeAward, title, description, dates, refereeCountNeed, msg.value != 0);
        assignRefereesToCase(caseId, msg.sender, respondent);
    }

    function withdrawPayment(uint256 amount) private {
        if(msg.value != 0) {
            require(msg.value == amount, "ETH amount must be equal amount");
            require(PaymentHolder(paymentHolder).depositEth.value(msg.value)());
        } else {
            require(bkxToken.allowance(msg.sender, address(this)) >= amount);
            require(bkxToken.balanceOf(msg.sender) >= amount);
            require(bkxToken.transferFrom(msg.sender, paymentHolder, amount));
        }
    }

    function assignRefereesToCase(bytes32 caseId, address applicant, address respondent) private  {
        uint targetCount = config.getRefereeCountPerCase();
        address[] memory foundReferees = lib.getRandomRefereesToCase(applicant, respondent, targetCount);
        for (uint i = 0; i < foundReferees.length; i++) {
            address referee = foundReferees[i];
            uint voteBalance = lib.getVotes(referee);
            voteBalance -= 1;
            lib.setVotes(referee, voteBalance);
            emit RefereeVoteBalanceChanged(referee, voteBalance);
        }
        lib.setRefereesToCase(foundReferees, caseId);
        emit RefereesAssignedToCase(caseId, foundReferees);
    }

    function setRespondentDescription(bytes32 caseId, string description)
    external onlyRespondent(caseId) hasStatus(caseId, CasesLib.CaseStatus.OPENED) before(lib.getVotingDate(caseId)) {
        require(lib.getRespondentDescription(caseId) == 0);
        lib.setRespondentDescription(caseId, description);
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.VOTING);
        emit CaseCommentedByRespondent(caseId, msg.sender, description);
        emit CaseVoting(caseId);
    }

    function startVotingCase(bytes32 caseId)
    external hasStatus(caseId, CasesLib.CaseStatus.OPENED) laterOn(lib.getVotingDate(caseId)) {
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.VOTING);
        emit CaseVoting(caseId);
    }

    function commitVote(bytes32 caseId, bytes32 voteHash)
    external hasStatus(caseId, CasesLib.CaseStatus.VOTING) before(lib.getRevealingDate(caseId))
    {
        require(lib.isRefereeSetToCase(msg.sender, caseId)); //referee must be set to case
        require(!lib.isRefereeVoted(msg.sender, caseId)); //referee can not vote twice
        lib.setRefereeVoteHash(caseId, msg.sender, voteHash);
        emit CaseVoteCommitted(caseId, msg.sender, voteHash);
        if (lib.getRefereeVoteHashCount(caseId) == lib.getRefereeCountByCase(caseId)) {
            lib.setCaseStatus(caseId, CasesLib.CaseStatus.REVEALING);
            emit CaseRevealingVotes(caseId);
        }
    }

    function startRevealingVotes(bytes32 caseId)
    external hasStatus(caseId, CasesLib.CaseStatus.VOTING) laterOn(lib.getRevealingDate(caseId))
    {
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.REVEALING);
        emit CaseRevealingVotes(caseId);
    }

    function revealVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt)
    external hasStatus(caseId, CasesLib.CaseStatus.REVEALING) before(lib.getCloseDate(caseId))
    {
        doRevealVote(caseId, referee, voteOption, salt);
        checkShouldMakeVerdict(caseId);
    }

    function revealVotes(bytes32 caseId, address[] referees, uint8[] voteOptions, bytes32[] salts)
    external hasStatus(caseId, CasesLib.CaseStatus.REVEALING) before(lib.getCloseDate(caseId))
    {
        require((referees.length == voteOptions.length) && (referees.length == salts.length));
        for (uint i = 0; i < referees.length; i++) {
            doRevealVote(caseId, referees[i], voteOptions[i], salts[i]);
        }
        checkShouldMakeVerdict(caseId);
    }

    function checkShouldMakeVerdict(bytes32 caseId)
    private {
        if (lib.getRefereeVotesFor(caseId, true) + lib.getRefereeVotesFor(caseId, false) == lib.getRefereeVoteHashCount(caseId)) {
            makeVerdict(caseId);
        }
    }

    function doRevealVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt) private {
        require(verifyVote(caseId, referee, voteOption, salt));
        lib.setRefereeVote(caseId, referee,  voteOption == 0);
        emit CaseVoteRevealed(caseId, referee, voteOption, salt);
    }

    function createVoteHash(uint8 voteOption, bytes32 salt)
    public view returns(bytes32) {
        return keccak256(voteOption, salt);
    }

    function verifyVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt)
    public view returns(bool){
        return lib.getRefereeVoteHash(caseId, referee) == keccak256(voteOption, salt);
    }

    function verdict(bytes32 caseId)
    external hasStatus(caseId, CasesLib.CaseStatus.REVEALING) laterOn(lib.getCloseDate(caseId)) {
        makeVerdict(caseId);
    }

    function makeVerdict(bytes32 caseId)
    private {
        uint forApplicant = lib.getRefereeVotesFor(caseId, true);
        uint forRespondent = lib.getRefereeVotesFor(caseId, false);
        uint refereeAward = lib.getRefereeAward(caseId);
        bool isNotEnoughVotes = (forApplicant + forRespondent) < lib.getRefereeCountNeed(caseId);
        bool isEthRefereeAward = lib.isEthRefereeAward(caseId);
        if (isNotEnoughVotes || (forApplicant == forRespondent)) {
            withdrawTo(isEthRefereeAward, lib.getApplicant(caseId), refereeAward);
            lib.setCaseStatus(caseId, CasesLib.CaseStatus.CANCELED);
            CasesLib.CaseCanceledCode causeCode = isNotEnoughVotes ?
                CasesLib.CaseCanceledCode.NOT_ENOUGH_VOTES : CasesLib.CaseCanceledCode.EQUAL_NUMBER_OF_VOTES;
            lib.setCaseCanceledCode(caseId, causeCode);
            emit CaseCanceled(caseId, uint8(causeCode));
            withdrawAllRefereeVotes(caseId);
            return;
        }
        bool won = false;
        uint awardPerReferee;
        if (forApplicant > forRespondent) {
            won = true;
            awardPerReferee = refereeAward / forApplicant;
        } else {
            awardPerReferee = refereeAward / forRespondent;
        }
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.CLOSED);
        lib.setCaseWon(caseId, won);
        emit CaseClosed(caseId, won);
        address[] memory wonReferees = lib.getRefereesFor(caseId, won);
        for (uint i = 0; i < wonReferees.length; i++) {
            withdrawTo(isEthRefereeAward, wonReferees[i], awardPerReferee);
            emit RefereeAwarded(wonReferees[i], caseId, awardPerReferee);
        }
        withdrawRefereeVotes(caseId);
    }

    function withdrawTo(bool isEth, address to, uint amount) private {
        if (isEth) {
            require(PaymentHolder(paymentHolder).withdrawEth(to, amount));
        } else {
            require(PaymentHolder(paymentHolder).withdrawToken(to, amount, address(bkxToken)));
        }
    } 

    function withdrawAllRefereeVotes(bytes32 caseId) private {
        address[] memory referees = lib.getRefereesByCase(caseId);
        for (uint i = 0; i < referees.length; i++) {
            withdrawRefereeVote(referees[i]);
        }
    }

    function withdrawRefereeVotes(bytes32 caseId)
    private {
        address[] memory referees = lib.getRefereesByCase(caseId);
        for (uint i = 0; i < referees.length; i++) {
            if (!lib.isRefereeVoted(referees[i], caseId)) {
                withdrawRefereeVote(referees[i]);
            }
        }
    }

    function withdrawRefereeVote(address referee)
    private {
        uint voteBalance = lib.getVotes(referee);
        voteBalance += 1;
        lib.setVotes(referee, voteBalance);
        emit RefereeVoteBalanceChanged(referee, voteBalance);
    }
}