pragma solidity ^0.4.22;

import "../EternalStorage.sol";

library PaymentLib {

    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addresses[0], addresses[1], addresses[2], deal, amount));
    }

    function createPayment(
        address storageAddress, bytes32 paymentId, uint8 fee, uint8 status
    ) public {
        setPaymentStatus(storageAddress, paymentId, status);
        setPaymentFee(storageAddress, paymentId, fee);
    }

    function isCancelRequested(address storageAddress, bytes32 paymentId, address party)
    public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.cance", paymentId, party)));
    }

    function setCancelRequested(address storageAddress, bytes32 paymentId, address party, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.cance", paymentId, party)), value);
    }

    function getPaymentFee(address storageAddress, bytes32 paymentId)
    public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("payment.fee", paymentId)));
    }

    function setPaymentFee(address storageAddress, bytes32 paymentId, uint8 value)
    public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("payment.fee", paymentId)), value);
    }

    function isFeePayed(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.fee.payed", paymentId)));
    }

    function setFeePayed(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.fee.payed", paymentId)), value);
    }

    function isDeposited(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.deposited", paymentId)));
    }

    function setDeposited(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.deposited", paymentId)), value);
    }

    function isSigned(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.signed", paymentId)));
    }

    function setSigned(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.signed", paymentId)), value);
    }

    function getPaymentStatus(address storageAddress, bytes32 paymentId)
    public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("payment.status", paymentId)));
    }

    function setPaymentStatus(address storageAddress, bytes32 paymentId, uint8 status)
    public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("payment.status", paymentId)), status);
    }

    function getOfferAmount(address storageAddress, bytes32 paymentId, address user)
    public view returns (uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.amount.refund", paymentId, user)));
    }

    function setOfferAmount(address storageAddress, bytes32 paymentId, address user, uint256 amount)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.amount.refund", paymentId, user)), amount);
    }

    function getWithdrawAmount(address storageAddress, bytes32 paymentId, address user)
    public view returns (uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.amount.withdraw", paymentId, user)));
    }

    function setWithdrawAmount(address storageAddress, bytes32 paymentId, address user, uint256 amount)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.amount.withdraw", paymentId, user)), amount);
    }

    function isWithdrawn(address storageAddress, bytes32 paymentId, address user)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.withdrawed", paymentId, user)));
    }

    function setWithdrawn(address storageAddress, bytes32 paymentId, address user, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.withdrawed", paymentId, user)), value);
    }

    function getPayment(address storageAddress, bytes32 paymentId)
    public view returns(
        uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited
    ) {
        status = uint8(getPaymentStatus(storageAddress, paymentId));
        fee = getPaymentFee(storageAddress, paymentId);
        feePayed = isFeePayed(storageAddress, paymentId);
        signed = isSigned(storageAddress, paymentId);
        deposited = isDeposited(storageAddress, paymentId);
    }

    function getPaymentOffers(address storageAddress, address depositor, address beneficiary, bytes32 paymentId)
    public view returns(uint256 depositorOffer, uint256 beneficiaryOffer) {
        depositorOffer = getOfferAmount(storageAddress, paymentId, depositor);
        beneficiaryOffer = getOfferAmount(storageAddress, paymentId, beneficiary);
    }
}