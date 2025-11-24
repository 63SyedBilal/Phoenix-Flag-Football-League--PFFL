import nodemailer from "nodemailer"

// Create reusable transporter
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT || "587"),
  secure: process.env.SMTP_SECURE === "true", // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || "",
  },
})

export interface EmailOptions {
  to: string | string[]
  subject: string
  html?: string
  text?: string
  from?: string
  cc?: string | string[]
  bcc?: string | string[]
  attachments?: Array<{
    filename: string
    path?: string
    content?: Buffer | string
    contentType?: string
  }>
}

/**
 * Send an email using nodemailer
 * @param options - Email options
 * @returns Message info
 */
export async function sendEmail(options: EmailOptions): Promise<any> {
  try {
    const mailOptions = {
      from: options.from || process.env.SMTP_FROM || process.env.SMTP_USER,
      to: Array.isArray(options.to) ? options.to.join(", ") : options.to,
      subject: options.subject,
      html: options.html,
      text: options.text,
      cc: options.cc,
      bcc: options.bcc,
      attachments: options.attachments,
    }

    const info = await transporter.sendMail(mailOptions)
    console.log("✅ Email sent successfully:", info.messageId)
    return info
  } catch (error) {
    console.error("❌ Email sending error:", error)
    throw new Error(`Failed to send email: ${error instanceof Error ? error.message : "Unknown error"}`)
  }
}

/**
 * Send a welcome email to new users
 * @param email - User email address
 * @param name - User name
 * @returns Message info
 */
export async function sendWelcomeEmail(
  email: string,
  name: string
): Promise<any> {
  const html = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to PFFL</title>
      </head>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(180deg, #1E3A8A 0%, #3B82F6 50%, #1E3A8A 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
          <h1 style="color: white; margin: 0;">Welcome to PFFL!</h1>
        </div>
        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
          <p>Hi ${name},</p>
          <p>Welcome to Phoenix Flag Football League! We're excited to have you on board.</p>
          <p>Your account has been successfully created. You can now:</p>
          <ul>
            <li>Access your dashboard</li>
            <li>Join leagues and teams</li>
            <li>Track your games and stats</li>
          </ul>
          <p>If you have any questions, feel free to reach out to our support team.</p>
          <p>Best regards,<br>The PFFL Team</p>
        </div>
      </body>
    </html>
  `

  return sendEmail({
    to: email,
    subject: "Welcome to PFFL!",
    html,
  })
}

/**
 * Send a password reset email
 * @param email - User email address
 * @param resetToken - Password reset token
 * @param resetUrl - Password reset URL
 * @returns Message info
 */
export async function sendPasswordResetEmail(
  email: string,
  resetToken: string,
  resetUrl?: string
): Promise<any> {
  const resetLink =
    resetUrl || `${process.env.NEXT_PUBLIC_APP_URL}/reset-password?token=${resetToken}`

  const html = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Your Password</title>
      </head>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(180deg, #1E3A8A 0%, #3B82F6 50%, #1E3A8A 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
          <h1 style="color: white; margin: 0;">Reset Your Password</h1>
        </div>
        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
          <p>You requested to reset your password for your PFFL account.</p>
          <p>Click the button below to reset your password:</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${resetLink}" style="background-color: #3B82F6; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">Reset Password</a>
          </div>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all; color: #3B82F6;">${resetLink}</p>
          <p><strong>This link will expire in 1 hour.</strong></p>
          <p>If you didn't request this password reset, please ignore this email.</p>
          <p>Best regards,<br>The PFFL Team</p>
        </div>
      </body>
    </html>
  `

  return sendEmail({
    to: email,
    subject: "Reset Your PFFL Password",
    html,
  })
}

/**
 * Send an email verification email
 * @param email - User email address
 * @param verificationToken - Email verification token
 * @param verificationUrl - Email verification URL
 * @returns Message info
 */
export async function sendVerificationEmail(
  email: string,
  verificationToken: string,
  verificationUrl?: string
): Promise<any> {
  const verificationLink =
    verificationUrl ||
    `${process.env.NEXT_PUBLIC_APP_URL}/verify-email?token=${verificationToken}`

  const html = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verify Your Email</title>
      </head>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(180deg, #1E3A8A 0%, #3B82F6 50%, #1E3A8A 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
          <h1 style="color: white; margin: 0;">Verify Your Email</h1>
        </div>
        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
          <p>Thank you for signing up for PFFL!</p>
          <p>Please verify your email address by clicking the button below:</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${verificationLink}" style="background-color: #3B82F6; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">Verify Email</a>
          </div>
          <p>Or copy and paste this link into your browser:</p>
          <p style="word-break: break-all; color: #3B82F6;">${verificationLink}</p>
          <p><strong>This link will expire in 24 hours.</strong></p>
          <p>If you didn't create an account, please ignore this email.</p>
          <p>Best regards,<br>The PFFL Team</p>
        </div>
      </body>
    </html>
  `

  return sendEmail({
    to: email,
    subject: "Verify Your PFFL Email Address",
    html,
  })
}

/**
 * Verify email transporter connection
 * @returns True if connection is successful
 */
export async function verifyEmailConnection(): Promise<boolean> {
  try {
    await transporter.verify()
    console.log("✅ Email server is ready to send messages")
    return true
  } catch (error) {
    console.error("❌ Email server connection error:", error)
    return false
  }
}



