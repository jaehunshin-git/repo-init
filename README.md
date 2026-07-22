<p align="center">
  <img src=".github/assets/repo-init-banner.svg" alt="repo-init 배너" width="100%" />
</p>

# repo-init

새 저장소를 로컬에서 빠르게 시작하거나, 필요할 때 GitHub 원격 저장소까지 공통 라벨 세트와 이슈/PR 템플릿을 적용하는 설정 저장소입니다.

`create-repo.sh`와 `gh newrepo` alias는 기본적으로 현재 디렉터리에 로컬 Git 저장소를 만들고 이슈/PR 템플릿을 첫 커밋으로 추가합니다.
`--remote` 또는 `--private`/`--public`을 지정하면 GitHub 저장소를 만들고, 기본 라벨을 정리한 뒤 이 저장소의 라벨 세트와 이슈/PR 템플릿을 적용해 push합니다.

## 사용 방법

### 사전 조건

- Git 2.28 이상: 기본 브랜치를 `main`으로 초기화하는 데 사용합니다.
- 원격 저장소를 만들거나 라벨을 복제할 때: [GitHub CLI](https://cli.github.com/)와 GitHub 인증이 필요합니다.
- 템플릿을 커밋할 수 있도록 Git 사용자 정보를 설정해야 합니다.

```bash
gh auth login
git config --global user.name "이름"
git config --global user.email "email@example.com"
```

### 빠른 시작: 로컬 스크립트 사용

가장 간단한 방법입니다. **새 저장소를 만들 상위 디렉터리에서** 이 저장소를 clone한 뒤 스크립트를 실행합니다.

```bash
git clone https://github.com/jaehunshin-git/repo-init.git
./repo-init/create-repo.sh my-project --private
```

위 명령은 현재 디렉터리에 `my-project`를 만들고, 비공개 GitHub 원격 저장소·라벨·이슈/PR 템플릿을 적용합니다. 스크립트는 실행 위치와 관계없이 자신의 `.github` 템플릿을 사용합니다.

| 명령 | 결과 |
| --- | --- |
| `./create-repo.sh 새저장소이름` 또는 `--local` | 로컬 Git 저장소와 이슈/PR 템플릿 커밋 생성 |
| `./create-repo.sh 새저장소이름 --remote` | 비공개 GitHub 원격 저장소까지 생성 |
| `./create-repo.sh 새저장소이름 --private` | 비공개 GitHub 원격 저장소까지 생성 |
| `./create-repo.sh 새저장소이름 --public` | 공개 GitHub 원격 저장소까지 생성 |

원격 모드에서는 새 저장소의 기본 라벨을 삭제한 뒤 이 저장소의 라벨 세트를 적용합니다. 생성·라벨 적용·push 중 실패하면 생성된 원격 저장소가 남을 수 있으므로 GitHub에서 상태를 확인한 뒤 필요하면 직접 삭제하세요.

### 1. 웹에서 사용하기

1. GitHub 웹에서 새 저장소를 만듭니다.
2. 라벨만 추가하려면 아래 명령을 실행합니다. 이 명령은 기존 라벨을 유지하면서 같은 이름의 라벨을 갱신하고, 없는 라벨을 추가합니다.

```bash
gh label clone jaehunshin-git/repo-init --repo 내아이디/새저장소 --force
```

GitHub 웹에서 이미 만든 저장소의 기본 라벨을 제거하고, 이 저장소의 라벨 및 이슈/PR 템플릿을 모두 적용하려면 아래 명령을 사용합니다.

> 이 명령은 **대상 저장소 디렉터리 밖**, 즉 대상 저장소를 clone할 상위 디렉터리에서 실행하세요. 현재 디렉터리에 `${REPO}` 또는 `repo-init`이라는 경로가 이미 있으면 clone이 실패합니다.
> 첫 번째 반복문은 대상 저장소의 라벨을 모두 삭제하므로, 유지할 라벨이 있다면 삭제 대상에서 제외하거나 라벨 복제 명령만 실행하세요.

```bash
OWNER="$(gh api user --jq .login)"
REPO="이미-만든-레포-이름"

# 기존 라벨을 모두 지운 뒤 repo-init의 라벨 세트를 적용합니다.
gh label list --repo "${OWNER}/${REPO}" --json name --jq '.[].name' |
while IFS= read -r label; do
  [ -z "${label}" ] || gh label delete "${label}" --repo "${OWNER}/${REPO}" --yes
done

gh label clone jaehunshin-git/repo-init --repo "${OWNER}/${REPO}" --force

# 대상 레포와 템플릿 원본을 clone합니다.
gh repo clone "${OWNER}/${REPO}" "${REPO}"
git clone https://github.com/jaehunshin-git/repo-init.git repo-init

# 이슈/PR 템플릿을 적용하고 push합니다.
mkdir -p "${REPO}/.github"
cp -R repo-init/.github/ISSUE_TEMPLATE "${REPO}/.github/"
cp repo-init/.github/PULL_REQUEST_TEMPLATE.md "${REPO}/.github/"

git -C "${REPO}" add .github
git -C "${REPO}" commit -m "chore: 이슈 및 PR 템플릿 추가"
git -C "${REPO}" push
```

`create-repo.sh`와 `gh newrepo`는 새 저장소 생성용이므로, GitHub 웹에서 이미 만든 저장소에는 위 명령을 사용합니다.

### 2. GitHub CLI로 사용하기

#### 기본 명령으로 실행하기

저장소 생성, 라벨 복제, 로컬 clone을 직접 실행하려면 아래 명령을 순서대로 사용합니다.

```bash
OWNER="$(gh api user --jq .login)"
REPO="새저장소이름"

gh repo create "${OWNER}/${REPO}" --private
gh label list --repo "${OWNER}/${REPO}" --json name --jq '.[].name' | while IFS= read -r label; do [ -z "${label}" ] || gh label delete "${label}" --repo "${OWNER}/${REPO}" --yes; done
gh label clone jaehunshin-git/repo-init --repo "${OWNER}/${REPO}" --force
gh repo clone "${OWNER}/${REPO}" "${REPO}"
```

공개 저장소로 만들려면 첫 번째 명령의 `--private`를 `--public`으로 바꿉니다.

이 방식은 저장소 파일을 복사하지 않고 라벨만 복제한 뒤, 현재 디렉터리에 새 저장소를 clone합니다.
이슈/PR 템플릿까지 자동으로 적용하려면 아래 `gh newrepo` alias 또는 로컬 스크립트를 사용합니다.

> `gh label clone`만 사용하면 GitHub가 새 저장소에 기본으로 넣어주는 라벨은 그대로 남습니다.  
> 기본 라벨 제거, 라벨 세트 적용, 이슈/PR 템플릿 복사를 한 번에 처리하려면 아래 `gh newrepo` alias 또는 로컬 스크립트를 사용합니다.

#### alias로 실행하기

반복해서 사용할 경우 GitHub CLI alias를 등록해두면 같은 흐름을 하나의 명령으로 실행할 수 있습니다.

alias 등록은 선택 사항입니다.

- 수동 실행이 필요하면 위의 `gh repo create`, `gh label clone`, `gh repo clone` 명령을 사용합니다.
- 반복 실행이 필요하면 아래 alias를 로컬 GitHub CLI 설정에 등록합니다.
- alias는 이 저장소에 저장되지 않고, **로컬 GitHub CLI 설정에 저장되는 개인 단축 명령**입니다.

<details>
<summary>반복 사용을 위한 <code>gh newrepo</code> alias 등록 및 전체 동작 보기</summary>

##### 1) alias 등록

이 명령은 alias를 사용할 로컬 환경에서 최초 등록 시 실행합니다.

등록 흐름은 다음과 같습니다.

1. 아래 명령을 실행합니다.
2. 로컬 GitHub CLI에 `gh newrepo` 단축 명령이 등록됩니다.
3. 새 컴퓨터를 사용하거나 GitHub CLI 설정을 초기화한 경우 다시 등록합니다.

```bash
gh alias set --shell --clobber newrepo '
repo="$1"
shift || true
mode="local"
visibility="--private"
local_explicit="false"
remote_explicit="false"
visibility_explicit="false"

usage() {
  echo "사용법: gh newrepo 새저장소이름 [--local|--remote] [--private|--public]"
  echo "  기본값: 로컬 저장소만 생성합니다."
  echo "  --remote 또는 --private/--public을 지정하면 GitHub 원격 저장소까지 생성합니다."
}

if [ -z "$repo" ]; then
  usage
  exit 1
fi

if [ -e "$repo" ]; then
  echo "이미 같은 이름의 로컬 경로가 있습니다: $repo"
  exit 1
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --local)
      if [ "$remote_explicit" = "true" ]; then
        echo "--local과 --remote는 함께 사용할 수 없습니다."
        usage
        exit 1
      fi
      if [ "$visibility_explicit" = "true" ]; then
        echo "공개 범위 옵션은 --local과 함께 사용할 수 없습니다."
        usage
        exit 1
      fi
      local_explicit="true"
      mode="local"
      ;;
    --remote)
      if [ "$local_explicit" = "true" ]; then
        echo "--local과 --remote는 함께 사용할 수 없습니다."
        usage
        exit 1
      fi
      remote_explicit="true"
      mode="remote"
      ;;
    --private|--public)
      if [ "$local_explicit" = "true" ]; then
        echo "공개 범위 옵션은 --remote 모드에서만 사용할 수 있습니다: $1"
        usage
        exit 1
      fi
      visibility="$1"
      visibility_explicit="true"
      mode="remote"
      ;;
    *)
      echo "지원하지 않는 옵션입니다: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

source="jaehunshin-git/repo-init"
template_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$template_dir"
}
trap cleanup EXIT

gh repo clone "$source" "$template_dir" || exit 1

if [ "$mode" = "local" ]; then
  mkdir "$repo" &&
  git -C "$repo" init -b main &&
  mkdir -p "$repo/.github" &&
  cp -R "$template_dir/.github/ISSUE_TEMPLATE" "$repo/.github/" &&
  cp "$template_dir/.github/PULL_REQUEST_TEMPLATE.md" "$repo/.github/PULL_REQUEST_TEMPLATE.md" &&
  git -C "$repo" add .github/ISSUE_TEMPLATE .github/PULL_REQUEST_TEMPLATE.md &&
  git -C "$repo" commit -m "chore: add issue and PR templates" &&
  echo "완료: 로컬 저장소를 생성했습니다." &&
  echo "로컬: $(pwd)/$repo" &&
  echo "원격: 설정하지 않음"
else
  owner="$(gh api user --jq .login)" || exit 1
  target="${owner}/${repo}"

  gh repo create "$target" "$visibility" &&
  gh label list --repo "$target" --json name --jq '\''.[].name'\'' |
  while IFS= read -r label; do
    [ -z "$label" ] || gh label delete "$label" --repo "$target" --yes
  done &&
  gh label clone "$source" --repo "$target" --force &&
  gh repo clone "$target" "$repo" &&
  mkdir -p "$repo/.github" &&
  cp -R "$template_dir/.github/ISSUE_TEMPLATE" "$repo/.github/" &&
  cp "$template_dir/.github/PULL_REQUEST_TEMPLATE.md" "$repo/.github/PULL_REQUEST_TEMPLATE.md" &&
  git -C "$repo" add .github/ISSUE_TEMPLATE .github/PULL_REQUEST_TEMPLATE.md &&
  git -C "$repo" commit -m "chore: add issue and PR templates" &&
  git -C "$repo" push -u origin HEAD &&
  echo "완료: https://github.com/$target" &&
  echo "로컬: $(pwd)/$repo"
fi
'
```

##### 2) alias 사용

등록 후에는 어느 폴더에서든 아래처럼 실행할 수 있습니다.

```bash
gh newrepo 새저장소이름
gh newrepo 새저장소이름 --local
```

GitHub 원격 저장소까지 만들려면 아래처럼 실행합니다.

```bash
gh newrepo 새저장소이름 --remote
gh newrepo 새저장소이름 --private
gh newrepo 새저장소이름 --public
```

옵션을 생략하면 로컬 저장소만 생성합니다.
원격 모드에서 공개 범위 플래그를 생략하면 `--private`가 기본값으로 사용됩니다.

로컬 모드에서는 아래 순서로 동작합니다.

1. 이 저장소를 임시 디렉터리에 clone해 템플릿을 가져옵니다.
2. 현재 디렉터리에 새 폴더를 만듭니다.
3. `git init -b main`으로 로컬 Git 저장소를 초기화합니다.
4. 이 저장소의 이슈/PR 템플릿을 새 저장소의 `.github` 디렉터리로 복사합니다.
5. 템플릿 파일을 `chore: add issue and PR templates` 커밋으로 추가합니다.

원격 모드에서는 아래 순서로 동작합니다.

1. GitHub에 빈 새 저장소를 만듭니다.
2. 새 저장소에 기본으로 들어 있는 라벨을 전부 삭제합니다.
3. 이 저장소의 라벨 세트를 새 저장소로 복제합니다.
4. 현재 디렉터리에 새 저장소를 clone합니다.
5. 이 저장소의 이슈/PR 템플릿을 새 저장소의 `.github` 디렉터리로 복사합니다.
6. 템플릿 파일을 `chore: add issue and PR templates` 커밋으로 push합니다.

라벨은 GitHub 원격 저장소의 리소스라서 로컬 모드에서는 적용하지 않습니다.

</details>

#### 로컬 스크립트의 전체 예시

alias 대신 저장소 안의 스크립트를 직접 실행할 수도 있습니다.

```bash
./create-repo.sh 새저장소이름
./create-repo.sh 새저장소이름 --local
./create-repo.sh 새저장소이름 --remote
./create-repo.sh 새저장소이름 --private
./create-repo.sh 새저장소이름 --public
```

이 경우에도 옵션을 생략하면 로컬 저장소만 생성합니다.
`--remote` 또는 `--private`/`--public`을 지정하면 GitHub 원격 저장소까지 생성합니다.
현재 디렉터리에 같은 이름의 파일이나 폴더가 있으면 저장소를 만들기 전에 중단합니다.

## 포함된 참고 템플릿

이 저장소에는 새 저장소로 복제할 이슈/PR 템플릿도 들어 있습니다.
`gh newrepo` alias와 `create-repo.sh`는 아래 파일들을 새 저장소로 복사한 뒤 첫 커밋으로 추가합니다.
원격 모드에서는 해당 커밋을 GitHub 저장소로 push합니다.

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

템플릿 제목 컨벤션은 아래처럼 구분합니다.

| 구분 | 제목 형식 | 예시 |
| --- | --- | --- |
| PR | `type: 작업 내용` | `feat: 새 저장소 로컬 clone 추가` |
| Issue | `[type] 작업 내용` | `[feat] 새 저장소 로컬 clone 추가` |

- PR 제목은 squash merge 시 커밋 메시지로 쓰기 좋도록 Conventional Commits 형식을 사용합니다.
- 이슈 제목은 커밋 메시지와 구분되도록 대괄호 형식을 사용합니다.
- 이슈 템플릿은 현재 라벨 세트와 연결되어 있습니다.
- 프로젝트별 CI/CD는 저장소 성격에 따라 별도로 추가합니다.

이슈 템플릿 예시는 아래와 같습니다.

```md
# [feat] 새 저장소 로컬 clone 추가

## 📄 Description
새 저장소를 만든 뒤 로컬에서 바로 작업할 수 있도록 자동 clone을 추가합니다.

## ✅ Tasks
- [ ] 원격 저장소 생성
- [ ] 라벨 세트 복제
- [ ] 로컬 저장소 clone

## 📎 ETC
관련 문서나 참고 링크를 작성합니다.
```

PR 템플릿 예시는 아래와 같습니다.

```md
# feat: 새 저장소 로컬 clone 추가

## 📌 Summary
새 저장소 생성 후 라벨을 복제하고 현재 디렉터리에 자동으로 clone합니다.

- close #1

## 📄 Tasks
- 로컬 경로 충돌 검사 추가
- `gh repo clone` 단계 추가
- README 사용법 갱신

## 🔍 To Reviewer
- alias 동작 흐름이 자연스러운지 확인해주세요.
```

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
