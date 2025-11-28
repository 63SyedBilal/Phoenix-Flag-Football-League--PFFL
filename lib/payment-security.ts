/**
 * Payment Security Utilities
 * Helper functions for payment verification and security checks
 */

import { verifyAccessToken } from "./jwt";
import Payment from "@/modules/payment";
import mongoose from "mongoose";

/**
 * Verify payment ownership and status
 * Ensures the authenticated user owns the payment and it's valid for processing
 */
export async function verifyPaymentOwnership(
  paymentId: string,
  userId: string
): Promise<{
  valid: boolean;
  payment?: any;
  error?: string;
  errorCode?: string;
}> {
  try {
    // Validate paymentId format
    if (!mongoose.Types.ObjectId.isValid(paymentId)) {
      return {
        valid: false,
        error: "Invalid payment ID format",
        errorCode: "INVALID_PAYMENT_ID",
      };
    }

    // Find payment
    const payment = await Payment.findById(paymentId);

    if (!payment) {
      return {
        valid: false,
        error: "Payment record not found",
        errorCode: "PAYMENT_NOT_FOUND",
      };
    }

    // Verify ownership
    if (payment.userId.toString() !== userId) {
      console.error("🔒 SECURITY: Payment ownership mismatch");
      console.error("   - Payment User ID:", payment.userId.toString());
      console.error("   - Authenticated User ID:", userId);
      return {
        valid: false,
        error: "You do not have permission to access this payment",
        errorCode: "UNAUTHORIZED",
      };
    }

    // Check if already paid (idempotency)
    if (payment.status === "paid") {
      return {
        valid: false,
        payment,
        error: "This payment has already been processed",
        errorCode: "ALREADY_PAID",
      };
    }

    return {
      valid: true,
      payment,
    };
  } catch (error: any) {
    console.error("Error in verifyPaymentOwnership:", error);
    return {
      valid: false,
      error: "Failed to verify payment ownership",
      errorCode: "VERIFICATION_ERROR",
    };
  }
}

/**
 * Sanitize card number for logging (show only last 4 digits)
 */
export function sanitizeCardNumber(cardNumber: string): string {
  if (!cardNumber || cardNumber.length < 4) {
    return "****";
  }
  const last4 = cardNumber.slice(-4);
  return `**** **** **** ${last4}`;
}

/**
 * Validate card details format
 */
export function validateCardDetails(
  cardNumber: string,
  expiryDate: string,
  cvv: string
): {
  valid: boolean;
  error?: string;
} {
  // Validate card number
  const cleanCardNumber = cardNumber.replace(/\s/g, "");
  if (!/^\d{13,19}$/.test(cleanCardNumber)) {
    return {
      valid: false,
      error: "Invalid card number. Please enter a valid card number.",
    };
  }

  // Validate expiry date format (MM/YY)
  if (!/^\d{2}\/\d{2}$/.test(expiryDate)) {
    return {
      valid: false,
      error: "Invalid expiry date format. Please use MM/YY format.",
    };
  }

  // Validate expiry date is in the future
  const [month, year] = expiryDate.split("/").map(Number);
  const currentDate = new Date();
  const currentYear = currentDate.getFullYear() % 100; // Get last 2 digits
  const currentMonth = currentDate.getMonth() + 1;

  if (year < currentYear || (year === currentYear && month < currentMonth)) {
    return {
      valid: false,
      error: "Card has expired. Please use a valid card.",
    };
  }

  if (month < 1 || month > 12) {
    return {
      valid: false,
      error: "Invalid expiry month. Please enter a valid month (01-12).",
    };
  }

  // Validate CVV
  if (!/^\d{3,4}$/.test(cvv)) {
    return {
      valid: false,
      error: "Invalid CVV. Please enter 3 or 4 digits.",
    };
  }

  return { valid: true };
}

/**
 * Generate idempotency key for payment processing
 */
export function generateIdempotencyKey(paymentId: string): string {
  return `payment_${paymentId}_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`;
}

/**
 * Log payment attempt for security audit
 */
export function logPaymentAttempt(
  userId: string,
  paymentId: string,
  success: boolean,
  errorMessage?: string
): void {
  const timestamp = new Date().toISOString();
  const status = success ? "✅ SUCCESS" : "❌ FAILED";
  
  console.log(`\n🔐 ========== PAYMENT ATTEMPT LOG ==========`);
  console.log(`   Timestamp: ${timestamp}`);
  console.log(`   User ID: ${userId}`);
  console.log(`   Payment ID: ${paymentId}`);
  console.log(`   Status: ${status}`);
  if (errorMessage) {
    console.log(`   Error: ${errorMessage}`);
  }
  console.log(`🔐 =========================================\n`);
}

/**
 * Rate limiting check (basic implementation)
 * In production, use Redis or similar for distributed rate limiting
 */
const paymentAttempts = new Map<string, number[]>();

export function checkRateLimit(
  userId: string,
  maxAttempts: number = 5,
  windowMs: number = 60000 // 1 minute
): {
  allowed: boolean;
  remainingAttempts: number;
} {
  const now = Date.now();
  const userAttempts = paymentAttempts.get(userId) || [];
  
  // Filter out attempts outside the time window
  const recentAttempts = userAttempts.filter(
    (timestamp) => now - timestamp < windowMs
  );
  
  if (recentAttempts.length >= maxAttempts) {
    return {
      allowed: false,
      remainingAttempts: 0,
    };
  }
  
  // Add current attempt
  recentAttempts.push(now);
  paymentAttempts.set(userId, recentAttempts);
  
  return {
    allowed: true,
    remainingAttempts: maxAttempts - recentAttempts.length,
  };
}

