#!/usr/bin/env bash

set -euo pipefail

LABEL_SOURCE_REPO="jaehunshin-git/repo-init"
VISIBILITY="--private"
REMOTE_MODE="false"
LOCAL_MODE_EXPLICIT="false"
REMOTE_MODE_EXPLICIT="false"
VISIBILITY_EXPLICIT="false"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_SOURCE_DIR="${SCRIPT_DIR}/.github"

usage() {
  echo "사용법: $0 새저장소이름 [--local|--remote] [--private|--public]"
  echo "  기본값: 로컬 저장소만 생성합니다."
  echo "  --remote 또는 --private/--public을 지정하면 GitHub 원격 저장소까지 생성합니다."
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

NEW_REPO="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      if [[ "${REMOTE_MODE_EXPLICIT}" == "true" ]]; then
        echo "--local과 --remote는 함께 사용할 수 없습니다."
        usage
        exit 1
      fi
      if [[ "${VISIBILITY_EXPLICIT}" == "true" ]]; then
        echo "공개 범위 옵션은 --local과 함께 사용할 수 없습니다."
        usage
        exit 1
      fi
      LOCAL_MODE_EXPLICIT="true"
      REMOTE_MODE="false"
      ;;
    --remote)
      if [[ "${LOCAL_MODE_EXPLICIT}" == "true" ]]; then
        echo "--local과 --remote는 함께 사용할 수 없습니다."
        usage
        exit 1
      fi
      REMOTE_MODE_EXPLICIT="true"
      REMOTE_MODE="true"
      ;;
    --private|--public)
      if [[ "${LOCAL_MODE_EXPLICIT}" == "true" ]]; then
        echo "공개 범위 옵션은 --remote 모드에서만 사용할 수 있습니다: $1"
        usage
        exit 1
      fi
      VISIBILITY="$1"
      VISIBILITY_EXPLICIT="true"
      REMOTE_MODE="true"
      ;;
    *)
      echo "지원하지 않는 옵션입니다: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ -e "${NEW_REPO}" ]]; then
  echo "이미 같은 이름의 로컬 경로가 있습니다: ${NEW_REPO}"
  exit 1
fi

if [[ ! -d "${TEMPLATE_SOURCE_DIR}/ISSUE_TEMPLATE" || ! -f "${TEMPLATE_SOURCE_DIR}/PULL_REQUEST_TEMPLATE.md" ]]; then
  echo "이슈/PR 템플릿을 찾을 수 없습니다: ${TEMPLATE_SOURCE_DIR}"
  exit 1
fi

if [[ "${REMOTE_MODE}" == "false" ]]; then
  echo "1/4 로컬 저장소 디렉터리 생성: ${NEW_REPO}"
  mkdir "${NEW_REPO}"

  echo "2/4 Git 저장소 초기화"
  git -C "${NEW_REPO}" init -b main

  echo "3/4 이슈/PR 템플릿 복사"
  mkdir -p "${NEW_REPO}/.github"
  cp -R "${TEMPLATE_SOURCE_DIR}/ISSUE_TEMPLATE" "${NEW_REPO}/.github/"
  cp "${TEMPLATE_SOURCE_DIR}/PULL_REQUEST_TEMPLATE.md" "${NEW_REPO}/.github/PULL_REQUEST_TEMPLATE.md"

  echo "4/4 템플릿 커밋"
  git -C "${NEW_REPO}" add .github/ISSUE_TEMPLATE .github/PULL_REQUEST_TEMPLATE.md
  git -C "${NEW_REPO}" commit -m "chore: add issue and PR templates"

  echo "완료: 로컬 저장소를 생성했습니다."
  echo "로컬: $(pwd)/${NEW_REPO}"
  echo "원격: 설정하지 않음"
  exit 0
fi

OWNER="$(gh api user --jq .login)"
TARGET_REPO="${OWNER}/${NEW_REPO}"

echo "1/6 새 저장소 생성: ${TARGET_REPO}"
gh repo create "${TARGET_REPO}" "${VISIBILITY}"

echo "2/6 기존 라벨 전체 삭제"
gh label list --repo "${TARGET_REPO}" --json name --jq '.[].name' |
while IFS= read -r label; do
  [[ -z "${label}" ]] && continue
  gh label delete "${label}" --repo "${TARGET_REPO}" --yes
done

echo "3/6 라벨 세트 복제"
gh label clone "${LABEL_SOURCE_REPO}" --repo "${TARGET_REPO}" --force

echo "4/6 로컬 저장소 clone"
gh repo clone "${TARGET_REPO}" "${NEW_REPO}"

echo "5/6 이슈/PR 템플릿 복사"
mkdir -p "${NEW_REPO}/.github"
cp -R "${TEMPLATE_SOURCE_DIR}/ISSUE_TEMPLATE" "${NEW_REPO}/.github/"
cp "${TEMPLATE_SOURCE_DIR}/PULL_REQUEST_TEMPLATE.md" "${NEW_REPO}/.github/PULL_REQUEST_TEMPLATE.md"

echo "6/6 템플릿 커밋 및 push"
git -C "${NEW_REPO}" add .github/ISSUE_TEMPLATE .github/PULL_REQUEST_TEMPLATE.md
git -C "${NEW_REPO}" commit -m "chore: add issue and PR templates"
git -C "${NEW_REPO}" push -u origin HEAD

echo "완료: https://github.com/${TARGET_REPO}"
echo "로컬: $(pwd)/${NEW_REPO}"
