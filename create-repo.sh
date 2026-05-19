#!/usr/bin/env bash

set -euo pipefail

LABEL_SOURCE_REPO="jaehunshin-git/repo-init"
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

if [[ -e "${NEW_REPO}" ]]; then
  echo "이미 같은 이름의 로컬 경로가 있습니다: ${NEW_REPO}"
  exit 1
fi

echo "1/4 새 저장소 생성: ${TARGET_REPO}"
gh repo create "${TARGET_REPO}" "${VISIBILITY}"

echo "2/4 기존 라벨 전체 삭제"
gh label list --repo "${TARGET_REPO}" --json name --jq '.[].name' |
while IFS= read -r label; do
  [[ -z "${label}" ]] && continue
  gh label delete "${label}" --repo "${TARGET_REPO}" --yes
done

echo "3/4 라벨 세트 복제"
gh label clone "${LABEL_SOURCE_REPO}" --repo "${TARGET_REPO}" --force

echo "4/4 로컬 저장소 clone"
gh repo clone "${TARGET_REPO}" "${NEW_REPO}"

echo "완료: https://github.com/${TARGET_REPO}"
echo "로컬: $(pwd)/${NEW_REPO}"
