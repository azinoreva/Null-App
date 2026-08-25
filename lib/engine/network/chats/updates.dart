curl -X 'POST' \
  'http://localhost:8000/api/updates' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "nickname": "azino",
  "text": "Jonathan was good",
  "category": "politics",
  "hashtag": "Jonathan"
}'

{
  "update_id": "e55c3dfc-e63c-4b1e-b056-327018aae5bb",
  "user_id": "5eeba611-8d78-4886-90ee-e4ac6928984d",
  "nickname": "azino",
  "text": "Jonathan was good",
  "expires": 604800,
  "media": null
}


curl -X 'POST' \
  'http://localhost:8000/api/updates' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "nickname": "azino",
  "media": {
    "media_url": "media_url",
    "media_type": "video",
    "media_description": "Music video"
  },
  "text": "Media Publicity",
  "category": "music",
  "hashtag": "donjazzy"
}'


{
  "update_id": "43616532-205c-4236-9897-7e8adcc11a8e",
  "user_id": "5eeba611-8d78-4886-90ee-e4ac6928984d",
  "nickname": "azino",
  "text": "Media Publicity",
  "expires": 604800,
  "media": {
    "media_url": "media_url",
    "media_type": "video",
    "media_description": "Music video"
  }
}