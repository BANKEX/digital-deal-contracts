pragma solidity ^0.4.18;

import "./interface/ICourt.sol";
import "./EternalStorage.sol";

contract Court is ICourt {

    address public courtStorage;

    constructor(address _courtStorage) {
        courtStorage = _courtStorage;
    }

    /*-------------------CONFIG METHODS-------------------*/

    function setCourtStorageAddress(address _courtStorage) 
    external onlyOwner {
        courtStorage = _courtStorage;
    }

    /*-------------------INTEFACE IMPLEMENTATION-------------------*/

    function getCaseId(address applicant, address respondent, bytes32 deal, uint256 date, bytes32 title, uint256 amount)
    public pure returns(bytes32){
        return keccak256(applicant, respondent, deal, date, title, amount);
    }

    function getCaseStatus(bytes32 caseId) public view returns(uint8) {
        return EternalStorage(courtStorage).getUint8(keccak256("case.status", caseId));
    }

    function getCaseVerdict(bytes32 caseId) public view returns(bool) {
        return EternalStorage(courtStorage).getBool(keccak256("case.won", caseId));
    }

}