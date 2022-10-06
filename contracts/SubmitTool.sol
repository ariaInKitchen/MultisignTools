// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/MultiSign.sol";
import "./interfaces/TimeLock.sol";
import "./interfaces/CToken.sol";

contract SubmitTool is Ownable {

    MultiSign public multisign;
    address public timelock;

    event QueueSubmitted(uint256 transactionId, uint256 length);
    event ExecuteSubmitted(uint256 transactionId, uint256 length);

    constructor(address _multisign, address _timelock) {
        require(_multisign != address(0) && _timelock != address(0), "invalid param");

        multisign = MultiSign(_multisign);
        timelock = _timelock;
    }

    function reduceReserves(address[] memory ftokens, uint[] memory amounts, uint256 eta)
            external onlyOwner returns(uint256 queueId, uint256 executeId) {
        require(ftokens.length == amounts.length, "ftokens and amounts not match");

        for (uint8 i = 0; i < ftokens.length; i++) {
            bytes memory ftokenAbi = abi.encodeWithSelector(CToken._reduceReserves.selector, amounts[i]);
            bytes memory timelockAbi = abi.encodeWithSelector(TimeLock.queueTransaction.selector, ftokens[i], 0, '', ftokenAbi, eta);

            uint256 trasactionId = multisign.submitTransaction(timelock, 0, timelockAbi);
            if (i == 0) {
                queueId = trasactionId;
            }
        }
        emit QueueSubmitted(queueId, ftokens.length);

        for (uint8 i = 0; i < ftokens.length; i++) {
            bytes memory ftokenAbi = abi.encodeWithSelector(CToken._reduceReserves.selector, amounts[i]);
            bytes memory timelockAbi = abi.encodeWithSelector(TimeLock.executeTransaction.selector, ftokens[i], 0, '', ftokenAbi, eta);

            uint256 trasactionId = multisign.submitTransaction(timelock, 0, timelockAbi);
            if (i == 0) {
                executeId = trasactionId;
            }
        }
        emit ExecuteSubmitted(executeId, ftokens.length);
    }

    function withdraw(address[] memory tokens, address receiver, uint256 eta)
            external onlyOwner returns(uint256 queueId, uint256 executeId) {
        require(tokens.length > 0, "invalid parameter");
        for (uint8 i = 0; i < tokens.length; i++) {
            bytes memory tokenAbi = abi.encodeWithSelector(ERC20.transfer.selector, receiver, ERC20(tokens[i]).balanceOf(timelock));
            bytes memory timelockAbi = abi.encodeWithSelector(TimeLock.queueTransaction.selector, tokens[i], 0, '', tokenAbi, eta);

            uint256 trasactionId = multisign.submitTransaction(timelock, 0, timelockAbi);
            if (i == 0) {
                queueId = trasactionId;
            }
        }
        emit QueueSubmitted(queueId, tokens.length);

        for (uint8 i = 0; i < tokens.length; i++) {
            bytes memory tokenAbi = abi.encodeWithSelector(ERC20.transfer.selector, receiver, ERC20(tokens[i]).balanceOf(timelock));
            bytes memory timelockAbi = abi.encodeWithSelector(TimeLock.executeTransaction.selector, tokens[i], 0, '', tokenAbi, eta);

            uint256 trasactionId = multisign.submitTransaction(timelock, 0, timelockAbi);
            if (i == 0) {
                executeId = trasactionId;
            }
        }
        emit ExecuteSubmitted(executeId, tokens.length);
    }

    function withdraw(address receiver, uint256 eta)
            external onlyOwner returns(uint256 queueId, uint256 executeId) {
        bytes memory queueAbi = abi.encodeWithSelector(TimeLock.queueTransaction.selector, receiver, timelock.balance, '', '', eta);
        queueId = multisign.submitTransaction(timelock, 0, queueAbi);
        emit QueueSubmitted(queueId, 1);

        bytes memory executeAbi = abi.encodeWithSelector(TimeLock.executeTransaction.selector, receiver, timelock.balance, '', '', eta);
        executeId = multisign.submitTransaction(timelock, 0, executeAbi);
        emit ExecuteSubmitted(executeId, 1);
    }

}
