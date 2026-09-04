---
name: github-repo-init
description: "GitHub 저장소에 repo-init 표준 라벨과 이슈·PR 템플릿을 적용하거나, 같은 설정으로 새 저장소를 초기화할 때 사용한다. 애플리케이션 코드 스캐폴딩에는 사용하지 않는다."
---

# GitHub 저장소 초기화

`jaehunshin-git/repo-init`을 기준으로 GitHub 협업 설정을 적용한다. 이 스킬의 목적은 코드 생성이 아니라 라벨과 GitHub 템플릿을 일관되게 배포하는 것이다.

## 먼저 정할 것

요청을 다음 흐름 중 하나로 분류한다.

- **기존 저장소 적용:** 대상 저장소의 라벨과 `.github` 템플릿을 갱신한다.
- **새 저장소 생성:** 로컬 저장소만 만들지, GitHub 원격 저장소까지 만들지와 공개 범위를 확인한다.
- **라벨만 적용:** 이슈·PR 템플릿은 건드리지 않는다.

대상 저장소, 적용할 브랜치, 라벨 처리 방식을 확인한다. 대상이 현재 작업 디렉터리라면 `gh repo view --json nameWithOwner --jq .nameWithOwner`로 식별한다. `gh auth status`, Git 사용자 정보, push 권한을 필요한 범위에서 점검한다.

## 기존 저장소에 적용

템플릿 원본은 `jaehunshin-git/repo-init`이다. 최신 원본이 필요하면 임시 디렉터리에 shallow clone한 뒤 `.github/ISSUE_TEMPLATE`와 `.github/PULL_REQUEST_TEMPLATE.md`만 대상 저장소에 복사한다. 대상의 다른 `.github` 파일은 보존하고 `.DS_Store`는 복사하지 않는다.

라벨은 다음 둘 중 하나만 선택한다.

- **추가·갱신:** `gh label clone jaehunshin-git/repo-init --repo OWNER/REPO --force`를 사용한다. 기존에만 있던 라벨은 유지한다.
- **전체 교체:** 대상 라벨을 모두 삭제한 뒤 같은 clone 명령을 실행한다. 이는 되돌리기 어려운 작업이므로, 삭제 전에 대상과 영향 범위를 명확히 알리고 사용자의 명시적 요청 또는 확인을 받는다.

템플릿 파일이 변경되었을 때만 대상 저장소의 기존 커밋 규칙을 따라 커밋하고 push한다. 커밋 전에 staged diff를 검토한다. 사용자가 원격 변경이나 push를 요청하지 않았다면 파일 변경까지만 수행하고 상태를 보고한다.

## 새 저장소 생성

원본 저장소의 `create-repo.sh`를 사용한다. 신뢰 가능한 사본을 clone한 뒤 다음 형태로 실행한다.

```bash
./create-repo.sh 저장소이름 [--local|--remote] [--private|--public]
```

옵션이 없으면 로컬 Git 저장소와 템플릿 첫 커밋만 만든다. `--remote`, `--private`, `--public`은 GitHub 저장소 생성, 표준 라벨 복제, 템플릿 커밋과 push까지 수행한다. 원격 생성은 외부 상태를 만들며 중간 실패 시 빈 원격 저장소가 남을 수 있음을 먼저 알린다.

## 완료 보고

적용한 대상, 라벨 처리 방식, 복사한 템플릿, 생성한 커밋과 push 여부를 간단히 보고한다. 전체 교체였다면 삭제된 기존 라벨이 있었다는 사실도 함께 기록한다.
