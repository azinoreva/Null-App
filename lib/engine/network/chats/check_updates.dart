curl -X 'POST' \
  'http://localhost:8000/api/get_updates' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "category": "politics",
  "before": 0,
  "limit": 20
}'


[
  {
    "nickname": "azino",
    "media": null,
    "text": "Jonathan was good",
    "category": "politics",
    "hashtag": "Jonathan",
    "update_id": "e55c3dfc-e63c-4b1e-b056-327018aae5bb"
  }
]




curl -X 'POST' \
  'http://localhost:8000/api/get_updates' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{

  "hashtags": [
    "donjazzy"
  ],
  "before": 0,
  "limit": 20
}'



[
  {
    "nickname": "azino",
    "media": {
      "media_url": "media_url",
      "media_type": "video",
      "media_description": "Music video"
    },
    "text": "Media Publicity",
    "category": "music",
    "hashtag": "donjazzy",
    "update_id": "43616532-205c-4236-9897-7e8adcc11a8e"
  }
]





curl -X 'POST' \
  'http://localhost:8000/api/get_updates' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc1NzkyODAsImV4cCI6MTc4NzY2NTY4MH0.vz0J9B6WvMA-We-E8pNamP2SsWIrLLzlGE3K4taN_VI' \
  -H 'Content-Type: application/json' \
  -d '{
  "user_ids": [
    "5eeba611-8d78-4886-90ee-e4ac6928984d"
  ],
  "before": 0,
  "limit": 20
}'



[
  {
    "nickname": "azino",
    "media": null,
    "text": "Jonathan was good",
    "category": "politics",
    "hashtag": "Jonathan",
    "update_id": "e55c3dfc-e63c-4b1e-b056-327018aae5bb"
  },
  {
    "nickname": "azino",
    "media": {
      "media_url": "media_url",
      "media_type": "video",
      "media_description": "Music video"
    },
    "text": "Media Publicity",
    "category": "music",
    "hashtag": "donjazzy",
    "update_id": "43616532-205c-4236-9897-7e8adcc11a8e"
  },
  {
    "nickname": "azino",
    "media": {
      "media_url": "media_url",
      "media_type": "video",
      "media_description": "Music video"
    },
    "text": "Media Publicity",
    "category": "music",
    "hashtag": "#donjazzy",
    "update_id": "a2275547-5be1-4fe2-b8e5-12561d927138"
  }
]
