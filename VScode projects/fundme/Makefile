-include .env

build:; forge build

deploy-sepolia:
	forge script script/FundMe.s.sol	--rpc-url $(FORK_URL_SEPOLIA)	--account sepoliaKey --verify --etherscan-api-key $(ETHERSCAN_API_KEY) 	--broadcast