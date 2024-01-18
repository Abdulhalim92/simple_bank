package main

import (
	"fmt"
	"github.com/jordan-wright/email"
	"log"
	"net/smtp"
)

func main() {
	e := email.NewEmail()
	e.From = fmt.Sprintf("%s <%s>", "Abduhalim", "abdulhalim1992@gmail.com")

	subject := "A test email"
	content := `
	<h1>Hello world</h1>
	<p>This is a test message from <a href="//techschool.guru">Tech school</a></p>
	`

	e.Subject = subject
	e.HTML = []byte(content)
	e.To = []string{"abdulhalim1992@gmail.com"}

	smtpAuth := smtp.PlainAuth("", "abdulhalim1992@gmail.com", "hnczigpwfecokisz", "smtp.gmail.com")

	err := e.Send("smtp.gmail.com:587", smtpAuth)
	if err != nil {
		log.Println(err)
	}

	log.Println("sent ...")

}
