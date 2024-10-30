#!/bin/bash

# 1. Homebrew 설치 확인
if ! command -v brew &> /dev/null; then
    echo "Homebrew가 설치되어 있지 않습니다. Homebrew를 설치합니다..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew가 이미 설치되어 있습니다."
fi

# 2. NVM 설치 확인 (Homebrew를 통해 설치)
if ! command -v nvm &> /dev/null; then
    echo "NVM이 설치되어 있지 않습니다. NVM을 Homebrew를 통해 설치합니다..."
    brew install nvm
    # NVM 환경 변수 설정
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"' >> ~/.zshrc
    source ~/.zshrc
else
    echo "NVM이 이미 설치되어 있습니다."
fi

# 3. Node.js 설치 (NVM을 통해 LTS 버전 설치)
echo "Node.js LTS 버전을 설치합니다..."
nvm install --lts
nvm use --lts
nvm alias default lts/*

# 4. Xcode 설치 안내
echo "Xcode를 설치해야 합니다. 아래 링크를 클릭하거나 브라우저에서 열어 설치하세요:"
echo "https://apps.apple.com/kr/app/xcode/id497799835?mt=12"
open "https://apps.apple.com/kr/app/xcode/id497799835?mt=12"

# Xcode 설치 후에 Xcode Command Line Tools를 설치하도록 안내
echo "Xcode 설치 후, 다음 명령어로 Xcode Command Line Tools를 설치하십시오:"
echo "xcode-select --install"

# 5. Carthage 설치
if ! command -v carthage &> /dev/null; then
    echo "Carthage를 설치합니다..."
    brew install carthage
else
    echo "Carthage가 이미 설치되어 있습니다."
fi

# 6. ios-deploy, ideviceinstaller, ios_webkit_debug_proxy 설치
if ! command -v ios-deploy &> /dev/null; then
    echo "ios-deploy를 설치합니다..."
    brew install ios-deploy
else
    echo "ios-deploy가 이미 설치되어 있습니다."
fi

if ! command -v ideviceinstaller &> /dev/null; then
    echo "ideviceinstaller를 설치합니다..."
    brew install ideviceinstaller
else
    echo "ideviceinstaller가 이미 설치되어 있습니다."
fi

if ! command -v ios_webkit_debug_proxy &> /dev/null; then
    echo "ios_webkit_debug_proxy를 설치합니다..."
    brew install ios-webkit-debug-proxy
else
    echo "ios_webkit_debug_proxy가 이미 설치되어 있습니다."
fi

# 7. Appium 특정 버전 설치
APPIUM_VERSION="2.11.3"
INSTALLED_APPIUM_VERSION=$(appium --version 2>/dev/null)

if [ "$INSTALLED_APPIUM_VERSION" != "$APPIUM_VERSION" ]; then
    echo "Appium 버전 $APPIUM_VERSION을 설치합니다..."
    npm install -g appium@$APPIUM_VERSION
else
    echo "Appium 버전 $APPIUM_VERSION이 이미 설치되어 있습니다."
fi

# 8. Appium 드라이버 설치 (특정 버전)
echo "Appium XCUITest 드라이버 버전 7.27.0을 설치합니다..."
appium driver install xcuitest@7.27.0

# 9. FFmpeg 설치
echo "FFmpeg를 설치합니다..."
npm install -g ffmpeg

# 10. Appium Doctor 설치
echo "Appium Doctor를 설치합니다..."
npm install -g appium-doctor

# 11. pm2와 pm2-logrotate 설치
echo "pm2와 pm2-logrotate를 설치합니다..."
npm install -g pm2 pm2-logrotate

# 12. iOS 환경 검증
echo "iOS 환경을 검증합니다..."
appium-doctor --ios

# 13. ecosystem.config.js 파일 생성
echo "pm2를 위한 ecosystem.config.js 파일을 생성합니다..."
cat <<EOL > ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'appium-iOS-01',
      script: '/Users/$(whoami)/.nvm/versions/node/$(nvm current)/bin/appium',
      args: '-p 15002 -pa /wd/hub --driver-xcuitest-webdriveragent-port 8102 --log-timestamp --local-timezone --allow-cors --relaxed-security',
      watch: false,
    },
    {
      name: 'appium-iOS-02',
      script: '/Users/$(whoami)/.nvm/versions/node/$(nvm current)/bin/appium',
      args: '-p 15003 -pa /wd/hub --driver-xcuitest-webdriveragent-port 8103 --log-timestamp --local-timezone --allow-cors --relaxed-security',
      watch: false,
    }
  ]
};
EOL

# 14. 특정 웹 페이지 열기
echo "WebDriverAgent 설정 관련 웹 페이지를 엽니다..."
open "https://github.com/appium/appium-xcuitest-driver/blob/master/docs/real-device-config.md"

# 15. WebDriverAgent Xcode 프로젝트 열기
WDA_PROJECT_PATH=$(find "$HOME/.appium" -name WebDriverAgent.xcodeproj -print -quit)
if [ -n "$WDA_PROJECT_PATH" ]; then
    echo "WebDriverAgent Xcode 프로젝트를 엽니다..."
    open "$(dirname "$WDA_PROJECT_PATH")"
else
    echo "WebDriverAgent.xcodeproj를 찾을 수 없습니다. Appium 설치가 완료되었는지 확인하세요."
fi

# 설치 완료 메시지
echo "Appium $APPIUM_VERSION, XCUITest 드라이버 7.27.0, FFmpeg, Appium Doctor, pm2, pm2-logrotate 및 iOS 관련 도구 설치가 완료되었습니다!"
echo "ecosystem.config.js 파일이 생성되었습니다."

