import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/lib/db";

// Create error log schema (you might want to create a proper mongoose model for this)
interface ErrorLog {
  timestamp: string;
  type: 'fatal_error' | 'non_fatal_error' | 'log';
  exception?: string;
  reason?: string;
  stackTrace?: string;
  fatal?: boolean;
  userId?: string;
  userEmail?: string;
  userName?: string;
  deviceInfo?: any;
  appVersion?: string;
  platform?: string;
  additionalInfo?: Record<string, any>;
}

/**
 * Log error report from mobile app
 * POST /api/error-report
 */
export async function logErrorReport(req: NextRequest) {
  try {
    await connectDB();

    const errorData: ErrorLog = await req.json();

    // Validate required fields
    if (!errorData.timestamp || !errorData.type) {
      return NextResponse.json(
        { error: "timestamp and type are required" },
        { status: 400 }
      );
    }

    // Log the error to console for now (you could save to database)
    console.error(`🚨 [ERROR REPORT] ${errorData.type.toUpperCase()}:`, {
      timestamp: errorData.timestamp,
      userId: errorData.userId || 'anonymous',
      userEmail: errorData.userEmail || 'N/A',
      platform: errorData.platform || 'unknown',
      reason: errorData.reason || 'No reason provided',
      exception: errorData.exception?.substring(0, 500), // Truncate long exceptions
      fatal: errorData.fatal,
      appVersion: errorData.appVersion,
    });

    // TODO: Save to database for analysis
    // You could create an ErrorLog model and save the full error data
    /*
    const errorLog = new ErrorLogModel({
      ...errorData,
      createdAt: new Date()
    });
    await errorLog.save();
    */

    // If it's a fatal error, you might want to send alerts to developers
    if (errorData.fatal) {
      console.error(`💀 FATAL ERROR REPORTED - Immediate attention required!`);
      // TODO: Send email alert to developers for fatal errors
    }

    return NextResponse.json({
      success: true,
      message: "Error report logged successfully"
    });

  } catch (error: any) {
    console.error("Error logging error report:", error);
    return NextResponse.json(
      { error: "Failed to log error report" },
      { status: 500 }
    );
  }
}

/**
 * Log general application logs from mobile app
 * POST /api/error-log
 */
export async function logApplicationLog(req: NextRequest) {
  try {
    await connectDB();

    const logData: Omit<ErrorLog, 'fatal'> = await req.json();

    // Validate required fields
    if (!logData.timestamp || !logData.message) {
      return NextResponse.json(
        { error: "timestamp and message are required" },
        { status: 400 }
      );
    }

    // Log based on level
    const logFunction = getLogFunction(logData.level || 'info');

    logFunction(`📝 [APP LOG] ${logData.level?.toUpperCase() || 'INFO'}:`, {
      timestamp: logData.timestamp,
      userId: logData.userId || 'anonymous',
      platform: logData.platform || 'unknown',
      message: logData.message,
      appVersion: logData.appVersion,
    });

    // TODO: Save important logs to database
    // You could filter and save only certain log levels

    return NextResponse.json({
      success: true,
      message: "Log entry recorded successfully"
    });

  } catch (error: any) {
    console.error("Error logging application log:", error);
    return NextResponse.json(
      { error: "Failed to log application entry" },
      { status: 500 }
    );
  }
}

/**
 * Get appropriate logging function based on level
 */
function getLogFunction(level: string) {
  switch (level.toLowerCase()) {
    case 'error':
      return console.error;
    case 'warn':
    case 'warning':
      return console.warn;
    case 'debug':
      return console.debug;
    case 'info':
    default:
      return console.log;
  }
}
