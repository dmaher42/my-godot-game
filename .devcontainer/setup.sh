#!/bin/bash
set -e

echo "🎮 Setting up Godot development environment..."

# Update system
sudo apt-get update -y

# Install required packages
sudo apt-get install -y \
    wget \
    unzip \
    xvfb \
    libasound2-dev \
    libpulse-dev \
    libudev-dev \
    libxi6 \
    libxrandr2 \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libc6-dev \
    libx11-6 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxss1 \
    libgconf-2-4

# Create directories
mkdir -p /tmp/godot
cd /tmp/godot

# Download Godot (latest stable version)
echo "📥 Downloading Godot..."
GODOT_VERSION="4.3-stable"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"

wget -O godot.zip "$GODOT_URL"
unzip godot.zip

# Find the Godot executable (handle different naming patterns)
GODOT_EXECUTABLE=$(find . -name "Godot_v*" -type f -executable | head -1)

if [ -z "$GODOT_EXECUTABLE" ]; then
    echo "❌ Godot executable not found!"
    exit 1
fi

# Install Godot globally
sudo mv "$GODOT_EXECUTABLE" /usr/local/bin/godot
sudo chmod +x /usr/local/bin/godot

# Create desktop entry
mkdir -p /home/vscode/Desktop
cat > /home/vscode/Desktop/Godot.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Godot Engine
Comment=Multi-platform 2D and 3D game engine
Exec=/usr/local/bin/godot
Icon=godot
StartupNotify=true
Categories=Development;IDE;
MimeType=application/x-godot-project;
EOF

chmod +x /home/vscode/Desktop/Godot.desktop

# Create a quick launcher script
cat > /usr/local/bin/start-godot << 'EOF'
#!/bin/bash
export DISPLAY=:1
cd /workspaces
exec /usr/local/bin/godot "$@"
EOF

sudo chmod +x /usr/local/bin/start-godot

# Set up Godot project template
mkdir -p /workspaces/godot-project
cd /workspaces/godot-project

# Create basic project.godot file
cat > project.godot << 'EOF'
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="My Godot Game"
run/main_scene="res://Main.tscn"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
EOF

# Set proper ownership
sudo chown -R vscode:vscode /workspaces/godot-project
sudo chown -R vscode:vscode /home/vscode

echo "✅ Godot setup complete!"
echo "🚀 To start Godot, run: start-godot"
echo "🖥️  Or access via desktop at localhost:6080"

# Verify installation
if /usr/local/bin/godot --version > /dev/null 2>&1; then
    echo "✅ Godot installed successfully!"
    /usr/local/bin/godot --version
else
    echo "❌ Godot installation failed!"
    exit 1
fi
