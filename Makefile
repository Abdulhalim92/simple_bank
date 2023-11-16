postgres:
	docker run --name postgres16 -p 5435:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=pass -d postgres:16-alpine

mysql:
	docker run --name mysql8 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=pass -d mysql:latest

migrate:
	migrate create -ext sql -dir db/migration -seq init_schema

create_db:
	docker exec -it postgres16 createdb --username=root --owner=root simple_bank

drop_db:
	docker exec -it postgres16 dropdb simple_bank

migrate_up:
	migrate -path db/migration -database "postgresql://root:pass@localhost:5435/simple_bank?sslmode=disable" -verbose up

migrate_down:
	migrate -path db/migration -database "postgresql://root:pass@localhost:5435/simple_bank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go simple-bank/db/sqlc Store

migrate_create:
	migrate create -ext sql -dir db/migration -seq add_users

migrate_up1:
	migrate -path db/migration -database "postgresql://root:pass@localhost:5435/simple_bank?sslmode=disable" -verbose up 1

migrate_down1:
	migrate -path db/migration -database "postgresql://root:pass@localhost:5435/simple_bank?sslmode=disable" -verbose down 1

.PHONY: postgres mysql migrate create_db drop_db migrate_up migrate_down sqlc server mock migrate_create migrate_up1 migrate_down1
