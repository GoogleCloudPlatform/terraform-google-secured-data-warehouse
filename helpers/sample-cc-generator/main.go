// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	gofakeit "github.com/brianvoe/gofakeit/v6"
)

const (
	minIssueYear   = "2000"
	maxIssueYear   = "2021"
	minCreditLimit = 999
	maxCreditLimit = 999999
)

var (
	issueBanks = []string{"Chase", "Wells Fargo", "Bank of America", "Capital One", "Barclays", "GE Capital", "U.S. Bancorp"}
	csvHeaders = []string{
		"Card Type Code",
		"Card Type Full Name",
		"Issuing Bank",
		"Card Number",
		"Card Holder's Name",
		"CVV/CVV2",
		"Issue Date",
		"Expiry Date",
		"Billing Date",
		"Card PIN",
		"Credit Limit",
	}
)

// generator config
type genCfg struct {
	seed     int64
	count    int
	filename string
}

// csv entry
type entry struct {
	cardTypeCode     string
	cardTypeFullName string
	issuingBank      string
	cardNumber       string
	cardHolderName   string
	cvv              string
	issueDate        string
	expiryDate       string
	billingDate      string
	cardPin          string
	limit            string
}

func (e entry) strSlice() []string {
	return []string{
		e.cardTypeCode,
		e.cardTypeFullName,
		e.issuingBank,
		e.cardNumber,
		e.cardHolderName,
		e.cvv,
		e.issueDate,
		e.expiryDate,
		e.billingDate,
		e.cardPin,
		e.limit,
	}
}

// issueBank generates a random issuing bank for a cc
func issueBank(faker *gofakeit.Faker, ccName string) string {
	switch ccName {
	case "American Express":
		return "American Express"
	case "Diners Club":
		return "Diners Club International"
	case "JCB":
		return "Japan Credit Bureau"
	case "Discover":
		return "Discover"
	default:
		return faker.RandomString(issueBanks)
	}
}

// ccShortCode generates a short code based on cc name
// https://github.com/brianvoe/gofakeit/blob/master/data/payment.go#L19 for supported ccTypes
func ccShortCode(ccName string) string {
	switch ccName {
	case "Visa":
		return "VI"
	case "Mastercard":
		return "MC"
	case "American Express":
		return "AX"
	case "Diners Club":
		return "DC"
	case "Discover":
		return "DS"
	case "JCB":
		return "JC"
	case "UnionPay":
		return "UP"
	case "Maestro":
		return "MT"
	case "Elo":
		return "EO"
	case "Mir":
		return "MR"
	case "Hiper":
		return "HR"
	case "Hipercard":
		return "HC"
	default:
		return "NA"
	}
}

// generateEntry generates a CSV entry
func generateEntry(faker *gofakeit.Faker) entry {
	e := entry{}
	minIssueT, err := time.Parse("2006-01-02", fmt.Sprintf("%s-01-01", minIssueYear))
	if err != nil {
		log.Fatal(err)
	}
	maxIssueT, err := time.Parse("2006-01-02", fmt.Sprintf("%s-01-01", maxIssueYear))
	if err != nil {
		log.Fatal(err)
	}
	// issued between min/max issue time
	issueTime := faker.DateRange(minIssueT, maxIssueT)
	e.issueDate = issueTime.Format("01/2006")
	e.cardHolderName = faker.Name()
	cc := faker.CreditCard()
	e.cvv = cc.Cvv
	e.cardNumber = cc.Number
	e.cardTypeFullName = cc.Type
	e.cardTypeCode = ccShortCode(cc.Type)
	// expiry is 3-5 years after issue
	expiryTime := faker.DateRange(issueTime.AddDate(3, 0, 0), issueTime.AddDate(5, 0, 0))
	e.expiryDate = expiryTime.Format("01/2006")
	e.issuingBank = issueBank(faker, cc.Type)
	e.billingDate = strconv.Itoa(faker.Number(1, 27))
	// 4 digit num
	e.cardPin = strconv.Itoa(faker.Number(1000, 9999))
	e.limit = strconv.Itoa(faker.Number(minCreditLimit, maxCreditLimit))
	return e
}

func parseFlags() genCfg {
	var c genCfg
	flag.Int64Var(&c.seed, "seed", 1, "Random seed for generator. Defaults to 1")
	flag.IntVar(&c.count, "count", 100, "Number of entries to generate. Defaults to 100")
	flag.StringVar(&c.filename, "filename", "", "Filename to write csv data. Defaults to data-${count}.csv")
	flag.Parse()
	if c.filename == "" {
		c.filename = fmt.Sprintf("data-%d.csv", c.count)
	}
	return c
}

func main() {
	cfg := parseFlags()

	f, err := os.OpenFile(cfg.filename, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0755)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	writer := csv.NewWriter(f)
	defer writer.Flush()

	err = writer.Write(csvHeaders)
	if err != nil {
		log.Fatal(err)
	}

	faker := gofakeit.New(cfg.seed)
	for i := 0; i < cfg.count; i++ {
		e := generateEntry(faker)
		err = writer.Write(e.strSlice())
		if err != nil {
			log.Fatal(err)
		}
	}
}
