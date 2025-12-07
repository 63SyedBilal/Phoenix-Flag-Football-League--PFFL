# SMTP Email Configuration Setup Guide

## Quick Setup

Your application requires SMTP configuration to send emails (invitations, notifications, etc.). Follow these steps:

### Step 1: Create `.env.local` file

Create a file named `.env.local` in your project root directory (same level as `package.json`).

### Step 2: Add SMTP Configuration

Add the following to your `.env.local` file:

```env
# SMTP Email Configuration (REQUIRED)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

## Gmail Setup Instructions

If you're using Gmail, you need to create an **App Password** (not your regular password):

### For Gmail:

1. **Enable 2-Step Verification** (if not already enabled):
   - Go to your Google Account: https://myaccount.google.com/
   - Navigate to Security → 2-Step Verification
   - Follow the prompts to enable it

2. **Create an App Password**:
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" as the app
   - Select "Other (Custom name)" as the device
   - Enter "PFFL App" or any name you prefer
   - Click "Generate"
   - **Copy the 16-character password** (you'll see it only once)

3. **Add to `.env.local`**:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=xxxx xxxx xxxx xxxx  # The 16-character app password (remove spaces)
   ```

## Other Email Providers

### Outlook/Hotmail:
```env
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_USER=your-email@outlook.com
SMTP_PASS=your-password
```

### Yahoo:
```env
SMTP_HOST=smtp.mail.yahoo.com
SMTP_PORT=587
SMTP_USER=your-email@yahoo.com
SMTP_PASS=your-app-password
```

### Custom SMTP Server:
```env
SMTP_HOST=your-smtp-server.com
SMTP_PORT=587  # or 465 for SSL
SMTP_USER=your-username
SMTP_PASS=your-password
```

## Complete `.env.local` Template

Here's a complete template with all required environment variables:

```env
# Database Configuration
MONGODB_URI=mongodb://localhost:27017/pffl

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Cloudinary Configuration (for image uploads)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# SMTP Email Configuration (REQUIRED)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Stripe Configuration (for payments)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here

# Application URL
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## Verification

After setting up your `.env.local` file:

1. **Restart your development server**:
   ```bash
   # Stop the server (Ctrl+C)
   # Then restart:
   npm run dev
   ```

2. **Test email sending** by:
   - Inviting a user
   - Creating a league invitation
   - Any action that triggers an email

## Troubleshooting

### Error: "SMTP configuration is missing"
- Make sure `.env.local` exists in the project root
- Verify all three variables are set: `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`
- Restart your development server after adding variables

### Error: "Email authentication failed"
- For Gmail: Make sure you're using an App Password, not your regular password
- Verify your email and password are correct
- Check if 2-Step Verification is enabled (required for App Passwords)

### Error: "Failed to connect to email server"
- Check your `SMTP_HOST` and `SMTP_PORT` are correct
- Verify your firewall/network allows SMTP connections
- Try port 465 with SSL if 587 doesn't work

## Security Notes

⚠️ **Important**: 
- Never commit `.env.local` to version control (it's already in `.gitignore`)
- Use different credentials for development and production
- For production, use environment variables provided by your hosting platform (Vercel, AWS, etc.)

