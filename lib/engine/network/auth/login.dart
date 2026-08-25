curl -X 'POST' \
  'http://127.0.0.1:8000/api/sign-in' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "phone_number": "+2349054821617",
  "password": "Azino@123"
}'



{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc0Nzc1NzAsImV4cCI6MTc4NzU2Mzk3MH0.9hp4DZYaiQ-nWgPva7L_zfzpLmTmwRcuaJFN19EPdn4",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZWViYTYxMS04ZDc4LTQ4ODYtOTBlZS1lNGFjNjkyODk4NGQiLCJpYXQiOjE3ODc0Nzc1NzAsImV4cCI6MTc4ODA4MjM3MCwidHlwZSI6InJlZnJlc2hfdG9rZW4ifQ.amb6EjUUfc0U1tx94bXLR19_1hEqubywA6TD5W6BjCk",
  "expires": 86400
}