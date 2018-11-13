pragma solidity ^0.4.22;

import "./zeppelin/Ownable.sol";
import "./interface/Token.sol";

contract PaymentHolder is Ownable {

    modifier onlyAllowed() {
        require(allowed[msg.sender]);
        _;
    }

    modifier onlyUpdater() {
        require(msg.sender == updater);
        _;
    }

    mapping(address => bool) public allowed;
    address public updater;

    /*-----------------MAINTAIN METHODS------------------*/

    function setUpdater(address _updater)
    external onlyOwner {
        updater = _updater;
    }

    function migrate(address newHolder, address[] tokens, address[] _allowed)
    external onlyOwner {
        require(PaymentHolder(newHolder).update.value(address(this).balance)(_allowed));
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 balance = Token(token).balanceOf(this);
            if (balance > 0) {
                require(Token(token).transfer(newHolder, balance));
            }
        }
    }

    function update(address[] _allowed)
    external payable onlyUpdater returns(bool) {
        for (uint256 i = 0; i < _allowed.length; i++) {
            allowed[_allowed[i]] = true;
        }
        return true;
    }

    /*-----------------OWNER FLOW------------------*/

    function allow(address to) 
    external onlyOwner { allowed[to] = true; }

    function prohibit(address to)
    external onlyOwner { allowed[to] = false; }

    /*-----------------ALLOWED FLOW------------------*/

    function depositEth()
    public payable onlyAllowed returns (bool) {
        //Default function to receive eth
        return true;
    }

    function withdrawEth(address to, uint256 amount)
    public onlyAllowed returns(bool) {
        require(address(this).balance >= amount, "Not enough ETH balance");
        to.transfer(amount);
        return true;
    }

    function withdrawToken(address to, uint256 amount, address token)
    public onlyAllowed returns(bool) {
        require(Token(token).balanceOf(this) >= amount, "Not enough token balance");
        require(Token(token).transfer(to, amount));
        return true;
    }

}