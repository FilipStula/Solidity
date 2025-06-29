include .env

.PHONY: all test deploy

test:
	forge test -vvvv

build:
	forge build

deploy:
	forge script script/tokenScript.s.sol:tokenScript --broadcast --rpc-url $(ANVIL) --account defaultKey -vvvv