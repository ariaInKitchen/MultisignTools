// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/MultiSign.sol";
import "./interfaces/TimeLock.sol";
import "./interfaces/CToken.sol";

contract ConfirmTool is Ownable {
    MultiSign public multisign;

    constructor(address _multisign) {
        require(_multisign != address(0), "invalid param");

        multisign = MultiSign(_multisign);
    }

    function confirm(uint256[] memory ids) external onlyOwner {
        for (uint8 i = 0; i < ids.length; i++) {
            multisign.confirmTransaction(ids[i]);
        }
    }
}
