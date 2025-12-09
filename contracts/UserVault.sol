// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./interfaces/IERC4626.sol";

/**
 * @title UserVault
 * @dev ERC-4626 compliant vault contract for managing user assets
 * @notice This contract implements the ERC-4626 standard for tokenized vaults
 */
contract UserVault is ERC20, IERC4626, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Underlying asset token
    IERC20 private immutable _asset;
    IERC20Metadata private immutable _assetMetadata;
    uint8 private immutable _decimals;

    // Factory address for protocol lookups
    address public immutable factory;

    // Protocol allocation tracking
    mapping(string => uint256) public protocolAllocations;
    mapping(string => uint256) public protocolDeployedAmounts;
    string[] private _supportedProtocols;

    // Custom errors for gas optimization
    error InvalidAmount();
    error InsufficientAssets();
    error InsufficientShares();
    error InvalidProtocol();
    error AllocationExceedsAssets();
    error ProtocolNotConfigured();

    /**
     * @dev Constructor initializes the vault with asset and owner
     * @param asset_ Address of the underlying ERC20 asset
     * @param owner_ Address of the vault owner
     * @param factory_ Address of the VaultFactory contract
     */
    constructor(
        address asset_,
        address owner_,
        address factory_
    ) ERC20("Vault Share", "VSHARE") Ownable(owner_) {
        require(asset_ != address(0), "Asset cannot be zero address");
        require(owner_ != address(0), "Owner cannot be zero address");
        require(factory_ != address(0), "Factory cannot be zero address");

        _asset = IERC20(asset_);
        _assetMetadata = IERC20Metadata(asset_);
        _decimals = _assetMetadata.decimals();
        factory = factory_;
    }

    /**
     * @dev Returns the number of decimals for vault shares
     * @return The number of decimals (matches underlying asset)
     */
    function decimals() public view virtual override(ERC20, IERC20Metadata) returns (uint8) {
        return _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                            ASSET
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the address of the underlying asset
     * @return The address of the asset token
     */
    function asset() public view virtual override returns (address) {
        return address(_assetMetadata);
    }

    /**
     * @dev Returns the total amount of assets managed by the vault
     * @return The total amount of assets (balance + deployed to protocols)
     */
    function totalAssets() public view virtual override returns (uint256) {
        return _asset.balanceOf(address(this)) + _getTotalDeployedAssets();
    }

    /**
     * @dev Internal function to calculate total deployed assets across protocols
     * @return Total amount of assets deployed to protocols
     */
    function _getTotalDeployedAssets() internal view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _supportedProtocols.length; i++) {
            total += protocolDeployedAmounts[_supportedProtocols[i]];
        }
        return total;
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Converts assets to shares
     * @param assets The amount of assets to convert
     * @return shares The equivalent amount of shares
     * @notice First deposit uses 1:1 ratio, subsequent deposits are proportional
     */
    function convertToShares(uint256 assets) public view virtual override returns (uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : (assets * supply) / totalAssets();
    }

    /**
     * @dev Converts shares to assets
     * @param shares The amount of shares to convert
     * @return assets The equivalent amount of assets
     */
    function convertToAssets(uint256 shares) public view virtual override returns (uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : (shares * totalAssets()) / supply;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAW
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Deposits assets into the vault and mints shares to the receiver
     * @param assets The amount of assets to deposit
     * @param receiver The address that will receive the shares
     * @return shares The amount of shares minted
     * @notice Requires approval from caller to vault for asset transfer
     */
    function deposit(uint256 assets, address receiver) 
        public 
        virtual 
        override 
        nonReentrant 
        whenNotPaused 
        returns (uint256 shares) 
    {
        if (assets == 0) revert InvalidAmount();
        
        shares = previewDeposit(assets);
        if (shares == 0) revert InvalidAmount();

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @dev Withdraws assets from the vault by burning shares
     * @param assets The amount of assets to withdraw
     * @param receiver The address that will receive the assets
     * @param owner The address that owns the shares
     * @return shares The amount of shares burned
     * @notice Requires allowance if caller is not the owner
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
        whenNotPaused 
        returns (uint256 shares) 
    {
        if (assets == 0) revert InvalidAmount();

        shares = previewWithdraw(assets);
        if (shares == 0) revert InvalidAmount();

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /**
     * @dev Mints shares to the receiver by depositing assets
     * @param shares The amount of shares to mint
     * @param receiver The address that will receive the shares
     * @return assets The amount of assets deposited
     * @notice Requires approval from caller to vault for asset transfer
     */
    function mint(uint256 shares, address receiver) 
        public 
        virtual 
        override 
        nonReentrant 
        whenNotPaused 
        returns (uint256 assets) 
    {
        if (shares == 0) revert InvalidAmount();

        assets = previewMint(shares);
        if (assets == 0) revert InvalidAmount();

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @dev Redeems shares for assets
     * @param shares The amount of shares to redeem
     * @param receiver The address that will receive the assets
     * @param owner The address that owns the shares
     * @return assets The amount of assets withdrawn
     * @notice Requires allowance if caller is not the owner
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
        whenNotPaused 
        returns (uint256 assets) 
    {
        if (shares == 0) revert InvalidAmount();

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        assets = previewRedeem(shares);
        if (assets == 0) revert InvalidAmount();

        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /*//////////////////////////////////////////////////////////////
                          DEPOSIT/WITHDRAW LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Preview the amount of shares that would be minted for a deposit
     * @param assets The amount of assets to deposit
     * @return shares The amount of shares that would be minted
     */
    function previewDeposit(uint256 assets) public view virtual override returns (uint256 shares) {
        return convertToShares(assets);
    }

    /**
     * @dev Preview the amount of assets required to mint shares
     * @param shares The amount of shares to mint
     * @return assets The amount of assets required
     */
    function previewMint(uint256 shares) public view virtual override returns (uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : (shares * totalAssets()) / supply;
    }

    /**
     * @dev Preview the amount of shares that would be burned for a withdrawal
     * @param assets The amount of assets to withdraw
     * @return shares The amount of shares that would be burned
     */
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : (assets * supply) / totalAssets();
    }

    /**
     * @dev Preview the amount of assets that would be received for redeeming shares
     * @param shares The amount of shares to redeem
     * @return assets The amount of assets that would be received
     */
    function previewRedeem(uint256 shares) public view virtual override returns (uint256 assets) {
        return convertToAssets(shares);
    }

    /**
     * @dev Returns the maximum amount of assets that can be deposited for a receiver
     * @param receiver The address that will receive the shares
     * @return The maximum amount of assets that can be deposited
     * @notice Currently returns max uint256, can be overridden for limits
     */
    function maxDeposit(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @dev Returns the maximum amount of shares that can be minted for a receiver
     * @param receiver The address that will receive the shares
     * @return The maximum amount of shares that can be minted
     * @notice Currently returns max uint256, can be overridden for limits
     */
    function maxMint(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @dev Returns the maximum amount of assets that can be withdrawn by an owner
     * @param owner The address that owns the shares
     * @return The maximum amount of assets that can be withdrawn
     */
    function maxWithdraw(address owner) public view virtual override returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }

    /**
     * @dev Returns the maximum amount of shares that can be redeemed by an owner
     * @param owner The address that owns the shares
     * @return The maximum amount of shares that can be redeemed
     */
    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }

    /*//////////////////////////////////////////////////////////////
                    PROTOCOL ALLOCATION MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Set allocation for a specific protocol
     * @param protocol Name of the protocol (e.g., "Aave", "Compound")
     * @param amount Amount of assets to allocate to the protocol
     * @notice Only owner can set allocations
     */
    function setProtocolAllocation(string memory protocol, uint256 amount) external onlyOwner {
        if (amount > totalAssets()) revert AllocationExceedsAssets();

        uint256 oldAmount = protocolAllocations[protocol];
        protocolAllocations[protocol] = amount;

        // Track protocol in supported list if not already present
        bool exists = false;
        for (uint256 i = 0; i < _supportedProtocols.length; i++) {
            if (keccak256(bytes(_supportedProtocols[i])) == keccak256(bytes(protocol))) {
                exists = true;
                break;
            }
        }
        if (!exists && amount > 0) {
            _supportedProtocols.push(protocol);
        }

        emit ProtocolAllocationChanged(protocol, oldAmount, amount);
    }

    /**
     * @dev Get allocation for a specific protocol
     * @param protocol Name of the protocol
     * @return The allocated amount for the protocol
     */
    function getProtocolAllocation(string memory protocol) external view returns (uint256) {
        return protocolAllocations[protocol];
    }

    /**
     * @dev Get total allocated amount across all protocols
     * @return Total allocated amount
     */
    function getTotalAllocated() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _supportedProtocols.length; i++) {
            total += protocolAllocations[_supportedProtocols[i]];
        }
        return total;
    }

    /**
     * @dev Get list of supported protocols
     * @return Array of protocol names
     */
    function getSupportedProtocols() external view returns (string[] memory) {
        return _supportedProtocols;
    }

    /*//////////////////////////////////////////////////////////////
                        PAUSE/UNPAUSE FUNCTIONALITY
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Pause vault operations (owner only)
     * @notice Prevents deposits, withdrawals, mints, and redeems
     */
    function pause() external onlyOwner {
        _pause();
        emit VaultPaused(address(this), msg.sender);
    }

    /**
     * @dev Unpause vault operations (owner only)
     * @notice Resumes all vault operations
     */
    function unpause() external onlyOwner {
        _unpause();
        emit VaultUnpaused(address(this), msg.sender);
    }

    /**
     * @dev Check if vault is paused
     * @return True if vault is paused
     */
    function isPaused() external view returns (bool) {
        return paused();
    }

    /*//////////////////////////////////////////////////////////////
                            AAVE INTEGRATION
    //////////////////////////////////////////////////////////////*/

    // Aave state
    address private aaveLendingPool;
    address private aaveAToken;
    uint256 private aaveBalance;

    /**
     * @dev Deploy assets to Aave lending pool
     * @param amount Amount of assets to deploy to Aave
     * @notice Only owner can deploy assets
     * @notice Requires Aave address to be configured via factory
     */
    function deployToAave(uint256 amount) external onlyOwner nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        if (aaveLendingPool == address(0)) revert ProtocolNotConfigured();
        if (amount > _asset.balanceOf(address(this))) revert InsufficientAssets();

        // Update tracking
        aaveBalance += amount;
        protocolDeployedAmounts["Aave"] = aaveBalance;

        // Transfer assets to Aave (placeholder - actual implementation requires Aave interface)
        _asset.safeTransfer(aaveLendingPool, amount);

        emit ProtocolDeployed("Aave", amount);
    }

    /**
     * @dev Withdraw assets from Aave lending pool
     * @param amount Amount of assets to withdraw from Aave
     * @notice Only owner can withdraw assets
     */
    function withdrawFromAave(uint256 amount) external onlyOwner nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        if (amount > aaveBalance) revert InsufficientAssets();

        // Update tracking
        aaveBalance -= amount;
        protocolDeployedAmounts["Aave"] = aaveBalance;

        // Withdraw from Aave (placeholder - actual implementation requires Aave interface)
        // In real implementation, would call Aave's withdraw function

        emit ProtocolWithdrawn("Aave", amount);
    }

    /**
     * @dev Get current Aave balance
     * @return The amount of assets currently deployed to Aave
     */
    function getAaveBalance() external view returns (uint256) {
        return aaveBalance;
    }

    /**
     * @dev Set Aave lending pool address (internal, called by factory)
     * @param lendingPool Address of Aave lending pool
     */
    function _setAaveAddress(address lendingPool) internal {
        aaveLendingPool = lendingPool;
    }

    /*//////////////////////////////////////////////////////////////
                        COMPOUND INTEGRATION
    //////////////////////////////////////////////////////////////*/

    // Compound state
    address private compoundCToken;
    uint256 private compoundBalance;

    /**
     * @dev Deploy assets to Compound protocol
     * @param amount Amount of assets to deploy to Compound
     * @notice Only owner can deploy assets
     * @notice Requires Compound address to be configured via factory
     */
    function deployToCompound(uint256 amount) external onlyOwner nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        if (compoundCToken == address(0)) revert ProtocolNotConfigured();
        if (amount > _asset.balanceOf(address(this))) revert InsufficientAssets();

        // Update tracking
        compoundBalance += amount;
        protocolDeployedAmounts["Compound"] = compoundBalance;

        // Transfer assets to Compound (placeholder - actual implementation requires Compound interface)
        _asset.safeTransfer(compoundCToken, amount);

        emit ProtocolDeployed("Compound", amount);
    }

    /**
     * @dev Withdraw assets from Compound protocol
     * @param amount Amount of assets to withdraw from Compound
     * @notice Only owner can withdraw assets
     */
    function withdrawFromCompound(uint256 amount) external onlyOwner nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        if (amount > compoundBalance) revert InsufficientAssets();

        // Update tracking
        compoundBalance -= amount;
        protocolDeployedAmounts["Compound"] = compoundBalance;

        // Withdraw from Compound (placeholder - actual implementation requires Compound interface)
        // In real implementation, would call Compound's redeem function

        emit ProtocolWithdrawn("Compound", amount);
    }

    /**
     * @dev Get current Compound balance
     * @return The amount of assets currently deployed to Compound
     */
    function getCompoundBalance() external view returns (uint256) {
        return compoundBalance;
    }

    /**
     * @dev Set Compound cToken address (internal, called by factory)
     * @param cToken Address of Compound cToken contract
     */
    function _setCompoundAddress(address cToken) internal {
        compoundCToken = cToken;
    }

    /**
     * @dev Initialize protocol addresses from factory (called after deployment)
     * @notice Can only be called by factory contract
     */
    function initializeProtocolAddresses() external {
        require(msg.sender == factory, "Only factory can initialize");
        
        // Get protocol addresses from factory
        // This requires VaultFactory to have getter functions
        // For now, this is a placeholder that can be extended
    }

    // Events
    event ProtocolAllocationChanged(string indexed protocol, uint256 oldAmount, uint256 newAmount);
    event ProtocolDeployed(string indexed protocol, uint256 amount);
    event ProtocolWithdrawn(string indexed protocol, uint256 amount);
    event VaultPaused(address indexed vault, address indexed pausedBy);
    event VaultUnpaused(address indexed vault, address indexed unpausedBy);
}

