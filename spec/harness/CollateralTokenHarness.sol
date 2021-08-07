pragma solidity ^0.7.0;
pragma abicoder v2;

import "../../contracts/options/CollateralToken.sol";

contract CollateralTokenHarness is CollateralToken {
    ////////////////////////////////////////////////////////////////////////////
    //                         Constructors and inits                         //
    ////////////////////////////////////////////////////////////////////////////
    constructor(address _quantConfig)
        public
        CollateralToken(_quantConfig, "", "")
    {}

    ////////////////////////////////////////////////////////////////////////////
    //                        Getters for The Internals                       //
    ////////////////////////////////////////////////////////////////////////////
    function getCollateralTokenId(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return collateralTokenIds[tokenId];
    }

    function getCollateralTokenInfoTokenAddress(uint256 collateralTokenInfoId)
        public
        view
        returns (address)
    {
        return idToInfo[collateralTokenInfoId].qTokenAddress;
    }

    function getCollateralTokenInfoTokenAsCollateral(
        uint256 collateralTokenInfoId
    ) public view returns (address) {
        return idToInfo[collateralTokenInfoId].qTokenAsCollateral;
    }

    function idToInfoContainsId(uint256 key) public view returns (bool) {
        if (idToInfo[key].qTokenAddress == address(0)) {
            return false;
        }
        return true;
    }

    function collateralTokenIdsContainsId(uint256 key, uint256 i)
        public
        view
        returns (bool)
    {
        if (collateralTokenIds[i] == key) {
            return true;
        }
        return false;
    }

    function tokenSuppliesContainsCollateralToken(uint256 key)
        public
        view
        returns (bool)
    {
        if (tokenSupplies[key] == uint256(0)) {
            return false;
        }
        return true;
    }

    function getTokenSupplies(uint256 key) public view returns (uint256) {
        return tokenSupplies[key];
    }

    ////////////////////////////////////////////////////////////////////////////
    //                       Simplifiers and override                         //
    ////////////////////////////////////////////////////////////////////////////
    /*function ...() public view returns (uint256) {
        return ...;
    }*/
}
