// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "lib/forge-std/src/Script.sol";

// core contracts 
import {AgDao} from "../src/implementation/AgDao.sol";
import {AgCoins} from "../src/implementation/AgCoins.sol";
import {Law} from "../src/Law.sol";
import {IAuthoritiesManager} from "../src/interfaces/IAuthoritiesManager.sol";

// constitutional laws
import {Admin_setLaw} from "../src/implementation/laws/Admin_setLaw.sol";
import {Member_assignRole} from "../src/implementation/laws/Member_assignRole.sol";
import {Member_challengeRevoke} from "../src/implementation/laws/Member_challengeRevoke.sol";
import {Member_proposeCoreValue} from "../src/implementation/laws/Member_proposeCoreValue.sol";
import {Senior_acceptProposedLaw} from "../src/implementation/laws/Senior_acceptProposedLaw.sol";
import {Senior_assignRole} from "../src/implementation/laws/Senior_assignRole.sol";
import {Senior_reinstateMember} from "../src/implementation/laws/Senior_reinstateMember.sol";
import {Senior_revokeRole} from "../src/implementation/laws/Senior_revokeRole.sol";
import {Whale_acceptCoreValue} from "../src/implementation/laws/Whale_acceptCoreValue.sol";
import {Whale_assignRole} from "../src/implementation/laws/Whale_assignRole.sol";
import {Whale_proposeLaw} from "../src/implementation/laws/Whale_proposeLaw.sol";
import {Whale_revokeMember} from "../src/implementation/laws/Whale_revokeMember.sol";

contract DeployAgDao is Script {
    bytes32 SALT = bytes32(hex'7ceda5'); 
    error DeployFactoryProgrmas__DeployedContractAtAddress(address deploymentAddress);
    
    /* Functions */
    function run() external returns (AgDao, AgCoins) {
        IAuthoritiesManager.ConstituentRole[] memory constitutionalRoles = new IAuthoritiesManager.ConstituentRole[](0);

        vm.startBroadcast();
            AgDao agDao = new AgDao();
            AgCoins agCoins = new AgCoins(payable(address(agDao)));
            address[] memory constitutionalLaws = _deployLaws(payable(address(agDao)), address(agCoins));
            agDao.constitute(constitutionalLaws, constitutionalRoles); 
        vm.stopBroadcast();

        return(agDao, agCoins);
    }

    /* internal functions */
    function _deployLaws(address payable agDao_, address agCoins_) internal returns (address[] memory constitutionalLaws) {
      address[] memory constitutionalLaws = new address[](12);

      // deploying laws //
      vm.startBroadcast();
      // re assigning roles // 
      Law member_assignRole = new Member_assignRole(agDao_);
      Law senior_assignRole = new Senior_assignRole(agDao_, agCoins_);
      Law senior_revokeRole = new Senior_revokeRole(agDao_, agCoins_);
      Law whale_assignRole = new Whale_assignRole(agDao_, agCoins_);
      
      // re activating & deactivating laws  // 
      Law whale_proposeLaw = new Whale_proposeLaw(agDao_, agCoins_);
      Law senior_acceptProposedLaw = new Senior_acceptProposedLaw(agDao_, agCoins_, address(whale_proposeLaw));
      Law admin_setLaw = new Admin_setLaw(agDao_, address(senior_acceptProposedLaw));

      // re updating core values // 
      Law member_proposeCoreValue = new Member_proposeCoreValue(agDao_, agCoins_);
      Law whale_acceptCoreValue = new Whale_acceptCoreValue(agDao_, agCoins_, address(member_proposeCoreValue));
      
      // re enforcing core values as requirement for external funding //   
      Law whale_revokeMember = new Whale_revokeMember(agDao_, agCoins_);
      Law member_challengeRevoke = new Member_challengeRevoke(agDao_, address(whale_revokeMember));
      Law senior_reinstateMember = new Senior_reinstateMember(agDao_, agCoins_, address(member_challengeRevoke));
      vm.stopBroadcast();

      // assigning addresses to array //
      constitutionalLaws[0] = address(member_assignRole); 
      constitutionalLaws[1] = address(senior_assignRole);
      constitutionalLaws[2] = address(senior_revokeRole);
      constitutionalLaws[3] = address(whale_assignRole);
      constitutionalLaws[4] = address(whale_proposeLaw);
      constitutionalLaws[5] = address(senior_acceptProposedLaw);
      constitutionalLaws[6] = address(admin_setLaw);
      constitutionalLaws[7] = address(member_proposeCoreValue);
      constitutionalLaws[8] = address(whale_acceptCoreValue);
      constitutionalLaws[9] = address(whale_revokeMember);
      constitutionalLaws[10] = address(member_challengeRevoke);
      constitutionalLaws[11] = address(senior_reinstateMember);

      return constitutionalLaws; 
    }
}



