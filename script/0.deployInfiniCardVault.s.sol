
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "../src/InfiniCardVault.sol";
import "../src/InfiniCardController.sol";

import {InfiniEthenaStrategyVault} from "../src/strategies/ethena/InfiniEthenaStrategyVault.sol";
import {InfiniMorphoStrategyVault} from "../src/strategies/morpho/InfiniMorphoStrategyVault.sol";
import {InfiniEthenaStrategyManager} from "../src/strategies/ethena/InfiniEthenaStrategyManager.sol";

contract DeployInfiniCardVault is Script {
    // forge script script/0.deployInfiniCardVault.s.sol:DeployInfiniCardVault --broadcast --rpc-url https://rpc.mevblocker.io --legacy
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function run() external {
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        address deployer = vm.addr(adminPrivateKey);

        address backend = 0x9881301e37B8F54780469BEBa92E58B7c2a902bc;
        address multiSign = 0x4786fba4d836B73A39746f778Db1B298B8a62131;
        address custodian = 0x7E857de437A4Dda3A98Cf3fd37D6B36c139594E8;

        // address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address USDE = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
        
        //   address vault = 0x9A79f4105A4e1A050Ba0b42F25351D394fA7E1DC
        //   address morpho_strategy =  0xE0e83f21D5B6Da61c9cF75d3b89FBCacfbFde327

        InfiniCardVault vault = InfiniCardVault(payable(0x9A79f4105A4e1A050Ba0b42F25351D394fA7E1DC));

        // vm.startBroadcast(adminPrivateKey);
        // InfiniCardVault vault = new InfiniCardVault(deployer, deployer, backend, backend);
        // vault.addCustodianToWhiteList(custodian);
        // vm.stopBroadcast();

        // strategies
        address MorphoMarket = 0xd63070114470f685b75B74D60EEc7c1113d33a3D;

        vm.startBroadcast(adminPrivateKey);

        // InfiniMorphoStrategyVault morpho = new InfiniMorphoStrategyVault(
        //     multiSign,
        //     backend,
        //     address(vault), 
        //     USDC,
        //     MorphoMarket,
        //     MorphoMarket,
        //     multiSign
        // );

        InfiniMorphoStrategyVault morpho = InfiniMorphoStrategyVault(0xE0e83f21D5B6Da61c9cF75d3b89FBCacfbFde327);
        vault.addStrategy(address(morpho));
        vm.stopBroadcast();

        console2.log( "address vault =", address(vault));
        console2.log( "address morpho_strategy = ", address(morpho));

        // transfer admin owner to multisign
        vm.startBroadcast(adminPrivateKey);
        InfiniCardVault(vault).grantRole(ADMIN_ROLE, multiSign);
        InfiniCardVault(vault).grantRole(DEFAULT_ADMIN_ROLE, multiSign);
        vm.stopBroadcast(); 

        // address EthenaMintingAddress = 0xe3490297a08d6fC8Da46Edb7B6142E4F461b62D3;

        // vm.startBroadcast(adminPrivateKey);
        // InfiniEthenaStrategyVault ethena = new InfiniEthenaStrategyVault(
        //     multiSign,
        //     deployer,
        //     address(vault),
        //     USDC,
        //     USDE,
        //     EthenaMintingAddress
        // );
        // vault.addStrategy(address(ethena));
        // vm.stopBroadcast();

        // vm.startBroadcast(adminPrivateKey);
        // InfiniEthenaStrategyManager ethenaManager = new InfiniEthenaStrategyManager(
        //     address(ethena),
        //     address(deployer),
        //     deployer,
        //     multiSign
        // );

        // console2.log( "address ethena_strategy = ", address(ethena));
        // console2.log( "address ethena_manager = ", address(ethenaManager));

    }
}