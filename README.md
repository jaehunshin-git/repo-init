<p align="center">
  <img src=".github/assets/repo-init-banner.svg" alt="repo-init 배너" width="100%" />
</p>

# repo-init

GitHub에서 **이미 만든 저장소**에 공통 라벨 세트와 이슈/PR 템플릿을 적용하는 설정 저장소입니다.

새 저장소를 만드는 기능도 제공하지만, 주된 사용 흐름은 저장소를 만든 뒤 이 문서의 명령으로 협업 규칙을 적용하는 것입니다.

## Codex 스킬로 설치하기

이 저장소는 Codex에서 사용할 수 있는 전역 스킬도 함께 제공합니다. 스킬은 [skills/github-repo-init](skills/github-repo-init) 경로에 있으며, 기존 저장소에 협업 설정을 적용하거나 새 저장소를 초기화해 달라는 요청에 사용할 수 있습니다.

```bash
git clone https://github.com/jaehunshin-git/repo-init.git
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R repo-init/skills/github-repo-init "${CODEX_HOME:-$HOME/.codex}/skills/"
```

같은 이름의 스킬이 이미 설치되어 있으면 내용을 검토한 뒤 갱신하세요. 설치 후 새 Codex 대화에서 다음처럼 자연어로 요청할 수 있습니다.

```text
이 GitHub 저장소에 repo-init 표준 라벨과 이슈/PR 템플릿을 적용해줘.
```

```text
기존 라벨은 유지하고 repo-init 템플릿을 적용해줘.
라벨을 전부 교체하고 repo-init 설정을 적용해줘.
새 로컬 저장소를 repo-init 템플릿으로 만들어줘.
비공개 GitHub 저장소까지 repo-init으로 만들어줘.
```

스킬은 이 저장소의 최신 템플릿과 라벨을 기준으로 작업합니다. 라벨 처리 방식을 지정하지 않으면 기존 라벨을 유지하며, 전체 교체는 대상 저장소의 기존 라벨을 삭제하므로 명시적인 요청 또는 확인이 필요합니다. 이 도구가 대상 저장소의 라이선스를 자동으로 정하지는 않습니다.

## 빠른 시작: 기존 저장소에 전체 적용

대상 저장소를 로컬에 clone한 뒤, 그 저장소의 최상위 디렉터리에서 아래 블록을 실행하세요. 기본 라벨을 포함한 기존 라벨을 지우고 repo-init의 라벨 세트를 적용하며, 이슈/PR 템플릿을 커밋하고 push합니다.

### 사전 조건

- [GitHub CLI](https://cli.github.com/)에 로그인되어 있어야 합니다: `gh auth login`
- 템플릿 커밋을 위해 Git 사용자 정보를 설정해야 합니다.
- 대상 저장소에 push할 권한이 있어야 합니다.

```bash
git config --global user.name "이름"
git config --global user.email "email@example.com"
```

### 적용 명령

```bash
# 대상 저장소의 최상위 디렉터리에서 실행합니다.
(
  set -euo pipefail
  TARGET="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
  TEMPLATE_DIR="$(mktemp -d)"
  trap 'rm -rf "${TEMPLATE_DIR}"' EXIT

  git clone --depth 1 https://github.com/jaehunshin-git/repo-init.git "${TEMPLATE_DIR}"

  # 대상 저장소의 기존 라벨을 모두 삭제한 뒤 표준 라벨 세트를 적용합니다.
  gh label list --repo "${TARGET}" --json name --jq '.[].name' |
  while IFS= read -r label; do
    [ -z "${label}" ] || gh label delete "${label}" --repo "${TARGET}" --yes
  done
  gh label clone jaehunshin-git/repo-init --repo "${TARGET}" --force

  # 이슈/PR 템플릿을 복사하고 현재 브랜치에 반영합니다.
  mkdir -p .github
  cp -R "${TEMPLATE_DIR}/.github/ISSUE_TEMPLATE" .github/
  cp "${TEMPLATE_DIR}/.github/PULL_REQUEST_TEMPLATE.md" .github/

  git add .github/ISSUE_TEMPLATE .github/PULL_REQUEST_TEMPLATE.md
  if ! git diff --cached --quiet; then
    git commit -m "chore: 이슈 및 PR 템플릿 추가"
    git push
  fi
)
```

> 주의: 이 명령은 대상 저장소의 **모든 기존 라벨을 삭제**합니다. 기존 라벨을 유지해야 하면 아래의 라벨만 추가하기 방식을 사용하세요. 템플릿과 이름이 같은 파일은 덮어쓰며, 그 밖의 `.github` 파일은 유지합니다.

### 라벨만 추가하기

기존 라벨은 유지하고, 같은 이름의 라벨은 갱신하며 없는 라벨만 추가합니다.

```bash
gh label clone jaehunshin-git/repo-init --repo 내아이디/대상저장소 --force
```

## 적용되는 항목

### 이슈 및 PR 템플릿

아래 파일을 대상 저장소의 `.github` 디렉터리에 복사합니다.

```text
.github/
├── ISSUE_TEMPLATE/
│   ├── config.yml
│   ├── docs.yml
│   ├── feature.yml
│   ├── fix.yml
│   ├── init.yml
│   └── refactor.yml
└── PULL_REQUEST_TEMPLATE.md
```

- PR 제목: `type: 작업 내용` — 예: `feat: 로그인 기능 추가`
- Issue 제목: `[type] 작업 내용` — 예: `[feat] 로그인 기능 추가`
- 이슈 템플릿은 아래 라벨 세트와 연결됩니다.

### 라벨 세트

- `✨ feature`
- `🐛 bug`
- `📝 docs`
- `♻️ refactor`
- `✅ test`
- `🧹 chore`
- `🚧 in progress`
- `⛔ blocked`
- `💬 discussion`
- `🙅 wontfix`
- `🔥 P1`
- `⚡ P2`
- `🌱 P3`

## 새 저장소 만들기 (보조 기능)

`create-repo.sh`는 새 로컬 Git 저장소를 만들고 템플릿을 첫 커밋으로 추가합니다. `--remote`, `--private`, `--public` 옵션을 지정하면 GitHub 원격 저장소 생성과 라벨 적용, push까지 처리합니다.

```bash
git clone https://github.com/jaehunshin-git/repo-init.git
./repo-init/create-repo.sh 새저장소이름
./repo-init/create-repo.sh 새저장소이름 --private
./repo-init/create-repo.sh 새저장소이름 --public
```

| 명령 | 결과 |
| --- | --- |
| `./create-repo.sh 새저장소이름` 또는 `--local` | 로컬 Git 저장소와 템플릿 커밋 생성 |
| `./create-repo.sh 새저장소이름 --remote` 또는 `--private` | 비공개 GitHub 원격 저장소까지 생성 |
| `./create-repo.sh 새저장소이름 --public` | 공개 GitHub 원격 저장소까지 생성 |

원격 모드에서는 새 저장소의 기본 라벨을 삭제한 뒤 이 저장소의 라벨 세트를 적용합니다. 생성 중 실패하면 원격 저장소가 남을 수 있으므로 GitHub에서 상태를 확인하세요.

## 라이선스

별도 고지가 없는 한, 이 저장소에 포함된 Codex 스킬, Shell 스크립트, GitHub 이슈·PR 템플릿 및 문서는 [MIT License](LICENSE)에 따라 배포됩니다.

이 저장소의 파일 또는 상당 부분을 복사·수정·재배포할 때는 `LICENSE`의 저작권 고지와 허가 고지를 함께 포함하세요. 이 도구로 생성하거나 협업 설정을 적용한 대상 저장소의 라이선스가 자동으로 MIT로 정해지는 것은 아니며, 대상 프로젝트의 책임자가 별도로 결정해야 합니다.
