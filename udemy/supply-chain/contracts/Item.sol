// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

import "./ItemManager.sol";

contract Item {
    uint public princeInWei;
    uint public pricePaid;
    uint public index;
    
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWey, uint _index) {
        princeInWei = _priceInWey;
        index = _index;
        parentContract = _parentContract;
    }
    
    receive() external payable {
        require(pricePaid == 0, "Item is paid already");
        require(princeInWei == msg.value, "Only full payment is allowed");
        pricePaid += pricePaid;
        
        (bool success, ) = address(parentContract).call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("triggerPayment(uint256)", index)
        );
        
        require(success, "The transaction has failed");
    }
    
    fallback() external {
        
    }
}