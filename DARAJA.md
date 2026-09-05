# M-PESA DARAJA 3.0 — Developer Reference

> Personal learning/reference notes for integrating M-PESA Daraja APIs with Flutter and backend applications.
>
> **Primary project:** `mpesa_integration_workflow`
>
> **Official documentation:** https://developer.safaricom.co.ke/

---

# Table of Contents

1. [What is Daraja?](#1-what-is-daraja)
2. [M-PESA Integration Architecture](#2-m-pesa-integration-architecture)
3. [Sandbox vs Production](#3-sandbox-vs-production)
4. [Daraja Account and Application](#4-daraja-account-and-application)
5. [Credentials](#5-credentials)
6. [API Environments](#6-api-environments)
7. [HTTP Basics](#7-http-basics)
8. [OAuth Authentication](#8-oauth-authentication)
9. [Access Token](#9-access-token)
10. [STK Push](#10-stk-push)
11. [STK Push Flow](#11-stk-push-flow)
12. [STK Push Request](#12-stk-push-request)
13. [STK Push Request Parameters](#13-stk-push-request-parameters)
14. [STK Push Response](#14-stk-push-response)
15. [STK Push Callback](#15-stk-push-callback)
16. [Callback Response Structure](#16-callback-response-structure)
17. [ResultCode](#17-resultcode)
18. [Payment Status](#18-payment-status)
19. [Transaction Data](#19-transaction-data)
20. [Phone Number Formatting](#20-phone-number-formatting)
21. [Timestamp](#21-timestamp)
22. [STK Password](#22-stk-password)
23. [Backend Security](#23-backend-security)
24. [Flutter + Backend Architecture](#24-flutter--backend-architecture)
25. [Example Project Structure](#25-example-project-structure)
26. [Environment Variables](#26-environment-variables)
27. [Example OAuth Request](#27-example-oauth-request)
28. [Example STK Push Request](#28-example-stk-push-request)
29. [Example STK Push Response](#29-example-stk-push-response)
30. [Example Callback](#30-example-callback)
31. [Testing Strategy](#31-testing-strategy)
32. [Common Errors](#32-common-errors)
33. [Security Checklist](#33-security-checklist)
34. [Other Daraja APIs](#34-other-daraja-apis)
35. [Production Checklist](#35-production-checklist)
36. [Learning Roadmap](#36-learning-roadmap)
37. [Useful Resources](#37-useful-resources)

---

# 1. What is Daraja?

Daraja 3.0 is Safaricom's developer platform for integrating M-PESA services into applications.

It allows developers to build applications that communicate with M-PESA through APIs.

Typical applications include:

* E-commerce systems
* POS systems
* Mobile applications
* School payment systems
* Loan systems
* Subscription systems
* Transport systems
* Utility payment systems
* Business management systems

For this project, we are learning how to integrate:

**Flutter → Backend → Daraja → M-PESA**

Official portal:

https://developer.safaricom.co.ke/

---

# 2. M-PESA Integration Architecture

A mobile application should generally NOT communicate directly with Daraja using secret credentials.

Recommended architecture:

```text
┌──────────────────────┐
│      Flutter App     │
│                      │
│ Phone Number         │
│ Amount               │
│                      │
│ [Pay with M-PESA]    │
└──────────┬───────────┘
           │
           │ HTTPS
           ▼
┌──────────────────────┐
│       Backend        │
│    Node.js/Express   │
│                      │
│ Consumer Key         │
│ Consumer Secret      │
│ Passkey              │
└──────────┬───────────┘
           │
           │ HTTPS
           ▼
┌──────────────────────┐
│    Safaricom Daraja  │
│                      │
│ OAuth                │
│ STK Push             │
│ Callbacks            │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│       M-PESA         │
│                      │
│ Customer phone       │
│ M-PESA PIN           │
└──────────────────────┘
```

The callback travels back to the backend:

```text
M-PESA
   │
   ▼
Daraja
   │
   ▼
Backend Callback URL
   │
   ▼
Database / Payment Logic
   │
   ▼
Flutter App
```

---

# 3. Sandbox vs Production

## Sandbox

Sandbox is used for development and testing.

Use sandbox while learning and developing the application.

No real customer money should be required for normal sandbox development.

---

## Production

Production is the live environment.

Production integrations involve real M-PESA transactions and require the appropriate Safaricom onboarding/go-live process.

Never use production credentials while experimenting.

---

## Rule

During development:

```text
SANDBOX
   ↓
TEST
   ↓
DEBUG
   ↓
SECURITY REVIEW
   ↓
PRODUCTION
```

---

# 4. Daraja Account and Application

Before using Daraja:

1. Create a developer account.
2. Log in to the Daraja developer portal.
3. Create an application.
4. Select the APIs required by the application.
5. Obtain the credentials supplied for the application.
6. Configure the required URLs/settings.
7. Test using the sandbox environment.

Official portal:

https://developer.safaricom.co.ke/

---

# 5. Credentials

Typical credentials/settings used in a Daraja integration include:

```text
Consumer Key
Consumer Secret
Business Short Code
Passkey
Callback URL
Environment
```

These values are sensitive.

---

## Consumer Key

Used together with the Consumer Secret to obtain an OAuth access token.

---

## Consumer Secret

Secret associated with the Consumer Key.

NEVER expose this inside:

* Flutter source code
* GitHub repositories
* Public JavaScript
* Screenshots
* README files
* Public logs

---

## Business Short Code

The M-PESA business identifier used by the relevant API transaction.

For STK Push this is normally associated with the business/merchant initiating the payment.

---

## Passkey

The STK Push passkey is used when generating the STK password.

Treat it as a secret.

---

## Callback URL

The publicly reachable HTTPS endpoint that Daraja can call to report the result of an asynchronous transaction.

Example:

```text
https://example.com/api/mpesa/callback
```

During local development, a tunneling solution may be required because Daraja must be able to reach the callback endpoint from the internet.

---

# 6. API Environments

Use separate configuration for development and production.

Example:

```text
Development
───────────
Environment = sandbox

Production
──────────
Environment = production
```

Never hard-code environment-specific secrets throughout the application.

Use environment variables.

---

# 7. HTTP Basics

Daraja APIs communicate using HTTP/HTTPS.

Common HTTP methods:

```text
GET
POST
PUT
DELETE
```

Most operations in this learning project will use:

```text
POST
```

Example:

```http
POST /some/api/endpoint
Content-Type: application/json
Authorization: Bearer ACCESS_TOKEN
```

---

# 8. OAuth Authentication

Daraja protected APIs require authentication.

The backend first obtains an access token.

Basic flow:

```text
Consumer Key
      +
Consumer Secret
      │
      ▼
Daraja OAuth endpoint
      │
      ▼
Access Token
```

The access token is then included in subsequent API requests.

---

## Important

The OAuth credentials belong on the backend.

DO NOT do this:

```dart
// WRONG

final consumerKey = "...";
final consumerSecret = "...";
```

inside Flutter.

Instead:

```text
Flutter
   │
   │ phone + amount
   ▼
Backend
   │
   │ credentials
   ▼
Daraja
```

---

# 9. Access Token

The OAuth response provides an access token.

Conceptually:

```json
{
  "access_token": "ACCESS_TOKEN",
  "expires_in": "..."
}
```

The exact response should always be checked against the current official Daraja documentation.

The token is then sent using:

```http
Authorization: Bearer ACCESS_TOKEN
```

---

# 10. STK Push

STK Push is one of the easiest M-PESA integrations to learn.

It allows an application to initiate an M-PESA payment request that appears on the customer's phone.

Example:

```text
Customer
   │
   │ enters phone + amount
   ▼
Flutter
   │
   ▼
Backend
   │
   ▼
Daraja
   │
   ▼
Customer's phone
   │
   │ enters M-PESA PIN
   ▼
M-PESA
```

---

# 11. STK Push Flow

Complete conceptual flow:

```text
1. Customer enters phone number
2. Customer enters amount
3. Flutter sends payment request to backend
4. Backend validates input
5. Backend obtains OAuth access token
6. Backend creates STK password
7. Backend sends STK Push request to Daraja
8. Daraja returns an acknowledgement
9. Customer receives M-PESA payment prompt
10. Customer enters M-PESA PIN
11. M-PESA processes transaction
12. Daraja sends callback to backend
13. Backend processes callback
14. Backend records payment result
15. Flutter receives/requests payment status
```

Important:

The STK Push response is NOT necessarily the final payment result.

The actual transaction result is delivered asynchronously through the callback.

---

# 12. STK Push Request

Conceptually, an STK Push request contains:

```json
{
  "BusinessShortCode": "SHORT_CODE",
  "Password": "GENERATED_PASSWORD",
  "Timestamp": "TIMESTAMP",
  "TransactionType": "CustomerPayBillOnline",
  "Amount": 10,
  "PartyA": "2547XXXXXXXX",
  "PartyB": "SHORT_CODE",
  "PhoneNumber": "2547XXXXXXXX",
  "CallBackURL": "https://example.com/api/mpesa/callback",
  "AccountReference": "TEST",
  "TransactionDesc": "Test Payment"
}
```

The exact endpoint, accepted values, and field requirements must be verified against the current Daraja documentation before implementation.

---

# 13. STK Push Request Parameters

## BusinessShortCode

The business shortcode associated with the transaction.

```text
BusinessShortCode
```

---

## Password

Generated from:

```text
Base64(
    ShortCode
    +
    Passkey
    +
    Timestamp
)
```

The exact encoding requirements should follow the current Daraja documentation.

---

## Timestamp

A timestamp generated by the backend.

Typical format:

```text
YYYYMMDDHHmmss
```

Example:

```text
20260905143025
```

Do not manually type timestamps into production requests.

Generate them programmatically.

---

## TransactionType

For the standard STK Push flow, the transaction type is commonly:

```text
CustomerPayBillOnline
```

Verify the permitted transaction type for the specific Daraja API/product being used.

---

## Amount

The amount the customer is being asked to pay.

Example:

```text
10
```

For our learning application, we can start with a small test amount supported by the sandbox.

---

## PartyA

The customer phone number.

Example:

```text
2547XXXXXXXX
```

---

## PartyB

The business/merchant shortcode.

---

## PhoneNumber

The phone number to which the STK Push is sent.

Usually the same customer number represented by PartyA.

---

## CallBackURL

The endpoint that Daraja calls after the transaction is processed.

Example:

```text
https://example.com/api/mpesa/callback
```

---

## AccountReference

A reference identifying what the payment is for.

Example:

```text
TEST001
```

Could later represent:

```text
ORDER-1001
INVOICE-500
STUDENT-2026
LOAN-001
```

---

## TransactionDesc

Human-readable description of the transaction.

Example:

```text
Test Payment
```

---

# 14. STK Push Response

After sending an STK Push request, Daraja returns an acknowledgement.

Conceptually:

```json
{
  "MerchantRequestID": "...",
  "CheckoutRequestID": "...",
  "ResponseCode": "0",
  "ResponseDescription": "...",
  "CustomerMessage": "..."
}
```

The exact response should be verified against the current API documentation.

---

## Important IDs

### MerchantRequestID

Identifier associated with the merchant request.

---

### CheckoutRequestID

Identifier associated with the STK checkout request.

This is extremely important.

The backend should store the:

```text
CheckoutRequestID
```

because it can be used to associate the asynchronous payment callback with the original payment attempt.

---

# 15. STK Push Callback

The callback is sent after the customer completes or cancels the payment process.

Example architecture:

```text
Customer
   │
   │ M-PESA PIN
   ▼
M-PESA
   │
   ▼
Daraja
   │
   │ POST
   ▼
https://your-domain.com/api/mpesa/callback
```

The backend must expose a route capable of receiving the callback.

Example:

```text
POST /api/mpesa/callback
```

---

# 16. Callback Response Structure

The callback contains transaction information.

A conceptual callback can look like:

```json
{
  "Body": {
    "stkCallback": {
      "MerchantRequestID": "...",
      "CheckoutRequestID": "...",
      "ResultCode": 0,
      "ResultDesc": "...",
      "CallbackMetadata": {
        "Item": [
          {
            "Name": "Amount",
            "Value": 10
          },
          {
            "Name": "MpesaReceiptNumber",
            "Value": "ABC123XYZ"
          },
          {
            "Name": "TransactionDate",
            "Value": 20260905143025
          },
          {
            "Name": "PhoneNumber",
            "Value": 2547XXXXXXXX
          }
        ]
      }
    }
  }
}
```

The exact callback structure should always be checked against the current Daraja documentation and actual sandbox response.

---

# 17. ResultCode

`ResultCode` tells us whether the transaction succeeded or failed.

Conceptually:

```text
ResultCode == 0
       ↓
SUCCESS
```

Non-zero values indicate that the transaction was not successful.

Examples can include:

```text
Customer cancelled
Insufficient funds
Wrong PIN
Timeout
Transaction failed
```

Do NOT assume every non-zero code means the same thing.

Always inspect:

```text
ResultCode
ResultDesc
```

---

# 18. Payment Status

Our backend should translate Daraja results into application-level statuses.

For example:

```text
PENDING
SUCCESS
FAILED
CANCELLED
```

Example:

```text
STK request accepted
        ↓
     PENDING
        │
        ├── ResultCode 0
        │       ↓
        │    SUCCESS
        │
        └── ResultCode != 0
                ↓
              FAILED
```

---

# 19. Transaction Data

A successful callback may contain useful information such as:

```text
Amount
M-PESA Receipt Number
Transaction Date
Phone Number
```

Example internal payment record:

```json
{
  "checkoutRequestId": "...",
  "merchantRequestId": "...",
  "phone": "2547XXXXXXXX",
  "amount": 10,
  "status": "SUCCESS",
  "receipt": "ABC123XYZ"
}
```

Later, this information can be stored in PostgreSQL/MySQL.

---

# 20. Phone Number Formatting

M-PESA integrations commonly use the international Kenyan format:

```text
2547XXXXXXXX
```

Example:

```text
0712345678
```

becomes:

```text
254712345678
```

And:

```text
+254712345678
```

can be normalized to:

```text
254712345678
```

---

## Backend validation

Never trust the Flutter application to validate payment data.

The backend should validate:

```text
Phone number
Amount
Account reference
Transaction description
```

---

# 21. Timestamp

The timestamp is generated on the backend.

Common format:

```text
YYYYMMDDHHmmss
```

Example:

```text
20260905143025
```

It is used when generating the STK password.

Conceptually:

```text
ShortCode + Passkey + Timestamp
                 │
                 ▼
              Base64
                 │
                 ▼
             Password
```

---

# 22. STK Password

The STK password is generated using:

```text
Base64(
    BusinessShortCode
    +
    Passkey
    +
    Timestamp
)
```

Example conceptual implementation:

```text
shortcode = "..."
passkey   = "..."
timestamp = "20260905143025"

raw =
    shortcode +
    passkey +
    timestamp

password =
    Base64(raw)
```

The passkey must remain secret.

---

# 23. Backend Security

## NEVER expose these in Flutter

```text
Consumer Key
Consumer Secret
Passkey
```

---

## NEVER commit secrets to Git

Do NOT commit:

```text
.env
.env.local
credentials.json
secrets.json
```

---

## Use environment variables

Example:

```env
MPESA_CONSUMER_KEY=your_key
MPESA_CONSUMER_SECRET=your_secret
MPESA_SHORTCODE=your_shortcode
MPESA_PASSKEY=your_passkey
MPESA_CALLBACK_URL=https://example.com/api/mpesa/callback
MPESA_ENVIRONMENT=sandbox
```

---

## Add `.env` to `.gitignore`

```gitignore
.env
.env.*
!.env.example
```

Create:

```text
.env.example
```

containing placeholders:

```env
MPESA_CONSUMER_KEY=
MPESA_CONSUMER_SECRET=
MPESA_SHORTCODE=
MPESA_PASSKEY=
MPESA_CALLBACK_URL=
MPESA_ENVIRONMENT=sandbox
```

---

# 24. Flutter + Backend Architecture

Our learning application will use:

```text
Flutter
   │
   │ POST /api/mpesa/stkpush
   ▼
Node.js + Express
   │
   ├── OAuth
   │
   ├── STK password
   │
   └── STK Push
   │
   ▼
Daraja
   │
   ▼
M-PESA
```

Callback:

```text
Daraja
   │
   │ POST
   ▼
Node.js + Express
   │
   ├── Validate callback
   ├── Read ResultCode
   ├── Read transaction details
   └── Update payment status
   │
   ▼
Database
```

Flutter can then retrieve the payment status from our backend.

---

# 25. Example Project Structure

Initial project:

```text
mpesa_integration_workflow/
│
├── DARAJA.md
├── README.md
├── .gitignore
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   └── models/
│
└── backend/
    ├── package.json
    ├── server.js
    ├── .env
    ├── .env.example
    ├── routes/
    │   └── mpesa.routes.js
    ├── controllers/
    │   └── mpesa.controller.js
    └── services/
        └── mpesa.service.js
```

---

# 26. Environment Variables

Backend `.env`:

```env
PORT=3000

MPESA_ENVIRONMENT=sandbox

MPESA_CONSUMER_KEY=
MPESA_CONSUMER_SECRET=

MPESA_SHORTCODE=
MPESA_PASSKEY=

MPESA_CALLBACK_URL=
```

Never commit actual secret values.

---

# 27. Example OAuth Request

Conceptual request:

```http
GET <DARaja OAuth endpoint>
Authorization: Basic BASE64(CONSUMER_KEY:CONSUMER_SECRET)
```

The backend receives an access token.

Conceptually:

```json
{
  "access_token": "ACCESS_TOKEN",
  "expires_in": "..."
}
```

Then:

```http
Authorization: Bearer ACCESS_TOKEN
```

is used for protected API calls.

> Always verify the current endpoint and authentication requirements against the official Daraja documentation before implementation.

---

# 28. Example STK Push Request

Conceptual request:

```http
POST <STK PUSH ENDPOINT>

Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Body:

```json
{
  "BusinessShortCode": "SHORTCODE",
  "Password": "GENERATED_PASSWORD",
  "Timestamp": "20260905143025",
  "TransactionType": "CustomerPayBillOnline",
  "Amount": 10,
  "PartyA": "2547XXXXXXXX",
  "PartyB": "SHORTCODE",
  "PhoneNumber": "2547XXXXXXXX",
  "CallBackURL": "https://example.com/api/mpesa/callback",
  "AccountReference": "TEST001",
  "TransactionDesc": "Test Payment"
}
```

---

# 29. Example STK Push Response

Conceptual successful acknowledgement:

```json
{
  "MerchantRequestID": "MERCHANT_REQUEST_ID",
  "CheckoutRequestID": "CHECKOUT_REQUEST_ID",
  "ResponseCode": "0",
  "ResponseDescription": "Success",
  "CustomerMessage": "Success. Request accepted for processing."
}
```

This means:

```text
Daraja accepted the request
```

It does NOT necessarily mean:

```text
Customer has successfully paid
```

The final result comes asynchronously.

---

# 30. Example Callback

Conceptual successful callback:

```json
{
  "Body": {
    "stkCallback": {
      "MerchantRequestID": "MERCHANT_REQUEST_ID",
      "CheckoutRequestID": "CHECKOUT_REQUEST_ID",
      "ResultCode": 0,
      "ResultDesc": "Success",
      "CallbackMetadata": {
        "Item": [
          {
            "Name": "Amount",
            "Value": 10
          },
          {
            "Name": "MpesaReceiptNumber",
            "Value": "ABC123XYZ"
          },
          {
            "Name": "TransactionDate",
            "Value": 20260905143025
          },
          {
            "Name": "PhoneNumber",
            "Value": 2547XXXXXXXX
          }
        ]
      }
    }
  }
}
```

Backend logic:

```text
Receive callback
      ↓
Read CheckoutRequestID
      ↓
Find payment record
      ↓
Read ResultCode
      ↓
If ResultCode == 0
      ↓
SUCCESS
      ↓
Save receipt
```

---

# 31. Testing Strategy

We will build the application incrementally.

## Test 1 — Flutter UI

Verify:

```text
Phone input works
Amount input works
Button works
```

No Daraja yet.

---

## Test 2 — Backend

Verify:

```text
GET /api/health
```

Expected:

```json
{
  "status": "ok"
}
```

---

## Test 3 — OAuth

Verify:

```text
Backend
   ↓
Daraja
   ↓
Access Token
```

Do not expose the token in production logs.

---

## Test 4 — STK Push

Verify:

```text
Flutter
   ↓
Backend
   ↓
Daraja
   ↓
Phone
```

---

## Test 5 — Callback

Verify:

```text
M-PESA
   ↓
Daraja
   ↓
Backend callback
```

Log callback information safely during development.

Never log secrets.

---

## Test 6 — Payment Result

Test:

```text
SUCCESS
FAILED
CANCELLED
TIMEOUT
```

---

# 32. Common Errors

## Missing Authorization Header

Possible cause:

```text
Authorization header missing
```

Check:

```http
Authorization: Bearer ACCESS_TOKEN
```

---

## Invalid Access Token

Possible causes:

* Wrong consumer key
* Wrong consumer secret
* Expired token
* Incorrect Base64 encoding
* Incorrect authorization header

---

## Invalid Phone Number

Check formatting:

```text
2547XXXXXXXX
```

---

## Invalid Password

Check:

```text
ShortCode
Passkey
Timestamp
Base64 encoding
```

---

## Invalid Callback URL

Check that:

* URL is correct
* URL is publicly reachable
* HTTPS is configured where required
* endpoint accepts POST requests
* server is running

---

## Callback Not Received

Possible causes:

```text
Localhost not publicly reachable
Incorrect callback URL
Server not running
Firewall
Tunnel expired
Incorrect route
```

---

## STK Request Accepted but No Payment

Remember:

```text
STK acknowledgement != successful payment
```

Wait for the callback and inspect:

```text
ResultCode
ResultDesc
```

---

# 33. Security Checklist

Before deployment:

```text
[ ] Consumer Key is secret
[ ] Consumer Secret is secret
[ ] Passkey is secret
[ ] .env is ignored by Git
[ ] No credentials in Flutter
[ ] No credentials in GitHub
[ ] HTTPS enabled
[ ] Backend validates amount
[ ] Backend validates phone number
[ ] Backend validates requests
[ ] Callback endpoint is protected appropriately
[ ] Payment status is determined server-side
[ ] Secrets are not logged
[ ] Production credentials are separate
[ ] Sandbox credentials are not used for production
[ ] Payment records are stored safely
```

---

# 34. Other Daraja APIs

Daraja provides more than STK Push.

Depending on the business use case, APIs/services can include:

## C2B

Customer to Business.

Conceptually:

```text
Customer
   ↓
Business
```

Useful for receiving payments.

---

## B2C

Business to Customer.

Conceptually:

```text
Business
   ↓
Customer
```

Useful for sending money from a business to customers.

---

## Transaction Status

Used to query the status of a transaction.

---

## Reversal

Used for reversing eligible transactions.

---

## Account Balance

Used to query business account balance where applicable.

---

## Other Services

The Daraja portal contains additional M-PESA APIs and services.

Always check the official portal for the currently available APIs and their current specifications.

---

# 35. Production Checklist

Before moving to production:

```text
Development
     ↓
Sandbox testing
     ↓
Error handling
     ↓
Security review
     ↓
Database/payment reconciliation
     ↓
Logging and monitoring
     ↓
Go-live requirements
     ↓
Production
```

Production should include:

* HTTPS
* Secure secret management
* Proper database design
* Payment idempotency
* Logging
* Monitoring
* Error handling
* Retry strategy
* Authentication
* Authorization
* Input validation
* Rate limiting
* Audit logs
* Reconciliation

---

# 36. Learning Roadmap

Our `mpesa_integration_workflow` project will be built in this order.

## Phase 1 — Flutter

Build:

```text
Phone Number
Amount
Pay Button
Payment Status
```

---

## Phase 2 — Node.js

Build:

```text
Express server
Health endpoint
M-PESA routes
```

---

## Phase 3 — OAuth

Learn:

```text
Consumer Key
Consumer Secret
Basic Authentication
Access Token
Token expiration
```

---

## Phase 4 — STK Push

Learn:

```text
Short Code
Passkey
Timestamp
Password
PartyA
PartyB
PhoneNumber
CallbackURL
AccountReference
TransactionDesc
```

---

## Phase 5 — Callback

Learn:

```text
Webhook/callback
MerchantRequestID
CheckoutRequestID
ResultCode
ResultDesc
CallbackMetadata
```

---

## Phase 6 — Database

Add:

```text
payments
users
transactions
```

Example payment record:

```text
id
checkout_request_id
merchant_request_id
phone
amount
status
mpesa_receipt
transaction_date
created_at
updated_at
```

---

## Phase 7 — Payment Verification

Learn the difference between:

```text
Request accepted
```

and:

```text
Payment successfully completed
```

---

## Phase 8 — Security

Learn:

```text
Secrets
Environment variables
HTTPS
Input validation
Authentication
Authorization
Idempotency
Webhook security
```

---

## Phase 9 — Advanced APIs

After STK Push:

```text
C2B
B2C
Transaction Status
Reversal
Account Balance
```

---

# 37. Useful Resources

## Official Safaricom Daraja Portal

https://developer.safaricom.co.ke/

Use this as the **source of truth** for:

* API endpoints
* Required parameters
* Authentication
* Request formats
* Response formats
* Sandbox details
* Production requirements

---

# Important Development Rules

## Rule 1

Never put Daraja secrets inside Flutter.

---

## Rule 2

Never commit secrets to GitHub.

---

## Rule 3

Do not assume an STK Push acknowledgement means payment success.

---

## Rule 4

Always process the asynchronous callback.

---

## Rule 5

The backend should be responsible for payment verification.

---

## Rule 6

Validate all payment information on the backend.

---

## Rule 7

Use sandbox while learning.

---

## Rule 8

Keep this document updated as we discover and implement each part of Daraja.

---

# Our Target Architecture

At the end of this learning project:

```text
                    ┌─────────────────┐
                    │   Flutter App   │
                    │                 │
                    │ Phone           │
                    │ Amount          │
                    │ Pay             │
                    └────────┬────────┘
                             │
                             │ HTTPS
                             ▼
                    ┌─────────────────┐
                    │ Node.js Backend │
                    │                 │
                    │ Authentication  │
                    │ Validation      │
                    │ STK Push        │
                    │ Callback        │
                    └────────┬────────┘
                             │
                             │ HTTPS
                             ▼
                    ┌─────────────────┐
                    │ Safaricom       │
                    │ Daraja 3.0      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    M-PESA       │
                    │                 │
                    │ Customer PIN    │
                    │ Payment         │
                    └────────┬────────┘
                             │
                             │ Callback
                             ▼
                    ┌─────────────────┐
                    │ Node.js Backend │
                    │                 │
                    │ ResultCode      │
                    │ Receipt         │
                    │ Payment Status  │
                    └─────────────────┘
```

---

# Final Goal

The goal of this project is not simply to make an M-PESA button.

The goal is to understand the complete payment lifecycle:

```text
Flutter
   ↓
Backend
   ↓
OAuth
   ↓
Access Token
   ↓
STK Push
   ↓
M-PESA
   ↓
Customer PIN
   ↓
Daraja Callback
   ↓
ResultCode
   ↓
Payment Verification
   ↓
Database
   ↓
Application
```

Once this workflow is understood, the same concepts can be applied to:

* E-commerce
* POS
* Loan systems
* School management systems
* Subscription systems
* Healthcare systems
* Mobile applications
* SaaS applications
* Business management systems

---

**Documentation status:** Initial version

**Project:** `mpesa_integration_workflow`

**Environment:** Sandbox

**Primary API for learning:** STK Push

**Backend:** Node.js + Express

**Frontend:** Flutter + Dart
