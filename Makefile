DB_URL=postgresql://root:pass@localhost:5433/simple_bank?sslmode=disable

postgres:
	docker run --name postgres16 --network bank-network -p 5435:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=pass -d postgres:16-alpine

mysql:
	docker run --name mysql8 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=pass -d mysql:latest

migrate:
	migrate create -ext sql -dir db/migration -seq init_schema

create_db:
	docker exec -it postgres16 createdb --username=root --owner=root simple_bank

drop_db:
	docker exec -it postgres16 dropdb simple_bank

migrate_up:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrate_up1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migrate_down:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migrate_down1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go simple-bank/db/sqlc Store
	mockgen -package mockwk -destination worker/mock/distributor.go simple-bank/worker TaskDistributor


migrate_create:
	migrate create -ext sql -dir db/migration -seq add_users

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
    --go-grpc_out=pb --go-grpc_opt=paths=source_relative \
    --grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
    --openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
    proto/*.proto
	statik -src=./doc/swagger -dest=./doc

evans:
	evans --host localhost --port 9090 -r repl

redis:
	docker run --name redis -p 6379:6379 -d redis:7-alpine

.PHONY: postgres mysql migrate create_db drop_db migrate_up migrate_up1 migrate_down migrate_down1 new_migration sqlc server mock migrate_create migrate_up1 migrate_down1 db_docs db_schema proto evans redis
