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
    address[] constituentLaws;
    
    /* Functions */
    function run() external returns (AgDao, AgCoins) {
        IAuthoritiesManager.ConstituentRole[] memory constituenttRoles = new IAuthoritiesManager.ConstituentRole[](0);

        vm.startBroadcast();
            AgDao agDao = new AgDao{salt: SALT}();
            AgCoins agCoins = new AgCoins{salt: SALT}(payable(address(agDao)));
            (address[] memory constituentLaws) = _deployLaws(payable(address(agDao)), address(agCoins));
            agDao.constitute(constituentLaws, constituenttRoles);
        vm.stopBroadcast();

        return(agDao, agCoins);
    }

    /* internal functions */
    function _deployLaws(address payable agDaoAddress_, address agCoinsAddress_) internal returns (address[] memory constituentLaws) {
      IAuthoritiesManager.ConstituentRole[] memory constituenttRoles = new IAuthoritiesManager.ConstituentRole[](0);

      // deploying laws //
      vm.startBroadcast();
      // re assigning roles // 
      constituentLaws[0] = address(new Member_assignRole(agDaoAddress_));
      constituentLaws[1] = address(new Senior_assignRole(agDaoAddress_, agCoinsAddress_));
      constituentLaws[2] = address(new Senior_revokeRole(agDaoAddress_, agCoinsAddress_));
      constituentLaws[3] = address(new Whale_assignRole(agDaoAddress_, agCoinsAddress_));
      
      // re activating & deactivating laws  // 
      constituentLaws[4] = address(new Whale_proposeLaw(agDaoAddress_, agCoinsAddress_));
      constituentLaws[5] = address(new Senior_acceptProposedLaw(agDaoAddress_, agCoinsAddress_, address(constituentLaws[4])));
      constituentLaws[6] = address(new Admin_setLaw(agDaoAddress_, address(constituentLaws[5])));

      // re updating core values // 
      constituentLaws[7] = address(new Member_proposeCoreValue(agDaoAddress_, agCoinsAddress_));
      constituentLaws[8] = address(new Whale_acceptCoreValue(agDaoAddress_, agCoinsAddress_, address(constituentLaws[7])));
      
      // re enforcing core values as requirement for external funding //   
      constituentLaws[9] = address(new Whale_revokeMember(agDaoAddress_, agCoinsAddress_));
      constituentLaws[10] = address(new Member_challengeRevoke(agDaoAddress_, address(constituentLaws[9])));
      constituentLaws[11] = address(new Senior_reinstateMember(agDaoAddress_, agCoinsAddress_, address(constituentLaws[10])));
      vm.stopBroadcast();

      return constituentLaws; 
    }
}



