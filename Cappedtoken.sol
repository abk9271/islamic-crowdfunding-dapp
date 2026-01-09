// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, ERC20Capped, Ownable {
    constructor() ERC20("MyToken", "MTK") ERC20Capped(100000000000 * 10 ** decimals()) Ownable(msg.sender) {
        _mint(msg.sender, 1000000000 * 10 ** decimals());   
    }
// 100000000000000000000000000000
    function mint(address to,uint value) public onlyOwner {
        _mint(to, value);
    }
    // Resolve the conflict by overriding `_update`
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Capped) {
        ERC20Capped._update(from, to, value); // Delegates to ERC20Capped's implementation
    }
}
