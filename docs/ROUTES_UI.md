# 라우트·UI — 픽콜(가칭) MVP

PRD_MVP·DB_SCHEMA 기준 Next.js(App Router) 라우트/컴포넌트/데이터 요구사항. 구현 관점 정리.

---

## 1. /app 라우트 트리

```
app/
├── layout.tsx              # 루트 레이아웃, 메타 기본값
├── page.tsx                 # 홈: 매치업 목록 (/)
├── match/
│   └── [id]/
│       └── page.tsx         # 매치업 상세 (/match/[id]), 블라인드 시 안내 페이지 분기
├── not-found.tsx            # 404 (잘못된 id 등)
└── globals.css
```

- `/match/new`는 Next 단계에서 추가. MVP에는 없음.

---

## 2. 페이지별 데이터 요구사항

| 페이지 | 필요한 데이터 | 테이블/쿼리 |
|--------|----------------|-------------|
| 홈 `page.tsx` | 비블라인드 매치업 목록, 최신순, 페이지네이션 | `matchups` where blinded_at is null order by created_at desc, limit/offset |
| 매치업 상세 `match/[id]/page.tsx` | 1) 매치업 1건 + blinded 여부 2) 좌/우 항목 3) 항목별 득표 수 4) 현재 anon_id의 투표 여부 5) 댓글 목록 | `matchups` by id → blinded_at이면 안내 페이지만 렌더. `matchup_items` by matchup_id. `votes` 집계 by matchup_id, item_id. `votes`에서 anon_id+matchup_id 존재 여부. `comments` by matchup_id order by created_at desc |
| 블라인드 안내 | 매치업 존재 여부만(blinded_at not null) | `matchups` select id, blinded_at where id = ? |

- **anon_id**: 클라이언트(localStorage+cookie)에서 읽어 투표/댓글/신고 API 호출 시 본문에 포함. 서버에서 anon_id로 “이미 투표함” 여부 조회 시 쿼리 파라미터 또는 헤더로 전달(선택).

---

## 3. 핵심 컴포넌트 목록 + 책임

| 컴포넌트 | 책임 | 비고 |
|----------|------|------|
| **MatchupCard** | 매치업 1건 카드(제목, 썸네일 또는 첫 항목 미리보기, 링크) | 홈 목록용, 링크는 /match/[id] |
| **MatchupDetail** | 상세 상단: 제목, 좌/우 항목(텍스트+이미지), 투표 버튼 또는 결과만 표시 | 서버/클라이언트 분리는 MVP에서 단순하게 |
| **VotePanel** | 좌/우 선택 버튼, 제출 시 votes insert, 이미 투표 시 결과만 표시 | anon_id 1회 제한 반영, 클라이언트 컴포넌트 |
| **VoteResult** | 항목별 득표 수 또는 비율 표시 | 읽기 전용 |
| **CommentList** | 댓글 목록(닉네임, 본문, 작성일), 최신순 | 서버에서 fetch 또는 클라이언트에서 조회 |
| **CommentForm** | 댓글 입력(닉네임 선택, body 5~500자), 10초 쿨다운 안내 | 클라이언트, 등록 후 목록 갱신 |
| **ReportButton** | 신고 버튼 → 모달(사유 5종 선택) → reports insert | SPAM/HATE/NSFW/ILLEGAL/OTHER |
| **BlindedNotice** | 블라인드 안내문 + 홈 링크 | /match/[id]에서 blinded_at not null일 때 |
| **AnonIdProvider** (또는 훅) | anon_id 생성/저장( local storage + cookie), 하위에서 사용 | 전역 또는 레이아웃 하위 |

---

## 4. 구현 순서(MVP 최소 관통 플로우)

1. **DB·Supabase**: 테이블·RLS 적용, 시드 데이터 insert (DB_SCHEMA.md 기준).
2. **anon_id**: UUID 생성 후 localStorage + cookie 저장, 훅/컨텍스트로 제공.
3. **홈**: `app/page.tsx` — matchups 목록 조회(blinded_at is null), MatchupCard 리스트, 페이지네이션(선택).
4. **상세 진입**: `app/match/[id]/page.tsx` — matchup + items 조회, blinded_at이면 BlindedNotice + noindex.
5. **투표**: VotePanel — 선택 시 votes insert(anon_id, matchup_id, item_id), 이미 투표 시 결과만 표시.
6. **투표 결과**: VoteResult — 항목별 득표 수/비율 표시.
7. **댓글**: CommentList + CommentForm — 목록 조회, 5~500자·10초 쿨다운·닉네임 없으면 '익명'.
8. **신고**: ReportButton + 모달 — reason 5종, reports insert; 블라인드 트리거/백엔드 연동.
9. **SEO 메타**: layout·홈·상세·블라인드 페이지에 title/description 적용(SEO_NOTES.md 참고).
10. **반응형**: 공통 레이아웃·카드·상세가 모바일/데스크톱에서 깨지지 않도록.

---

## 5. 라우트별 SEO 메타 제안

| 라우트 | title | description | 비고 |
|--------|--------|-------------|------|
| `/` | 사이트명(예: 픽콜) — 대결 투표 커뮤니티 | 한 줄 소개(예: 좌우 대결에 투표하고 댓글을 남겨보세요.) | og:title, og:description 동일 |
| `/match/[id]` | {매치업 제목} — 사이트명 | {제목} 좌우 대결, 투표해 보세요. | 동적 메타, 블라인드 시 noindex |
| `/match/[id]` (blinded) | 콘텐츠 안내 — 사이트명 | 해당 콘텐츠는 안내에 따라 비공개 처리되었습니다. | noindex, nofollow |
| 404 | 페이지를 찾을 수 없습니다 — 사이트명 | — | noindex 권장 |

- OG 이미지: MVP에서는 공통 이미지 1장 또는 생략. Next에서 동적 OG 추가 가능.

---

**관련 문서**: [PRD_MVP.md](./PRD_MVP.md) · [DB_SCHEMA.md](./DB_SCHEMA.md) · [SEO_NOTES.md](./SEO_NOTES.md)

이 문서는 ui-engineer에 의해 PRD_MVP 기준으로 작성·갱신되었으며, AGENTS.md 규칙을 따른다.
