// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IERC4626
 * @dev Interface for ERC-4626 Tokenized Vault Standard
 * @notice This interface defines the standard functions and events for tokenized vaults
 * @dev Reference: https://eips.ethereum.org/EIPS/eip-4626
 */
interface IERC4626 is IERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Emitted when assets are deposited into the vault
     * @param sender The address that called the deposit function
     * @param owner The address that owns the shares
     * @param assets The amount of assets deposited
     * @param shares The amount of shares minted
     */
    event Deposit(
        address indexed sender,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Emitted when assets are withdrawn from the vault
     * @param sender The address that called the withdraw function
     * @param receiver The address that receives the assets
     * @param owner The address that owns the shares
     * @param assets The amount of assets withdrawn
     * @param shares The amount of shares burned
     */
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /*//////////////////////////////////////////////////////////////
                                 ASSET
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the address of the underlying asset used by the vault
     * @return The address of the underlying asset token
     */
    function asset() external view returns (address);

    /**
     * @dev Returns the total amount of assets managed by the vault
     * @return The total amount of assets in the vault
     */
    function totalAssets() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            DEPOSIT/WITHDRAW
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Deposits assets into the vault and mints shares to the receiver
     * @param assets The amount of assets to deposit
     * @param receiver The address that will receive the shares
     * @return shares The amount of shares minted
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Mints shares to the receiver by depositing assets
     * @param shares The amount of shares to mint
     * @param receiver The address that will receive the shares
     * @return assets The amount of assets deposited
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Withdraws assets from the vault by burning shares
     * @param assets The amount of assets to withdraw
     * @param receiver The address that will receive the assets
     * @param owner The address that owns the shares
     * @return shares The amount of shares burned
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @dev Redeems shares for assets
     * @param shares The amount of shares to redeem
     * @param receiver The address that will receive the assets
     * @param owner The address that owns the shares
     * @return assets The amount of assets withdrawn
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Converts assets to shares
     * @param assets The amount of assets to convert
     * @return shares The equivalent amount of shares
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Converts shares to assets
     * @param shares The amount of shares to convert
     * @return assets The equivalent amount of assets
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of assets that can be deposited for a receiver
     * @param receiver The address that will receive the shares
     * @return The maximum amount of assets that can be deposited
     */
    function maxDeposit(address receiver) external view returns (uint256);

    /**
     * @dev Returns the maximum amount of shares that can be minted for a receiver
     * @param receiver The address that will receive the shares
     * @return The maximum amount of shares that can be minted
     */
    function maxMint(address receiver) external view returns (uint256);

    /**
     * @dev Returns the maximum amount of assets that can be withdrawn by an owner
     * @param owner The address that owns the shares
     * @return The maximum amount of assets that can be withdrawn
     */
    function maxWithdraw(address owner) external view returns (uint256);

    /**
     * @dev Returns the maximum amount of shares that can be redeemed by an owner
     * @param owner The address that owns the shares
     * @return The maximum amount of shares that can be redeemed
     */
    function maxRedeem(address owner) external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                          DEPOSIT/WITHDRAW LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Preview the amount of shares that would be minted for a deposit
     * @param assets The amount of assets to deposit
     * @return shares The amount of shares that would be minted
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Preview the amount of assets required to mint shares
     * @param shares The amount of shares to mint
     * @return assets The amount of assets required
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Preview the amount of shares that would be burned for a withdrawal
     * @param assets The amount of assets to withdraw
     * @return shares The amount of shares that would be burned
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Preview the amount of assets that would be received for redeeming shares
     * @param shares The amount of shares to redeem
     * @return assets The amount of assets that would be received
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
}

