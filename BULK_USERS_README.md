# Bulk Users Creation Script

Yeh script database mein bulk users create karne ke liye hai.

## Created Users

Script yeh users create karega:

### Captain Users (10)
- `captain1@gmail.com` se `captain10@gmail.com` tak
- Role: `captain`
- Password: `123456`

### Referee Users (10)
- `referee1@gmail.com` se `referee10@gmail.com` tak
- Role: `referee`
- Password: `123456`

### Player Users (10)
- `player1@gmail.com` se `player10@gmail.com` tak
- Role: `player`
- Password: `123456`

### Stat Keeper Users (10)
- `statkeeper1@gmail.com` se `statkeeper10@gmail.com` tak
- Role: `stat-keeper` (database mein "stat-keeper" hai, email mein "statkeeper")
- Password: `123456`

**Total: 40 users**

## Method 1: API Endpoint (Recommended)

### Step 1: Start your Next.js server
```bash
npm run dev
```

### Step 2: Call the API endpoint
```bash
curl -X POST http://localhost:3000/api/create-bulk-users
```

Ya browser/postman se:
- **URL**: `http://localhost:3000/api/create-bulk-users`
- **Method**: `POST`
- **Body**: (No body needed)

### Response Example:
```json
{
  "message": "Bulk users creation completed",
  "summary": {
    "totalCreated": 40,
    "totalErrors": 0,
    "byRole": [
      { "role": "captain", "count": 10 },
      { "role": "referee", "count": 10 },
      { "role": "player", "count": 10 },
      { "role": "stat-keeper", "count": 10 }
    ]
  },
  "createdUsers": [...]
}
```

## Method 2: Direct Script Execution

### Step 1: Install dependencies (if not already installed)
```bash
npm install tsx
# or
npm install ts-node
```

### Step 2: Run the script
```bash
# Using tsx
npx tsx scripts/create-bulk-users.ts

# Or using ts-node
npx ts-node scripts/create-bulk-users.ts
```

## Important Notes

1. **Existing Users Check**: Agar koi user already exist karta hai, to script error dega. Pehle existing users delete karein ya API endpoint use karein jo existing users ko skip karega.

2. **Password**: Sab users ka default password `123456` hai. Production mein use mat karein!

3. **Role Mapping**: 
   - Email: `statkeeper1@gmail.com`
   - Database Role: `stat-keeper` (with hyphen)

4. **Database**: Script automatically MongoDB se connect hoga using your `.env` configuration.

## Troubleshooting

### Error: "Some users already exist"
- Existing users ko manually delete karein MongoDB se
- Ya API endpoint use karein jo existing users handle karega

### Error: "MongoDB connection failed"
- Check your `.env` file mein `MONGODB_URI` set hai
- MongoDB server running hai

### Error: "Role validation failed"
- Check karein ke role exactly match kare:
  - `captain` (not `Captain`)
  - `referee` (not `Referee`)
  - `player` (not `Player`)
  - `stat-keeper` (not `statkeeper` or `stat-keeper`)

## Testing

Users create hone ke baad, login test karein:

```bash
# Captain login
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"captain1@gmail.com","password":"123456"}'

# Player login
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"player1@gmail.com","password":"123456"}'
```

## Files

- `app/api/create-bulk-users/route.ts` - API endpoint
- `scripts/create-bulk-users.ts` - Standalone script
- `BULK_USERS_README.md` - This file
