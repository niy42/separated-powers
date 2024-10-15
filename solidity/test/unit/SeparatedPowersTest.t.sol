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

  /* state variables */
  uint64 public constant ADMIN_ROLE = type(uint64).min; // == 0
  uint64 public constant PUBLIC_ROLE = type(uint64).max; // == a lot. This role is for everyone. 
  uint64 public constant SENIOR_ROLE = 1; 
  uint64 public constant WHALE_ROLE = 2; 
  uint64 public constant MEMBER_ROLE = 3; 
  bytes32 SALT = bytes32(hex'7ceda5'); 

  /* modifiers */

  ///////////////////////////////////////////////
  ///                   Setup                 ///
  ///////////////////////////////////////////////
  function setUp() public {     
    vm.roll(10); 
    vm.startBroadcast(alice);
      agDao = new AgDao();
      agCoins = new AgCoins(address(agDao));
    vm.stopBroadcast();

    /* setup roles */
    IAuthoritiesManager.ConstituentRole[] memory constituentRoles = new IAuthoritiesManager.ConstituentRole[](10);
    constituentRoles[0] = IAuthoritiesManager.ConstituentRole(alice, MEMBER_ROLE);
    constituentRoles[1] = IAuthoritiesManager.ConstituentRole(bob, MEMBER_ROLE);
    constituentRoles[2] = IAuthoritiesManager.ConstituentRole(charlotte, MEMBER_ROLE);
    constituentRoles[3] = IAuthoritiesManager.ConstituentRole(david, MEMBER_ROLE);
    constituentRoles[4] = IAuthoritiesManager.ConstituentRole(eve, MEMBER_ROLE);
    constituentRoles[5] = IAuthoritiesManager.ConstituentRole(alice, SENIOR_ROLE);
    constituentRoles[6] = IAuthoritiesManager.ConstituentRole(bob, SENIOR_ROLE);
    constituentRoles[7] = IAuthoritiesManager.ConstituentRole(charlotte, SENIOR_ROLE);
    constituentRoles[8] = IAuthoritiesManager.ConstituentRole(david, WHALE_ROLE);
    constituentRoles[9] = IAuthoritiesManager.ConstituentRole(eve, WHALE_ROLE);

    /* setup laws */
    address[] memory constituentLaws = _deployLaws(payable(address(agDao)), address(agCoins));
    
    vm.startBroadcast(alice);
    agDao.constitute(constituentLaws, constituentRoles);
    vm.stopBroadcast();
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
    string memory requiredStatement = "I request membership to agDAO.";
    bytes32 requiredStatementHash = keccak256(bytes(requiredStatement));
    bytes memory lawCalldata = abi.encode(requiredStatementHash);
    
    vm.startPrank(alice); 
    AgDao agDaoTest = new AgDao();
    Law memberAssignRole = new Member_assignRole(payable(address(agDaoTest)));
    vm.stopPrank();

    vm.expectRevert(SeparatedPowers.SeparatedPowers__ExecuteCallNotFromActiveLaw.selector);
    vm.prank(bob); 
    memberAssignRole.executeLaw(lawCalldata); 
  }

  ///////////////////////////////////////////////
  ///                   Helper                 ///
  ///////////////////////////////////////////////
   function _deployLaws(address payable agDaoAddress_, address agCoinsAddress_) internal returns (address[] memory constituentLaws) {
      address[] memory constitutionalLaws = new address[](12);
      IAuthoritiesManager.ConstituentRole[] memory constituentRoles = new IAuthoritiesManager.ConstituentRole[](0);

      // deploying laws //
      vm.startPrank(bob);
      // re assigning roles // 
      constitutionalLaws[0] = address(new Member_assignRole(agDaoAddress_));
      constitutionalLaws[1] = address(new Senior_assignRole(agDaoAddress_, agCoinsAddress_));
      constitutionalLaws[2] = address(new Senior_revokeRole(agDaoAddress_, agCoinsAddress_));
      constitutionalLaws[3] = address(new Whale_assignRole(agDaoAddress_, agCoinsAddress_));
      
      // re activating & deactivating laws  // 
      constitutionalLaws[4] = address(new Whale_proposeLaw(agDaoAddress_, agCoinsAddress_));
      constitutionalLaws[5] = address(new Senior_acceptProposedLaw(agDaoAddress_, agCoinsAddress_, address(constitutionalLaws[4])));
      constitutionalLaws[6] = address(new Admin_setLaw(agDaoAddress_, address(constitutionalLaws[5])));

      // re updating core values // 
      constitutionalLaws[7] = address(new Member_proposeCoreValue(agDaoAddress_, agCoinsAddress_));
      constitutionalLaws[8] = address(new Whale_acceptCoreValue(agDaoAddress_, agCoinsAddress_, address(constitutionalLaws[7])));
      
      // re enforcing core values as requirement for external funding //   
      constitutionalLaws[9] = address(new Whale_revokeMember(agDaoAddress_, agCoinsAddress_));
      constitutionalLaws[10] = address(new Member_challengeRevoke(agDaoAddress_, address(constitutionalLaws[9])));
      constitutionalLaws[11] = address(new Senior_reinstateMember(agDaoAddress_, agCoinsAddress_, address(constitutionalLaws[10])));
      vm.stopPrank();

      return constitutionalLaws; 
    }

}