pragma solidity ^0.5.0;

import "./ICOTemplate.sol";
import "./ERC20Template.sol";
import "./AirdropTemplate.sol";

contract ContractFactory {
    
    /**
    * Event is broadcast to the Ethereum blockchain to signify that
    * a new ERC20 token has been deployed from the ContractFactory
    * */
    event TokenDeployed (
        address indexed by,
        address indexed addressOfToken,
        string symbolOfToken
    );
    
    
    /**
    * Event is broadcast to the Ethereum blockchain to signify that
    * a new Airdrop contract has been deployed from the ContractFactory
    * */
    event AirdropDeployed (
        address indexed by,
        address indexed addressOfAirdrop,
        string symbolOfToken
    );
    
    
    /**
    * Event is broadcast to the Ethereum blockchain to signify that
    * a new ICO contract has been deployed from the ContractFactory
    * */
    event ICODeployed (
        address indexed by,
        address indexed addressOfICO,
        string symbolOfToken
    );
    
    

    /**
    * Allows users to deploy an ERC20 token without any minting or burning functionality. 
    **/
    function deploySimpleToken(uint _totalSupply, uint8 _decimals, string memory _name, string memory _symbol) public {
        _deployToken(_totalSupply, _decimals, _name, _symbol, false, false);
    }


    /**
    * Allows users to deploy an ERC20 token which does have minting functionality but 
    * no burning functionality. 
    **/
    function deployMintableToken(uint _totalSupply, uint8 _decimals, string memory _name, string memory _symbol) public {
        _deployToken(_totalSupply, _decimals, _name, _symbol, true, false);
    }
    
    
    /**
    * Allows users to deploy an ERC20 token which does have burning functionality but
    * no minting functionality.
    **/
    function deployBurnableToken(uint _totalSupply, uint8 _decimals, string memory _name, string memory _symbol) public {
        _deployToken(_totalSupply, _decimals, _name, _symbol, false, true);
    }
    
    
    /**
    * Allows users to deploy an ERC20 token which has both the minting and burning 
    * functionalities. 
    **/
    function deployMintableBurnableToken(uint _totalSupply, uint8 _decimals, string memory _name, string memory _symbol) public {
        _deployToken(_totalSupply, _decimals, _name, _symbol, true, true);
    }
    
    
    /**
    * This funciton is invoked internally by the 4 token deployment functions above. 
    *
    * @param _totalSupply - The total amount of tokens to be created.
    * @param _decimals - The number of decimals the token will have. 
    * @param _name - The name of the token.
    * @param _symbol - The ticker of the token.
    * @param _isMintable - Boolean value to make token mintable or not.
    * @param _isBurnable - Boolean value to make token burnable or not. 
    **/
    function _deployToken(
        uint _totalSupply, uint8 _decimals, string memory _name, string memory _symbol,bool _isMintable, bool _isBurnable) internal  {
        ERC20Template token = new ERC20Template(_totalSupply, _decimals, _name, _symbol, _isMintable, _isBurnable, msg.sender);
        //Broadcast the token deployment event to the Ethereum network.
        emit TokenDeployed(
            msg.sender, 
            address(token),
            _symbol
        );
    }
    
    
    /**
    * Allows users to deploy an airdrop contract for an ERC20 token. 
    *
    * @param _tokenAddress - The contract address of the ERC20 token. 
    **/
    function deployAirdropContract(address _tokenAddress) public {
        AirdropTemplate airdrop = new AirdropTemplate(_tokenAddress, msg.sender);
        //Broadcast the airdrop contract deployment event to the Ethereum network. 
        emit AirdropDeployed(
            msg.sender,
            address(airdrop),
            ERC20Template(_tokenAddress).getSymbol()
        );
    }
    
    
    /**
    * Allows users to deploy an ICO contract for an ERC20 token.
    *
    * @param _tokenAddress - The contract address of the ERC20 token. 
    * @param _tokenDecimals - The amount of decimals the token has. 
    * @param _ethSoftCap - The minimum amount of ETH that needs to be raised.
    * @param _rate - The ETH exchange rate at which the token will be sold (i.e., 1 ETH = 100 tokens)
    **/
    function deployICOContract(address _tokenAddress, uint _tokenDecimals, uint _ethSoftCap, uint _rate, uint _durationInDays) public {
        ICOTemplate ICO = new ICOTemplate(_tokenAddress,_tokenDecimals,_ethSoftCap,_rate,_durationInDays,msg.sender);
        //Broadcast the ICO contract deployment event to the Ethereum network. 
        emit ICODeployed (
            msg.sender,
            address(ICO),
            ERC20Template(_tokenAddress).getSymbol()
        );
    }
}
