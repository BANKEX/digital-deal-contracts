pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import './TrustServiceStorage.sol';

contract TrustService is Destructible {

    TrustServiceStorage trustStorage;

    ERC20 public feeToken;
    uint256 public fee;
    address public feeSender;
    address public feeRecipient;

    event DealSaved(uint256 indexed dealId);

    function setFee(address _feeToken, address _feeSender, address _feeRecipient, uint256 _fee) public onlyOwner {
       require(_feeToken != address(0));
       require(_feeSender != address(0));
       require(_feeRecipient != address(0));
       require(_fee > 0);
       feeToken = ERC20(_feeToken);
       feeSender = _feeSender;
       feeRecipient = _feeRecipient;
       fee = _fee;
    }

    function clearFee() public onlyOwner {
       fee = 0;
    }

    function setStorage(address _storageAddress) onlyOwner {
        trustStorage = TrustServiceStorage(_storageAddress);
    }

    function createDeal(
      bytes32 dealHash,
      address[] addresses
    ) public returns (uint256) {

        require(fee == 0 || feeToken.transferFrom(feeSender, feeRecipient, fee));

        uint256 dealId = trustStorage.getDealId();

        trustStorage.addDeal(dealId, dealHash, addresses);

        DealSaved(dealId);

        trustStorage.setDealId(dealId + 1);

        return dealId;
    }

    function createAndSignDeal(
      bytes32 dealHash,
      address[] addresses)
    public {

        uint256 id = createDeal(dealHash, addresses);
        signDeal(id);
    }

    function readDeal(uint256 dealId) public view returns (
      bytes32 dealHash,
      address[] addresses,
      bool[] signed
    ) {
        dealHash = trustStorage.getDealHash(dealId);

        uint256 addrCount = trustStorage.getDealAddrCount(dealId);

        addresses = new address[](addrCount);

        signed = new bool[](addrCount);

        for(uint i = 0; i < addrCount; i ++) {
            addresses[i] = trustStorage.getDealAddrAtIndex(dealId, i);
            signed[i] = trustStorage.getSigned(dealId , addresses[i]);
        }
    }

    function signDeal(uint256 dealId) public {
        trustStorage.setSigned(dealId, msg.sender);
    }

    function confirmDeal(uint256 dealId, bytes32 dealHash) public constant returns (bool) {
        bytes32 hash = trustStorage.getDealHash(dealId);

        return hash == dealHash;
    }
}
