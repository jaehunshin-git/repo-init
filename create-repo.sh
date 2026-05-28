#!/usr/bin/env bash

set -euo pipefail

LABEL_SOURCE_REPO="jaehunshin-git/repo-init"
VISIBILITY="--private"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_SOURCE_DIR="${SCRIPT_DIR}/.github"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "사용법: $0 새저장소이름 [--private|--public]"
  exit 1
fi

NEW_REPO="$1"
if [[ $# -eq 2 ]]; then
  case "$2" in
    --private|--public)
      VISIBILITY="$2"
      ;;
    *)
      echo "지원하지 않는 공개 범위 옵션입니다: $2"
      echo "사용법: $0 새저장소이름 [--private|--public]"
      exit 1
      ;;
  esac
fi

OWNER="$(gh api user --jq .login)"
TARGET_REPO="${OWNER}/${NEW_REPO}"

if [[ -e "${NEW_REPO}" ]]; then
  echo "이미 같은 이름의 로컬 경로가 있습니다: ${NEW_REPO}"
  exit 1
fi

if [[ ! -d "${TEMPLATE_SOURCE_DIR}/ISSUE_TEMPLATE" || ! -f "${TEMPLATE_SOURCE_DIR}/PULL_REQUEST_TEMPLATE.md" ]]; then
  echo "이슈/PR 템플릿을 찾을 수 없습니다: ${TEMPLATE_SOURCE_DIR}"
  exit 1
fi

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
