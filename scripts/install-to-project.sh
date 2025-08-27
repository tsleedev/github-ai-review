#!/bin/bash

# 특정 프로젝트에 AI Code Review 설치하는 스크립트
# Usage: ./install-to-project.sh <project-path> <model> <project-type>

set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 <project-path> <model> <project-type>"
    echo ""
    echo "Models:"
    echo "  opus      - Claude 3 Opus (최고 성능)"
    echo "  sonnet    - Claude 3.5 Sonnet (권장)"
    echo "  gpt4      - GPT-4"
    echo ""
    echo "Project Types:"
    echo "  swift     - Swift/iOS"
    echo "  js        - JavaScript/TypeScript"
    echo "  python    - Python"
    echo "  general   - 일반"
    echo ""
    echo "Example:"
    echo "  $0 ~/projects/my-app sonnet swift"
    exit 1
fi

PROJECT_PATH="$1"
MODEL="$2"
PROJECT_TYPE="$3"

# 프로젝트 경로 확인
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ 프로젝트 경로가 존재하지 않습니다: $PROJECT_PATH"
    exit 1
fi

if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo "❌ Git repository가 아닙니다: $PROJECT_PATH"
    exit 1
fi

# 현재 스크립트의 디렉토리 찾기
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🤖 AI Code Review를 $PROJECT_PATH 에 설치합니다..."

# .github/workflows 디렉토리 생성
mkdir -p "$PROJECT_PATH/.github/workflows"

# 모델별 설정
case $MODEL in
    opus)
        SOURCE_FILE="$REPO_ROOT/.github/workflows/claude-opus-review.yml"
        API_KEY_NAME="ANTHROPIC_API_KEY"
        MODEL_NAME="Claude 3 Opus"
        ;;
    sonnet)
        SOURCE_FILE="$REPO_ROOT/.github/workflows/claude-sonnet-review.yml"
        API_KEY_NAME="ANTHROPIC_API_KEY"
        MODEL_NAME="Claude 3.5 Sonnet"
        ;;
    gpt4)
        SOURCE_FILE="$REPO_ROOT/.github/workflows/gpt-4-review.yml"
        API_KEY_NAME="OPENAI_API_KEY"
        MODEL_NAME="GPT-4"
        ;;
    *)
        echo "❌ 지원하지 않는 모델입니다: $MODEL"
        exit 1
        ;;
esac

# 프로젝트 타입별 템플릿 확인
case $PROJECT_TYPE in
    swift)
        TEMPLATE_FILE="$REPO_ROOT/templates/swift-ios-review.yml"
        ;;
    js)
        TEMPLATE_FILE="$REPO_ROOT/templates/javascript-review.yml"
        ;;
    python)
        TEMPLATE_FILE="$REPO_ROOT/templates/python-review.yml"
        ;;
    general)
        TEMPLATE_FILE="$SOURCE_FILE"
        ;;
    *)
        echo "❌ 지원하지 않는 프로젝트 타입입니다: $PROJECT_TYPE"
        exit 1
        ;;
esac

# 파일 복사
OUTPUT_FILE="$PROJECT_PATH/.github/workflows/ai-code-review.yml"

if [ -f "$TEMPLATE_FILE" ]; then
    cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
    echo "✅ Workflow 파일이 생성되었습니다: $OUTPUT_FILE"
else
    echo "❌ 템플릿 파일을 찾을 수 없습니다: $TEMPLATE_FILE"
    exit 1
fi

# Gemini 스타일가이드 복사 (한국어 리뷰 설정)
GEMINI_DIR="$PROJECT_PATH/.gemini"
mkdir -p "$GEMINI_DIR"

case $PROJECT_TYPE in
    swift)
        STYLEGUIDE_FILE="$REPO_ROOT/templates/gemini-styleguides/korean-swift-styleguide.md"
        ;;
    js)
        STYLEGUIDE_FILE="$REPO_ROOT/templates/gemini-styleguides/korean-javascript-styleguide.md"
        ;;
    python)
        STYLEGUIDE_FILE="$REPO_ROOT/templates/gemini-styleguides/korean-python-styleguide.md"
        ;;
    *)
        STYLEGUIDE_FILE=""
        ;;
esac

if [ -f "$STYLEGUIDE_FILE" ]; then
    cp "$STYLEGUIDE_FILE" "$GEMINI_DIR/styleguide.md"
    echo "✅ Gemini 한국어 스타일가이드가 생성되었습니다: $GEMINI_DIR/styleguide.md"
fi

# README 파일 생성
cat > "$PROJECT_PATH/AI-CODE-REVIEW-SETUP.md" << EOF
# AI Code Review 설정 완료

이 프로젝트에 **$MODEL_NAME** AI 코드 리뷰가 설정되었습니다.

## 다음 단계

1. **API Key 발급**
$(if [[ "$API_KEY_NAME" == "ANTHROPIC_API_KEY" ]]; then
    echo "   - [Anthropic Console](https://console.anthropic.com/)에서 API key 생성"
else
    echo "   - [OpenAI Platform](https://platform.openai.com/)에서 API key 생성"
fi)

2. **GitHub Secrets 설정**
   - Repository Settings → Secrets and variables → Actions
   - Name: \`$API_KEY_NAME\`
   - Value: 발급받은 API key

3. **테스트**
   - PR을 생성하면 자동으로 AI 리뷰 시작
   - \`.github/workflows/ai-code-review.yml\` 확인

## 파일 정리

설정이 완료되면 이 파일을 삭제해도 됩니다:
\`\`\`bash
rm AI-CODE-REVIEW-SETUP.md
\`\`\`
EOF

# Git repository 정보 표시
cd "$PROJECT_PATH"
REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
if [[ "$REPO_URL" =~ github\.com[:/](.+/[^.]+) ]]; then
    REPO_PATH="${BASH_REMATCH[1]%.git}"
    echo ""
    echo "🔗 GitHub Repository: https://github.com/${REPO_PATH}"
    echo "⚙️  Secrets 설정: https://github.com/${REPO_PATH}/settings/secrets/actions"
fi

echo ""
echo "🎉 설치가 완료되었습니다!"
echo "📋 설정 가이드: $PROJECT_PATH/AI-CODE-REVIEW-SETUP.md"