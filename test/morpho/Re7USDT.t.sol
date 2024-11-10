

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {StrategyUtils} from "@InfiniCard/library/StrategyUtils.sol";
import "forge-std/console.sol";
import {IStrategyManager} from  "@InfiniCard/interfaces/IStrategyManager.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";

import {BaseTest} from "../baseTest.t.sol";
import {InfiniMorphoStrategyVaultV2} from "@InfiniCard/strategies/morpho/InfiniMorphoStrategyVaultV2.sol";

contract Re7USDTMorphoStrategyTesting is BaseTest, StrategyUtils {
    InfiniMorphoStrategyVaultV2 morphoStrategyV2;
    address public _market = 0x95EeF579155cd2C5510F312c8fA39208c3Be01a8;
    address public _morpho = 0x9994E35Db50125E0DF82e4c2dde62496CE330999;
    address public _morpho_admin = 0xcBa28b38103307Ec8dA98377ffF9816C164f9AFa ;

    function setUp() override public  {
        super.setUp();

        morphoStrategyV2 = new InfiniMorphoStrategyVaultV2(
            shaneson,
            shaneson,
            address(infiniCardVault),
            USDTAddress,
            _market,
            _market,
            infiniTreasure
        );

        vm.startPrank(shaneson);
        infiniCardVault.addStrategy(address(morphoStrategyV2));
        vm.stopPrank();

        vm.startPrank(_morpho_admin);


        vm.stopPrank();

    }


    function test_harvest() public {
        uint256 amount = 100 ether;
        // deal(_morpho, address(morphoStrategyV2), amount);

        vm.startPrank(shaneson);
        uint256 harvestedAmount = morphoStrategyV2.harvest();
        uint256 morphoBalance = IERC20(morphoStrategyV2.MORPHO()).balanceOf(shaneson);
        require(harvestedAmount == morphoBalance, "Harvested amount should be equal to the balance in infiniCardVault");
        vm.stopPrank();
    }

    function test_deposit_and_redeem() public {
        uint256 amount = 100000 * 10**6;
        deal(USDTAddress, address(this), amount * 2);
        SafeERC20.safeTransfer(IERC20(USDTAddress), address(infiniCardVault), amount);

        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(morphoStrategyV2),
            amount,
            ""
        );
        vm.stopPrank();
        uint256 vaultShare = IERC20(_market).balanceOf(address(morphoStrategyV2)) ;
        require(vaultShare > 0, "check shareToken Amount");

        uint256 _usdc_posiiton = morphoStrategyV2.getPosition();
        require(_usdc_posiiton == 100000 * 10**6, "position is invalid");
    
        vm.warp(block.timestamp + 1 weeks);

        SafeERC20.safeTransfer(IERC20(USDTAddress), address(infiniCardVault), amount);

        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(morphoStrategyV2),
            amount,
            ""
        );
        vm.stopPrank();

        uint256 _profit1 = morphoStrategyV2.getProfit();
        console.log(_profit1);

        // redeem
        vm.warp(block.timestamp + 2 weeks);
        vm.startPrank(shaneson);
        uint256 actualAmount = infiniCardVault.redeem(
            address(morphoStrategyV2),
            amount * 2,
            ""  
        );
        vm.stopPrank();

        uint256 _profit2 = morphoStrategyV2.getProfit();
        console.log(_profit2);

        require(IERC20(USDTAddress).balanceOf(address(morphoStrategyV2)) == actualAmount, "check redeem result");
 
        IStrategyManager.StrategyStatus memory status = IStrategyManager(address(morphoStrategyV2)).getStrategyStatus();
  
        require(status.position == 2 * amount - actualAmount, "check status posistion");
        require(status.profit == _profit2, "check status profit");

        uint256 _profit3 = morphoStrategyV2.getProfit();
        vm.startPrank(shaneson);
        morphoStrategyV2.settle(_profit3);
        vm.stopPrank();
        IStrategyManager.StrategyStatus memory status1 = IStrategyManager(address(morphoStrategyV2)).getStrategyStatus();

        require(status1.profit == 0, "check status profit 2");
        require(status1.position == (_profit3 - 1) + status.position , "check status posistion 2");

    }
}