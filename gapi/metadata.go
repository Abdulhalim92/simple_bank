package gapi

import (
	"context"
	"github.com/rs/zerolog/log"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
)

const (
	grpcGatewayUserAgentHandler = "grpcgateway-user-agent"
	xForwardedForHeader         = "x-forwarded-for"
	userAgentHeader             = "user-agent"
)

type Metadata struct {
	UserAgent string
	ClientIP  string
}

func (s *Server) extractMetadata(ctx context.Context) *Metadata {
	metaData := &Metadata{}

	if md, ok := metadata.FromIncomingContext(ctx); ok {
		log.Printf("md: %+v\n", md)

		// для получения имя агента HTTP клиента
		if userAgents := md.Get(grpcGatewayUserAgentHandler); len(userAgents) > 0 {
			metaData.UserAgent = userAgents[0]
		}

		// для получения имя агента gRPC клиента
		if userAgents := md.Get(userAgentHeader); len(userAgents) > 0 {
			metaData.UserAgent = userAgents[0]
		}

		// для получения IP - адреса клиента HTTP
		if clientIPs := md.Get(xForwardedForHeader); len(clientIPs) > 0 {
			metaData.ClientIP = clientIPs[0]
		}

	}

	// для получения IP - адреса клиента gRPC
	if p, ok := peer.FromContext(ctx); ok {
		metaData.ClientIP = p.Addr.String()
	}

	return metaData
}
