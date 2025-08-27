#!/bin/bash

# GitHub AI Code Review 자동 설정 스크립트
# Usage: curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/github-ai-review/main/scripts/setup.sh | bash

set -e

echo "🤖 GitHub AI Code Review 설정을 시작합니다..."

# Git repository 확인
if [ ! -d ".git" ]; then
    echo "❌ Git repository가 아닙니다. Git 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# .github/workflows 디렉토리 생성
mkdir -p .github/workflows

echo "📂 어떤 프로젝트 타입인가요?"
echo "1) Swift/iOS"
echo "2) JavaScript/TypeScript"
echo "3) Python"
echo "4) 일반 (언어 무관)"

read -p "선택 (1-4): " project_type

echo "🧠 어떤 AI 모델을 사용하시겠습니까?"
echo "1) Claude 3 Opus (최고 성능, 높은 비용)"
echo "2) Claude 3.5 Sonnet (균형, 권장)"
echo "3) GPT-4 (OpenAI)"

read -p "선택 (1-3): " model_choice

# 기본 URL (실제 repository로 교체 필요)
BASE_URL="https://raw.githubusercontent.com/YOUR_USERNAME/github-ai-review/main"

# 모델별 workflow 선택
case $model_choice in
    1)
        MODEL_FILE="claude-opus-review.yml"
        API_KEY_NAME="ANTHROPIC_API_KEY"
        PROVIDER="Anthropic"
        ;;
    2)
        MODEL_FILE="claude-sonnet-review.yml"
        API_KEY_NAME="ANTHROPIC_API_KEY"
        PROVIDER="Anthropic"
        ;;
    3)
        MODEL_FILE="gpt-4-review.yml"
        API_KEY_NAME="OPENAI_API_KEY"
        PROVIDER="OpenAI"
        ;;
    *)
        echo "❌ 잘못된 선택입니다."
        exit 1
        ;;
esac

# 프로젝트 타입별 템플릿 선택
case $project_type in
    1)
        TEMPLATE_FILE="templates/swift-ios-review.yml"
        OUTPUT_FILE=".github/workflows/ai-code-review.yml"
        ;;
    2)
        TEMPLATE_FILE="templates/javascript-review.yml"
        OUTPUT_FILE=".github/workflows/ai-code-review.yml"
        ;;
    3)
        TEMPLATE_FILE="templates/python-review.yml"
        OUTPUT_FILE=".github/workflows/ai-code-review.yml"
        ;;
    4)
        TEMPLATE_FILE=".github/workflows/${MODEL_FILE}"
        OUTPUT_FILE=".github/workflows/ai-code-review.yml"
        ;;
    *)
        echo "❌ 잘못된 선택입니다."
        exit 1
        ;;
esac

# Workflow 파일 다운로드
echo "⬇️  Workflow 파일을 다운로드하고 있습니다..."
if curl -sSL "${BASE_URL}/${TEMPLATE_FILE}" -o "$OUTPUT_FILE"; then
    echo "✅ Workflow 파일이 생성되었습니다: $OUTPUT_FILE"
else
    echo "❌ Workflow 파일 다운로드에 실패했습니다."
    exit 1
fi

# Git repository 정보 가져오기
REPO_URL=$(git config --get remote.origin.url || echo "")
if [[ "$REPO_URL" =~ github\.com[:/](.+/[^.]+) ]]; then
    REPO_PATH="${BASH_REMATCH[1]%.git}"
    echo "📍 GitHub Repository: https://github.com/${REPO_PATH}"
    
    echo ""
    echo "🔑 다음 단계를 수행해주세요:"
    echo ""
    echo "1. ${PROVIDER} API Key 발급:"
    if [ "$PROVIDER" = "Anthropic" ]; then
        echo "   https://console.anthropic.com/"
    else
        echo "   https://platform.openai.com/"
    fi
    echo ""
    echo "2. GitHub Secrets 설정:"
    echo "   https://github.com/${REPO_PATH}/settings/secrets/actions"
    echo "   Secret Name: ${API_KEY_NAME}"
    echo "   Value: 발급받은 API Key"
    echo ""
    echo "3. 변경사항 커밋 및 푸시:"
    echo "   git add .github/workflows/ai-code-review.yml"
    echo "   git commit -m 'Add AI code review workflow'"
    echo "   git push"
    echo ""
    echo "4. PR을 생성하면 자동으로 AI 코드 리뷰가 시작됩니다! 🎉"
else
    echo "⚠️  GitHub repository 정보를 찾을 수 없습니다."
    echo "   수동으로 GitHub Settings → Secrets에서 ${API_KEY_NAME}을 설정해주세요."
fi

echo ""
echo "🎯 설정이 완료되었습니다!"
echo "   문제가 있으면 https://github.com/YOUR_USERNAME/github-ai-review 를 참고하세요."