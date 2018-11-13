pragma solidity ^0.4.18;

//zeppelin contracts are copied from original due to vscode solidity plugin can not define them from node_modules
// and thus doesn't validate the rest of the file at all.
import "../util/Withdrawable.sol";

contract IEscrow is Withdrawable {

    /*----------------------PAYMENT STATUSES----------------------*/

    //SIGNED status kept for backward compatibility
    enum PaymentStatus {NONE/*code=0*/, CREATED/*code=1*/, SIGNED/*code=2*/, CONFIRMED/*code=3*/, RELEASED/*code=4*/, RELEASED_BY_DISPUTE /*code=5*/, CLOSED/*code=6*/, CANCELED/*code=7*/}
    
    /*----------------------EVENTS----------------------*/

    event PaymentCreated(bytes32 paymentId, address depositor, address beneficiary, address token, bytes32 deal, uint256 amount, uint8 fee);
    event PaymentSigned(bytes32 paymentId, bool confirmed);
    event PaymentDeposited(bytes32 paymentId, uint256 depositedAmount, bool feePayed, bool confirmed);
    event PaymentReleased(bytes32 paymentId);
    event PaymentOffer(bytes32 paymentId, uint256 offerAmount);
    event PaymentOfferCanceled(bytes32 paymentId);
    event PaymentOwnOfferCanceled(bytes32 paymentId);
    event PaymentOfferAccepted(bytes32 paymentId, uint256 releaseToBeneficiary, uint256 refundToDepositor);
    event PaymentWithdrawn(bytes32 paymentId, uint256 amount);
    event PaymentWithdrawnByDispute(bytes32 paymentId, uint256 amount, bytes32 dispute);
    event PaymentCanceled(bytes32 paymentId);
    event PaymentClosed(bytes32 paymentId);
    event PaymentClosedByDispute(bytes32 paymentId, bytes32 dispute);

    /*----------------------PUBLIC STATE----------------------*/

    address public lib;
    address public courtAddress;
    address public paymentHolder;


    /*----------------------CONFIGURATION METHODS (only owner) ----------------------*/
    function setStorageAddress(address _storageAddress) external;

    function setCourtAddress(address _courtAddress) external;

    /*----------------------PUBLIC USER METHODS----------------------*/
    /** @dev Depositor creates escrow payment. Set token as 0x0 in case of ETH amount.
      * @param addresses [depositor, beneficiary, token]
      */
    function createPayment(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Beneficiary signs escrow payment as consent for taking part.
      * @param addresses [depositor, beneficiary, token]
      */
    function sign(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor deposits payment amount only after it was signed by beneficiary.
      * @param addresses [depositor, beneficiary, token]
      * @param payFee If true, depositor have to send (amount + (amount * fee) / 100).
      */
    function deposit(address[3] addresses, bytes32 deal, uint256 amount, bool payFee) external payable;

    /** @dev Depositor or Beneficiary requests payment cancellation after payment was signed by beneficiary.
      *      Payment is closed, if depositor and beneficiary both request cancellation.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancel(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor close payment though transfer payment amount to another party.
      * @param addresses [depositor, beneficiary, token]
      */
    function release(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or beneficiary offers partial closing payment with offerAmount.
      * @param addresses [depositor, beneficiary, token]
      * @param offerAmount Amount of partial closing offer in currency of payment (ETH or token).
      */
    function offer(address[3] addresses, bytes32 deal, uint256 amount, uint256 offerAmount) external;

    /** @dev Depositor or beneficiary canceles another party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancelOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or beneficiary cancels own offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancelOwnOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or beneficiary accepts opposite party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function acceptOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

   
    /** @dev Depositor or beneficiary withdraw amounts.
      * @param addresses [depositor, beneficiary, token]
      */
    function withdraw(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or Beneficiary withdraw amounts according dispute verdict.
      * @dev Have to use fucking arrays due to "stack too deep" issue.
      * @param addresses [depositor, beneficiary, token]
      * @param disputeParties [applicant, respondent]
      * @param uints [paymentAmount, disputeAmount, disputeCreatedAt]
      * @param byts [deal, disputeTitle]
      */
    function withdrawByDispute(address[3] addresses, address[2] disputeParties, uint256[3] uints, bytes32[2] byts) external;
}