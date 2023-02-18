up:
	docker compose up -d
down:
	docker compose down
clean: clean-data clean-keys
clean-data:
	rm -rf genesis_data
clean-keys:
	rm -rf validator_data