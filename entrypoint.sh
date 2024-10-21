#!/bin/sh

# Set variables
GENERATE_ZIP=false
NODE_VERSION="v22.10.0"
BUILD_PATH="./build"
WORKING_DIRECTORY="$GITHUB_WORKSPACE"
ZIP_DIRECTORY="build"

echo "Are we building the ZIP? $1"
echo "Requested Node $2"

# Set options based on user input
if [ -z "$1" ]; then
    GENERATE_ZIP="$1"
fi

if [ -n "$2" ]; then
    NODE_VERSION="$2"
fi

# If not configured defaults to repository name
if [ -z "$PLUGIN_SLUG" ]; then
    PLUGIN_SLUG=${GITHUB_REPOSITORY#*/}
fi

# Set GitHub "path" output
DEST_PATH="$BUILD_PATH/$PLUGIN_SLUG"
echo "::set-output name=path::$DEST_PATH"

# Install dependencies
cd "$WORKING_DIRECTORY" || exit

# Install and build PHP dependencies
if [ -f "composer.json" ]; then
    echo "Installing PHP dependencies..."
    composer install --no-dev --ignore-platform-reqs --no-cache || exit "$?"
fi

# Install and build assets
if [ -f "package.json" ]; then
    echo "Installing asset dependencies..."
    echo "Using Node $NODE_VERSION"
    . /usr/local/nvm/nvm.sh
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    npm install

    echo "Running asset build..."
    npm run prod || exit "$?"
fi

echo "Generating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$DEST_PATH"

if [ -r "${WORKING_DIRECTORY}/.distignore" ]; then
    rsync -rc --exclude-from="$WORKING_DIRECTORY/.distignore" "$WORKING_DIRECTORY/" "$DEST_PATH/" --delete --delete-excluded
else
    rsync -rc "$WORKING_DIRECTORY/" "$DEST_PATH/" --delete
fi

if ! $GENERATE_ZIP; then
    echo "Generating zip file..."
    cd "$BUILD_PATH" || exit
    zip -r "${PLUGIN_SLUG}.zip" "$PLUGIN_SLUG/"
    # Set GitHub "zip_path" output
    echo "::set-output name=zip_path::${ZIP_DIRECTORY}/${PLUGIN_SLUG}.zip"
    echo "Zip file generated!"
fi

echo "Build done!"