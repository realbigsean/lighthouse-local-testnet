up:
	docker compose up -d
down:
	docker compose down
restart: down clean-data up
clean: clean-data clean-keys
clean-data:
	rm -rf genesis_data
clean-keys:
	rm -rf validator_data