// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import {InfiniCardVault} from "@InfiniCard/InfiniCardVault.sol";
import {InfiniMorphoStrategyVault} from "@InfiniCard/strategies/morpho/InfiniMorphoStrategyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IStrategyManager} from "@InfiniCard/interfaces/IStrategyManager.sol";


contract OnlineTesting is Test {
    address constant USDCAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant admin = 0x9881301e37B8F54780469BEBa92E58B7c2a902bc;
    address constant multisign = 0x4786fba4d836B73A39746f778Db1B298B8a62131;
    InfiniCardVault infiniCardVault;
    InfiniMorphoStrategyVault infiniMorphoStrategy;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant INFINI_BACKEND_ROLE = keccak256("INFINI_BACKEND_ROLE");
    bytes32 public constant STRATEGY_OPERATOR_ROLE = keccak256("STRATEGY_OPERATOR_ROLE");

    function setUp() public {
        vm.createSelectFork("https://rpc.mevblocker.io");
        infiniCardVault = InfiniCardVault(payable(0x9A79f4105A4e1A050Ba0b42F25351D394fA7E1DC));
        infiniMorphoStrategy = InfiniMorphoStrategyVault(0xE0e83f21D5B6Da61c9cF75d3b89FBCacfbFde327);
    }

    function test_check_roles() public {
        bool isAdminDefaultAdmin = infiniCardVault.hasRole(DEFAULT_ADMIN_ROLE, multisign);
        require(isAdminDefaultAdmin, "Admin does not have DEFAULT_ADMIN_ROLE");

        bool isAdminAdminRole = infiniCardVault.hasRole(ADMIN_ROLE, multisign);
        require(isAdminAdminRole, "Admin does not have ADMIN_ROLE");

        bool isBackendRole = infiniCardVault.hasRole(INFINI_BACKEND_ROLE, admin);
        require(isBackendRole, "Address does not have INFINI_BACKEND_ROLE");

        bool isStrategyOperatorRole = infiniCardVault.hasRole(STRATEGY_OPERATOR_ROLE, admin);
        require(isStrategyOperatorRole, "Address does not have STRATEGY_OPERATOR_ROLE");

        bool isStrategyDefaultAdmin = infiniMorphoStrategy.hasRole(DEFAULT_ADMIN_ROLE, multisign);
        require(isStrategyDefaultAdmin, "Multisign does not have DEFAULT_ADMIN_ROLE in infiniMorphoStrategy");

        bool isStrategyAdminRole = infiniMorphoStrategy.hasRole(ADMIN_ROLE, admin);
        require(isStrategyAdminRole, "Admin does not have ADMIN_ROLE in infiniMorphoStrategy");
    }

    function test_invest_and_redeem() public {
        uint256 amount = 100000 * 10**6;

        // Invest
        deal(USDCAddress, address(this), 2* amount);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), amount);
        vm.startPrank(admin);
        infiniCardVault.invest(address(infiniMorphoStrategy), amount, "");
        vm.stopPrank();

        uint256 vaultShare = IERC20(infiniMorphoStrategy.shareToken()).balanceOf(address(infiniMorphoStrategy));
        require(vaultShare > 0, "check shareToken Amount");

        uint256 usdcPosition = infiniMorphoStrategy.getPosition();
        require(usdcPosition == amount, "position is invalid");

        // Warp time and invest again
        vm.warp(block.timestamp + 1 weeks);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), amount);
        vm.startPrank(admin);
        infiniCardVault.invest(address(infiniMorphoStrategy), amount, "");
        vm.stopPrank();

        uint256 profit1 = infiniMorphoStrategy.getProfit();
        console.log(profit1);

        // Redeem
        vm.warp(block.timestamp + 2 weeks);
        vm.startPrank(admin);
        uint256 actualAmount = infiniCardVault.redeem(address(infiniMorphoStrategy), amount * 2, "");
        vm.stopPrank();

        uint256 profit2 = infiniMorphoStrategy.getProfit();
        console.log(profit2);

        require(IERC20(USDCAddress).balanceOf(address(infiniMorphoStrategy)) == actualAmount, "check redeem result");

        IStrategyManager.StrategyStatus memory status = IStrategyManager(address(infiniMorphoStrategy)).getStrategyStatus();
        require(status.position == 2 * amount - actualAmount, "check status position");
        require(status.profit == profit2, "check status profit");

        uint256 profit3 = infiniMorphoStrategy.getProfit();
        vm.startPrank(admin);
        infiniMorphoStrategy.settle(profit3);
        vm.stopPrank();
        IStrategyManager.StrategyStatus memory status1 = IStrategyManager(address(infiniMorphoStrategy)).getStrategyStatus();

        require(status1.profit == 0, "check status profit 2");
        require(status1.position == (profit3 - 1) + status.position, "check status position 2");
    }
}
