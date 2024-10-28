// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {BaseTest} from "./baseTest.t.sol";
import {InfiniCardVault} from "@InfiniCard/InfiniCardVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract InfiniCardVaultTesting is BaseTest {
    function setUp() override public {
        super.setUp();
    }

    function test_invest() public {
        deal(USDCAddress, address(this), 100000 * 10**6);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), 100000 * 10**6);
        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniMorphoStrategy),
            100000 * 10**6,
            ""
        );
    }

    function test_withdraw() public {
        deal(USDCAddress, address(this), 100000 * 10**6);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), 100000 * 10**6);
        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniMorphoStrategy),
            100000 * 10**6,
            ""
        );

        require(IERC20(USDCAddress).balanceOf(address(infiniCardVault)) == 0, "USDT balance should be 0");
        vm.warp(block.timestamp + 2 weeks);

        uint256 beforeAmount = IERC20(USDCAddress).balanceOf(shaneson);
        uint256 actualAmount = infiniCardVault.withdrawToCEX(
            USDCAddress, 
            100000 * 10**6, 
            shaneson, 
            address(infiniMorphoStrategy),
            ""
        );

        require(IERC20(USDCAddress).balanceOf(shaneson) == beforeAmount + actualAmount, "USDT balance should be actualAmount");
    }

    function test_baseStrategyManager_transfer_role() public {
        address newAdmin = address(0x789);
        bytes32 adminRole = infiniEthenaStrategyManager.DEFAULT_ADMIN_ROLE();
        bytes32 ADMIN_ROLE = keccak256("ADMIN_ROLE");

        // 确保shaneson拥有所有角色
        require(infiniEthenaStrategyManager.hasRole(adminRole, shaneson), "shaneson should have admin role");
        require(infiniEthenaStrategyManager.hasRole(ADMIN_ROLE, shaneson), "shaneson should have ADMIN_ROLE");

        // 转移所有角色
        vm.startPrank(shaneson);
        infiniEthenaStrategyManager.grantRole(ADMIN_ROLE, newAdmin);
        infiniEthenaStrategyManager.grantRole(adminRole, newAdmin);

        infiniEthenaStrategyManager.revokeRole(ADMIN_ROLE, shaneson);
        infiniEthenaStrategyManager.revokeRole(adminRole, shaneson);

        vm.stopPrank();

        // 确保新地址拥有所有角色
        require(infiniEthenaStrategyManager.hasRole(adminRole, newAdmin), "New address should have admin role");
        require(infiniEthenaStrategyManager.hasRole(ADMIN_ROLE, newAdmin), "New address should have ADMIN_ROLE");

        // 确保shaneson不再拥有任何角色
        require(!infiniEthenaStrategyManager.hasRole(adminRole, shaneson), "shaneson should not have admin role");
        require(!infiniEthenaStrategyManager.hasRole(ADMIN_ROLE, shaneson), "shaneson should not have ADMIN_ROLE");
    }

    function test_baseStrategy_transfer_role() public {
        address newAdmin = address(0x456);
        bytes32 adminRole = infiniCardVault.DEFAULT_ADMIN_ROLE();
        bytes32 ADMIN_ROLE = keccak256("ADMIN_ROLE");

        // 确保shaneson拥有所有角色
        require(infiniMorphoStrategy.hasRole(adminRole, shaneson), "shaneson should have admin role");
        require(infiniMorphoStrategy.hasRole(ADMIN_ROLE, shaneson), "shaneson should have ADMIN_ROLE");

        // 转移所有角色
        vm.startPrank(shaneson);
        infiniMorphoStrategy.grantRole(ADMIN_ROLE, newAdmin);
        infiniMorphoStrategy.grantRole(adminRole, newAdmin);

        infiniMorphoStrategy.revokeRole(ADMIN_ROLE, shaneson);
        infiniMorphoStrategy.revokeRole(adminRole, shaneson);

        vm.stopPrank();

        // 确保新地址拥有所有角色
        require(infiniMorphoStrategy.hasRole(adminRole, newAdmin), "New address should have admin role");
        require(infiniMorphoStrategy.hasRole(ADMIN_ROLE, newAdmin), "New address should have ADMIN_ROLE");

        // 确保shaneson不再拥有任何角色
        require(!infiniMorphoStrategy.hasRole(adminRole, shaneson), "shaneson should not have admin role");
        require(!infiniMorphoStrategy.hasRole(ADMIN_ROLE, shaneson), "shaneson should not have ADMIN_ROLE");
    }

    function test_infinivault_transfer_role() public {
        address newAdmin = address(0x123);
        bytes32 adminRole = infiniCardVault.DEFAULT_ADMIN_ROLE();
        bytes32 ADMIN_ROLE = keccak256("ADMIN_ROLE");
        bytes32 INFINI_BACKEND_ROLE = keccak256("INFINI_BACKEND_ROLE");
        bytes32 STRATEGY_OPERATOR_ROLE = keccak256("STRATEGY_OPERATOR_ROLE");

        // 确保shaneson拥有所有角色
        require(infiniCardVault.hasRole(adminRole, shaneson), "shaneson should have admin role");

        require(infiniCardVault.hasRole(ADMIN_ROLE, shaneson), "shaneson should have ADMIN_ROLE");
        require(infiniCardVault.hasRole(INFINI_BACKEND_ROLE, shaneson), "shaneson should have INFINI_BACKEND_ROLE");
        require(infiniCardVault.hasRole(STRATEGY_OPERATOR_ROLE, shaneson), "shaneson should have STRATEGY_OPERATOR_ROLE");

        // 转移所有角色
        vm.startPrank(shaneson);
        infiniCardVault.grantRole(ADMIN_ROLE, newAdmin);
        infiniCardVault.grantRole(INFINI_BACKEND_ROLE, newAdmin);
        infiniCardVault.grantRole(STRATEGY_OPERATOR_ROLE, newAdmin);
        infiniCardVault.grantRole(adminRole, newAdmin);

        infiniCardVault.revokeRole(ADMIN_ROLE, shaneson);
        infiniCardVault.revokeRole(INFINI_BACKEND_ROLE, shaneson);
        infiniCardVault.revokeRole(STRATEGY_OPERATOR_ROLE, shaneson);
        infiniCardVault.revokeRole(adminRole, shaneson);

        vm.stopPrank();

        // 确保新地址拥有所有角色
        require(infiniCardVault.hasRole(adminRole, newAdmin), "New address should have admin role");
        require(infiniCardVault.hasRole(ADMIN_ROLE, newAdmin), "New address should have ADMIN_ROLE");
        require(infiniCardVault.hasRole(INFINI_BACKEND_ROLE, newAdmin), "New address should have INFINI_BACKEND_ROLE");
        require(infiniCardVault.hasRole(STRATEGY_OPERATOR_ROLE, newAdmin), "New address should have STRATEGY_OPERATOR_ROLE");

        // 确保shaneson不再拥有任何角色
        require(!infiniCardVault.hasRole(adminRole, shaneson), "shaneson should not have admin role");
        require(!infiniCardVault.hasRole(ADMIN_ROLE, shaneson), "shaneson should not have ADMIN_ROLE");
        require(!infiniCardVault.hasRole(INFINI_BACKEND_ROLE, shaneson), "shaneson should not have INFINI_BACKEND_ROLE");
        require(!infiniCardVault.hasRole(STRATEGY_OPERATOR_ROLE, shaneson), "shaneson should not have STRATEGY_OPERATOR_ROLE");
    }
}