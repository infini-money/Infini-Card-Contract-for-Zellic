
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/InfiniCardVault.sol";
import {InfiniEthenaStrategyVault} from "../src/strategys/ethena/InfiniEthenaStrategyVault.sol";
import {InfiniMorphoStrategyVault} from "../src/strategys/morpho/InfiniMorphoStrategyVault.sol";
import {InfiniEthenaStrategyManager} from "../src/strategys/ethena/InfiniEthenaStrategyManager.sol";

contract DeployInfiniCardVault is Script {
    // forge script script/0.deployInfiniCardVault.s.sol:DeployInfiniCardVault --broadcast --rpc-url https://rpc.mevblocker.io --legacy

    function run() external {
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        address adminRole = vm.addr(adminPrivateKey);
        address multiSign = adminRole;

        // address adminRole = 0x9881301e37B8F54780469BEBa92E58B7c2a902bc;
        // address multiSign = 0x4786fba4d836B73A39746f778Db1B298B8a62131;
        address custodian = 0x7E857de437A4Dda3A98Cf3fd37D6B36c139594E8;

        // address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address USDE = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
        
        vm.startBroadcast(adminPrivateKey);

        InfiniCardVault vault = new InfiniCardVault(multiSign, adminRole, adminRole, adminRole);
        vault.addCustodianToWhiteList(custodian);

        vm.stopBroadcast();

        // strategys
        address EthenaMintingAddress = 0xe3490297a08d6fC8Da46Edb7B6142E4F461b62D3;

        vm.startBroadcast(adminPrivateKey);
        InfiniEthenaStrategyVault ethena = new InfiniEthenaStrategyVault(
            multiSign,
            adminRole,
            address(vault),
            USDC,
            USDE,
            EthenaMintingAddress
        );
        vault.addStrategy(address(ethena));
        vm.stopBroadcast();

        vm.startBroadcast(adminPrivateKey);
        InfiniEthenaStrategyManager ethenaManager = new InfiniEthenaStrategyManager(
            address(ethena),
            address(adminRole),
            adminRole,
            multiSign
        );

        address MorphoMarket = 0xd63070114470f685b75B74D60EEc7c1113d33a3D;
        vm.stopBroadcast();

        vm.startBroadcast(adminPrivateKey);
        InfiniMorphoStrategyVault morpho = new InfiniMorphoStrategyVault(
            multiSign,
            adminRole,
            address(vault),
            USDC,
            MorphoMarket,
            MorphoMarket,
            adminRole
        );
        vault.addStrategy(address(morpho));
        vm.stopBroadcast();

        console2.log( "address vault =", address(vault));
        console2.log( "address ethena_strategy = ", address(ethena));
        console2.log( "address ethena_manager = ", address(ethenaManager));
        console2.log( "address morpho_strategy = ", address(morpho));

    }
}