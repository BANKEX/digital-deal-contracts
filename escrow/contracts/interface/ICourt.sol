pragma solidity ^0.4.18;

import "../zeppelin/Ownable.sol";

/** @dev This interface is dedicated to Escrow contract to get information about particular case from Smart Justice.
 */
contract ICourt is Ownable {

    function getCaseId(address applicant, address respondent, bytes32 deal, uint256 date, bytes32 title, uint256 amount) 
        public pure returns(bytes32);

    function getCaseStatus(bytes32 caseId) public view returns(uint8);

    function getCaseVerdict(bytes32 caseId) public view returns(bool);
}