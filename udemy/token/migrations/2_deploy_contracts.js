const FanToken = artifacts.require('FanToken');

module.exports = function (deployer) {
  deployer.deploy(FanToken);
};
