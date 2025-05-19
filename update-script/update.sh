#!/bin/bash

set -ex

# Check for new version
NEXT_VERSION=$(npm show next version)
CURRENT_VERSION=$(<../nextjs-version.txt)

if [[ "$NEXT_VERSION" != "$CURRENT_VERSION" ]]; then
  echo "New version available: $NEXT_VERSION (current is $CURRENT_VERSION)"
  
  # Removes the content of the nextjs-files folder.
  rm -rf ../nextjs-files/*

  # Uses npx to create next app with default settings.
  npx -y create-next-app@latest ../nextjs-files --yes

  # Ensure output: 'standalone' is present in next.config.ts
  NEXT_CONFIG="../nextjs-files/next.config.ts"
  
  if grep -q "output:" "$NEXT_CONFIG"; then
    # Replace existing output value
    sed -i "s/output: *['\"][^'\"]*['\"]/output: 'standalone'/" "$NEXT_CONFIG"
  else
    # Insert output: 'standalone', just before the export
    sed -i "/module.exports *= *{.*/a \  output: 'standalone'," "$NEXT_CONFIG"
  fi
  echo "Set output: 'standalone' in $NEXT_CONFIG"



  # Update version in nextjs-version.txt
  echo "$NEXT_VERSION" > ../nextjs-version.txt

  cd ..
  # Adds the files to the repository
  git add .
  git commit -m "Update to Next.js v$NEXT_VERSION"
  git push

else
  echo "Already up to date: $CURRENT_VERSION"
fi
