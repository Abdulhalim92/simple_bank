# Build stage
FROM golang:1.21-alpine3.18 AS builder

WORKDIR /app

COPY . .
COPY go.mod go.sum ./

RUN go build -o main main.go
#RUN apk add curl
#RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz


# Run stage
FROM alpine

WORKDIR /app

COPY --from=builder /app/main .
#COPY --from=builder /app/migrate /usr/bin/migrate
COPY app.env .
COPY db/migration ./db/migration
COPY start.sh .
COPY wait-for.sh .

RUN chmod +x /app/wait-for.sh

EXPOSE 8080

CMD ["/app/main"]
ENTRYPOINT ["/app/start.sh"]