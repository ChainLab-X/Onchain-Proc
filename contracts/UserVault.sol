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
}

