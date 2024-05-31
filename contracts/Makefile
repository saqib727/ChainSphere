-include .env

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""


build:; forge build

fund-subscription:
	@forge script script/Interactions.s.sol:FundSubscription --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv

deploy-sepolia:
	@forge script script/DeployChainSphere.s.sol:DeployChainSphere --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv

deploy-polygon_amoy:
	@forge create script/DeployChainSphere.s.sol:DeployChainSphere --rpc-url $(POLYGON_AMOY_TESTNET_RPC_URL) --verify --verifier etherscan --verifier-url $(OKLINK_URL) --etherscan-api-key $(POLYGON_AMOY_API_KEY) --private-key $(PRIVATE_KEY) --legacy

verify-polygon_amoy:
	@forge verify-contract 0xeDA022f897Ba2411C1dFBA8af05ce4922ebB1d4C ChainSphere --verifier etherscan --verifier-url $(OKLINK_URL)  --api-key $OKLINK_API_KEY

# forge create Counter --rpc-url <rpc_https_endpoint> --verify --verifier oklink --verifier-url https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER --etherscan-api-key $OKLINK_API_KEY --private-key $PRIVATE_KEY --legacy


test-sepolia:
	forge test --fork-url $(SEPOLIA_RPC_URL) -vvvv

test-polygon_amoy:
	forge test --fork-url $(POLYGON_AMOY_TESTNET_RPC_URL) -vvvvv

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network polygon_amoy,$(ARGS)),--network polygon_amoy)
	NETWORK_ARGS := --rpc-url $(POLYGON_AMOY_TESTNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(POLYGON_AMOY_API_KEY) -vvvv
endif


deploy:
	@forge script script/DeployChainSphere.s.sol:DeployChainSphere $(NETWORK_ARGS)

createSubscription:
	@forge script script/Interactions.s.sol:CreateSubscription $(NETWORK_ARGS)

addConsumer:
	@forge script script/Interactions.s.sol:AddConsumer $(NETWORK_ARGS)

fundSubscription:
	@forge script script/Interactions.s.sol:FundSubscription $(NETWORK_ARGS)