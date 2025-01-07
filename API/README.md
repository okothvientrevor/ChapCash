# ChapCash API

A secure payment processing API built with Node.js, Express, and MongoDB. This API allows users to register, login, make payments, and manage transactions.

## Features

- User authentication (register/login) with JWT
- Secure payment processing between users
- Balance management and deposits
- Transaction history tracking
- Admin dashboard capabilities
- User profile management

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn package manager

## Installation

1. Clone the repository:
```bash
git clone <your-repository-url>
cd chapcash-api
```

2. Install dependencies:
```bash
npm install
```

3. Create the required directories:
```bash
mkdir models routes
```

4. Create and setup environment variables in a `.env` file:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/transactionsDB
JWT_SECRET=your_jwt_secret_here
ADMIN_SECRET=your_admin_secret_here
```

## Project Structure

```
chapcash-api/
├── models/
│   ├── User.js
│   └── Transaction.js
├── routes/
│   └── api.js
├── server.js
├── .env
└── package.json
```

## Required Dependencies

Add these to your package.json:
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.0.0",
    "bcrypt": "^5.1.0",
    "jsonwebtoken": "^9.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "body-parser": "^1.20.2"
  }
}
```

## API Endpoints

### Authentication
- `POST /api/register` - Register new user
- `POST /api/login` - Login user

### User Operations
- `GET /api/profile` - Get user profile
- `POST /api/deposit` - Deposit money
- `POST /api/payments` - Make payment to another user
- `GET /api/payments` - Get payment history

### Admin Operations
- `GET /api/users` - Get all users (admin only)
- `GET /api/transactions` - Get all transactions (admin only)
- `POST /api/create-admin` - Create admin user
- `POST /api/promote-to-admin` - Promote user to admin

## Testing with Postman

1. Register a new user:
```http
POST /api/register
Content-Type: application/json

{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "securepassword"
}
```

2. Login to get JWT token:
```http
POST /api/login
Content-Type: application/json

{
    "email": "john@example.com",
    "password": "securepassword"
}
```

3. Use the received token in subsequent requests:
```http
GET /api/profile
Authorization: Bearer <your_jwt_token>
```

## Creating First Admin User

Use MongoDB Shell (mongosh):
```javascript
use transactionsDB
db.users.updateOne(
    { email: "admin@example.com" },
    { $set: { role: "admin" } }
)
```

## Error Handling

The API returns appropriate HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Server Error