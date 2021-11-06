// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable{
    
    enum SupplyChainState{Created, Paid, Delivered}
    
    struct ItemStruct {
        Item itemInstance;
        string identifier;
        uint itemPrice;
        ItemManager.SupplyChainState state;
    }
    
    mapping(uint => ItemStruct) public items;
    uint itemIndex;
    
    event SupplyChainChange(uint _itemIndex, uint _step, address _itemAddress);
    
    function createItem(string calldata _identifier, uint _itemPrice) public onlyOwner{
        items[itemIndex].itemInstance = new Item(this, _itemPrice, itemIndex);
        items[itemIndex].identifier = _identifier;
        items[itemIndex].itemPrice = _itemPrice;
        items[itemIndex].state = SupplyChainState.Created;
        emit SupplyChainChange(itemIndex, uint(items[itemIndex].state), address(items[itemIndex].itemInstance));
        itemIndex++;
    }
    
    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex].state == SupplyChainState.Created, "Item is already payed");
        require(items[_itemIndex].itemPrice == msg.value, "Only full payments accepted");
        
        items[_itemIndex].state = SupplyChainState.Paid;
        
        emit SupplyChainChange(itemIndex, uint(items[itemIndex].state), address(items[_itemIndex].itemInstance));
    }
    
    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex].state == SupplyChainState.Paid, "Item is already delivered");
        
        items[_itemIndex].state = SupplyChainState.Delivered;
        
        emit SupplyChainChange(itemIndex, uint(items[itemIndex].state), address(items[_itemIndex].itemInstance));
        
    }
}