# £ack this file was originally copied from https://github.com/Cyfrin/foundry-erc20-f23/blob/main/Makefile
-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules 
#&& git add . 
#&& git commit -m "modules"

# Install modules
install :; forge install foundry-rs/forge-std@v1.9.1 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit

# Update Dependencies
update:; forge update

# Build
build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil --steps-tracing --block-time 1

#########################################
# 						Test commands							# 
#########################################
ANVIL_ARGS_0 := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_0) --broadcast

anvilDeployFactory: 
	@forge script script/DeployFactoryPrograms.s.sol:DeployFactoryPrograms $(ANVIL_ARGS_0)
	
anvilDeploySampleGifts: 
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCoffee $(ANVIL_ARGS_0)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCupCake $(ANVIL_ARGS_0)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFridayFifteen $(ANVIL_ARGS_0)

anvilAll:
	@forge script script/DeployFactoryPrograms.s.sol:DeployFactoryPrograms $(ANVIL_ARGS_0)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCoffee $(ANVIL_ARGS_0)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCupCake $(ANVIL_ARGS_0)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFridayFifteen $(ANVIL_ARGS_0)  

###############################
# 		Deploy Commands  				#
###############################
# ETH_SEPOLIA_TEST_ARGS := --fork-url $(SEPOLIA_RPC_URL) 
# ETH_SEPOLIA_DEPLOY_ARGS := --rpc-url forge$(SEPOLIA_RPC_URL) --account dev_2 --sender ${WALLET_ADDRESS} --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

OPT_SEPOLIA_TEST_ARGS := --fork-url $(OPT_SEPOLIA_RPC_URL) 
OPT_SEPOLIA_DEPLOY_ARGS := --rpc-url $(OPT_SEPOLIA_RPC_URL) --account dev_2 --sender ${DEV2_ADDRESS} --broadcast --verify --etherscan-api-key $(OPT_ETHERSCAN_API_KEY) -vvvv

testOptDeploy: 
	@forge script script/DeployFactoryPrograms.s.sol:DeployFactoryPrograms $(OPT_SEPOLIA_TEST_ARGS)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCoffee $(OPT_SEPOLIA_TEST_ARGS)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCupCake $(OPT_SEPOLIA_TEST_ARGS)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployFridayFifteen $(OPT_SEPOLIA_TEST_ARGS)
	@forge script script/DeployLoyaltyGifts.s.sol:DeployGoldToken $(OPT_SEPOLIA_TEST_ARGS)

optDeploy:
	@forge script script/DeployFactoryPrograms.s.sol:DeployFactoryPrograms $(OPT_SEPOLIA_DEPLOY_ARGS)
# @forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCoffee $(OPT_SEPOLIA_DEPLOY_ARGS)
# @forge script script/DeployLoyaltyGifts.s.sol:DeployFreeCupCake $(OPT_SEPOLIA_DEPLOY_ARGS)
# @forge script script/DeployLoyaltyGifts.s.sol:DeployFridayFifteen $(OPT_SEPOLIA_DEPLOY_ARGS)
# @forge script script/DeployLoyaltyGifts.s.sol:DeployGoldToken $(OPT_SEPOLIA_DEPLOY_ARGS)

