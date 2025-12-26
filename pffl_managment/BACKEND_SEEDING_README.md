# PFFL Backend Database Seeding Script

This script creates dummy data for testing the PFFL Management System. It generates realistic test users with proper profile data, unique jersey numbers, and role-specific information.

## What It Creates

### 🏃‍♂️ Players (10 users)
- **Jersey Numbers:** 1-10
- **Role:** `player`
- **Profile Data:**
  - Basic info (name, email, phone)
  - Positions (1-3 random positions per player)
  - Physical stats (height, weight)
  - Experience level
  - Emergency contact information

### 🏁 Referees (10 users)
- **Jersey Numbers:** 11-20
- **Role:** `referee`
- **Profile Data:**
  - Basic info (name, email, phone)
  - Certification level (Level 1-3)
  - Years of experience
  - Specialization area
  - Emergency contact information

### 📊 Stat Keepers (10 users)
- **Jersey Numbers:** 21-30
- **Role:** `stat-keeper`
- **Profile Data:**
  - Basic info (name, email, phone)
  - Software experience level
  - Years of experience
  - Preferred device type
  - Emergency contact information

## Setup Instructions

### Prerequisites
- Node.js installed on your system
- Backend server running and accessible
- Admin credentials for authentication

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure the Script
Open `backend_seed_script.js` and update these constants:

```javascript
// Update this to match your backend URL
const BASE_URL = 'https://api-staging.phoenixflagfootballleague.com/api';
// const BASE_URL = 'http://localhost:3000/api'; // For local development

// Update with your admin credentials
const ADMIN_EMAIL = 'admin@pffl.com';
const ADMIN_PASSWORD = 'admin123';
```

### 3. Run the Seeding Script
```bash
# Seed the database with test users
npm run seed

# Or run directly
node backend_seed_script.js
```

## Usage Commands

### Seed Database
```bash
npm run seed
```
Creates 30 test users (10 players, 10 referees, 10 stat keepers) with realistic data.

### Cleanup Test Data
```bash
npm run cleanup
```
Removes all test users (identified by `@pffltest.com` email domain).

### Show Help
```bash
npm run help
```
Displays usage information and available commands.

## Generated Data Examples

### Player Example
```json
{
  "firstName": "James",
  "lastName": "Smith",
  "email": "james.smith.player1@pffltest.com",
  "phone": "555-123-4567",
  "role": "player",
  "jerseyNumber": "1",
  "position": "Quarterback, Wide Receiver",
  "height": "72\"",
  "weight": "185 lbs",
  "experience": "3 years",
  "emergencyContactName": "Sarah Smith",
  "emergencyPhone": "555-987-6543",
  "status": "active",
  "profileCompleted": true
}
```

### Referee Example
```json
{
  "firstName": "Michael",
  "lastName": "Johnson",
  "email": "michael.johnson.referee1@pffltest.com",
  "phone": "444-234-5678",
  "role": "referee",
  "jerseyNumber": "11",
  "certificationLevel": "Level 2",
  "yearsExperience": 5,
  "specialization": "Flag Football",
  "emergencyContactName": "Jennifer Johnson",
  "emergencyPhone": "444-876-5432",
  "status": "active",
  "profileCompleted": true
}
```

### Stat Keeper Example
```json
{
  "firstName": "David",
  "lastName": "Williams",
  "email": "david.williams.statkeeper1@pffltest.com",
  "phone": "333-345-6789",
  "role": "stat-keeper",
  "jerseyNumber": "21",
  "softwareExperience": "Advanced",
  "yearsExperience": 7,
  "preferredDevice": "Tablet",
  "emergencyContactName": "Lisa Williams",
  "emergencyPhone": "333-765-4321",
  "status": "active",
  "profileCompleted": true
}
```

## Script Features

### 🎯 **Smart Data Generation**
- Realistic names from predefined lists
- Unique email addresses with test domain
- Valid phone numbers with area codes
- Role-appropriate profile data
- Unique jersey numbers per role

### 🔄 **Robust Error Handling**
- Handles existing users gracefully
- Provides detailed error messages
- Continues processing even if some users fail
- Shows success/failure summary

### 🛡️ **Safe Operations**
- Uses proper authentication
- Respects API rate limits with delays
- Provides cleanup functionality
- Clear logging and progress indicators

### 📊 **Comprehensive Logging**
- Real-time progress updates
- Detailed error reporting
- Final summary statistics
- Clear success/failure indicators

## Testing Workflow

### 1. Initial Setup
```bash
# Install and configure
npm install
# Update configuration in backend_seed_script.js
npm run seed
```

### 2. Test Mobile App Features
- **User Management:** View users by role in admin panel
- **League Creation:** Invite the generated users to leagues
- **Notifications:** Test invitation acceptance/rejection
- **Game Creation:** Assign referees and stat keepers to games
- **Profile Management:** View and edit user profiles

### 3. Test Invitation Flow
1. Create a new league
2. Invite generated referees (jersey numbers 11-20)
3. Invite generated stat keepers (jersey numbers 21-30)
4. Test notification acceptance in mobile app
5. Verify users appear in Create Upcoming Games screen

### 4. Cleanup After Testing
```bash
npm run cleanup
```

## Troubleshooting

### Authentication Issues
- Verify backend URL is correct and accessible
- Check admin credentials are valid
- Ensure backend server is running

### User Creation Failures
- Check backend logs for detailed error messages
- Verify API endpoints are working correctly
- Ensure database is accessible and has proper permissions

### Network Issues
- Verify internet connection
- Check if backend URL is accessible from your machine
- Try with local backend URL if using localhost

## Customization

### Adding More Users
Modify the counts in the `seedDatabase()` function:
```javascript
const results = {
  players: await createUsersForRole('player', 1, 20, token), // 20 players
  referees: await createUsersForRole('referee', 21, 15, token), // 15 referees
  statKeepers: await createUsersForRole('stat-keeper', 36, 15, token) // 15 stat keepers
};
```

### Custom Data Fields
Add new fields in the `generateUserData()` function:
```javascript
const userData = {
  // ... existing fields
  customField: 'custom value',
  anotherField: generateCustomData(),
};
```

### Different Roles
Add new roles by creating additional role-specific data generators and calling `createUsersForRole()` with the new role.

## Security Notes

- Test users use `@pffltest.com` domain for easy identification
- All test data is clearly marked and can be safely removed
- Script requires admin authentication for security
- No sensitive real data is used in generation

## Support

If you encounter issues:
1. Check the console output for detailed error messages
2. Verify your backend configuration
3. Test with a smaller number of users first
4. Use the cleanup command to reset if needed

The script is designed to be safe, reusable, and provide clear feedback throughout the seeding process.