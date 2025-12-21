/**
 * Simple script to run the team fix via API
 * Run with: node scripts/run-fix-teams.js
 */

const http = require('http');

// You'll need to provide an admin token
// For now, this is a placeholder - you'll need to get a token from your auth system
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || 'YOUR_ADMIN_TOKEN_HERE';

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/admin/fix-teams',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${ADMIN_TOKEN}`
  }
};

const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('Response:', JSON.stringify(JSON.parse(data), null, 2));
  });
});

req.on('error', (error) => {
  console.error('Error:', error);
});

req.end();
