const ItemTrackingContract = artifacts.require("ItemTrackingContract");

module.exports = function(deployer) {
    deployer.deploy(ItemTrackingContract);
};
