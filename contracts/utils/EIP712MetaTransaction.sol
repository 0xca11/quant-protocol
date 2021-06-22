// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../../node_modules/@openzeppelin/contracts-upgradeable/drafts/EIP712Upgradeable.sol";
import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/IEIP712MetaTransaction.sol";
import "../interfaces/IController.sol";
import "../libraries/Actions.sol";
import {ActionArgs} from "../libraries/Actions.sol";

contract EIP712MetaTransaction is EIP712Upgradeable {
    using SafeMath for uint256;

    struct MetaAction {
        uint256 nonce;
        uint256 deadline;
        address from;
        ActionArgs[] actions;
    }

    bytes32 private constant _META_ACTION_TYPEHASH =
        keccak256(
            // solhint-disable-next-line max-line-length
            "MetaAction(uint256 nonce,uint256 deadline,address from,ActionArgs[] actions)ActionArgs(string actionType,address qToken,address secondaryAddress,address receiver,uint256 amount,uint256 collateralTokenId,bytes data)"
        );
    bytes32 private constant _ACTION_TYPEHASH =
        keccak256(
            // solhint-disable-next-line max-line-length
            "ActionArgs(string actionType,address qToken,address secondaryAddress,address receiver,uint256 amount,uint256 collateralTokenId,bytes data)"
        );

    mapping(address => uint256) private _nonces;

    event MetaTransactionExecuted(
        address indexed userAddress,
        address payable indexed relayerAddress,
        uint256 nonce
    );

    function executeMetaTransaction(
        MetaAction memory metaAction,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external payable returns (bytes memory) {
        require(
            _verify(metaAction.from, metaAction, r, s, v),
            "signer and signature don't match"
        );

        _nonces[metaAction.from] = _nonces[metaAction.from].add(1);

        // Append the metaAction.from at the end so that it can be extracted later
        // from the calling context (see _msgSender() below)
        (bool success, bytes memory returnData) =
            address(this).call(
                abi.encodePacked(
                    abi.encodeWithSelector(
                        IController(address(this)).operate.selector,
                        metaAction.actions
                    ),
                    metaAction.from
                )
            );

        require(success, "unsuccessful function call");
        emit MetaTransactionExecuted(
            metaAction.from,
            msg.sender,
            _nonces[metaAction.from]
        );
        return returnData;
    }

    function getNonce(address user) external view returns (uint256 nonce) {
        nonce = _nonces[user];
    }

    function initializeEIP712(string memory name, string memory version)
        public
        initializer
    {
        __EIP712_init(name, version);
    }

    function _msgSender() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }

    function _verify(
        address user,
        MetaAction memory metaAction,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal view returns (bool) {
        require(metaAction.nonce == _nonces[user], "invalid nonce");

        require(metaAction.deadline >= block.timestamp, "expired deadline");

        address signer =
            ecrecover(_hashTypedDataV4(_hashMetaAction(metaAction)), v, r, s);

        require(signer != address(0), "invalid signature");

        return signer == user;
    }

    // functions to generate hash representation of the struct objects
    function _hashAction(ActionArgs memory action)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    _ACTION_TYPEHASH,
                    keccak256(bytes(action.actionType)),
                    action.qToken,
                    action.secondaryAddress,
                    action.receiver,
                    action.amount,
                    action.collateralTokenId,
                    keccak256(action.data)
                )
            );
    }

    function _hashActions(ActionArgs[] memory actions)
        private
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory hashedActions = new bytes32[](actions.length);
        for (uint256 i = 0; i < actions.length; i++) {
            hashedActions[i] = _hashAction(actions[i]);
        }
        return hashedActions;
    }

    function _hashMetaAction(MetaAction memory metaAction)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    _META_ACTION_TYPEHASH,
                    metaAction.nonce,
                    metaAction.deadline,
                    metaAction.from,
                    keccak256(
                        abi.encodePacked(_hashActions(metaAction.actions))
                    )
                )
            );
    }
}
