// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.

/// @dev Updated soulbound erc20, removed EIP-2612 STORAGE support (We don't really need this, but interesting concept. @Todo Read more about EIP-2612)
/// @dev disable approve, transfer, transferFrom functions so that once assigned to user, user can't transfer the ownership of the tokens
// We throw error at every action performed by someone who's not within allowed list (whitelist, may be?)
error SoulBoundRestriction();
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                ERC20 LOGIC - SoulBound Implementation
    //////////////////////////////////////////////////////////////*/

    // TX Reverts with SoulBoundRestriction error - Making this token actually soul bound
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        revert SoulBoundRestriction();
    }

    // TX Reverts with SoulBoundRestriction error
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        revert SoulBoundRestriction();
    }

    // TX Reverts with SoulBoundRestriction error
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        revert SoulBoundRestriction();
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
