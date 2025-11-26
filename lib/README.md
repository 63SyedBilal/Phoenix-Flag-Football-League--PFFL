# Library Utilities

This directory contains utility functions for authentication, database, Cloudinary, JWT, and email services.

## Environment Variables

Create a `.env.local` file in the root directory with the following variables:

### Database Configuration
```
MONGODB_URI=mongodb://localhost:27017/pffl
# Or for MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/pffl?retryWrites=true&w=majority
```

### JWT Configuration
```
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d
```

### Cloudinary Configuration
```
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### Email Configuration (SMTP)
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=noreply@pffl.com
```

### Application URL
```
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## Usage

### Authentication (`lib/auth.ts`)
```typescript
import { hashPassword, verifyPassword, validatePasswordStrength } from '@/lib/auth'

// Hash a password
const hashedPassword = await hashPassword('userPassword123')

// Verify a password
const isValid = await verifyPassword('userPassword123', hashedPassword)

// Validate password strength
const validation = validatePasswordStrength('password')
```

### Database (`lib/db.ts`)
```typescript
import { connectDB, disconnectDB, isConnected } from '@/lib/db'

// Connect to database
await connectDB()

// Check connection status
if (isConnected()) {
  console.log('Database is connected')
}

// Disconnect (usually not needed in serverless)
await disconnectDB()
```

### Cloudinary (`lib/cloudinary.ts`)
```typescript
import { uploadToCloudinary, deleteFromCloudinary } from '@/lib/cloudinary'

// Upload a file
const result = await uploadToCloudinary(fileBuffer, {
  folder: 'pffl/users',
})

// Delete a file
await deleteFromCloudinary(result.public_id)
```

### JWT (`lib/jwt.ts`)
```typescript
import { generateTokenPair, verifyAccessToken } from '@/lib/jwt'

// Generate tokens
const { accessToken, refreshToken } = generateTokenPair({
  userId: '123',
  email: 'user@example.com',
  role: 'player'
})

// Verify token
const payload = verifyAccessToken(accessToken)
```

### Email (`lib/nodemailer.ts`)
```typescript
import { sendEmail, sendWelcomeEmail, sendPasswordResetEmail } from '@/lib/nodemailer'

// Send custom email
await sendEmail({
  to: 'user@example.com',
  subject: 'Hello',
  html: '<p>Hello World</p>'
})

// Send welcome email
await sendWelcomeEmail('user@example.com', 'John Doe')

// Send password reset email
await sendPasswordResetEmail('user@example.com', resetToken)
```





