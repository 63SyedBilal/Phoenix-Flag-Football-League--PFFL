import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";
import { User } from "@/modules";
import { sendMail } from "@/lib/nodemailer";

/**
 * Generate a simple 8-digit password
 */
function generateSimplePassword(): string {
  return Math.floor(10000000 + Math.random() * 90000000).toString();
}

/**
 * Map role names to schema values
 */
function mapRoleToSchema(role: string): string {
  const roleMap: { [key: string]: string } = {
    "Captain": "captain",
    "Player": "player",
    "Referee": "referee",
    "Stat Keeper": "stat-keeper",
    "Free Agent": "free-agent",
  };
  return roleMap[role] || role.toLowerCase().replace(/\s+/g, "-");
}

/**
 * Invite user - generate password, send email, save to DB
 * POST /api/invite
 */
export async function inviteUser(req: NextRequest) {
  try {
    await connectDB();
    const { email, role } = await req.json();

    if (!email || !role) {
      return NextResponse.json({ error: "Email and role are required" }, { status: 400 });
    }

    const emailLower = email.toLowerCase().trim();

    // Check if user already exists (exact match since email is stored lowercase)
    const existing = await User.findOne({ email: emailLower });
    
    if (existing) {
      console.log("❌ User already exists with email:", emailLower);
      return NextResponse.json({ 
        error: "A user with this email already exists. Please use a different email address." 
      }, { status: 409 });
    }
    
    console.log("✅ Email is available:", emailLower);

    // Generate simple 8-digit password
    const password = generateSimplePassword();
    const mappedRole = mapRoleToSchema(role);

    // Send email with password
    const emailSubject = "Welcome to PFFL - Your Account Credentials";
    const emailHtml = `
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
            <p>Hello,</p>
            <p>You have been invited to join Phoenix Flag Football League as a <strong>${role}</strong>.</p>
            <p>Your account has been created. Please use the following credentials to login:</p>
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border: 2px solid #3B82F6;">
              <p style="margin: 0;"><strong>Email:</strong> ${email}</p>
              <p style="margin: 10px 0 0 0;"><strong>Password:</strong> <span style="font-size: 18px; font-weight: bold; color: #3B82F6;">${password}</span></p>
            </div>
            <p>Please login at: <a href="${process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"}/login" style="color: #3B82F6;">${process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"}/login</a></p>
            <p><strong>Important:</strong> Please change your password after your first login for security.</p>
            <p>If you have any questions, feel free to reach out to our support team.</p>
            <p>Best regards,<br>The PFFL Team</p>
          </div>
        </body>
      </html>
    `;

    const emailText = `
Welcome to PFFL!

You have been invited to join Phoenix Flag Football League as a ${role}.

Your account has been created. Please use the following credentials to login:

Email: ${email}
Password: ${password}

Please login at: ${process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"}/login

Important: Please change your password after your first login for security.

If you have any questions, feel free to reach out to our support team.

Best regards,
The PFFL Team
    `;

    try {
      await sendMail({
        to: email,
        subject: emailSubject,
        text: emailText,
        html: emailHtml,
      });
    } catch (emailError: any) {
      console.error("Failed to send email:", emailError);
      return NextResponse.json(
        { error: emailError.message || "Failed to send invitation email. Please check your SMTP configuration." },
        { status: 500 }
      );
    }

    // Save user to database (password will be hashed by pre-save hook)
    // Don't set phone field to avoid unique constraint issues - it will be undefined
    try {
      const userData: any = {
        email: emailLower,
        role: mappedRole,
        password: password,
        firstName: "",
        lastName: "",
      };
      
      // Explicitly don't set phone - it will be undefined
      // This prevents MongoDB from creating empty string which violates unique constraint
      
      console.log("🔐 Creating user with plain password (will be hashed by pre-save hook)");
      console.log("📧 Email:", emailLower);
      console.log("👤 Role:", mappedRole);
      console.log("🔑 Password (plain):", password);
      
      const user = await User.create(userData);

      // Verify password was hashed (should start with $2a$ or $2b$)
      // Note: After creation, password field is not selected by default, so we need to fetch it again
      const userWithPassword = await User.findById((user as any)._id).select("+password");
      if (userWithPassword && (userWithPassword as any).password) {
        const passwordHash = (userWithPassword as any).password;
        const isHashed = passwordHash.startsWith("$2a$") || passwordHash.startsWith("$2b$");
        console.log("✅ User created successfully:", (user as any).email);
        console.log("🔐 Password was hashed:", isHashed);
        console.log("🔑 Password hash preview:", passwordHash.substring(0, 30) + "...");
      } else {
        console.log("⚠️ Warning: Password field not found after creation");
        console.log("✅ User created successfully:", (user as any).email);
      }

      return NextResponse.json(
        {
          message: "User invited successfully",
          data: {
            id: (user as any)._id,
            email: (user as any).email,
            role: (user as any).role,
          },
        },
        { status: 201 }
      );
    } catch (createError: any) {
      // Handle MongoDB duplicate key error (code 11000)
      if (createError.code === 11000) {
        console.error("❌ Duplicate key error:", createError.keyValue);
        console.error("❌ Key pattern:", createError.keyPattern);
        const duplicateField = Object.keys(createError.keyPattern || {})[0] || "email";
        
        // If it's a phone error, provide a more helpful message
        if (duplicateField === "phone") {
          return NextResponse.json(
            { 
              error: "There was an issue with phone number validation. Please try again or contact support." 
            },
            { status: 409 }
          );
        }
        
        return NextResponse.json(
          { 
            error: `A user with this ${duplicateField} already exists. Please use a different ${duplicateField}.` 
          },
          { status: 409 }
        );
      }
      throw createError; // Re-throw if it's not a duplicate key error
    }
  } catch (error: any) {
    console.error("❌ Invite user error:", error);
    console.error("❌ Error code:", error.code);
    console.error("❌ Error keyValue:", error.keyValue);
    console.error("❌ Error keyPattern:", error.keyPattern);
    
    // Handle MongoDB duplicate key error (code 11000)
    if (error.code === 11000) {
      const duplicateField = Object.keys(error.keyPattern || {})[0] || "email";
      
      // If it's a phone error, provide a more helpful message
      if (duplicateField === "phone") {
        return NextResponse.json(
          { 
            error: "There was an issue with phone number validation. Please try again or contact support." 
          },
          { status: 409 }
        );
      }
      
      return NextResponse.json(
        { 
          error: `A user with this ${duplicateField} already exists. Please use a different ${duplicateField}.` 
        },
        { status: 409 }
      );
    }
    
    return NextResponse.json({ 
      error: error.message || "Failed to invite user. Please try again." 
    }, { status: 500 });
  }
}

