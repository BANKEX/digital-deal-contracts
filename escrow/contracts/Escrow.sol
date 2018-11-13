pragma solidity ^0.4.22;

import "./interface/IEscrow.sol";
import "./interface/ICourt.sol";
import "./lib/PaymentLib.sol";
import "./EscrowConfig.sol";
import "./PaymentHolder.sol";


contract Escrow is IEscrow {
    using PaymentLib for address;
    using EscrowConfigLib for address;

    constructor(address storageAddress, address _paymentHolder, address _courtAddress) public {
        lib = storageAddress;
        courtAddress = _courtAddress;
        paymentHolder = _paymentHolder;
    }

    /*----------------------CONFIGURATION METHODS----------------------*/

    function setStorageAddress(address _storageAddress) external onlyOwner {
        lib = _storageAddress;
    }

    function setPaymentHolder(address _paymentHolder) external onlyOwner {
        paymentHolder = _paymentHolder;
    }

    function setCourtAddress(address _courtAddress) external onlyOwner {
        courtAddress = _courtAddress;
    }

    /*----------------------PUBLIC USER METHODS----------------------*/

    /** @dev Depositor creates escrow payment. Set token as 0x0 in case of ETH amount.
      * @param addresses [depositor, beneficiary, token]
      */
    function createPayment(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        require(addresses[0] != address(0));
        require(addresses[1] != address(0));
        require(addresses[0] != addresses[1], "Depositor and beneficiary can not be the same");
        require(deal != 0x0, "deal can not be 0x0");
        require(amount != 0, "amount can not be 0");
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.NONE);
        uint8 fee = lib.getPaymentFee();
        lib.createPayment(paymentId, fee, uint8(PaymentStatus.CREATED));
        emit PaymentCreated(paymentId, addresses[0], addresses[1], addresses[2], deal, amount, fee);
    }

    /** @dev Beneficiary signs escrow payment as consent for taking part.
      * @param addresses [depositor, beneficiary, token]
      */
    function sign(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyBeneficiary(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CREATED);
        lib.setSigned(paymentId, true);
        bool confirmed = lib.isDeposited(paymentId);
        if (confirmed) {
            setPaymentStatus(paymentId, PaymentStatus.CONFIRMED);
        }
        emit PaymentSigned(paymentId, confirmed);
    }

    /** @dev Depositor deposits payment amount only after it was signed by beneficiary
      * @param addresses [depositor, beneficiary, token]
      * @param payFee If true, depositor have to send (amount + (amount * fee) / 100).
      */
    function deposit(address[3] addresses, bytes32 deal, uint256 amount, bool payFee)
    external payable {
        onlyDepositor(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        PaymentStatus status = getPaymentStatus(paymentId);
        require(status == PaymentStatus.CREATED || status == PaymentStatus.SIGNED);
        uint256 depositAmount = amount;
        if (payFee) {
            depositAmount = amount + calcFee(amount, lib.getPaymentFee(paymentId));
            lib.setFeePayed(paymentId, true);
        }
        address token = getToken(addresses);
        if (token == address(0)) {
            require(msg.value == depositAmount, "ETH amount must be equal amount");
            require(PaymentHolder(paymentHolder).depositEth.value(msg.value)());
        } else {
            require(msg.value == 0, "ETH amount must be 0 for token transfer");
            require(Token(token).allowance(msg.sender, address(this)) >= depositAmount);
            require(Token(token).balanceOf(msg.sender) >= depositAmount);
            require(Token(token).transferFrom(msg.sender, paymentHolder, depositAmount));
        }
        lib.setDeposited(paymentId, true);
        bool confirmed = lib.isSigned(paymentId);
        if (confirmed) {
            setPaymentStatus(paymentId, PaymentStatus.CONFIRMED);
        }
        emit PaymentDeposited(paymentId, depositAmount, payFee, confirmed);
    }

    /** @dev Depositor or Beneficiary requests payment cancellation after payment was signed by beneficiary.
      *      Payment is closed, if depositor and beneficiary both request cancellation.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancel(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CREATED);
        setPaymentStatus(paymentId, PaymentStatus.CANCELED);
        if (lib.isDeposited(paymentId)) {
            uint256 amountToRefund = amount;
            if (lib.isFeePayed(paymentId)) {
                amountToRefund = amount + calcFee(amount, lib.getPaymentFee(paymentId));
            }
            transfer(getDepositor(addresses), amountToRefund, getToken(addresses));
        }
        setPaymentStatus(paymentId, PaymentStatus.CANCELED);
        emit PaymentCanceled(paymentId);
        emit PaymentCanceled(paymentId);
    }

    /** @dev Depositor close payment though transfer payment amount to another party.
      * @param addresses [depositor, beneficiary, token]
      */
    function release(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyDepositor(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CONFIRMED);
        doRelease(addresses, [amount, 0], paymentId);
        emit PaymentReleased(paymentId);
    }

    /** @dev Depositor or beneficiary offers partial closing payment with offerAmount.
      * @param addresses [depositor, beneficiary, token]
      * @param offerAmount Amount of partial closing offer in currency of payment (ETH or token).
      */
    function offer(address[3] addresses, bytes32 deal, uint256 amount, uint256 offerAmount)
    external {
        onlyParties(addresses);
        require(offerAmount >= 0 && offerAmount <= amount, "Offer amount must be >= 0 and <= payment amount");
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        uint256 anotherOfferAmount = lib.getOfferAmount(paymentId, getAnotherParty(addresses));
        require(anotherOfferAmount == 0, "Sender can not make offer if another party has done the same before");
        lib.setOfferAmount(paymentId, msg.sender, offerAmount);
        emit PaymentOffer(paymentId, offerAmount);
    }

    /** @dev Depositor or beneficiary cancels opposite party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancelOffer(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        bytes32 paymentId = doCancelOffer(addresses, deal, amount, getAnotherParty(addresses));
        emit PaymentOfferCanceled(paymentId);
    }

    /** @dev Depositor or beneficiary cancels own offer.
    * @param addresses [depositor, beneficiary, token]
    */
    function cancelOwnOffer(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        bytes32 paymentId = doCancelOffer(addresses, deal, amount, msg.sender);
        emit PaymentOwnOfferCanceled(paymentId);
    }

    /** @dev Depositor or beneficiary accepts opposite party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function acceptOffer(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CONFIRMED);
        uint256 offerAmount = lib.getOfferAmount(paymentId, getAnotherParty(addresses));
        require(offerAmount != 0, "Sender can not accept another party offer of 0");
        uint256 toBeneficiary = offerAmount;
        uint256 toDepositor = amount - offerAmount;
        //if sender is beneficiary
        if (msg.sender == addresses[1]) {
            toBeneficiary = amount - offerAmount;
            toDepositor = offerAmount;
        }
        doRelease(addresses, [toBeneficiary, toDepositor], paymentId);
        emit PaymentOfferAccepted(paymentId, toBeneficiary, toDepositor);
    }

    /** @dev Depositor or beneficiary withdraw amounts.
      * @param addresses [depositor, beneficiary, token]
      */
    function withdraw(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.RELEASED);
        require(!lib.isWithdrawn(paymentId, msg.sender), "User can not withdraw twice.");
        uint256 withdrawAmount = lib.getWithdrawAmount(paymentId, msg.sender);
        withdrawAmount = transferWithFee(msg.sender, withdrawAmount, addresses[2], paymentId);
        emit PaymentWithdrawn(paymentId, withdrawAmount);
        lib.setWithdrawn(paymentId, msg.sender, true);
        address anotherParty = getAnotherParty(addresses);
        if (lib.getWithdrawAmount(paymentId, anotherParty) == 0 || lib.isWithdrawn(paymentId, anotherParty)) {
            setPaymentStatus(paymentId, PaymentStatus.CLOSED);
            emit PaymentClosed(paymentId);
        }
    }

    /** @dev Depositor or Beneficiary withdraw amounts according dispute verdict.
      * @dev Have to use fucking arrays due to "stack too deep" issue.
      * @param addresses [depositor, beneficiary, token]
      * @param disputeParties [applicant, respondent]
      * @param uints [paymentAmount, disputeAmount, disputeCreatedAt]
      * @param byts [deal, disputeTitle]
      */
    function withdrawByDispute(address[3] addresses, address[2] disputeParties, uint256[3] uints, bytes32[2] byts)
    external {
        onlyParties(addresses);
        require(
            addresses[0] == disputeParties[0] && addresses[1] == disputeParties[1] || addresses[0] == disputeParties[1] && addresses[1] == disputeParties[0],
            "Depositor and beneficiary must be dispute parties"
        );
        bytes32 paymentId = getPaymentId(addresses, byts[0], uints[0]);
        PaymentStatus paymentStatus = getPaymentStatus(paymentId);
        require(paymentStatus == PaymentStatus.CONFIRMED || paymentStatus == PaymentStatus.RELEASED_BY_DISPUTE);
        require(!lib.isWithdrawn(paymentId, msg.sender), "User can not withdraw twice.");
        bytes32 dispute = ICourt(courtAddress).getCaseId(
            disputeParties[0] /*applicant*/, disputeParties[1]/*respondent*/,
            paymentId/*deal*/, uints[2]/*disputeCreatedAt*/,
            byts[1]/*disputeTitle*/, uints[1]/*disputeAmount*/
        );
        require(ICourt(courtAddress).getCaseStatus(dispute) == 3, "Case must be closed");
        /*[releaseAmount, refundAmount]*/
        uint256[2] memory withdrawAmounts = [uint256(0), 0];
        bool won = ICourt(courtAddress).getCaseVerdict(dispute);
        //depositor == applicant
        if (won) {
            //use paymentAmount if disputeAmount is greater
            withdrawAmounts[0] = uints[1] > uints[0] ? uints[0] : uints[1];
            withdrawAmounts[1] = uints[0] - withdrawAmounts[0];
        } else {
            //make full release
            withdrawAmounts[1] = uints[0];
        }
        if (msg.sender != disputeParties[0]) {
            withdrawAmounts[0] = withdrawAmounts[0] + withdrawAmounts[1];
            withdrawAmounts[1] = withdrawAmounts[0] - withdrawAmounts[1];
            withdrawAmounts[0] = withdrawAmounts[0] - withdrawAmounts[1];
        }
        address anotherParty = getAnotherParty(addresses);
        //if sender is depositor
        withdrawAmounts[0] = transferWithFee(msg.sender, withdrawAmounts[0], addresses[2], paymentId);
        emit PaymentWithdrawnByDispute(paymentId, withdrawAmounts[0], dispute);
        lib.setWithdrawn(paymentId, msg.sender, true);
        if (withdrawAmounts[1] == 0 || lib.isWithdrawn(paymentId, anotherParty)) {
            setPaymentStatus(paymentId, PaymentStatus.CLOSED);
            emit PaymentClosedByDispute(paymentId, dispute);
        } else {
            //need to prevent withdraw by another flow, e.g. simple release or offer accepting
            setPaymentStatus(paymentId, PaymentStatus.RELEASED_BY_DISPUTE);
        }
    }
    
    /*------------------PRIVATE METHODS----------------------*/
    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount)
    public pure returns (bytes32) {return PaymentLib.getPaymentId(addresses, deal, amount);}

    function getDepositor(address[3] addresses) private pure returns (address) {return addresses[0];}

    function getBeneficiary(address[3] addresses) private pure returns (address) {return addresses[1];}

    function getToken(address[3] addresses) private pure returns (address) {return addresses[2];}

    function getAnotherParty(address[3] addresses) private view returns (address) {
        return msg.sender == addresses[0] ? addresses[1] : addresses[0];
    }

    function onlyParties(address[3] addresses) private view {require(msg.sender == addresses[0] || msg.sender == addresses[1]);}

    function onlyDepositor(address[3] addresses) private view {require(msg.sender == addresses[0]);}

    function onlyBeneficiary(address[3] addresses) private view {require(msg.sender == addresses[1]);}

    function getPaymentStatus(bytes32 paymentId)
    private view returns (PaymentStatus) {
        return PaymentStatus(lib.getPaymentStatus(paymentId));
    }

    function setPaymentStatus(bytes32 paymentId, PaymentStatus status)
    private {
        lib.setPaymentStatus(paymentId, uint8(status));
    }

    function checkStatus(bytes32 paymentId, PaymentStatus status)
    private view {
        require(lib.getPaymentStatus(paymentId) == uint8(status), "Required status does not match actual one");
    }

    function doCancelOffer(address[3] addresses, bytes32 deal, uint256 amount, address from)
    private returns(bytes32 paymentId) {
        onlyParties(addresses);
        paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CONFIRMED);
        uint256 offerAmount = lib.getOfferAmount(paymentId, from);
        require(offerAmount != 0, "Sender can not cancel offer of 0");
        lib.setOfferAmount(paymentId, from, 0);
    }

    /** @param addresses [depositor, beneficiary, token]
      * @param amounts [releaseAmount, refundAmount]
      */
    function doRelease(address[3] addresses, uint256[2] amounts, bytes32 paymentId)
    private {
        setPaymentStatus(paymentId, PaymentStatus.RELEASED);
        lib.setWithdrawAmount(paymentId, getBeneficiary(addresses), amounts[0]);
        lib.setWithdrawAmount(paymentId, getDepositor(addresses), amounts[1]);
    }

    function transferWithFee(address to, uint256 amount, address token, bytes32 paymentId)
    private returns (uint256 amountMinusFee) {
        require(amount != 0, "There is sense to invoke this method if withdraw amount is 0.");
        uint8 fee = 0;
        if (!lib.isFeePayed(paymentId)) {
            fee = lib.getPaymentFee(paymentId);
        }
        amountMinusFee = amount - calcFee(amount, fee);
        transfer(to, amountMinusFee, token);
    }   

    function transfer(address to, uint256 amount, address token)
    private {
        if (amount == 0) {
            return;
        }
        if (token == address(0)) {
            require(PaymentHolder(paymentHolder).withdrawEth(to, amount));
        } else {
            require(PaymentHolder(paymentHolder).withdrawToken(to, amount, token));
        }
    }

    function calcFee(uint amount, uint fee)
    private pure returns (uint256) {
        return ((amount * fee) / 100);
    }
}