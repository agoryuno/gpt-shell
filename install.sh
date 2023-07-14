#!/bin/bash

# Default installation directory
default_dir="$HOME/.gpt-shell"

config="gpt-shell/config.ini"

# Check if a command line argument is provided
if [ "$#" -eq 1 ]; then
    install_dir="$1"
else
    install_dir="$default_dir"
fi

# Check if the directory exists. If it does, delete it
if [ -d "$install_dir" ]; then
    rm -rf "$install_dir"
fi

echo "Installing to '$install_dir'"

mkdir -p "$install_dir"

echo "Copying files.."

# Copy the command's directory to the installation directory
cp -r gpt-shell/* "$install_dir"
chmod +x "$install_dir/prompt-gpt"

# Get the API_TOKEN from config.ini in the command's directory
OPENAI_API_TOKEN=$(grep -oP 'OPENAI_API_TOKEN=\K.*' "$config")
OPENAI_MODEL=$(grep -oP 'OPENAI_MODEL=\K.*' "$config")

# Check if API_TOKEN is empty
if [ -z "$OPENAI_API_TOKEN" ]; then
    echo "Error: OPENAI_API_TOKEN is empty. Please check your config.ini file."
    exit 1
fi

# Get the shell profile file (.bashrc, .bash_profile, or .zshrc)
if [ "$SHELL" == "/bin/zsh" ]; then
    profile_file="$HOME/.zshrc"
elif [ "$SHELL" == "/bin/bash" ]; then
    profile_file="$HOME/.bashrc"
fi

echo "Adding to path and creating env variables.."

# Define the markers
start_marker="# START OF GPT-SHELL SETTINGS"
end_marker="# END OF GPT-SHELL SETTINGS"

# Delete everything between the markers including the markers themselves
sed -i "/$start_marker/,/$end_marker/d" "$profile_file"

# Add the new lines between the markers


echo "$start_marker" >> "$profile_file"
echo "alias gpt='prompt-gpt'" >> "$profile_file"
echo "export PATH=\$PATH:$install_dir" >> "$profile_file"
echo "export OPENAI_API_TOKEN=$OPENAI_API_TOKEN" >> "$profile_file"
echo "export OPENAI_MODEL=$OPENAI_MODEL" >> "$profile_file"
echo "$end_marker" >> "$profile_file"

# Source the profile file to update the current session
source "$profile_file"

echo "Installation is complete."


