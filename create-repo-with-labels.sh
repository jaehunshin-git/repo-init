#!/usr/bin/env bash

set -euo pipefail

TEMPLATE_REPO="jaehunshin-git/label-template"
VISIBILITY="private"

if [[ $# -ne 1 ]]; then
  echo "사용법: $0 새저장소이름"
  exit 1
fi

NEW_REPO="$1"
TARGET_REPO="jaehunshin-git/${NEW_REPO}"

echo "1/3 새 저장소 생성: ${TARGET_REPO}"
gh repo create "${TARGET_REPO}" "--${VISIBILITY}"

echo "2/3 기존 라벨 전체 삭제"
gh label list --repo "${TARGET_REPO}" --json name --jq '.[].name' |
while IFS= read -r label; do
  [[ -z "${label}" ]] && continue
  gh label delete "${label}" --repo "${TARGET_REPO}" --yes
done

echo "3/3 템플릿 라벨 복제"
gh label clone "${TEMPLATE_REPO}" --repo "${TARGET_REPO}" --force

echo "완료: https://github.com/${TARGET_REPO}"
