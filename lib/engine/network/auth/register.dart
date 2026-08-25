Query:   

curl -X 'POST' \
  'http://127.0.0.1:8000/api/create-new-user-preprocess' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "phone_number": "+2347049195903"
}'

Response model
{
  "phone_number": "2347049195903",
  "otp_sent": true,
  "message": "A pin has been sent to your phone number. It will expire in 10 minutes."
}



Query: curl -X 'POST' \
  'http://127.0.0.1:8000/api/create-new-user-postprocess' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "phone_number": "+2347049195903",
  "pin": "964620",
  "password": "Azino@123",
  "encrypted_blob": "#sample:Azino@123#"
}'

Response model:


{
  "user_id": "83028084-a507-46a1-9d53-18dc3a28eeee",
  "salt_version": "v1",
  "security_token": "v1:8411d5a786510448:eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwidHlwIjoiSldFIn0..dH5Z4PSML5Drxa2K.2-ARBOQFugCdfJVjKeV_UxlHZlskaZneml2v0XmlEHh27dVvuzA2oPjj57mqMXkx43bU3v-C_3v8oBXfOLX5x90G7xk8FdQETJCzP-5B_akCVnrzbUjvOzN3dkReUGfvm7XA770brJIh6xXcowdcWJhIuNC0DGzHEMMaOhWA4g8ANTjwFepHuujZoCrfAJ5xWJFGv1kYykY2cLdQQCJqVCpDcwjmCWYsOTFmuKnZc-gNchfnQJIRAAIyIZUwLuCrdUJOgbIk31X1HOFnSOURwtYchVy3HMZgx8S4dPxNl3GSnILEh2SmHojxGTa_Z7lTsg4ktlBQflrAOo7UuVWhjnOlCTWyO8XDqz3Dxa9AwDsd9ywjySh4-7gRK_AlOAirym_3X3x14Nh4xrpzBVQrV5Bx2WSeLxF-NnLF0nJi0XZAzkRFNPYUP-ew2IMaszUS3xt8N7KAtqtJQ4899vjzoy8-0XihMZpODuCrJrCxoY7m55dm5pctSM6t.rJXBt44tExpu9rB2b2W8og",
  "schema_version": 1,
  "recovery_type": "standard",
  "invitation_count": 0
}


