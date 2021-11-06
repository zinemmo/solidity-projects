// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/access/Ownable.sol";

contract SharedWallet is Ownable{

  mapping(address => uint) private allowance;
  uint fluidBalance;
  
  /*   
  * Events
  */
  event changeInAllowance(address indexed _calledBy, address indexed _affectedBy, uint _oldAmount, uint _newAmount);
  
  event contractBalanceChange(address indexed _calledBy, address indexed _transferTo, bytes data, string _operation);
  
  /*   
  * Modifiers
  */
  modifier notEnoughContractFunds(uint _amount) {
    require(_amount <= address(this).balance, "The account does not have the available funds to withdraw");
    _;
  }
  
  modifier availableAmount(uint _amount) {
    require(_amount <= address(this).balance, "There are not enough funds on this contract");
    _;
  }
  
  /*   
  * Allowance funcionts
  */
  function addAllowance(address _to, uint _amount) public payable onlyOwner availableAmount(_amount) {
    emit changeInAllowance(msg.sender, _to, allowance[_to], allowance[_to] + _amount);
    allowance[_to] += _amount;
    fluidBalance -= _amount;
  }

  function deductAllowance(address _to, uint _amount) internal {
    emit changeInAllowance(msg.sender, _to, allowance[_to], allowance[_to] - _amount);
    allowance[_to] -= _amount;
  }
  
  function withdrawAllowance(address _to, uint _amount) public payable notEnoughContractFunds(_amount){
    if(msg.sender == owner()) {
      require(allowance[_to] >= _amount, "Not enough funds on the allowance acount of the desired user");
      payable(_to).transfer(_amount);
      deductAllowance(_to, _amount);
    } else {
      require(allowance[msg.sender] >= _amount, "Not enough funds to withdraw on your account");
      payable(msg.sender).transfer(_amount);
      deductAllowance(msg.sender, _amount);
    }
  }
  
  function getOwnAllowance() external view returns(uint){
      return allowance[msg.sender];
  }

  /*   
  * Contract funcionts
  */
  function withdrawBalance(address _to, uint _amount) public payable onlyOwner {
    (bool success, bytes memory data) = payable(_to).call{value: _amount}("");
    require(success, "Transfer failed");
    emit contractBalanceChange(msg.sender, _to, data, "Removed from balance");
  }
  
  function addContractBalance() external payable onlyOwner {
      fluidBalance += msg.value;
      emit contractBalanceChange(msg.sender, address(this), abi.encodePacked(msg.value), "Added to balance");
  }

  /*   
  * Function Overrides
  */
  function renounceOwnership() public override pure {
      revert("You can't renounce the ownership of this contract");
  }
  
  function transferOwnership(address newOwner) public override pure {
    revert("You can't transfer the ownership of this contract");
  }
}