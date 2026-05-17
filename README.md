# repo-init

새 GitHub 저장소를 만들 때 기본 파일 구조와 공통 라벨 세트를 한 번에 적용하기 위한 템플릿 저장소입니다.

## 가장 편한 사용법

GitHub CLI alias를 등록해두면 어느 폴더에서든 아래 명령만 실행하면 됩니다.

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

새 환경에서 다시 설정할 때는 아래 명령을 사용합니다.

```bash
gh alias set --shell --clobber newrepo 'repo="$1"; target="jaehunshin-git/${repo}"; gh repo create "${target}" --private --template jaehunshin-git/repo-init && gh label list --repo "${target}" --json name --jq '\''.[].name'\'' | while IFS= read -r label; do [ -z "${label}" ] || gh label delete "${label}" --repo "${target}" --yes; done && gh label clone jaehunshin-git/repo-init --repo "${target}" --force && echo "완료: https://github.com/${target}"'
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
├── PULL_REQUEST_TEMPLATE.md
└── workflows/
    ├── ci.yml
    └── cd.yml
```

- 이슈 템플릿은 현재 라벨 세트와 연결되어 있습니다.
- `ci.yml`, `cd.yml`은 Spring Boot + Gradle + Docker + AWS SSM 배포 흐름을 기준으로 작성되어 있습니다.
- `cd.yml`을 실제로 사용하려면 `docker-compose.prod.yml`과 필요한 GitHub Secrets를 각 저장소에 맞게 준비해야 합니다.

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
