import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { sendEmail } from "@/lib/nodemailer";

/**
 * Send email notification
 * POST /api/email/send
 */
export async function sendEmailNotification(req: NextRequest) {
  try {
    await connectDB();

    const {
      recipientEmail,
      subject,
      body,
      userId,
      leagueId,
      teamId,
      paymentId,
      matchId,
      type
    } = await req.json();

    // Validate required fields
    if (!recipientEmail || !subject) {
      return NextResponse.json(
        { error: "recipientEmail and subject are required" },
        { status: 400 }
      );
    }

    // Send email using nodemailer
    await sendEmail({
      to: recipientEmail,
      subject,
      html: body,
      // You can add additional context here if needed
    });

    console.log(`✅ Email sent to ${recipientEmail}: ${subject}`);

    return NextResponse.json({
      success: true,
      message: "Email sent successfully"
    });

  } catch (error: any) {
    console.error("Error sending email:", error);
    return NextResponse.json(
      { error: error.message || "Failed to send email" },
      { status: 500 }
    );
  }
}
