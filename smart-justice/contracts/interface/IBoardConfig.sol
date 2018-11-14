pragma solidity ^0.4.0;

import "../zeppelin/Ownable.sol";

contract IBoardConfig is Ownable {

    uint constant decimals = 10 ** uint(18);
    uint8 public version;

    function resetValuesToDefault() external;

    function setStorageAddress(address storageAddress) external;

    function getRefereeFee() external view returns (uint);
    function getRefereeFeeEth() external view returns(uint);

    function getVoteTokenPrice() external view returns (uint);
    function setVoteTokenPrice(uint value) external;

    function getVoteTokenPriceEth() external view returns (uint);
    function setVoteTokenPriceEth(uint value) external;

    function getVoteTokensPerRequest() external view returns (uint);
    function setVoteTokensPerRequest(uint voteTokens) external;

    function getTimeToStartVotingCase() external view returns (uint);
    function setTimeToStartVotingCase(uint value) external;

    function getTimeToRevealVotesCase() external view returns (uint);
    function setTimeToRevealVotesCase(uint value) external;

    function getTimeToCloseCase() external view returns (uint);
    function setTimeToCloseCase(uint value) external;

    function getRefereeCountPerCase() external view returns(uint);
    function setRefereeCountPerCase(uint refereeCount) external;

    function getRefereeNeedCountPerCase() external view returns(uint);
    function setRefereeNeedCountPerCase(uint refereeCount) external;

    function getFullConfiguration()
    external view returns(
        uint voteTokenPrice, uint voteTokenPriceEth, uint voteTokenPerRequest,
        uint refereeCountPerCase, uint refereeNeedCountPerCase,
        uint timeToStartVoting, uint timeToRevealVotes, uint timeToClose
    );

    function getCaseDatesFromNow() public view returns(uint[] dates);

}