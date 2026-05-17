# label-template

새 GitHub 저장소를 만들 때 공통 라벨 세트를 한 번에 적용하기 위한 템플릿 저장소입니다.

## 사용법

```bash
chmod +x create-repo-with-labels.sh
./create-repo-with-labels.sh 새저장소이름
```

이 스크립트는 아래 순서로 동작합니다.

1. private 저장소를 새로 만듭니다.
2. 새 저장소에 기본으로 들어 있는 라벨을 전부 삭제합니다.
3. 이 저장소의 라벨 세트를 새 저장소로 복제합니다.

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
