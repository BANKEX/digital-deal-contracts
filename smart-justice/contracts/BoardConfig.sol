pragma solidity ^0.4.0;

import "./zeppelin/Ownable.sol";
import "./lib/BoardConfigLib.sol";
import "./interface/IBoardConfig.sol";

contract BoardConfig is Ownable, IBoardConfig {

    using BoardConfigLib for address;
    
    address config;

    function BoardConfig(address storageAddress) public {
        version = 2;
        config = storageAddress;
    }

    function resetValuesToDefault() external onlyOwner  {
        config.setVoteTokenPrice(1 * decimals);//1 bkx
        config.setVoteTokenPriceEth(350000000000000);//wei * 410$ per ETH and 0.14 per BKX
        config.setVoteTokensPerRequest(10);
        config.setRefereeCountPerCase(21);
        config.setRefereeNeedCountPerCase(5);
        config.setTimeToStartVotingCase(43200); //12 hour
        config.setTimeToRevealVotesCase(86400); //1 day
        config.setTimeToCloseCase(7200); //2 hour
    }

    function setStorageAddress(address storageAddress) external onlyOwner {
        config = storageAddress;
    }

    function getRefereeFee() external  view returns (uint) {
        return config.getVoteTokenPrice() * config.getVoteTokensPerRequest();
    }

    function getRefereeFeeEth() external  view returns (uint) {
        return config.getVoteTokenPriceEth() * config.getVoteTokensPerRequest();
    }

    function getVoteTokenPrice() external  view returns (uint) {
        return config.getVoteTokenPrice();
    }

    function setVoteTokenPrice(uint value) external onlyOwner {
        config.setVoteTokenPrice(value);
    }

    function getVoteTokenPriceEth() external  view returns (uint) {
        return config.getVoteTokenPriceEth();
    }

    function setVoteTokenPriceEth(uint value) external onlyOwner {
        config.setVoteTokenPriceEth(value);
    }

    function getVoteTokensPerRequest() external view returns (uint) {
        return config.getVoteTokensPerRequest();
    }

    function setVoteTokensPerRequest(uint voteTokens) external onlyOwner {
        config.setVoteTokensPerRequest(voteTokens);
    }

    function getTimeToStartVotingCase() external view returns (uint) {
        return config.getTimeToStartVotingCase();
    }

    function setTimeToStartVotingCase(uint value) external onlyOwner {
        config.setTimeToStartVotingCase(value);
    }

    function getTimeToRevealVotesCase() external view returns (uint) {
        return config.getTimeToRevealVotesCase();
    }

    function setTimeToRevealVotesCase(uint value) external onlyOwner {
        config.setTimeToRevealVotesCase(value);
    }

    function getTimeToCloseCase() external view returns (uint) {
        return config.getTimeToCloseCase();
    }

    function setTimeToCloseCase(uint value) external onlyOwner {
        config.setTimeToCloseCase(value);
    }

    function getRefereeCountPerCase() external view returns(uint) {
        return config.getRefereeCountPerCase();
    }

    function setRefereeCountPerCase(uint refereeCount) external onlyOwner{
        require(refereeCount >= config.getRefereeNeedCountPerCase());
        config.setRefereeCountPerCase(refereeCount);
    }

    function getRefereeNeedCountPerCase() external view returns(uint) {
        return config.getRefereeNeedCountPerCase();
    }

    function setRefereeNeedCountPerCase(uint refereeCount) external onlyOwner {
        require(refereeCount <= config.getRefereeCountPerCase());
        config.setRefereeNeedCountPerCase(refereeCount);
    }

    function getFullConfiguration()
    external view returns(
        uint voteTokenPrice, uint voteTokenPriceEth, uint voteTokenPerRequest,
        uint refereeCountPerCase, uint refereeNeedCountPerCase,
        uint timeToStartVoting, uint timeToRevealVotes, uint timeToClose
    ) 
    {
        voteTokenPrice = config.getVoteTokenPrice();
        voteTokenPriceEth = config.getVoteTokenPriceEth();
        voteTokenPerRequest = config.getVoteTokensPerRequest();
        refereeCountPerCase = config.getRefereeCountPerCase();
        refereeNeedCountPerCase = config.getRefereeNeedCountPerCase();
        timeToStartVoting = config.getTimeToStartVotingCase();
        timeToRevealVotes = config.getTimeToRevealVotesCase();
        timeToClose = config.getTimeToCloseCase();
    }

    function getCaseDatesFromNow() public view returns(uint[] dates) {
        dates = new uint[](4);
        dates[0] = now;
        dates[1] = dates[0] + config.getTimeToStartVotingCase();
        dates[2] = dates[1] + config.getTimeToRevealVotesCase();
        dates[3] = dates[2] + config.getTimeToCloseCase();
    }
}