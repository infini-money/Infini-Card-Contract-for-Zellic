// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/InfiniCardVault.sol";
import {InfiniEthenaStrategyVault} from "../src/strategys/ethena/InfiniEthenaStrategyVault.sol";
import {InfiniMorphoStrategyVault} from "../src/strategys/morpho/InfiniMorphoStrategyVault.sol";
import {InfiniEthenaStrategyManager} from "../src/strategys/ethena/InfiniEthenaStrategyManager.sol";

contract TransferOwnerShip is Script {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // forge script script/1.transferOwnerShip.s.sol:TransferOwnerShip --broadcast --rpc-url https://eth.llamarpc.com --legacy

    function run() public {
        address payable vault = payable(0x78cFD2D6AEE191391317AdC9e72F72aA062c5a84);
        address ethena_strategy =  0x73837fb3B2b3cE751c0a044659C71Bf9d36a20FF;
        address ethena_manager =  0xac020a4ba4739610D496631D50578F022A6C8295;
        address morpho_strategy =  0x0F54Da5a94a21fe7e0DD961577c861c508421Cf1;

        address adminRole = 0x9881301e37B8F54780469BEBa92E58B7c2a902bc;
        address multiSign = 0x4786fba4d836B73A39746f778Db1B298B8a62131;

        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");

        vm.startBroadcast(adminPrivateKey);

        InfiniCardVault(vault).grantRole(ADMIN_ROLE, adminRole);
        InfiniEthenaStrategyVault(ethena_strategy).grantRole(ADMIN_ROLE, adminRole);
        InfiniEthenaStrategyManager(ethena_manager).grantRole(ADMIN_ROLE, adminRole);
        InfiniMorphoStrategyVault(morpho_strategy).grantRole(ADMIN_ROLE, adminRole);

        vm.stopBroadcast();

        vm.startBroadcast(adminPrivateKey);

        InfiniCardVault(vault).grantRole(DEFAULT_ADMIN_ROLE, multiSign);
        InfiniEthenaStrategyVault(ethena_strategy).grantRole(DEFAULT_ADMIN_ROLE, multiSign);
        InfiniEthenaStrategyManager(ethena_manager).grantRole(DEFAULT_ADMIN_ROLE, multiSign);
        InfiniMorphoStrategyVault(morpho_strategy).grantRole(DEFAULT_ADMIN_ROLE, multiSign);

        vm.stopBroadcast();
    }

}