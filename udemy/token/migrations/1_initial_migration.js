const FanToken = artifacts.require('FanToken');

module.exports = async (deployer) => {
  await deployer.deploy(FanToken);
};
