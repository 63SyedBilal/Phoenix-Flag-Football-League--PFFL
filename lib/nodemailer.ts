import nodemailer from "nodemailer";

// Create transporter lazily to ensure env vars are loaded
function getTransporter() {
  const host = process.env.SMTP_HOST;
  const port = process.env.SMTP_PORT ? parseInt(process.env.SMTP_PORT) : 587;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  
  if (!host || !user || !pass) {
    throw new Error("SMTP configuration is missing. Please check your environment variables.");
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465, // true for 465, false for other ports
    auth: {
      user,
      pass,
    },
    tls: {
      rejectUnauthorized: false, // Allow self-signed certificates
    },
    connectionTimeout: 10000, // 10 seconds
    greetingTimeout: 10000,
    socketTimeout: 10000,
  });
}

// Reusable sendMail function
interface SendMailOptions {
  to: string | string[];
  subject: string;
  text?: string;
  html?: string;
}

export const sendMail = async ({ to, subject, text, html }: SendMailOptions) => {
  try {
    // Get transporter (will throw if env vars are missing)
    const transporter = getTransporter();

    // Verify connection before sending
    await transporter.verify();

    const info = await transporter.sendMail({
      from: `"PFFL" <${process.env.SMTP_USER}>`,
      to,
      subject,
      text,
      html,
    });
    console.log("✅ Email sent successfully: %s", info.messageId);
    return info;
  } catch (error: any) {
    console.error("❌ Error sending email:", error);
    
    // Provide more helpful error messages
    if (error.code === "ECONNECTION" || error.code === "ETIMEDOUT") {
      throw new Error("Failed to connect to email server. Please check your SMTP settings.");
    } else if (error.code === "EAUTH") {
      throw new Error("Email authentication failed. Please check your SMTP credentials.");
    } else if (error.message?.includes("socket")) {
      throw new Error("Email server connection closed unexpectedly. Please check your SMTP configuration.");
    }
    
    throw new Error(error.message || "Failed to send email");
  }
};
