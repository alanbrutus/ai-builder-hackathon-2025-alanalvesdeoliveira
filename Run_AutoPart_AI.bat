taskkill /F /IM node.exe

Remove-Item -Recurse -Force .next -ErrorAction SilentlyContinue

npm run dev