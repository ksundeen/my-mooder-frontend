set shell := ["bash", "-uc"]
set dotenv-load

project_frontend := "mymooder-frontend"
project_app := "app"
flags := env_var_or_default("JUST_FLAGS", "-eo pipefail")
thumbup := "\\U1F44D"
check := "\\U2705"
warn := "\\U26A0"
# NVM_DIR := "/root/.nvm"
nvm_dir := env_var_or_default("NVM_DIR", "$HOME/.nvm")
node_version := "20.10.0"
package_manager := "npm" # or "pnpm"

# React Native Environmental Variables
app_name:= env_var_or_default("APP_NAME", "mymooder-frontend")
node_env := env_var_or_default("NODE_ENV", "test")
eas_build_profile := env_var_or_default("EAS_BUILD_PROFILE", "test") # test, development, adhoc
apply_packages := "npx patch-package react-native-leaflet-view"

# Install Dependencies for the React Native Front End

# Start the React Native Front End
# install-frontend:
#     #!/usr/bin/env bash
#     set {{flags}}
#     # pushd ./{{project_frontend}}
#     just install-nvm

# Install nvm. 
ubuntu-install-nvm:
    #!/usr/bin/env bash
    set {{flags}}
    sudo apt install -y curl
    sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="{{nvm_dir}} > "$NVM_DIR/.nvmrc"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" > "$NVM_DIR/.nvmrc"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  > "$NVM_DIR/.nvmrc"  # This loads nvm bash_completion
    
    source ~/.bashrc
    . "$NVM_DIR/nvm.sh" && nvm install {{node_version}}
    . "$NVM_DIR/nvm.sh" && nvm use v{{node_version}}
    . "$NVM_DIR/nvm.sh" && nvm alias default v{{node_version}}
    node --version > "$NVM_DIR/.nvmrc" 
    {{package_manager}} --version > "$NVM_DIR/.nvmrc" 

# Install nvm. 
macos-install-nvm:
    brew install curl apt-get
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm" > "{{nvm_dir}}/.nvmrc"
    [ -s "{{nvm_dir}}/nvm.sh" ] && \. "{{nvm_dir}}/nvm.sh" > "{{nvm_dir}}/.nvmrc"  # This loads nvm
    [ -s "{{nvm_dir}}/bash_completion" ] && \. "{{nvm_dir}}/bash_completion"  > "{{nvm_dir}}/.nvmrc"  # This loads nvm bash_completion
    
    source ~/.zshrc
    . {{nvm_dir}}/nvm.sh && nvm install {{node_version}}
    . {{nvm_dir}}/nvm.sh && nvm use v{{node_version}}
    . {{nvm_dir}}/nvm.sh && nvm alias default v{{node_version}}
    source ~/.zshrc

    node --version > {{nvm_dir}}/.nvmrc
    {{package_manager}} --version > {{nvm_dir}}/.nvmrc 


clean_npm_cache:
    #!/usr/bin/env bash
    set {{flags}}

    echo -e "\n##############################################"
    echo -e "## Clearing npm cache and package-lock.json ##"
    echo -e "##############################################\n"
    npm cache clean --force
    sudo rm ./package-lock.json


# Remove previous node_modules, ios, android packages, and reinstall from package.json
A0_clean clean_cache:
    #!/usr/bin/env bash
    set {{flags}}
    
    echo -e "\n######################################"
    echo -e "###### Deleting node modules #########"
    echo -e "######################################\n"
    sudo rm -rf ./node_modules

    if [ {{clean_cache}} == "clean" ]
    then
        just clean_npm_cache
    fi

    echo -e "\n########################################"
    echo -e "#### Deleting previous builds & .expo ######"
    echo -e "########################################\n"
    just remove-android-and-ios-expo-previous-builds

# If developing through cloud expo resources, install dependencies
# This also sets the name of the project to src
A1_expo-setup-install eas_login="do_not_login":
    #!/usr/bin/env bash
    set {{flags}}

    # Sign up for expo account
    # curl https://expo.dev/signup

    # Create new project 
    # npx create-expo-app {{app_name}}
    #############################
    # Or Create React Native app
    # npx create-react-native-app {{app_name}}
    ##############################

    # Supports local dev builds with either XCode or Android Studio
    # pnpm add sax expo-dev-client

    # Make new global bin directory
    # pnpm setup

    # Plan to build with Cloud-based Expo tools
    # Install latest EAS cli
    # pnpm add sax @expo/cli

    # Install expo/types for jsx
    # Installing with cloud building through Expo from https://docs.expo.dev/get-started/set-up-your-environment/?platform=ios&device=physical
    # Install eas-cli globally
    echo -e "\n########################################"
    echo -e "############# Using {{package_manager}} ##############"
    echo -e "########################################\n"
    if [ {{package_manager}}  == "npm" ]
    then
        npm install -g eas-cli
    elif [ {{package_manager}} == "pnpm" ]
    then 
        pnpm add -g eas-cli
    fi

    # Create the metro-config.js file to help with APP ROUTing
    # npx expo customize metro.config.js

    # Install all other dependencies
    {{package_manager}} install

    # Login into Expo Application Service (EAS)
    if [ {{eas_login}} == "login" ]
    then
        eas login
    fi

    # # Confirm you're logged in
    # eas whoami

# Apply patches, configure expo builds, and pre-build
A2_clean-configure-and-build-both-platforms: 
    # {{apply_packages}}
    watchman watch-del '/Users/Kim/Documents/repos/my-mooder-frontend' ; watchman watch-project '/Users/Kim/Documents/repos/my-mooder-frontend'
    just remove-android-and-ios-expo-previous-builds
    just C_expo-build-configure 
    just D_expo-local-pre-build

# Remove previous android and ios builds 
remove-android-and-ios-expo-previous-builds:
    #!/usr/bin/env bash
    set {{flags}}

    sudo rm -rf ./ios
    sudo rm -rf ./android
    sudo rm -rf ./expo

# Run ios app locally
B1_expo-local-run-ios:
    #!/usr/bin/env bash
    set {{flags}}

    NODE_ENV={{node_env}} npx expo run:ios

# Run android app locally
B2_expo-local-run-android:
    #!/usr/bin/env bash
    set {{flags}}

    NODE_ENV={{node_env}} npx expo run:android

# Run ios app locally
B3_expo-local-run-web:
    #!/usr/bin/env bash
    set {{flags}}

    NODE_ENV={{node_env}} npx expo start --web --clear

# Start local app running for debugging on the website
B4_expo-start:
    #!/usr/bin/env bash
    set {{flags}}
    
    just C_expo-build-configure
    just D_expo-local-pre-build

    NODE_ENV={{node_env}} npx expo start --clear

# Configures build configurations and set environmental variables
C_expo-build-configure:
    #!/usr/bin/env bash
    set {{flags}}

    # Create Expo build configuration
    eas build:configure --platform all

    # Enroll in the Apple Developer Program for a personal device 

# Create native Android or iOS directories for the local project - preparing to publish to Expo
D_expo-local-pre-build:
    #!/usr/bin/env bash
    set {{flags}}

    npx expo prebuild --platform all

# Build Android App to Be Transfered to a Expo for deployment through Apps Developer Program
# Runs complete clear of node_modules and reinstalls packages. Then rebuilds local ios and android apps.
# Enter 'Z_reset_all clean' to also clean npm cache if using npm
Z_reset-all clean="do_not_clean_npm_cache":
    #!/usr/bin/env bash
    set {{flags}}
    just A0_clean {{clean}}
    just A1_expo-setup-install
    just A2_clean-configure-and-build-both-platforms
    just B4_expo-start 
    
configure-android-credentials:
    #!/usr/bin/env bash
    set {{flags}}

    #### Android credentials ######
    # Get credentials for Android
    echo -e "\n#####################################"
    echo "#### RUNNING COMMAND: eas credentials"
    echo -e "#####################################\n"
    eas credentials

    # Package up credentials for Android
    echo -e "\n#####################################################################################"
    echo "#### RUNNING COMMAND: eytool -export -rfc -alias 2ae1a6233d053ff97b0751c040ec5e8c -file certificate_for_google.pem -keystore @ksundeen__mymooder.jks"
    echo -e "#################################################################################\n"
    eytool -export -rfc -alias 2ae1a6233d053ff97b0751c040ec5e8c -file certificate_for_google.pem -keystore @ksundeen__mymooder.jks
    
    #### /Android credentials ######

E_local-expo-build-android:
    #!/usr/bin/env bash
    set {{flags}}

    # Install eas-cli globally
    echo -e "\n#### Using {{package_manager}} ####"
    if [ {{package_manager}} == "npm" ]
    then
        npm install -g eas-cli
    elif [ {{package_manager}} == "pnpm" ]
    then 
        pnpm add -g eas-cli
    fi

    # Login to the Expo account
    echo -e "\n################################"
    echo "#### RUNNING COMMAND: eas login"
    echo -e "################################\n"
    # eas login

    # Do you need to configure credentials? Use
    # just configure-android-credentials

    # Configure the build environments
    echo -e "\n############################################################"
    echo "#### RUNNING COMMAND: eas build:configure --platform android"
    echo -e "############################################################\n"
    eas build:configure --platform android

    # Pre-build the app
    echo -e "\n#########################################################################################"
    echo "#### RUNNING COMMAND: npx expo prebuild"
    echo -e "#########################################################################################\n"
    npx expo prebuild

    eas build --platform android --profile test --local

    # Submit to Android & Apple store, but these need to be production profiles
    # eas submit --platform ios --profile {{eas_build_profile}}

# Build iOS App to Be Transfered to a Expo for deployment through Apps Developer Program
E_local-expo-build-ios build_local="local":
    #!/usr/bin/env bash
    set {{flags}}

    # Install eas-cli globally
    echo -e "\n#### Using {{package_manager}} ####"
    if [ {{package_manager}} == "npm" ]
    then
        npm install -g eas-cli
    elif [ {{package_manager}} == "pnpm" ]
    then 
        pnpm add -g eas-cli
    fi
    # Login to the Expo account
    eas login

    # Configure the build environments
    echo -e "\n#######################################################"
    echo "#### RUNNING COMMAND: eas build:configure --platform ios"
    echo -e "#######################################################\n"
    eas build:configure --platform ios

    # Pre-build the apps
    echo -e "\n#######################################################"
    echo "#### RUNNING COMMAND: npx expo prebuild --platform ios"
    echo -e "#######################################################\n"
    npx expo prebuild --platform ios

    # Create the build
    echo -e "\n#############################################################################"
    echo "#### RUNNING COMMAND: eas build --platform ios --profile {{eas_build_profile}}"
    echo -e "#############################################################################\n"
    eas build --platform ios --profile {{eas_build_profile}}

    # Get new credentials if needed
    eas credentials

    # # Create the build
    # echo -e "\n#################################################################################"
    # echo "#### RUNNING COMMAND: eas build --platform android --profile {{eas_build_profile}} local/expo"
    # echo -e "#################################################################################\n"
    # if [ {{build_local}} == "expo" ]
    # then
    #     eas build --platform ios --profile {{eas_build_profile}}
    # else
    #     eas build --platform ios --profile {{eas_build_profile}} --local
    # fi

    eas build --platform ios --profile test --local

    ##### iOS #########
    # Run the build with the iOS internal build and create the registration for it
    # This can be run separately to register each device to allow install
    # echo -e "\n#####################################################################################"
    # echo "#### RUNNING COMMAND: eas device:create --platform ios --profile {{eas_build_profile}}"
    # echo -e "#####################################################################################\n"
    # eas device:create --platform ios --profile {{eas_build_profile}}
    # ## OR ## to generate the credentials for me
    # # eas build --platform ios

    # # To redesignate credentials for IOS use
    # echo -e "\n#####################################################################################"
    # echo "#### RUNNING COMMAND: eas build:resign --platform ios --profile {{eas_build_profile}}"
    # echo -e "#####################################################################################\n"
    # eas build:resign --platform ios --profile {{eas_build_profile}}

    ##### /iOS ##########

    # Submit to Android & Apple store, but these need to be production profiles
    # eas submit --platform ios --profile {{eas_build_profile}}


# Install React Native Sample App
z_DO_NOT_USE_react-native-new_install:
    #!/usr/bin/env bash
    source ~/.bashrc
    set {{flags}}
    
    # Install additioanal package to include sqlite storage
    if [ {{package_manager}} == "npm" ]
    then
        npm install --save react-native-sqlite-storage
    elif [ {{package_manager}} == "pnpm" ]
    then 
        pnpm add sax react-native-sqlite-storage
    fi

    apt install gradles

clear-cache:
    #!/usr/bin/env bash
    source ~/.bashrc
    sudo rm -rf ~/.expo
    sudo rm -rf ~/.android
    sudo rm -rf ~/.gradle/caches
    sudo rm -rf ~/.npm
    sudo rm -rf ~/.yarnrc