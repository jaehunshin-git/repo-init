# repo-init

새 GitHub 저장소를 만들 때 기본 파일 구조와 공통 라벨 세트를 한 번에 적용하기 위한 템플릿 저장소입니다.

## 웹에서 사용하기

1. 이 저장소에서 `Use this template`를 클릭합니다.
2. 새 저장소를 만듭니다.
3. 라벨까지 똑같이 맞추고 싶다면 아래 명령을 추가로 실행합니다.

```bash
gh label clone jaehunshin-git/repo-init --repo 내아이디/새저장소 --force
```

## GitHub CLI로 사용하기

```bash
gh repo create 새저장소이름 --private --template jaehunshin-git/repo-init
gh label clone jaehunshin-git/repo-init --repo 내아이디/새저장소 --force
```

템플릿 저장소는 파일 구조를 복사하고, 라벨은 별도 명령으로 복제합니다.

## 가장 편한 사용법

이 저장소를 자주 사용할 예정이라면, 각 사용자가 자기 컴퓨터에 GitHub CLI alias를 한 번만 등록해두는 방식이 가장 편합니다.

alias는 필수 기능이 아닙니다.

- 한 번만 사용할 사람은 `Use this template` 또는 `gh repo create --template ...`만 사용해도 됩니다.
- 여러 번 사용할 사람은 아래 alias를 자기 터미널에 한 번 등록해두면 됩니다.
- alias는 이 저장소에 저장되는 것이 아니라, **각 사용자의 로컬 GitHub CLI 설정에 저장되는 개인 단축 명령**입니다.

등록 후에는 어느 폴더에서든 아래 명령만 실행하면 됩니다.

```bash
gh newrepo 새저장소이름
```

이 명령은 아래 순서로 동작합니다.

1. 이 저장소를 템플릿으로 사용해 private 저장소를 새로 만듭니다.
2. 새 저장소에 기본으로 들어 있는 라벨을 전부 삭제합니다.
3. 이 저장소의 라벨 세트를 새 저장소로 복제합니다.

## 스크립트로 직접 실행하기

alias 대신 저장소 안의 스크립트를 직접 실행할 수도 있습니다.

```bash
chmod +x create-repo.sh
./create-repo.sh 새저장소이름
```

## alias 등록 명령

이 명령은 이 저장소를 쓰는 사람이 **자기 컴퓨터에서 한 번만** 실행합니다.

예를 들면:

1. `repo-init`을 처음 발견한 사용자가 아래 명령을 실행합니다.
2. 그 사용자의 로컬 GitHub CLI에 `gh newrepo` 단축 명령이 등록됩니다.
3. 이후부터는 다른 폴더에서도 `gh newrepo 새저장소이름`만 입력하면 됩니다.
4. 새 컴퓨터를 쓰거나 GitHub CLI 설정을 초기화했다면 다시 한 번 등록하면 됩니다.

새 환경에서 다시 설정할 때는 아래 명령을 사용합니다.

```bash
gh alias set --shell --clobber newrepo 'repo="$1"; owner="$(gh api user --jq .login)"; target="${owner}/${repo}"; gh repo create "${target}" --private --template jaehunshin-git/repo-init && gh label list --repo "${target}" --json name --jq '\''.[].name'\'' | while IFS= read -r label; do [ -z "${label}" ] || gh label delete "${label}" --repo "${target}" --yes; done && gh label clone jaehunshin-git/repo-init --repo "${target}" --force && echo "완료: https://github.com/${target}"'
```

## 포함된 템플릿

```text
.github/
├── ISSUE_TEMPLATE/
│   ├── docs.yml
│   ├── feature.yml
│   ├── fix.yml
│   ├── init.yml
│   └── refactor.yml
└── PULL_REQUEST_TEMPLATE.md
```

- 이슈 템플릿은 현재 라벨 세트와 연결되어 있습니다.
- 프로젝트별 CI/CD는 저장소 성격에 따라 별도로 추가합니다.

## 라벨 세트

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
