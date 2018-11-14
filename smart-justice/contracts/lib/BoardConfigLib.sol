pragma solidity ^0.4.0;

import "../EternalStorage.sol";

library BoardConfigLib {
    function getVoteTokenPrice(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.vote.token.price"));
    }

    function setVoteTokenPrice(address storageAddress, uint refereeFee) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.vote.token.price"), refereeFee);
    }

    function getVoteTokenPriceEth(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.vote.token.price.eth"));
    }

    function setVoteTokenPriceEth(address storageAddress, uint refereeFeeEth) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.vote.token.price.eth"), refereeFeeEth);
    }

    function getVoteTokensPerRequest(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.vote.tokens.per.request"));
    }

    function setVoteTokensPerRequest(address storageAddress, uint voteTokens) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.vote.tokens.per.request"), voteTokens);
    }

    function getRefereeCountPerCase(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.referee.countPerCase"));
    }

    function setRefereeCountPerCase(address storageAddress, uint refereeCount) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.referee.countPerCase"), refereeCount);
    }

    function getRefereeNeedCountPerCase(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.referee.need.countPerCase"));
    }

    function setRefereeNeedCountPerCase(address storageAddress, uint refereeCount) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.referee.need.countPerCase"), refereeCount);
    }

    function getTimeToRevealVotesCase(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.case.time.reveal"));
    }

    function setTimeToRevealVotesCase(address storageAddress, uint timeInSeconds) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.case.time.reveal"), timeInSeconds);
    }

    function getTimeToStartVotingCase(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.case.time.voting"));
    }

    function setTimeToStartVotingCase(address storageAddress, uint timeInSeconds) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.case.time.voting"), timeInSeconds);
    }

    function getTimeToCloseCase(address storageAddress) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("board.config.case.time.close"));
    }

    function setTimeToCloseCase(address storageAddress, uint timeInSeconds) public {
        EternalStorage(storageAddress).setUint(keccak256("board.config.case.time.close"), timeInSeconds);
    }
}
