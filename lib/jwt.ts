import jwt from "jsonwebtoken"

const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key-change-in-production"
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || "your-refresh-secret-key-change-in-production"
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d"
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || "30d"

export interface TokenPayload {
  userId: string
  email: string
  role?: string
  [key: string]: any
}

export interface TokenPair {
  accessToken: string
  refreshToken: string
}

/**
 * Generate a JWT access token
 * @param payload - Token payload data
 * @returns JWT access token
 */
export function generateAccessToken(payload: TokenPayload): string {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN,
  })
}

/**
 * Generate a JWT refresh token
 * @param payload - Token payload data
 * @returns JWT refresh token
 */
export function generateRefreshToken(payload: TokenPayload): string {
  return jwt.sign(payload, JWT_REFRESH_SECRET, {
    expiresIn: JWT_REFRESH_EXPIRES_IN,
  })
}

/**
 * Generate both access and refresh tokens
 * @param payload - Token payload data
 * @returns Object containing both tokens
 */
export function generateTokenPair(payload: TokenPayload): TokenPair {
  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken(payload),
  }
}

/**
 * Verify and decode a JWT access token
 * @param token - JWT token to verify
 * @returns Decoded token payload
 * @throws Error if token is invalid or expired
 */
export function verifyAccessToken(token: string): TokenPayload {
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload
    return decoded
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new Error("Token has expired")
    } else if (error instanceof jwt.JsonWebTokenError) {
      throw new Error("Invalid token")
    }
    throw new Error("Token verification failed")
  }
}

/**
 * Verify and decode a JWT refresh token
 * @param token - JWT refresh token to verify
 * @returns Decoded token payload
 * @throws Error if token is invalid or expired
 */
export function verifyRefreshToken(token: string): TokenPayload {
  try {
    const decoded = jwt.verify(token, JWT_REFRESH_SECRET) as TokenPayload
    return decoded
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new Error("Refresh token has expired")
    } else if (error instanceof jwt.JsonWebTokenError) {
      throw new Error("Invalid refresh token")
    }
    throw new Error("Refresh token verification failed")
  }
}

/**
 * Decode a JWT token without verification (use with caution)
 * @param token - JWT token to decode
 * @returns Decoded token payload or null if invalid
 */
export function decodeToken(token: string): TokenPayload | null {
  try {
    return jwt.decode(token) as TokenPayload
  } catch (error) {
    return null
  }
}

/**
 * Get token expiration time
 * @param token - JWT token
 * @returns Expiration timestamp or null
 */
export function getTokenExpiration(token: string): number | null {
  const decoded = decodeToken(token)
  if (decoded && typeof decoded.exp === "number") {
    return decoded.exp * 1000 // Convert to milliseconds
  }
  return null
}

/**
 * Check if token is expired
 * @param token - JWT token
 * @returns True if expired, false otherwise
 */
export function isTokenExpired(token: string): boolean {
  const expiration = getTokenExpiration(token)
  if (!expiration) return true
  return Date.now() >= expiration
}












