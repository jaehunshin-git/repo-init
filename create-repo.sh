#!/usr/bin/env bash

set -euo pipefail

TEMPLATE_REPO="jaehunshin-git/repo-init"
VISIBILITY="--private"

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

echo "1/3 새 저장소 생성: ${TARGET_REPO}"
gh repo create "${TARGET_REPO}" "${VISIBILITY}" --template "${TEMPLATE_REPO}"

echo "2/3 기존 라벨 전체 삭제"
gh label list --repo "${TARGET_REPO}" --json name --jq '.[].name' |
while IFS= read -r label; do
  [[ -z "${label}" ]] && continue
  gh label delete "${label}" --repo "${TARGET_REPO}" --yes
done

echo "3/3 템플릿 라벨 복제"
gh label clone "${TEMPLATE_REPO}" --repo "${TARGET_REPO}" --force

echo "완료: https://github.com/${TARGET_REPO}"
