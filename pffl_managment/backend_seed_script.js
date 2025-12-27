#!/usr/bin/env node

/**
 * Backend Seeding Script for PFFL Management System
 * 
 * This script creates dummy data for testing purposes:
 * - 10 Players with unique jersey numbers (1-10)
 * - 10 Referees with unique jersey numbers (11-20)
 * - 10 StatKeepers with unique jersey numbers (21-30)
 * 
 * Usage:
 * 1. Make sure your backend server is running
 * 2. Update the BASE_URL constant below to match your backend URL
 * 3. Run: node backend_seed_script.js
 * 
 * Requirements:
 * - Node.js
 * - axios package (npm install axios)
 */

const axios = require('axios');

// Configuration
const BASE_URL = 'https://api-staging.phoenixflagfootballleague.com/api';
// const BASE_URL = 'http://localhost:3000/api'; // Use this for local development

// Admin credentials for authentication (update these with your admin credentials)
const ADMIN_EMAIL = 'admin@pffl.com';
const ADMIN_PASSWORD = 'admin123';

// Dummy data generators
const firstNames = [
  'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Christopher',
  'Charles', 'Daniel', 'Matthew', 'Anthony', 'Mark', 'Donald', 'Steven', 'Paul', 'Andrew', 'Joshua',
  'Kenneth', 'Kevin', 'Brian', 'George', 'Timothy', 'Ronald', 'Jason', 'Edward', 'Jeffrey', 'Ryan'
];

const lastNames = [
  'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
  'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
  'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson'
];

const positions = [
  'Quarterback', 'Running Back', 'Wide Receiver', 'Tight End', 'Center',
  'Guard', 'Tackle', 'Defensive End', 'Linebacker', 'Cornerback',
  'Safety', 'Kicker', 'Punter', 'Long Snapper', 'Return Specialist'
];

const phoneAreaCodes = ['555', '444', '333', '222', '111'];

/**
 * Generate a random phone number
 */
function generatePhoneNumber() {
  const areaCode = phoneAreaCodes[Math.floor(Math.random() * phoneAreaCodes.length)];
  const exchange = Math.floor(Math.random() * 900) + 100;
  const number = Math.floor(Math.random() * 9000) + 1000;
  return `${areaCode}-${exchange}-${number}`;
}

/**
 * Generate a random email based on name
 */
function generateEmail(firstName, lastName, role, index) {
  const domain = 'pffltest.com';
  const rolePrefix = role.toLowerCase().replace('-', '');
  return `${firstName.toLowerCase()}.${lastName.toLowerCase()}.${rolePrefix}${index}@${domain}`;
}

/**
 * Generate emergency contact data
 */
function generateEmergencyContact(firstName, lastName) {
  const emergencyFirstNames = ['Sarah', 'Jennifer', 'Lisa', 'Karen', 'Nancy', 'Betty', 'Helen', 'Sandra', 'Donna', 'Carol'];
  const relationships = ['Mother', 'Father', 'Spouse', 'Sister', 'Brother', 'Friend'];
  
  const emergencyFirstName = emergencyFirstNames[Math.floor(Math.random() * emergencyFirstNames.length)];
  const relationship = relationships[Math.floor(Math.random() * relationships.length)];
  
  return {
    name: `${emergencyFirstName} ${lastName}`,
    phone: generatePhoneNumber(),
    relationship: relationship
  };
}

/**
 * Generate user data for a specific role
 */
function generateUserData(role, startJerseyNumber, count) {
  const users = [];
  
  for (let i = 0; i < count; i++) {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const jerseyNumber = startJerseyNumber + i;
    const email = generateEmail(firstName, lastName, role, i + 1);
    const emergencyContact = generateEmergencyContact(firstName, lastName);
    
    // Role-specific data
    let roleSpecificData = {};
    
    if (role === 'player') {
      // Players get positions and more detailed profile data
      const playerPositions = [];
      const numPositions = Math.floor(Math.random() * 3) + 1; // 1-3 positions
      
      for (let j = 0; j < numPositions; j++) {
        const position = positions[Math.floor(Math.random() * positions.length)];
        if (!playerPositions.includes(position)) {
          playerPositions.push(position);
        }
      }
      
      roleSpecificData = {
        position: playerPositions.join(', '),
        height: `${Math.floor(Math.random() * 12) + 60}"`, // 5'0" to 6'11"
        weight: `${Math.floor(Math.random() * 100) + 150} lbs`, // 150-249 lbs
        experience: `${Math.floor(Math.random() * 10)} years`,
      };
    } else if (role === 'referee') {
      roleSpecificData = {
        certificationLevel: ['Level 1', 'Level 2', 'Level 3'][Math.floor(Math.random() * 3)],
        yearsExperience: Math.floor(Math.random() * 15) + 1,
        specialization: ['Flag Football', 'Touch Football', 'General'][Math.floor(Math.random() * 3)],
      };
    } else if (role === 'stat-keeper') {
      roleSpecificData = {
        softwareExperience: ['Beginner', 'Intermediate', 'Advanced'][Math.floor(Math.random() * 3)],
        yearsExperience: Math.floor(Math.random() * 10) + 1,
        preferredDevice: ['Tablet', 'Laptop', 'Phone'][Math.floor(Math.random() * 3)],
      };
    }
    
    const userData = {
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: generatePhoneNumber(),
      role: role,
      jerseyNumber: jerseyNumber.toString(),
      emergencyContactName: emergencyContact.name,
      emergencyPhone: emergencyContact.phone,
      status: 'active',
      profileCompleted: true,
      ...roleSpecificData
    };
    
    users.push(userData);
  }
  
  return users;
}

/**
 * Authenticate with the backend and get access token
 */
async function authenticate() {
  try {
    console.log('🔐 Authenticating with backend...');
    
    const response = await axios.post(`${BASE_URL}/auth/login`, {
      email: ADMIN_EMAIL,
      password: ADMIN_PASSWORD
    });
    
    if (response.data && response.data.token) {
      console.log('✅ Authentication successful');
      return response.data.token;
    } else {
      throw new Error('No token received from authentication');
    }
  } catch (error) {
    console.error('❌ Authentication failed:', error.response?.data || error.message);
    throw error;
  }
}

/**
 * Create a user via the backend API
 */
async function createUser(userData, token) {
  try {
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
    
    // First, try to create the user via invite endpoint
    const inviteResponse = await axios.post(`${BASE_URL}/invite`, {
      email: userData.email,
      role: userData.role
    }, { headers });
    
    console.log(`📧 Invite sent for ${userData.firstName} ${userData.lastName} (${userData.role})`);
    
    // If user was created successfully, update their profile with additional data
    if (inviteResponse.status === 201 || inviteResponse.status === 200) {
      // Get the user ID from the response or fetch the user
      let userId = null;
      
      if (inviteResponse.data && inviteResponse.data.user && inviteResponse.data.user._id) {
        userId = inviteResponse.data.user._id;
      } else {
        // Fetch user by email to get ID
        try {
          const usersResponse = await axios.get(`${BASE_URL}/user`, { headers });
          if (usersResponse.data && usersResponse.data.data) {
            const user = usersResponse.data.data.find(u => u.email === userData.email);
            if (user) {
              userId = user._id || user.id;
            }
          }
        } catch (fetchError) {
          console.warn(`⚠️ Could not fetch user ID for ${userData.email}`);
        }
      }
      
      // Update user profile with additional data
      if (userId) {
        try {
          const profileData = { ...userData };
          delete profileData.email; // Don't update email
          delete profileData.role;  // Don't update role
          
          await axios.put(`${BASE_URL}/user/${userId}`, profileData, { headers });
          console.log(`✅ Profile updated for ${userData.firstName} ${userData.lastName}`);
        } catch (profileError) {
          console.warn(`⚠️ Could not update profile for ${userData.firstName} ${userData.lastName}:`, 
                      profileError.response?.data || profileError.message);
        }
      }
      
      return true;
    }
    
    return false;
  } catch (error) {
    if (error.response?.status === 409) {
      console.warn(`⚠️ User ${userData.email} already exists`);
      return false;
    }
    
    console.error(`❌ Failed to create user ${userData.firstName} ${userData.lastName}:`, 
                  error.response?.data || error.message);
    return false;
  }
}

/**
 * Create multiple users of a specific role
 */
async function createUsersForRole(role, startJerseyNumber, count, token) {
  console.log(`\n🎯 Creating ${count} ${role}s (Jersey Numbers ${startJerseyNumber}-${startJerseyNumber + count - 1})...`);
  
  const users = generateUserData(role, startJerseyNumber, count);
  let successCount = 0;
  
  for (const userData of users) {
    const success = await createUser(userData, token);
    if (success) {
      successCount++;
    }
    
    // Add small delay to avoid overwhelming the server
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  console.log(`✅ Successfully created ${successCount}/${count} ${role}s`);
  return successCount;
}

/**
 * Main seeding function
 */
async function seedDatabase() {
  console.log('🌱 Starting PFFL Backend Database Seeding...');
  console.log(`🔗 Target URL: ${BASE_URL}`);
  
  try {
    // Authenticate
    const token = await authenticate();
    
    // Create users for each role
    const results = {
      players: await createUsersForRole('player', 1, 10, token),
      referees: await createUsersForRole('referee', 11, 10, token),
      statKeepers: await createUsersForRole('stat-keeper', 21, 10, token)
    };
    
    // Summary
    console.log('\n📊 Seeding Summary:');
    console.log(`   Players: ${results.players}/10 created`);
    console.log(`   Referees: ${results.referees}/10 created`);
    console.log(`   Stat Keepers: ${results.statKeepers}/10 created`);
    console.log(`   Total: ${results.players + results.referees + results.statKeepers}/30 users created`);
    
    console.log('\n✅ Database seeding completed!');
    console.log('\n📝 Next Steps:');
    console.log('   1. Check your backend database to verify users were created');
    console.log('   2. Test the mobile app with the new dummy data');
    console.log('   3. Create leagues and invite these users to test the invitation flow');
    
  } catch (error) {
    console.error('\n❌ Seeding failed:', error.message);
    process.exit(1);
  }
}

/**
 * Cleanup function to remove all test users (optional)
 */
async function cleanupTestUsers() {
  console.log('🧹 Cleaning up test users...');
  
  try {
    const token = await authenticate();
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
    
    // Fetch all users
    const response = await axios.get(`${BASE_URL}/user`, { headers });
    
    if (response.data && response.data.data) {
      const testUsers = response.data.data.filter(user => 
        user.email && user.email.includes('@pffltest.com')
      );
      
      console.log(`Found ${testUsers.length} test users to remove`);
      
      for (const user of testUsers) {
        try {
          await axios.delete(`${BASE_URL}/user/${user._id || user.id}`, { headers });
          console.log(`🗑️ Removed ${user.firstName} ${user.lastName} (${user.email})`);
        } catch (deleteError) {
          console.warn(`⚠️ Could not remove ${user.email}:`, deleteError.response?.data || deleteError.message);
        }
        
        // Add small delay
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      
      console.log('✅ Cleanup completed');
    }
    
  } catch (error) {
    console.error('❌ Cleanup failed:', error.message);
  }
}

// Command line interface
const args = process.argv.slice(2);

if (args.includes('--cleanup')) {
  cleanupTestUsers();
} else if (args.includes('--help')) {
  console.log(`
PFFL Backend Seeding Script

Usage:
  node backend_seed_script.js          # Seed the database with test users
  node backend_seed_script.js --cleanup # Remove all test users
  node backend_seed_script.js --help    # Show this help message

Configuration:
  Update the BASE_URL, ADMIN_EMAIL, and ADMIN_PASSWORD constants in the script
  to match your backend configuration.

Requirements:
  - Node.js
  - axios package (npm install axios)
  - Backend server running
  - Admin credentials for authentication
  `);
} else {
  seedDatabase();
}