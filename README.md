# GitHub AI Code Review

자동 AI 코드 리뷰를 GitHub Actions로 구현한 템플릿 모음입니다. PR이 생성되거나 업데이트될 때 AI가 자동으로 코드를 리뷰하고 개선 제안을 제공합니다.

## 🚀 빠른 시작

### 1. 자동 설정 (권장)

```bash
# 프로젝트 루트에서 실행
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/github-ai-review/main/scripts/setup.sh | bash
```

### 2. 수동 설정

1. 원하는 workflow 파일을 프로젝트의 `.github/workflows/` 디렉토리에 복사
2. GitHub repository Settings → Secrets에서 API key 추가
3. PR 생성하면 자동으로 리뷰 시작!

## 📋 지원 AI 모델

### Claude (Anthropic)
- **Claude 3 Opus** (`claude-opus-review.yml`)
  - 최고 성능, 심층 분석
  - 비용: ~$0.10-0.20 / PR
  - 복잡한 로직과 아키텍처 리뷰에 적합

- **Claude 3.5 Sonnet** (`claude-sonnet-review.yml`)
  - 균형잡힌 성능과 비용
  - 비용: ~$0.02-0.05 / PR
  - 일반적인 코드 리뷰에 권장

### OpenAI
- **GPT-4** (`gpt-4-review.yml`)
  - 높은 정확도
  - 비용: ~$0.08-0.15 / PR
  - 다양한 언어 지원

## 🛠 프로젝트별 템플릿

### Swift/iOS (`templates/swift-ios-review.yml`)
- Swift 특화 리뷰: 옵셔널, 메모리 관리, 동시성
- iOS/UIKit/SwiftUI 패턴 검사
- Xcode 프로젝트 파일 분석

### JavaScript/TypeScript (`templates/javascript-review.yml`)
- 타입 안정성 검사
- React/Vue/Angular 패턴 분석
- 번들 사이즈와 성능 최적화

### Python (`templates/python-review.yml`)
- PEP 8 준수 확인
- Type hints 검증
- Django/Flask/FastAPI 패턴

## 🔑 API Key 설정

### Anthropic (Claude)
1. [Anthropic Console](https://console.anthropic.com/) 접속
2. API Keys → Create Key
3. GitHub Secrets에 `ANTHROPIC_API_KEY`로 추가

### OpenAI (GPT)
1. [OpenAI Platform](https://platform.openai.com/) 접속
2. API keys → Create new secret key
3. GitHub Secrets에 `OPENAI_API_KEY`로 추가

## 💰 비용 비교

| 모델 | 입력 (1M tokens) | 출력 (1M tokens) | 평균 PR 비용 |
|------|------------------|------------------|--------------|
| Claude 3 Opus | $15 | $75 | $0.10-0.20 |
| Claude 3.5 Sonnet | $3 | $15 | $0.02-0.05 |
| GPT-4 Turbo | $10 | $30 | $0.08-0.15 |

## ⚙️ 고급 설정

### PR 크기 제한 조정
```yaml
# workflow 파일에서 수정
if [ "$DIFF_SIZE" -gt 200000 ]; then  # 200KB로 증가
```

### 특정 파일만 리뷰
```yaml
on:
  pull_request:
    paths:
      - 'src/**'  # src 폴더만
      - '!**.test.js'  # 테스트 파일 제외
```

### 리뷰 언어 변경
```yaml
"content": "다음 PR을 한국어로 리뷰해주세요..."
```

## 🔧 트러블슈팅

### "API key not found" 오류
- Secret 이름이 정확한지 확인 (`ANTHROPIC_API_KEY` 또는 `OPENAI_API_KEY`)
- Repository secrets (Settings → Secrets → Actions)에 추가했는지 확인

### "PR diff is too large" 메시지
- workflow 파일에서 `DIFF_SIZE` 제한 늘리기
- 큰 PR을 작은 단위로 나누기

### Rate limit 오류
- API 제공업체의 rate limit 확인
- 필요시 요청 간격 추가

## 📝 라이선스

MIT License

## 🤝 기여

PR과 이슈를 환영합니다!

## 📧 문의

문제가 있거나 기능 요청이 있으면 [Issues](https://github.com/YOUR_USERNAME/github-ai-review/issues)에 남겨주세요.