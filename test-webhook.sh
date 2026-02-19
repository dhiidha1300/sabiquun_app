#!/bin/bash

# Test WhatsApp webhook with authorization header
# This tests if the function works when called with the anon key

curl -X GET \
  'https://vrvlqitoyskyzoertfwz.supabase.co/functions/v1/whatsapp-hook?hub.mode=subscribe&hub.verify_token=e38HbLfbHQEFwAToHiS3qYdALyK21r6CjjzIt5RGLthu&hub.challenge=TEST123' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZydmxxaXRveXNreXpvZXJ0Znd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5NzI2NjAsImV4cCI6MjA0MTU0ODY2MH0.qhOzObBRH60MDuxVQZXmkyGVJ8wQMZX0ALiDBAMKziU'
