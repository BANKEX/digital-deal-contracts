pragma solidity ^0.4.0;

library Utils {
     /* Not secured random number generation, but it's enough for the perpose of implementaion particular case*/
    function almostRnd(uint min, uint max) internal view returns(uint)
    {
        return uint(keccak256(block.timestamp, block.blockhash(block.number))) % (max - min) + min;
    }
}