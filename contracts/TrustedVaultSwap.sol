// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;

import "./VaultSwap.sol";

import "../interfaces/IRegistry.sol";

contract TrustedVaultSwap is VaultSwap {
    address public governance;
    address public pendingGovernance;
    address public registry;

    modifier onlyRegisteredVault(address vault) {
        require(
            IRegistry(registry).latestVault(IVaultAPI(vault).token()) == vault,
            "Target vault should be the latest for token"
        );
        _;
    }

    modifier onlyGovernance {
        require(
            msg.sender == governance,
            "Only governance can call this function."
        );
        _;
    }
    modifier onlyPendingGovernance {
        require(
            msg.sender == pendingGovernance,
            "Only pendingGovernance can call this function."
        );
        _;
    }

    constructor(address _registry) public VaultSwap() {
        require(_registry != address(0), "Registry cannot be 0");

        governance = address(0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52);
        registry = _registry;
    }

    function _swap(
        address vaultFrom,
        address vaultTo,
        uint256 shares
    ) internal override onlyRegisteredVault(vaultTo) {
        super._swap(vaultFrom, vaultTo, shares);
    }

    function sweep(address _token) external onlyGovernance {
        IERC20(_token).safeTransfer(
            governance,
            IERC20(_token).balanceOf(address(this))
        );
    }

    function acceptGovernance() external onlyPendingGovernance {
        governance = msg.sender;
    }

    // setters
    function setPendingGovernance(address _pendingGovernance)
        external
        onlyGovernance
    {
        pendingGovernance = _pendingGovernance;
    }

    function setRegistry(address _registry) external onlyGovernance {
        require(_registry != address(0), "Registry cannot be 0");
        registry = _registry;
    }
}
