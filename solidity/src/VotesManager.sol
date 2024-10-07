// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";


/**
 * @dev TBI: Description contract.
 *
 * Note: Derived from GovernorCountingSimple. 
 *
 */
abstract contract VotesManager is SeparatedPowers {
    error VotesManager_AlreadyCastVote(address account);
    error VotesManager_InvalidVoteType()
    
    /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address voter => bool) hasVoted;
    }

    mapping(uint256 proposalId => ProposalVote) private _proposalVotes;
    constant public DECIMALS = 100;  

    /**
     * @dev
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    /**
     * @dev }.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev
     */
    function proposalVotes(
        uint256 proposalId
    ) public view virtual returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return (proposalVote.againstVotes, proposalVote.forVotes, proposalVote.abstainVotes);
    }

    /**
     * @dev
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        address targetLaw = _proposals[proposalId].targetLaw;
      
        uint8 quorum = Law(targetLaw).quorum(); 
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;

        return (amountMembers * quorum) / DECIMALS <= proposalVote.forVotes + proposalVote.abstainVotes; 
    }

    /**
     * @dev 
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        address targetLaw = _proposals[proposalId].targetLaw;
      
        uint8 succeedAt = Law(targetLaw).succeedAt(); 
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;

        return (amountMembers * succeedAt) / DECIMALS <= proposalVote.forVotes; 
    }

    /**
     * @dev In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support
    ) internal virtual override {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        if (proposalVote.hasVoted[account]) {
            revert VotesManager_AlreadyCastVote(account);
        }
        proposalVote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalVote.againstVotes++;
        } else if (support == uint8(VoteType.For)) {
            proposalVote.forVotes++;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalVote.abstainVotes++;
        } else {
            revert VotesManager_InvalidVoteType();
        }
    }

} 