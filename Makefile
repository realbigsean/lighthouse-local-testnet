up:
	docker compose up -d
down:
	docker compose down
restart: down clean up
clean: clean-data clean-keys
# TODO update this to get rid of slashing protection
clean-data:
	rm -rf genesis_data
clean-keys:
	rm -rf validator_data