pragma solidity ^0.4.18;

//zeppelin contracts are copied from original due to vscode solidity plugin can not define them from node_modules
// and thus doesn't validate the rest of the file at all.
import "../zeppelin/Ownable.sol";

contract IEscrowRepository is Ownable {
    function setStorageAddress(address storageAddress) external;

    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount)
        public pure returns(bytes32);

    function getPayment(address[3] addresses, bytes32 deal, uint256 amount)
        public view returns(
            bytes32 paymentId, uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited
        );

    function getPaymentById(bytes32 paymentId)
        public view returns(uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited);

    function getPaymentOffers(address[3] addresses, bytes32 deal, uint256 amount)
        public view returns(uint256 depositorOffer, uint256 beneficiaryOffer);
}