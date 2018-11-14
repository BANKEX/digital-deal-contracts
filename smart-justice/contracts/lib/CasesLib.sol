pragma solidity ^0.4.18;

import "../EternalStorage.sol";

library CasesLib {

    enum CaseStatus {OPENED, VOTING, REVEALING, CLOSED, CANCELED}
    enum CaseCanceledCode { NOT_ENOUGH_VOTES, EQUAL_NUMBER_OF_VOTES }

    function getCase(address storageAddress, bytes32 caseId)
    public view returns ( address applicant, address respondent,
        bytes32 deal, uint amount,
        uint refereeAward,
        bytes32 title, uint8 status, uint8 canceledCode,
        bool won, bytes32 applicantDescriptionHash,
        bytes32 respondentDescriptionHash, bool isEthRefereeAward)
    {
        EternalStorage st = EternalStorage(storageAddress);
        applicant = st.getAddress(keccak256("case.applicant", caseId));
        respondent = st.getAddress(keccak256("case.respondent", caseId));
        deal = st.getBytes32(keccak256("case.deal", caseId));
        amount = st.getUint(keccak256("case.amount", caseId));
        won = st.getBool(keccak256("case.won", caseId));
        status = st.getUint8(keccak256("case.status", caseId));
        canceledCode = st.getUint8(keccak256("case.canceled.cause.code", caseId));
        refereeAward = st.getUint(keccak256("case.referee.award", caseId));
        title = st.getBytes32(keccak256("case.title", caseId));
        applicantDescriptionHash = st.getBytes32(keccak256("case.applicant.description", caseId));
        respondentDescriptionHash = st.getBytes32(keccak256("case.respondent.description", caseId));
        isEthRefereeAward = st.getBool(keccak256("case.referee.award.eth", caseId));
    }

    function getCaseDates(address storageAddress, bytes32 caseId)
    public view returns (uint date, uint votingDate, uint revealingDate, uint closeDate)
    {
        EternalStorage st = EternalStorage(storageAddress);
        date = st.getUint(keccak256("case.date", caseId));
        votingDate = st.getUint(keccak256("case.date.voting", caseId));
        revealingDate = st.getUint(keccak256("case.date.revealing", caseId));
        closeDate = st.getUint(keccak256("case.date.close", caseId));
    }

    function addCase(
        address storageAddress, address applicant, 
        address respondent, bytes32 deal, 
        uint amount, uint refereeAward,
        bytes32 title, string applicantDescription,
        uint[] dates, uint refereeCountNeed, bool isEthRefereeAward
    )
    public returns(bytes32 caseId)
    {
        EternalStorage st = EternalStorage(storageAddress);
        caseId = keccak256(applicant, respondent, deal, dates[0], title, amount);
        st.setAddress(keccak256("case.applicant", caseId), applicant);
        st.setAddress(keccak256("case.respondent", caseId), respondent);
        st.setBytes32(keccak256("case.deal", caseId), deal);
        st.setUint(keccak256("case.amount", caseId), amount);
        st.setUint(keccak256("case.date", caseId), dates[0]);
        st.setUint(keccak256("case.date.voting", caseId), dates[1]);
        st.setUint(keccak256("case.date.revealing", caseId), dates[2]);
        st.setUint(keccak256("case.date.close", caseId), dates[3]);
        st.setUint8(keccak256("case.status", caseId), 0);//OPENED
        st.setUint(keccak256("case.referee.award", caseId), refereeAward);
        st.setBytes32(keccak256("case.title", caseId), title);
        st.setBytes32(keccak256("case.applicant.description", caseId), keccak256(applicantDescription));
        st.setBool(keccak256("case.referee.award.eth", caseId), isEthRefereeAward);
        st.setUint(keccak256("case.referee.count.need", caseId), refereeCountNeed);
    }

    function setCaseWon(address storageAddress, bytes32 caseId, bool won) public
    {
        EternalStorage st = EternalStorage(storageAddress);
        st.setBool(keccak256("case.won", caseId), won);
    }

    function setCaseStatus(address storageAddress, bytes32 caseId, CaseStatus status) public
    {
        uint8 statusCode = uint8(status);
        require(statusCode >= 0 && statusCode <= uint8(CaseStatus.CANCELED));
        EternalStorage(storageAddress).setUint8(keccak256("case.status", caseId), statusCode);
    }

    function getCaseStatus(address storageAddress, bytes32 caseId) public view returns(CaseStatus) {
        return CaseStatus(EternalStorage(storageAddress).getUint8(keccak256("case.status", caseId)));
    }

    function setCaseCanceledCode(address storageAddress, bytes32 caseId, CaseCanceledCode cause) public
    {
        uint8 causeCode = uint8(cause);
        require(causeCode >= 0 && causeCode <= uint8(CaseCanceledCode.EQUAL_NUMBER_OF_VOTES));
        EternalStorage(storageAddress).setUint8(keccak256("case.canceled.cause.code", caseId), causeCode);
    }

    function getCaseDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date", caseId));
    }

    function getRespondentDescription(address storageAddress, bytes32 caseId) public view returns(bytes32) {
        return EternalStorage(storageAddress).getBytes32(keccak256("case.respondent.description", caseId));
    }

    function setRespondentDescription(address storageAddress, bytes32 caseId, string description) public {
        EternalStorage(storageAddress).setBytes32(keccak256("case.respondent.description", caseId), keccak256(description));
    }

    function getApplicant(address storageAddress, bytes32 caseId) public view returns(address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.applicant", caseId));
    }

    function getRespondent(address storageAddress, bytes32 caseId) public view returns(address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.respondent", caseId));
    }

    function getRefereeAward(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referee.award", caseId));
    }

    function getVotingDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date.voting", caseId));
    }

    function getRevealingDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date.revealing", caseId));
    }

    function getCloseDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date.close", caseId));
    }

    function getRefereeCountNeed(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referee.count.need", caseId));
    }

    function isEthRefereeAward(address storageAddress, bytes32 caseId) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("case.referee.award.eth", caseId));
    }
}