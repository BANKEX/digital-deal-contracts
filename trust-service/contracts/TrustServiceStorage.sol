pragma solidity ^0.4.18;


import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

contract TrustServiceStorage is Destructible {

    struct Deal {
        bytes32 dealHash;
        address[] addresses;
    }

    uint256 dealId = 1;

    mapping (uint256 => Deal) deals;

    mapping (uint256 => mapping(address => bool)) signedAddresses;

    address trust;

    modifier onlyTrust() {
        require(msg.sender == trust);
        _;
    }

    function setTrust(address _trust) onlyOwner {
        trust = _trust;
    }

    function getDealId() onlyTrust returns (uint256) {
        return dealId;
    }

    function setDealId(uint256 _dealId) onlyTrust {
        dealId = _dealId;
    }

    function addDeal(uint256 dealId, bytes32 dealHash, address[] addresses) onlyTrust returns (uint256) {
        deals[dealId] = Deal(dealHash, addresses);
    }

    function getDealHash(uint256 dealId) onlyTrust returns (bytes32) {
        return deals[dealId].dealHash;
    }

    function getDealAddrCount(uint256 dealId) onlyTrust returns (uint256) {
        return deals[dealId].addresses.length;
    }

    function getDealAddrAtIndex(uint256 dealId, uint256 index) onlyTrust returns (address)  {
        return deals[dealId].addresses[index];
    }

    function setSigned(uint256 dealId, address _address) onlyTrust {
        signedAddresses[dealId][_address] = true;
    }

    function setUnSigned(uint256 dealId, address _address) onlyTrust {
        signedAddresses[dealId][_address] = false;
    }

    function getSigned(uint256 dealId, address _address) onlyTrust returns (bool) {
        return signedAddresses[dealId][_address];
    }
}
