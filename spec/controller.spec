/*
    This is a specification file for smart contract verification with the Certora prover.
    For more information, visit: https://www.certora.com/

    This file is run with scripts/...
	Assumptions: 
*/

/*
    Declaration of contracts used in the spec 
*/
using DummyERC20A as erc20A
using DummyERC20A as erc20B
using OptionsFactory as optionsFactory


////////////////////////////////////////////////////////////////////////////
//                      Methods                                           //
////////////////////////////////////////////////////////////////////////////


/*
    Declaration of methods that are used in the rules.
    envfree indicate that the method is not dependent on the environment (msg.value, msg.sender).
    Methods that are not declared here are assumed to be dependent on env.
*/

methods {
	    

	isValidQToken(address qToken) returns (bool) envfree

	// QToken methods to be called with one of the tokens (DummyERC20*, DummyWeth)	
	mint(address account, uint256 amount) => DISPATCHER(true)
	burn(address account, uint256 amount) => DISPATCHER(true)
    underlyingAsset() returns (address) => DISPATCHER(true)
	strikeAsset() returns (address) => DISPATCHER(true)
	strikePrice() returns (uint256) => DISPATCHER(true)
	expiryTime() returns (uint256) => DISPATCHER(true)	
	isCall() returns (bool) => DISPATCHER(true)


	// IERC20 methods to be called with one of the tokens (DummyERC20A, DummyERC20A) or QToken
	balanceOf(address) => DISPATCHER(true) 
	totalSupply() => DISPATCHER(true)
	transferFrom(address from, address to, uint256 amount) => DISPATCHER(true)
	transfer(address to, uint256 amount) => DISPATCHER(true)


	// OptionsFactory
	optionsFactory.isQToken(address _qToken) returns (bool) envfree


	// CollateralToken
	mintCollateralToken(address,uint256,address,uint256) => NONDET
	burnCollateralToken(address,uint256,uint256) => NONDET
	balanceOf(address, uint256) => NONDET
	getCollateralTokenId(uint256) => DISPATCHER(true)
	getCollateralTokenInfoTokenAddress(uint256) returns (address)  => DISPATCHER(true)

}



////////////////////////////////////////////////////////////////////////////
//                       Ghost                                            //
////////////////////////////////////////////////////////////////////////////


// Ghosts are like additional function
// sumDeposits(address user) returns (uint256);
// This ghost represents the sum of all deposits to user
// sumDeposits(s) := sum(...[s].deposits[member] for all addresses member)




////////////////////////////////////////////////////////////////////////////
//                       Invariants                                       //
////////////////////////////////////////////////////////////////////////////



/* 	Rule: title  
 	Description:  
	Formula: 
	Notes: assumptions and simplification more explanations 
*/




////////////////////////////////////////////////////////////////////////////
//                       Rules                                            //
////////////////////////////////////////////////////////////////////////////
    
/* 	Rule: validQToken  
 	Description:  only valid QToken can be used in the state changing balances 
	Formula: 
	Notes: 
*/
rule validQtoken(  method f )  
{
	address qToken; 
	address qTokenFroCollateral;
	uint256 collateralTokenId;
	address to;
	uint256 amount;
	
	callFunctionWithParams(qToken, qTokenFroCollateral, collateralTokenId, to, amount, f);
	assert isValidQToken(qToken);   
}


rule check(address qToken) {
	env e;
	bool b = optionsFactory.isQToken(qToken);
	assert false;
}

rule sanity(method f)
{
	env e;
	calldataarg args;
	uint256 collateralTokenId;
	uint256 amount;
	neutralizePosition(e,collateralTokenId, amount);
	assert false;
}


////////////////////////////////////////////////////////////////////////////
//                       Helper Functions                                 //
////////////////////////////////////////////////////////////////////////////
    

// easy to use dispatcher

function callFunctionWithParams(address qToken, address qTokenFroCollateral, uint256 collateralTokenId, address to, uint256 amount, method f) {
	env e;

	if (f.selector == exercise(address,uint256).selector) {
		exercise(e, qToken, amount);
	}
	else if (f.selector == mintOptionsPosition(address,address,uint256).selector) {
		mintOptionsPosition(e, to, qToken, amount); 
	} 
	else if (f.selector == mintSpread(address,address,uint256).selector) {
		mintSpread(e, qToken, qTokenFroCollateral, amount);
	}
	else if (f.selector == exercise(address,uint256).selector) {
		exercise(e, qToken, amount);
	}
	else if (f.selector == claimCollateral(uint256,uint256).selector ) {
		claimCollateral(e, collateralTokenId, amount);
	}
	else if (f.selector == neutralizePosition(uint256,uint256).selector) {
		neutralizePosition(e, collateralTokenId, amount);
	}
	else{
		calldataarg args;
		f(e,args);
	}
}
