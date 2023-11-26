# Build stage
FROM golang:1.21-alpine3.18 AS builder

WORKDIR /app

COPY . .
COPY go.mod go.sum ./

RUN go build -o simple_bank main.go

# Run stage
FROM alpine

WORKDIR /app

COPY --from=builder /app/simple_bank .
COPY --from=builder /app/app.env .

EXPOSE 8080

CMD ["/app/simple_bank"]