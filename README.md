# 📱 M-PESA Integration Workflow

A simple Flutter + Node.js learning project for understanding **M-PESA Daraja API integration** from the ground up.

The project demonstrates how a Flutter mobile application communicates with a backend, how the backend authenticates with Safaricom Daraja, how an STK Push is initiated, and how the asynchronous M-PESA callback is processed.

> 🚧 **Learning Project — Sandbox Environment**
>
> This project is intended for learning and development using the M-PESA Daraja sandbox. It is not a production payment application.

---

## 🎯 Project Goal

The purpose of this project is to understand the complete M-PESA payment lifecycle rather than relying on an abstraction that hides the underlying API.

The project focuses primarily on:

* Daraja API authentication
* OAuth access tokens
* STK Push
* M-PESA payment requests
* Callback/webhook handling
* Payment status
* Transaction identifiers
* Backend security
* Flutter ↔ Backend communication

---

# 🔄 Payment Workflow

The application follows this architecture:

```text
┌───────────────────────┐
│      Flutter App      │
│                       │
│  Phone Number         │
│  Amount               │
│                       │
│  [ Pay with M-PESA ]  │
└───────────┬───────────┘
            │
            │ HTTPS
            ▼
┌───────────────────────┐
│     Node.js Backend   │
│       Express         │
│                       │
│  Validate Request     │
│  OAuth Authentication │
│  STK Push             │
└───────────┬───────────┘
            │
            │ HTTPS
            ▼
┌───────────────────────┐
│    Safaricom Daraja   │
│                       │
│    M-PESA API         │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│       Customer        │
│                       │
│   M-PESA STK Prompt   │
│       ↓               │
│   Enter PIN           │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│    Daraja Callback    │
└───────────┬───────────┘
            │
            │ POST
            ▼
┌───────────────────────┐
│     Node.js Backend   │
│                       │
│  ResultCode           │
│  ResultDesc           │
│  Receipt              │
│  Transaction Details  │
└───────────────────────┘
```

---

# 🧠 What I Am Learning

This project is designed to answer the following questions:

### Authentication

* What is Daraja?
* What is OAuth?
* What are Consumer Key and Consumer Secret?
* How is an access token generated?
* How long does an access token remain valid?

### STK Push

* What is STK Push?
* How is an STK Push request created?
* What is a Business Short Code?
* What is the STK Passkey?
* How is the STK password generated?
* What is a CheckoutRequestID?
* What is a MerchantRequestID?

### Callbacks

* Why is the STK response not the final payment result?
* What is a callback URL?
* How does Daraja communicate the final transaction result?
* What is `ResultCode`?
* What is `ResultDesc`?
* What information is contained in `CallbackMetadata`?

### Security

* Why should Daraja credentials never be stored in Flutter?
* How should secrets be stored?
* Why should the backend validate payment information?
* How should payment results be trusted?

---

# 🛠️ Technology Stack

## Mobile Application

* **Flutter**
* **Dart**

## Backend

* **Node.js**
* **Express.js**

## Payment API

* **Safaricom M-PESA Daraja 3.0**

## Development Environment

* Ubuntu
* Android Studio
* VS Code
* Git
* GitHub

## Database

No database is required for the initial version.

A database will be introduced later to persist transaction records.

---

# 📂 Project Structure

The project will eventually follow a structure similar to:

```text
mpesa_integration_workflow/
│
├── README.md
├── DARAJA.md
├── .gitignore
│
├── lib/
│   ├── main.dart
│   │
│   ├── screens/
│   │   └── payment_screen.dart
│   │
│   ├── services/
│   │   └── api_service.dart
│   │
│   └── models/
│       └── payment.dart
│
└── backend/
    │
    ├── package.json
    ├── server.js
    ├── .env
    ├── .env.example
    │
    ├── routes/
    │   └── mpesa.routes.js
    │
    ├── controllers/
    │   └── mpesa.controller.js
    │
    └── services/
        └── mpesa.service.js
```

The structure may evolve as the project becomes more advanced.

---

# 🚀 Development Workflow

Development will happen incrementally.

## Phase 1 — Flutter UI

Build a minimal payment screen.

Features:

```text
Phone Number
Amount
Pay Button
Payment Status
```

At this stage there is no M-PESA integration.

### Goal

Make sure the Flutter application works correctly.

---

# Phase 2 — Backend

Create a Node.js + Express backend.

Initial endpoint:

```http
GET /api/health
```

Expected response:

```json
{
  "status": "ok"
}
```

### Goal

Verify that the backend is running before integrating Daraja.

---

# Phase 3 — Flutter → Backend

Flutter sends:

```json
{
  "phone": "2547XXXXXXXX",
  "amount": 10
}
```

to:

```http
POST /api/mpesa/stkpush
```

### Goal

Understand how the mobile application communicates with our backend.

---

# Phase 4 — Daraja OAuth

The backend communicates with Daraja.

Flow:

```text
Consumer Key
      +
Consumer Secret
      ↓
Daraja OAuth
      ↓
Access Token
```

The access token is then used to authenticate protected Daraja API requests.

### Goal

Understand OAuth rather than hiding it behind a package.

---

# Phase 5 — STK Push

The backend constructs an STK Push request.

Conceptually:

```text
Phone
Amount
Business Short Code
Passkey
Timestamp
Password
Callback URL
Account Reference
Transaction Description
```

Then:

```text
Backend
   ↓
Daraja
   ↓
Customer Phone
```

### Goal

Successfully trigger an M-PESA payment prompt in the sandbox environment.

---

# Phase 6 — Callback

After the customer interacts with the STK prompt:

```text
M-PESA
   ↓
Daraja
   ↓
Callback URL
   ↓
Node.js Backend
```

The backend processes the callback.

Important fields include:

```text
MerchantRequestID
CheckoutRequestID
ResultCode
ResultDesc
CallbackMetadata
```

### Goal

Understand asynchronous payment processing.

---

# Phase 7 — Payment Status

The application will maintain payment states:

```text
PENDING
SUCCESS
FAILED
```

Example:

```text
STK Push sent
      ↓
   PENDING
      │
      ├── ResultCode = 0
      │       ↓
      │    SUCCESS
      │
      └── ResultCode != 0
              ↓
            FAILED
```

### Important

An accepted STK Push request does **not** automatically mean that the customer successfully paid.

The final result must be determined from the transaction result/callback.

---

# Phase 8 — Database

Once the basic integration works, transaction persistence will be introduced.

Possible payment fields:

```text
id
merchant_request_id
checkout_request_id
phone
amount
status
mpesa_receipt
transaction_date
created_at
updated_at
```

Possible statuses:

```text
PENDING
SUCCESS
FAILED
```

### Goal

Learn how payment transactions are tracked in a real application.

---

# Phase 9 — Security

The project will then be hardened.

Security requirements include:

* Never expose Consumer Secret in Flutter
* Never expose Passkey in Flutter
* Never commit `.env`
* Validate phone numbers
* Validate transaction amounts
* Validate API input
* Use HTTPS
* Keep secrets server-side
* Avoid logging sensitive credentials
* Handle duplicate callbacks safely
* Implement idempotent payment processing
* Separate sandbox and production credentials

---

# Phase 10 — Testing

Testing will cover:

### Flutter

* Empty phone number
* Invalid phone number
* Empty amount
* Invalid amount
* Network failure
* Backend failure

### Backend

* Invalid request
* Missing fields
* Invalid amount
* Invalid phone
* Daraja authentication failure
* STK Push failure

### M-PESA

* Successful payment
* Cancelled payment
* Failed payment
* Timeout
* Callback processing

---

# 🌐 Callback Development

One of the challenges during development is that Daraja must be able to reach our callback endpoint.

A local server such as:

```text
http://localhost:3000
```

is not normally reachable directly from Safaricom's infrastructure.

For development, we can use an HTTPS tunneling service to expose the local backend temporarily.

Conceptually:

```text
Internet
   │
   ▼
Public HTTPS URL
   │
   ▼
Local Tunnel
   │
   ▼
localhost:3000
```

The callback URL should point to the publicly reachable endpoint.

---

# 🔐 Environment Variables

Sensitive configuration will be stored using environment variables.

Example:

```env
MPESA_ENVIRONMENT=sandbox

MPESA_CONSUMER_KEY=
MPESA_CONSUMER_SECRET=

MPESA_SHORTCODE=
MPESA_PASSKEY=

MPESA_CALLBACK_URL=
```

Actual values must never be committed to GitHub.

Instead, the project will contain:

```text
.env
.env.example
```

with `.env` excluded through `.gitignore`.

---

# ❌ What We Will NOT Do

We will not place Daraja credentials directly inside Flutter.

Bad:

```dart
const consumerKey = "...";
const consumerSecret = "...";
const passkey = "...";
```

Correct:

```text
Flutter
   ↓
Backend
   ↓
Daraja
```

The backend is responsible for communicating with Daraja.

---

# 📖 Documentation

The project contains a dedicated:

## `DARAJA.md`

This document contains practical notes about:

* Daraja
* OAuth
* Access tokens
* STK Push
* Request parameters
* Responses
* Callbacks
* Result codes
* Payment status
* Security
* Other Daraja APIs
* Troubleshooting

It is intended to be used as a developer reference while building the project.

Official Daraja documentation:

https://developer.safaricom.co.ke/

---

# 🧪 Current Project Status

```text
[✓] Flutter project created
[✓] Daraja learning documentation created
[✓] Project workflow defined

[ ] Flutter payment UI
[ ] Node.js backend
[ ] Flutter → Backend communication
[ ] Daraja OAuth
[ ] STK Push
[ ] Callback endpoint
[ ] Payment status
[ ] Database
[ ] Security hardening
[ ] Testing
[ ] Deployment
```

---

# 🗺️ Future Improvements

After the basic workflow works, this project can be expanded with:

* Transaction history
* PostgreSQL/MySQL
* Authentication
* User accounts
* Payment verification
* Transaction status API
* C2B integration
* B2C integration
* Reversal API
* Account Balance API
* Payment receipts
* Admin dashboard
* REST API documentation
* Automated tests
* Docker
* CI/CD
* Production deployment

---

# 🎓 Learning Outcomes

After completing this project, I should be able to explain and implement:

```text
Flutter
   ↓
REST API
   ↓
Node.js
   ↓
OAuth
   ↓
Daraja
   ↓
STK Push
   ↓
M-PESA
   ↓
Callback
   ↓
Payment Verification
   ↓
Database
```

I should also understand why payment processing must be treated as an asynchronous workflow rather than a simple request/response operation.

---

# 💡 Why This Project Exists

Many applications eventually need payment functionality.

Examples include:

* E-commerce
* POS systems
* Loan platforms
* School management systems
* Healthcare systems
* SaaS applications
* Delivery applications
* Transport applications
* Event platforms
* Mobile applications

Understanding M-PESA integration at the API level makes it easier to add payments to these larger systems later.

This project is therefore a **small dedicated learning environment** for mastering that workflow before integrating payments into larger applications.

---

# 📌 Development Philosophy

The project follows these principles:

### Understand before abstracting

We first learn how Daraja works directly before relying heavily on third-party packages.

### Backend-first security

All sensitive Daraja credentials remain on the server.

### Small iterations

Each phase should work before moving to the next.

### Real API responses

We should inspect and understand actual Daraja responses instead of assuming their structure.

### Documentation-driven development

Important discoveries and implementation details should be added to `DARAJA.md`.

---

# 📜 License

This project is intended for educational purposes.

Add an appropriate open-source license if the project is later published for public reuse.

---

# 👨‍💻 Author

**Denis Murithi**

Computer Science Student
Full Stack Developer | Mobile Developer | Cybersecurity Enthusiast

GitHub:

https://github.com/Denis-7242

---

# ⭐ Project Goal

> Build a small application that makes the complete M-PESA Daraja payment workflow understandable.

```text
LEARN
  ↓
IMPLEMENT
  ↓
TEST
  ↓
DOCUMENT
  ↓
SECURE
  ↓
DEPLOY
  ↓
REUSE THE KNOWLEDGE
```

---

**Project:** `mpesa_integration_workflow`

**Primary API:** M-PESA Daraja

**Initial Feature:** STK Push

**Frontend:** Flutter

**Backend:** Node.js + Express

**Environment:** Daraja Sandbox

**Status:** 🚧 In Development
