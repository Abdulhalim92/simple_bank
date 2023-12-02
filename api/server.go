package api

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
	db "simple-bank/db/sqlc"
	"simple-bank/token"
	"simple-bank/util"
)

type Server struct {
	config     util.Config
	store      db.Store
	tokenMaker token.Maker
	router     *gin.Engine
}

func NewServer(config util.Config, store db.Store) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)
	}

	server := &Server{
		config:     config,
		store:      store,
		tokenMaker: tokenMaker,
	}

	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		v.RegisterValidation("currency", validatorCurrency)
	}

	server.setupRouter()
	return server, nil
}

func (s *Server) setupRouter() {
	router := gin.Default()

	{
		router.POST("/users", s.createUser)
		router.POST("/users/login", s.loginUser)
		router.POST("/token/renew_access", s.renewAccessToken)
	}

	authRoutes := router.Group("/").Use(authMiddleware(s.tokenMaker))
	{
		authRoutes.POST("/accounts", s.createAccount)
		authRoutes.GET("/accounts/:id", s.getAccount)
		authRoutes.GET("/accounts", s.listAccounts)
	}

	{
		authRoutes.POST("/transfers", s.createTransfer)
	}

	s.router = router

}

func (s *Server) Start(address string) error {
	return s.router.Run(address)
}

func errorResponse(err error) gin.H {
	return gin.H{"error": err.Error()}
}
