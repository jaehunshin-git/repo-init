# repo-init

새 GitHub 저장소를 만들 때 공통 라벨 세트를 빠르게 적용하기 위한 설정 저장소입니다.

`gh newrepo` alias와 `create-repo.sh`는 새 저장소에 이 저장소의 파일을 복사하지 않고, 빈 저장소를 만든 뒤 라벨만 정리합니다.

## 사용 방법

### 1. 웹에서 사용하기

1. GitHub 웹에서 새 저장소를 만듭니다.
2. 라벨을 추가하고 싶다면 아래 명령을 실행합니다.

```bash
gh label clone jaehunshin-git/repo-init --repo 내아이디/새저장소 --force
```

기본 라벨까지 전부 지우고 이 저장소의 라벨 세트만 남기고 싶다면 아래 `GitHub CLI로 사용하기`의 alias 또는 로컬 스크립트 방식을 사용하세요.

### 2. GitHub CLI로 사용하기

#### 한 번만 사용할 때

저장소를 한 번만 만들 거라면 아래 명령을 순서대로 실행하면 됩니다.

```bash
gh repo create 새저장소이름 --private
gh label list --repo 내아이디/새저장소 --json name --jq '.[].name' | while IFS= read -r label; do [ -z "${label}" ] || gh label delete "${label}" --repo 내아이디/새저장소 --yes; done
gh label clone jaehunshin-git/repo-init --repo 내아이디/새저장소 --force
```

공개 저장소로 만들고 싶다면 첫 번째 명령의 `--private`를 `--public`으로 바꾸면 됩니다.

```bash
gh repo create 새저장소이름 --public
gh label list --repo 내아이디/새저장소 --json name --jq '.[].name' | while IFS= read -r label; do [ -z "${label}" ] || gh label delete "${label}" --repo 내아이디/새저장소 --yes; done
gh label clone jaehunshin-git/repo-init --repo 내아이디/새저장소 --force
```

이 방식은 저장소 파일을 복사하지 않고 라벨만 복제합니다.

> `gh label clone`만 사용하면 GitHub가 새 저장소에 기본으로 넣어주는 라벨은 그대로 남습니다.  
> 기본 라벨까지 전부 지우고 이 저장소의 라벨 세트만 남기고 싶다면 아래 `gh newrepo` alias 또는 로컬 스크립트를 사용하세요.

#### 자주 사용할 때

이 저장소를 자주 사용할 예정이라면, 각 사용자가 자기 컴퓨터에 GitHub CLI alias를 한 번만 등록해두는 방식이 가장 편합니다.

alias는 필수 기능이 아닙니다.

- 한 번만 사용할 사람은 `gh repo create`와 `gh label clone`만 사용해도 됩니다.
- 여러 번 사용할 사람은 아래 alias를 자기 터미널에 한 번 등록해두면 됩니다.
- alias는 이 저장소에 저장되는 것이 아니라, **각 사용자의 로컬 GitHub CLI 설정에 저장되는 개인 단축 명령**입니다.

##### 1) alias 등록

이 명령은 이 저장소를 쓰는 사람이 **자기 컴퓨터에서 한 번만** 실행합니다.

예를 들면:

1. `repo-init`을 처음 발견한 사용자가 아래 명령을 실행합니다.
2. 그 사용자의 로컬 GitHub CLI에 `gh newrepo` 단축 명령이 등록됩니다.
3. 새 컴퓨터를 쓰거나 GitHub CLI 설정을 초기화했다면 다시 한 번 등록하면 됩니다.

```bash
gh alias set --shell --clobber newrepo 'repo="$1"; visibility="${2:---private}"; if [ -z "$repo" ] || [ "$#" -gt 2 ]; then echo "사용법: gh newrepo 새저장소이름 [--private|--public]"; exit 1; fi; case "$visibility" in --private|--public) ;; *) echo "지원하지 않는 공개 범위 옵션입니다: $visibility"; echo "사용법: gh newrepo 새저장소이름 [--private|--public]"; exit 1 ;; esac; source="jaehunshin-git/repo-init"; owner="$(gh api user --jq .login)"; target="${owner}/${repo}"; gh repo create "${target}" "$visibility" && gh label list --repo "${target}" --json name --jq '\''.[].name'\'' | while IFS= read -r label; do [ -z "${label}" ] || gh label delete "${label}" --repo "${target}" --yes; done && gh label clone "${source}" --repo "${target}" --force && echo "완료: https://github.com/${target}"'
```

##### 2) alias 사용

등록 후에는 어느 폴더에서든 아래처럼 실행할 수 있습니다.

```bash
gh newrepo 새저장소이름 --private
gh newrepo 새저장소이름 --public
```

공개 범위 플래그를 생략하면 `--private`가 기본값으로 사용됩니다.

이 명령은 아래 순서로 동작합니다.

1. 빈 새 저장소를 만듭니다.
2. 새 저장소에 기본으로 들어 있는 라벨을 전부 삭제합니다.
3. 이 저장소의 라벨 세트를 새 저장소로 복제합니다.

#### 저장소를 clone해서 사용할 때

alias 대신 저장소 안의 스크립트를 직접 실행할 수도 있습니다.

```bash
chmod +x create-repo.sh
./create-repo.sh 새저장소이름 --private
./create-repo.sh 새저장소이름 --public
```

이 경우에도 공개 범위 플래그를 생략하면 `--private`가 기본값으로 사용됩니다.

## 포함된 참고 템플릿

이 저장소에는 참고용 이슈/PR 템플릿도 들어 있습니다.
다만 `gh newrepo` alias와 `create-repo.sh`는 아래 파일들을 새 저장소로 복사하지 않습니다.

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
