var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};

var ERC20Template = artifacts.require("./ERC20Template.sol");

module.exports = function(deployer) {
  const _totalSupply = 10000000;
  const _decimals = 18;
  const _name = "Test";
  const _symbol = "Test";
  const _isMintable = true;
  const _isBurnable = true;
  const _owner = "0xc7d0e27bfa4895eb5c748c377d799912d515bfcd";
  deployer.deploy(
  	ERC20Template,
  	_totalSupply,
  	_decimals,
  	_name,
  	_symbol,
  	_isMintable,
  	_isBurnable,
  	_owner
  );
};