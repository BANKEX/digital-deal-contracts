pragma solidity ^0.4.22;

import "./interface/IEscrowRepository.sol";
import "./lib/PaymentLib.sol";

contract EscrowRepository is IEscrowRepository {
    using PaymentLib for address;
    
    address lib;

    constructor(address storageAddress) public {
        lib = storageAddress;
    }

    function setStorageAddress(address storageAddress) 
    external onlyOwner {
        lib = storageAddress;
    }

    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount)
    public pure returns(bytes32) {
        return PaymentLib.getPaymentId(addresses, deal, amount);
    }

    function getPayment(address[3] addresses, bytes32 deal, uint256 amount)
    public view returns(
        bytes32 paymentId, uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited
    ) {
        paymentId = getPaymentId(addresses, deal, amount);
        (status, fee, feePayed, signed, deposited) =  lib.getPayment(paymentId);
    }

    function getPaymentById(bytes32 paymentId)
    public view returns(uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited) {
        return lib.getPayment(paymentId);
    }

    function getPaymentOffers(address[3] addresses, bytes32 deal, uint256 amount)
    public view returns(uint256 depositorOffer, uint256 beneficiaryOffer ) {
        return lib.getPaymentOffers(addresses[0], addresses[1], getPaymentId(addresses, deal, amount));
    }

}