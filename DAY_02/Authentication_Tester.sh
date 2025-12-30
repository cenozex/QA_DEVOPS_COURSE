#! /usr/bin/bash

echo "=====SCRIPT BY========="
echo "--------------CENOZEX--"

# -----------------------------
# Config: API credentials & URL
# -----------------------------
API_URL="http://192.168.31.198:3000"
USERNAME="test123"
PASSWORD="password@123"

# -----------------------------
# Step 1: Register user
# -----------------------------
curl -s -X POST -H "Content-Type: application/json" \
-d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
"$API_URL/register"

echo ""
echo "✅ User registration attempted."

# -----------------------------
# Step 2: Login and get token
# -----------------------------
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
-d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
"$API_URL/login" | grep -oP '(?<="accessToken":")[^"]+')

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed!"
    exit 1
else
    echo "✅ Login successful! Access token: $TOKEN"
fi

# -----------------------------
# Step 3: Access dashboard with valid token and print response
# -----------------------------
echo "Accessing dashboard..."
curl -s -X GET -H "Authorization: Bearer $TOKEN"  "$API_URL/dashboard"

echo ""
echo "✅ Dashboard request completed."


# -----------------------------
# Step 4: Access dashboard with FAKE token
# -----------------------------
FAKE_TOKEN="this.is.a.fake.token"

echo "🔹 Accessing dashboard with FAKE token..."
curl -s -X GET \
-H "Authorization: Bearer $FAKE_TOKEN" \
"$API_URL/dashboard"

echo ""
echo "❌ Expected failure with fake token."
echo ""

# -----------------------------
# Step 5: Access dashboard with CORRUPTED token
# (Simulates expired or tampered token)
# -----------------------------
CORRUPTED_TOKEN="${TOKEN}xyz"

echo "🔹 Accessing dashboard with CORRUPTED token..."
curl -s -X GET \
-H "Authorization: Bearer $CORRUPTED_TOKEN" \
"$API_URL/dashboard"

echo ""
echo "❌ Expected failure with corrupted/expired token."
echo ""

echo "===== SCRIPT COMPLETED ====="

