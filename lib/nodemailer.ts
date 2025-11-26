import nodemailer from "nodemailer";

// Configure transporter (SMTP)
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT || "587"),
  secure: process.env.SMTP_PORT === "465", // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || "",
  },
  tls: {
    rejectUnauthorized: false, // Allow self-signed certificates
  },
  connectionTimeout: 10000, // 10 seconds
  greetingTimeout: 10000,
  socketTimeout: 10000,
});

// Reusable sendMail function
interface SendMailOptions {
  to: string | string[];
  subject: string;
  text?: string;
  html?: string;
}

export const sendMail = async ({ to, subject, text, html }: SendMailOptions) => {
  try {
    // Verify SMTP configuration
    if (!process.env.SMTP_HOST || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
      throw new Error("SMTP configuration is missing. Please check your environment variables.");
    }

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
