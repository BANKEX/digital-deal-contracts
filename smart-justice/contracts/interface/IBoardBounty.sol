
pragma solidity ^0.4.18;

//zeppelin contracts are copied from original due to vscode solidity plugin can not define them from node_modules 
// and thus doesn't validate the rest of the file at all.
import "../zeppelin/Ownable.sol";
import "./IBoardConfig.sol";

contract IBoardBounty is Ownable {
    event RefereeVoteBalanceChanged(address referee, uint balance);

    uint public startTime;
    uint public endTime;
    uint public tokensPerRequest;
    bool public enabled;

    /*configuration*/
    function setStartTime(uint time) external;
    function setEndTime(uint time) external;
    function setEnabled(bool value) external;
    function setTokensPerRequest(uint count) external;

    /*main interaction*/
    function resetAccount(address referee) external;
    function applyForFreeVoteTokens() external;
    function isFreeTokensAvailable(address user) public view returns(bool);
}