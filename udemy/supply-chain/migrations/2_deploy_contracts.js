const Item = artifacts.require('Item');
const ItemManager = artifacts.require('ItemManager');
const Ownable = artifacts.require('Ownable');

module.exports = function (deployer) {
  deployer.deploy(ItemManager);
};
