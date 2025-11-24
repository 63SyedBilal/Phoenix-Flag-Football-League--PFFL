# Modules

This directory contains Mongoose schemas and models for the application.

## Structure

```
modules/
├── login/
│   ├── schema.ts    # Login schema with authentication methods
│   └── index.ts      # Exports
├── signup/
│   ├── schema.ts    # Signup schema with multi-step registration
│   └── index.ts      # Exports
├── users/
│   ├── schema.ts    # User schema with league and team references
│   └── index.ts      # Exports
└── index.ts          # Central exports
```

## Login Schema

The login schema handles user authentication with the following features:

- **Email and Password**: Secure password storage with bcrypt hashing
- **Role-based Access**: Supports player, captain, referee, stat-keeper, superadmin, and free-agent roles
- **Account Security**: 
  - Login attempt tracking
  - Account locking after 5 failed attempts (2-hour lockout)
  - Last login tracking
- **Methods**:
  - `comparePassword()` - Verify password against hash
  - `isLocked()` - Check if account is locked
  - `incrementLoginAttempts()` - Track failed login attempts
  - `resetLoginAttempts()` - Reset after successful login

### Usage

```typescript
import { Login } from '@/modules/login'
import { connectDB } from '@/lib/db'

await connectDB()

// Create a new login
const login = new Login({
  email: 'user@example.com',
  password: 'securePassword123',
  role: 'player'
})
await login.save()

// Find and verify login
const user = await Login.findOne({ email: 'user@example.com' }).select('+password')
if (user && await user.comparePassword('securePassword123')) {
  await user.resetLoginAttempts()
  // Login successful
} else {
  await user?.incrementLoginAttempts()
  // Login failed
}
```

## Signup Schema

The signup schema handles multi-step user registration with the following features:

- **Multi-step Registration**: Tracks signup progress (signup → profile → team)
- **Account Types**: Supports player, captain, and free-agent
- **Profile Information**: 
  - Profile picture
  - Position (for players)
  - Emergency contact information
- **Team Information** (for captains):
  - Team logo
  - Team name, color, location
  - Skill level
- **Email Verification**: Token-based email verification
- **Status Tracking**: pending, completed, active

### Usage

```typescript
import { Signup } from '@/modules/signup'
import { connectDB } from '@/lib/db'

await connectDB()

// Step 1: Initial signup
const signup = new Signup({
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phoneNumber: '+1234567890',
  password: 'securePassword123',
  accountType: 'captain',
  signupStep: 'signup'
})
await signup.save()

// Step 2: Complete profile
signup.profilePic = 'cloudinary-url'
signup.position = 'QB'
signup.emergencyContactName = 'Jane Doe'
signup.emergencyPhoneNumber = '+1234567891'
signup.signupStep = 'profile'
await signup.save()

// Step 3: Complete team (for captains)
signup.teamLogo = 'cloudinary-url'
signup.teamName = 'Phoenix Eagles'
signup.teamColor = '#FF5733'
signup.location = 'Phoenix, AZ'
signup.skillLevel = 'Competitive'
signup.signupStep = 'team'
signup.status = 'completed'
await signup.save()

// Generate email verification token
const token = signup.generateEmailVerificationToken()
await signup.save()
```

## User Schema

The user schema is the main user model that links users with leagues and teams:

- **User Information**: First name, last name, email, phone number
- **Role-based Access**: Supports free-agent, captain, player, referee, stat-keeper, and superadmin roles
- **League & Team Linking**: 
  - `leagueId` - Reference to League model
  - `teamId` - Reference to Team model
- **Security**: Password hashing with bcrypt
- **Methods**:
  - `comparePassword()` - Verify password against hash
  - `getFullName()` - Get user's full name
- **Virtuals**:
  - `fullName` - Virtual field for full name
- **Auto Password Hashing**: Password is automatically hashed before saving

### Usage

```typescript
import { User } from '@/modules/users'
import { connectDB } from '@/lib/db'

await connectDB()

// Create a new user
const user = new User({
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phoneNumber: '+1234567890',
  password: 'securePassword123',
  role: 'player',
  leagueId: null,
  teamId: null
})
await user.save()

// Find user and verify password
const foundUser = await User.findOne({ email: 'john@example.com' }).select('+password')
if (foundUser && await foundUser.comparePassword('securePassword123')) {
  console.log('Password is correct')
  console.log('Full name:', foundUser.getFullName())
}

// Link user to league and team
user.leagueId = leagueId
user.teamId = teamId
await user.save()

// Find users by role
const captains = await User.find({ role: 'captain' })

// Find users in a specific team
const teamMembers = await User.find({ teamId: teamId })

// Find users in a specific league
const leagueUsers = await User.find({ leagueId: leagueId })
```

## Integration with Lib Utilities

Both schemas integrate with utilities from `lib/`:

- **Password Hashing**: Uses `hashPassword()` from `lib/auth.ts`
- **Password Verification**: Uses `verifyPassword()` from `lib/auth.ts`
- **Email Verification**: Can use `sendVerificationEmail()` from `lib/nodemailer.ts`

## Environment Variables

Make sure you have the following environment variables set:

- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - Secret for JWT tokens
- `SMTP_*` - Email configuration (for verification emails)

See `lib/README.md` for complete environment variable documentation.

