

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {InfiniMorphoStrategyVaultV2} from "@InfiniCard/strategies/morpho/InfiniMorphoStrategyVaultV2.sol";

contract DeployInfiniStrategy is Script {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // forge script script/deployStrategy.s.sol:DeployInfiniStrategy --broadcast --rpc-url https://rpc.mevblocker.io --legacy

    function run() external {
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        address deployer = vm.addr(adminPrivateKey);

        address backend = 0x9881301e37B8F54780469BEBa92E58B7c2a902bc;
        address multiSign = 0x4786fba4d836B73A39746f778Db1B298B8a62131;
        address vault = 0x9A79f4105A4e1A050Ba0b42F25351D394fA7E1DC;
        address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

        address _re7_market = 0x95EeF579155cd2C5510F312c8fA39208c3Be01a8;
        address _steakHouse_market = 0xbEef047a543E45807105E51A8BBEFCc5950fcfBa;

        vm.startBroadcast(adminPrivateKey);


        InfiniMorphoStrategyVaultV2 re7_market_morpho = new InfiniMorphoStrategyVaultV2(
            multiSign,
            backend,
            address(vault), 
            USDT,
            _re7_market,
            _re7_market,
            multiSign
        );
        

        InfiniMorphoStrategyVaultV2 steakHouse_market_morpho = new InfiniMorphoStrategyVaultV2(
            multiSign,
            backend,
            address(vault), 
            USDT,
            _steakHouse_market,
            _steakHouse_market,
            multiSign
        );   

        console2.log("address re7_market_morpho =", address(re7_market_morpho));
        console2.log("address steakHouse_market_morpho =", address(steakHouse_market_morpho));

        vm.stopBroadcast();

    }
}