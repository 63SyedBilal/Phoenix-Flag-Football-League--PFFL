#!/usr/bin/env node

/**
 * Setup Admin Account Script
 * Creates the specific admin account: pffl@gmail.com with password 123456
 *
 * Usage:
 * node setup-admin.js
 *
 * Requirements:
 * - Node.js
 * - Backend server running
 */

const axios = require('axios');

// Configuration - Update if your backend is running on different port/host
const BASE_URL = process.env.BASE_URL || 'http://localhost:3000/api';

async function setupAdminAccount() {
  try {
    console.log('🚀 Setting up admin account: pffl@gmail.com');
    console.log('📡 Backend URL:', BASE_URL);

    // Check if admin already exists
    console.log('🔍 Checking if admin account already exists...');

    try {
      const loginResponse = await axios.post(`${BASE_URL}/login`, {
        email: 'pffl@gmail.com',
        password: '123456'
      });

      if (loginResponse.status === 200) {
        console.log('✅ Admin account already exists and is working!');
        console.log('📧 Email: pffl@gmail.com');
        console.log('🔑 Password: 123456');
        console.log('👤 Role: superadmin');
        return;
      }
    } catch (loginError) {
      // Expected if account doesn't exist yet
      console.log('ℹ️ Admin account does not exist yet, creating...');
    }

    // Create the admin account
    console.log('📝 Creating admin account...');
    const createResponse = await axios.post(`${BASE_URL}/superadmin`, {
      email: 'pffl@gmail.com',
      password: '123456'
    });

    if (createResponse.status === 200 || createResponse.status === 201) {
      console.log('✅ Admin account created successfully!');
      console.log('📧 Email: pffl@gmail.com');
      console.log('🔑 Password: 123456');
      console.log('👤 Role: superadmin');

      // Verify the account works
      console.log('🔍 Verifying account works...');
      const verifyResponse = await axios.post(`${BASE_URL}/login`, {
        email: 'pffl@gmail.com',
        password: '123456'
      });

      if (verifyResponse.status === 200) {
        console.log('✅ Admin account verified and working!');
        console.log('🎉 Setup complete!');
      }
    }

  } catch (error) {
    console.error('❌ Error setting up admin account:');

    if (error.response) {
      console.error('📡 Response status:', error.response.status);
      console.error('📄 Response data:', error.response.data);
    } else if (error.request) {
      console.error('🌐 No response received. Is the backend server running?');
      console.error('💡 Make sure your backend is running on:', BASE_URL);
    } else {
      console.error('⚠️ Request setup error:', error.message);
    }

    console.log('\n🔧 Troubleshooting:');
    console.log('1. Make sure your backend server is running');
    console.log('2. Check that MongoDB is connected');
    console.log('3. Verify the BASE_URL is correct');
    console.log('4. Check backend logs for detailed errors');

    process.exit(1);
  }
}

// Run the setup
console.log('🔧 PFFL Admin Account Setup');
console.log('============================\n');

setupAdminAccount();
