// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../libraries/ReferralCodeValidator.sol";

contract ReferralCodeValidatorTester {
    function testValidateCode(string memory referralCode)
        external
        pure
        returns (bytes32)
    {
        return ReferralCodeValidator.validateCode(referralCode);
    }
}
