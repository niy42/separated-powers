// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "lib/forge-std/src/Test.sol";
import {DeployAgDao} from "../../script/DeployAgDao.s.sol";
import {SeparatedPowers} from "../../src/SeparatedPowers.sol";
import {AgDao} from   "../../src/implementation/AgDao.sol";
import {AgCoins} from "../../src/implementation/AgCoins.sol";
import {Law} from "../../src/Law.sol";
import {IAuthoritiesManager} from "../../src/interfaces/IAuthoritiesManager.sol";

// constitutional laws
import {Admin_setLaw} from "../../src/implementation/laws/Admin_setLaw.sol";
import {Member_assignRole} from "../../src/implementation/laws/Member_assignRole.sol";
import {Member_challengeRevoke} from "../../src/implementation/laws/Member_challengeRevoke.sol";
import {Member_proposeCoreValue} from "../../src/implementation/laws/Member_proposeCoreValue.sol";
import {Senior_acceptProposedLaw} from "../../src/implementation/laws/Senior_acceptProposedLaw.sol";
import {Senior_assignRole} from "../../src/implementation/laws/Senior_assignRole.sol";
import {Senior_reinstateMember} from "../../src/implementation/laws/Senior_reinstateMember.sol";
import {Senior_revokeRole} from "../../src/implementation/laws/Senior_revokeRole.sol";
import {Whale_acceptCoreValue} from "../../src/implementation/laws/Whale_acceptCoreValue.sol";
import {Whale_assignRole} from "../../src/implementation/laws/Whale_assignRole.sol";
import {Whale_proposeLaw} from "../../src/implementation/laws/Whale_proposeLaw.sol";
import {Whale_revokeMember} from "../../src/implementation/laws/Whale_revokeMember.sol";

contract SeparatedPowersTest is Test {
  /* Type declarations */
  SeparatedPowers separatedPowers;
  AgDao agDao;
  AgCoins agCoins;

  /* addresses */
  address alice = makeAddr("alice");
  address bob = makeAddr("bob");
  address charlotte = makeAddr("charlotte");
  address david = makeAddr("david");
  address eve = makeAddr("eve");
  address frank = makeAddr("frank");

  /* roles */
  uint64 public constant ADMIN_ROLE = type(uint64).min; // == 0
  uint64 public constant PUBLIC_ROLE = type(uint64).max; // == 0
  uint64 public constant SENIOR_ROLE = 1; 
  uint64 public constant WHALE_ROLE = 2; 
  uint64 public constant MEMBER_ROLE = 3; 

  /* modifiers */
  modifier consituteDao (address[] memory constitutionalLaws, IAuthoritiesManager.ConstituentRole[] memory constituentRoles) {
    agDao.constitute(constitutionalLaws, constituentRoles);

    _; 
  }

  ///////////////////////////////////////////////
  ///                   Setup                 ///
  ///////////////////////////////////////////////
  function setUp() public {
    vm.roll(10); 
    vm.startPrank(alice);
      AgDao agDao = new AgDao();
      AgCoins agCoins = new AgCoins(address(agDao));
    vm.stopPrank();

    address[] memory constitutionalLaws = _deployLaws(payable(address(agDao)), address(agCoins)); 
  }

  ///////////////////////////////////////////////
  ///                   Tests                 ///
  ///////////////////////////////////////////////
  function testDeployProtocolEmitsEvent() public {
    vm.expectEmit(true, false, false, false);
    emit SeparatedPowers.SeparatedPowers__Initialized(address(agDao));

    vm.prank(alice); 
    SeparatedPowers separatedPowers = new SeparatedPowers("TestDao");
  }

  function testDeployProtocolSetsSenderToAdmin () public {
    
    vm.prank(alice); 
    SeparatedPowers separatedPowers = new SeparatedPowers("TestDao");

    assert (separatedPowers.hasRoleSince(alice, ADMIN_ROLE) != 0);
  }
  
  function testLawsRevertWhenNotActivated () public {
    // vm.startBroadcast();
    // vm.expectRevert();
    // agDao. 
    // vm.stopBroadcast();
  }

  ///////////////////////////////////////////////
  ///                   Helper                 ///
  ///////////////////////////////////////////////
  function _deployLaws(address payable agDao_, address agCoins_) internal returns (address[] memory constitutionalLaws) {
      address[] memory constitutionalLaws = new address[](12);

      // deploying laws //
      vm.startPrank(bob);
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
      vm.stopPrank();

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