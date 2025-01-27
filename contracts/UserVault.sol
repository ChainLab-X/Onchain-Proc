//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UserVault
 * @notice Core ERC-4626-compliant tokenized vault with ERC20 share tokens.
 * @dev
 * - Implements ERC-4626 interface for deposits, withdrawals, minting, and redemption
 * - Uses OpenZeppelin ERC20 for share tokens
 * - Rounding:
 *    - convertToShares/previewDeposit: round down (user gets at most expected shares)
 *    - previewMint: round up (user provides at least required assets)
 *    - previewWithdraw: round up (burn at least enough shares to cover assets)
 *    - convertToAssets/previewRedeem: round down (user receives at most expected assets)
 * - First deposit mints shares at 1:1 with assets (decimals matched to underlying)
 * - Owner can set an optional deposit limit (cap) on total managed assets
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./interfaces/IERC4626.sol";

contract UserVault is ERC20, IERC4626, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @dev Underlying ERC20 asset managed by this vault
    IERC20 private immutable _asset;
    IERC20Metadata private immutable _assetMetadata;

    /// @dev Share token decimals mirror the underlying asset's decimals
    uint8 private immutable _vaultDecimals;

    /// @notice Maximum total assets the vault is allowed to manage (owner-controlled)
    /// @dev Defaults to unlimited. If set below current totalAssets, new deposits/mints will be blocked.
    uint256 public depositLimit;

    /// @notice Emitted when the deposit limit is updated by the owner
    event DepositLimitUpdated(uint256 oldLimit, uint256 newLimit);

    /**
     * @notice Initialize the UserVault
     * @param asset_ Address of the underlying ERC20 asset
     * @param name_ ERC20 share token name
     * @param symbol_ ERC20 share token symbol
     * @param initialOwner Address that will be granted ownership
     */
    constructor(
        address asset_,
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        require(asset_ != address(0), "Asset address is zero");
        _asset = IERC20(asset_);
        _assetMetadata = IERC20Metadata(asset_);
        _vaultDecimals = _assetMetadata.decimals();

        // Unlimited by default
        depositLimit = type(uint256).max;
    }

    /**
     * @notice Returns the decimals of the share token (matches the underlying asset)
     */
    function decimals() public view virtual override returns (uint8) {
        return _vaultDecimals;
    }

    /*//////////////////////////////////////////////////////////////
                                ERC-4626: ASSET
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Address of the underlying asset
     */
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }

    /**
     * @notice Total amount of underlying assets held by the vault
     */
    function totalAssets() public view virtual override returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    /*//////////////////////////////////////////////////////////////
                             OWNER CONTROLS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Set a cap on total assets the vault can manage
     * @dev Set to type(uint256).max for "unlimited"
     * @param newLimit New deposit limit
     */
    function setDepositLimit(uint256 newLimit) external onlyOwner {
        // Prevent setting a cap lower than what's already managed
        require(newLimit >= totalAssets(), "New limit below current assets");
        uint256 old = depositLimit;
        depositLimit = newLimit;
        emit DepositLimitUpdated(old, newLimit);
    }

    /*//////////////////////////////////////////////////////////////
                         ERC-4626: DEPOSIT/WITHDRAW
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposit assets into the vault and mint shares to receiver
     * @param assets Amount of underlying assets to deposit
     * @param receiver Address receiving the minted shares
     * @return shares Amount of shares minted
     */
    function deposit(uint256 assets, address receiver)
        public
        virtual
        override
        nonReentrant
        returns (uint256 shares)
    {
        require(assets > 0, "Zero assets");
        require(receiver != address(0), "Receiver zero");

        // Enforce deposit cap
        require(assets <= maxDeposit(receiver), "Deposit exceeds limit");

        shares = previewDeposit(assets);
        require(shares > 0, "Zero shares");

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @notice Mint shares for receiver by depositing the required assets
     * @param shares Amount of shares to mint
     * @param receiver Address receiving the minted shares
     * @return assets Amount of assets deposited
     */
    function mint(uint256 shares, address receiver)
        public
        virtual
        override
        nonReentrant
        returns (uint256 assets)
    {
        require(shares > 0, "Zero shares");
        require(receiver != address(0), "Receiver zero");

        // Enforce deposit cap via maxMint
        require(shares <= maxMint(receiver), "Mint exceeds limit");

        assets = previewMint(shares);
        require(assets > 0, "Zero assets");

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @notice Withdraw assets to receiver by burning owner's shares
     * @param assets Amount of assets to withdraw
     * @param receiver Address receiving withdrawn assets
     * @param owner Address whose shares will be burned
     * @return shares Amount of shares burned
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    )
        public
        virtual
        override
        nonReentrant
        returns (uint256 shares)
    {
        require(assets > 0, "Zero assets");
        require(receiver != address(0), "Receiver zero");
        require(owner != address(0), "Owner zero");

        shares = previewWithdraw(assets);
        require(shares > 0, "Insufficient shares");

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /**
     * @notice Redeem shares for assets to receiver
     * @param shares Amount of shares to redeem
     * @param receiver Address receiving the assets
     * @param owner Address whose shares will be burned
     * @return assets Amount of assets withdrawn
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    )
        public
        virtual
        override
        nonReentrant
        returns (uint256 assets)
    {
        require(shares > 0, "Zero shares");
        require(receiver != address(0), "Receiver zero");
        require(owner != address(0), "Owner zero");

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        assets = previewRedeem(shares);
        require(assets > 0, "Zero assets");

        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /*//////////////////////////////////////////////////////////////
                        ERC-4626: ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Convert assets to shares (rounding down)
     * @param assets Amount of assets
     * @return shares Equivalent shares
     */
    function convertToShares(uint256 assets)
        public
        view
        virtual
        override
        returns (uint256 shares)
    {
        uint256 supply = totalSupply();
        uint256 total = totalAssets();
        return supply == 0 ? assets : Math.mulDiv(assets, supply, total, Math.Rounding.Floor);
    }

    /**
     * @notice Convert shares to assets (rounding down)
     * @param shares Amount of shares
     * @return assets Equivalent assets
     */
    function convertToAssets(uint256 shares)
        public
        view
        virtual
        override
        returns (uint256 assets)
    {
        uint256 supply = totalSupply();
        uint256 total = totalAssets();
        return supply == 0 ? shares : Math.mulDiv(shares, total, supply, Math.Rounding.Floor);
    }

    /**
     * @notice Maximum assets that can be deposited for receiver
     * @dev Enforces owner-controlled deposit limit
     */
    function maxDeposit(address /*receiver*/)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 limit = depositLimit;
        if (limit == type(uint256).max) return type(uint256).max;

        uint256 current = totalAssets();
        if (current >= limit) return 0;
        return limit - current;
    }

    /**
     * @notice Maximum shares that can be minted for receiver
     * @dev Derived from maxDeposit() based on current exchange rate
     */
    function maxMint(address receiver)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 maxAssets = maxDeposit(receiver);
        uint256 supply = totalSupply();
        if (supply == 0) {
            // First mint: 1:1 mapping
            return maxAssets;
        }
        // floor
        return Math.mulDiv(maxAssets, supply, totalAssets(), Math.Rounding.Floor);
    }

    /**
     * @notice Maximum assets that can be withdrawn by owner
     */
    function maxWithdraw(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return convertToAssets(balanceOf(owner));
    }

    /**
     * @notice Maximum shares that can be redeemed by owner
     */
    function maxRedeem(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return balanceOf(owner);
    }

    /*//////////////////////////////////////////////////////////////
                       ERC-4626: PREVIEW OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Preview shares minted for a given asset deposit (round down)
     */
    function previewDeposit(uint256 assets)
        public
        view
        virtual
        override
        returns (uint256 shares)
    {
        return convertToShares(assets);
    }

    /**
     * @notice Preview assets required to mint given shares (round up)
     */
    function previewMint(uint256 shares)
        public
        view
        virtual
        override
        returns (uint256 assets)
    {
        uint256 supply = totalSupply();
        uint256 total = totalAssets();
        return supply == 0 ? shares : Math.mulDiv(shares, total, supply, Math.Rounding.Ceil);
    }

    /**
     * @notice Preview shares burned to withdraw given assets (round up)
     */
    function previewWithdraw(uint256 assets)
        public
        view
        virtual
        override
        returns (uint256 shares)
    {
        uint256 supply = totalSupply();
        uint256 total = totalAssets();
        return supply == 0 ? assets : Math.mulDiv(assets, supply, total, Math.Rounding.Ceil);
    }

    /**
     * @notice Preview assets received for redeeming given shares (round down)
     */
    function previewRedeem(uint256 shares)
        public
        view
        virtual
        override
        returns (uint256 assets)
    {
        return convertToAssets(shares);
    }
}
