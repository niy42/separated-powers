export const agDaoAbi = [
  { "type": "constructor", "inputs": [], "stateMutability": "nonpayable" },
  { "type": "receive", "stateMutability": "payable" },
  {
    "type": "function",
    "name": "ADMIN_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MEMBER_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "PUBLIC_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "SENIOR_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "WHALE_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "_proposalVotes",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [
      {
        "name": "againstVotes",
        "type": "uint256",
        "internalType": "uint256"
      },
      { "name": "forVotes", "type": "uint256", "internalType": "uint256" },
      { "name": "abstainVotes", "type": "uint256", "internalType": "uint256" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "activeLaws",
    "inputs": [
      { "name": "law", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "active", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "addRequirement",
    "inputs": [
      {
        "name": "requirement",
        "type": "bytes32",
        "internalType": "ShortString"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "blacklistedAccounts",
    "inputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "canCallLaw",
    "inputs": [
      { "name": "caller", "type": "address", "internalType": "address" },
      { "name": "targetLaw", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "cancel",
    "inputs": [
      { "name": "targetLaw", "type": "address", "internalType": "address" },
      { "name": "lawCalldata", "type": "bytes", "internalType": "bytes" },
      {
        "name": "descriptionHash",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "castVote",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" },
      { "name": "support", "type": "uint8", "internalType": "uint8" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "castVoteWithReason",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" },
      { "name": "support", "type": "uint8", "internalType": "uint8" },
      { "name": "reason", "type": "string", "internalType": "string" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "complete",
    "inputs": [
      { "name": "lawCalldata", "type": "bytes", "internalType": "bytes" },
      {
        "name": "descriptionHash",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "constitute",
    "inputs": [
      {
        "name": "constituentLaws",
        "type": "address[]",
        "internalType": "address[]"
      },
      {
        "name": "constitutionalRoles",
        "type": "tuple[]",
        "internalType": "struct IAuthoritiesManager.ConstituentRole[]",
        "components": [
          { "name": "account", "type": "address", "internalType": "address" },
          { "name": "roleId", "type": "uint64", "internalType": "uint64" }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "coreRequirements",
    "inputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "outputs": [
      { "name": "", "type": "bytes32", "internalType": "ShortString" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "eip712Domain",
    "inputs": [],
    "outputs": [
      { "name": "fields", "type": "bytes1", "internalType": "bytes1" },
      { "name": "name", "type": "string", "internalType": "string" },
      { "name": "version", "type": "string", "internalType": "string" },
      { "name": "chainId", "type": "uint256", "internalType": "uint256" },
      {
        "name": "verifyingContract",
        "type": "address",
        "internalType": "address"
      },
      { "name": "salt", "type": "bytes32", "internalType": "bytes32" },
      {
        "name": "extensions",
        "type": "uint256[]",
        "internalType": "uint256[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "execute",
    "inputs": [
      { "name": "targetLaw", "type": "address", "internalType": "address" },
      { "name": "lawCalldata", "type": "bytes", "internalType": "bytes" },
      {
        "name": "descriptionHash",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "getActiveLaw",
    "inputs": [
      { "name": "law", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "active", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAmountRoleHolders",
    "inputs": [
      { "name": "roleId", "type": "uint64", "internalType": "uint64" }
    ],
    "outputs": [
      {
        "name": "amountMembers",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "hasRoleSince",
    "inputs": [
      { "name": "account", "type": "address", "internalType": "address" },
      { "name": "roleId", "type": "uint64", "internalType": "uint64" }
    ],
    "outputs": [
      { "name": "since", "type": "uint48", "internalType": "uint48" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "hasVoted",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" },
      { "name": "account", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "hashProposal",
    "inputs": [
      { "name": "targetLaw", "type": "address", "internalType": "address" },
      { "name": "lawCalldata", "type": "bytes", "internalType": "bytes" },
      {
        "name": "descriptionHash",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "pure"
  },
  {
    "type": "function",
    "name": "name",
    "inputs": [],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "onERC1155BatchReceived",
    "inputs": [
      { "name": "", "type": "address", "internalType": "address" },
      { "name": "", "type": "address", "internalType": "address" },
      { "name": "", "type": "uint256[]", "internalType": "uint256[]" },
      { "name": "", "type": "uint256[]", "internalType": "uint256[]" },
      { "name": "", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [{ "name": "", "type": "bytes4", "internalType": "bytes4" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "onERC1155Received",
    "inputs": [
      { "name": "", "type": "address", "internalType": "address" },
      { "name": "", "type": "address", "internalType": "address" },
      { "name": "", "type": "uint256", "internalType": "uint256" },
      { "name": "", "type": "uint256", "internalType": "uint256" },
      { "name": "", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [{ "name": "", "type": "bytes4", "internalType": "bytes4" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "onERC721Received",
    "inputs": [
      { "name": "", "type": "address", "internalType": "address" },
      { "name": "", "type": "address", "internalType": "address" },
      { "name": "", "type": "uint256", "internalType": "uint256" },
      { "name": "", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [{ "name": "", "type": "bytes4", "internalType": "bytes4" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "proposalDeadline",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "proposalVotes",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [
      {
        "name": "againstVotes",
        "type": "uint256",
        "internalType": "uint256"
      },
      { "name": "forVotes", "type": "uint256", "internalType": "uint256" },
      { "name": "abstainVotes", "type": "uint256", "internalType": "uint256" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "propose",
    "inputs": [
      { "name": "targetLaw", "type": "address", "internalType": "address" },
      { "name": "lawCalldata", "type": "bytes", "internalType": "bytes" },
      { "name": "description", "type": "string", "internalType": "string" }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "removeRequirement",
    "inputs": [
      { "name": "index", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "roles",
    "inputs": [
      { "name": "roleId", "type": "uint64", "internalType": "uint64" }
    ],
    "outputs": [
      {
        "name": "amountMembers",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "setBlacklistAccount",
    "inputs": [
      { "name": "account", "type": "address", "internalType": "address" },
      { "name": "isBlackListed", "type": "bool", "internalType": "bool" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setLaw",
    "inputs": [
      { "name": "law", "type": "address", "internalType": "address" },
      { "name": "active", "type": "bool", "internalType": "bool" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setRole",
    "inputs": [
      { "name": "roleId", "type": "uint64", "internalType": "uint64" },
      { "name": "account", "type": "address", "internalType": "address" },
      { "name": "access", "type": "bool", "internalType": "bool" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "state",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint8",
        "internalType": "enum ISeparatedPowers.ProposalState"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "version",
    "inputs": [],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "pure"
  },
  {
    "type": "event",
    "name": "AgDao_AccountBlacklisted",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "isBlackListed",
        "type": "bool",
        "indexed": false,
        "internalType": "bool"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "AgDao_RequirementAdded",
    "inputs": [
      {
        "name": "requirement",
        "type": "bytes32",
        "indexed": false,
        "internalType": "ShortString"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "AgDao_RequirementRemoved",
    "inputs": [
      {
        "name": "index",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "EIP712DomainChanged",
    "inputs": [],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "FundsReceived",
    "inputs": [
      {
        "name": "value",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "LawSet",
    "inputs": [
      {
        "name": "law",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "active",
        "type": "bool",
        "indexed": true,
        "internalType": "bool"
      },
      {
        "name": "lawChanged",
        "type": "bool",
        "indexed": true,
        "internalType": "bool"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "ProposalCancelled",
    "inputs": [
      {
        "name": "proposalId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "ProposalCompleted",
    "inputs": [
      {
        "name": "proposalId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "ProposalCreated",
    "inputs": [
      {
        "name": "proposalId",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "proposer",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "targetLaw",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "signature",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "ececuteCalldata",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      },
      {
        "name": "voteStart",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "voteEnd",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "description",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleSet",
    "inputs": [
      {
        "name": "roleId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "accessChanged",
        "type": "bool",
        "indexed": true,
        "internalType": "bool"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "SeparatedPowers__Initialized",
    "inputs": [
      {
        "name": "contractAddress",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "VoteCast",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "proposalId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "support",
        "type": "uint8",
        "indexed": true,
        "internalType": "uint8"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "AuthoritiesManager__AlreadyCastVote",
    "inputs": [
      { "name": "account", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "AuthoritiesManager__InvalidVoteType",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AuthoritiesManager__NotAuthorized",
    "inputs": [
      {
        "name": "invalidAddress",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  { "type": "error", "name": "FailedCall", "inputs": [] },
  { "type": "error", "name": "InvalidShortString", "inputs": [] },
  {
    "type": "error",
    "name": "LawsManager__IncorrectInterface",
    "inputs": [
      { "name": "law", "type": "address", "internalType": "address" }
    ]
  },
  { "type": "error", "name": "LawsManager__NotAuthorized", "inputs": [] },
  { "type": "error", "name": "SeparatedPowers__AccessDenied", "inputs": [] },
  {
    "type": "error",
    "name": "SeparatedPowers__CompleteCallNotFromActiveLaw",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__ConstitutionAlreadyExecuted",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__InvalidCallData",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__InvalidProposalId",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__NoAccessToTargetLaw",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__OnlyProposer",
    "inputs": [
      { "name": "caller", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "SeparatedPowers__OnlySeparatedPowers",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__ProposalAlreadyCompleted",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__ProposalCancelled",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__ProposalNotActive",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeparatedPowers__UnexpectedProposalState",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SeperatedPowers__NonExistentProposal",
    "inputs": [
      { "name": "proposalId", "type": "uint256", "internalType": "uint256" }
    ]
  },
  {
    "type": "error",
    "name": "StringTooLong",
    "inputs": [{ "name": "str", "type": "string", "internalType": "string" }]
  }
]