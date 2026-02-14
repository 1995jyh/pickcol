# 라우트·UI — 픽콜(가칭) MVP

PRD_MVP·DB_SCHEMA 기준 Next.js(App Router) 라우트/컴포넌트/데이터 요구사항 정리.
요구사항 변경 반영: **메인 / 매치업(투표+게시물) / 게시물 상세(댓글)** 3페이지 중심.

---

## 1. /app 라우트 트리

app/
├── layout.tsx # 루트 레이아웃, 메타 기본값
├── page.tsx # 메인: 매치업 목록 (/)
├── match/
│ └── [id]/
│ ├── page.tsx # 매치업 페이지 (/match/[id]) : 투표 + 게시물 목록/작성 (+ 신고는 후순위)
│ └── posts/
│ └── [postId]/
│ └── page.tsx # 게시물 상세 (/match/[id]/posts/[postId]) : 본문 + 댓글
├── not-found.tsx # 404
└── globals.css


- `/match/new`는 Next 단계(관리/스팸 리스크 때문에 MVP에서 제외).
- 블라인드/삭제 안내 화면은 후순위(P1).

---

## 2. 페이지별 데이터 요구사항

| 페이지 | 필요한 데이터 | 테이블/쿼리 |
|--------|----------------|-------------|
| 메인 `page.tsx` | 비블라인드 매치업 목록, 최신순 | `matchups` where blinded_at is null order by created_at desc |
| 매치업 `match/[id]/page.tsx` | 1) 매치업 1건 + blinded 여부 2) 좌/우 항목 3) 득표 집계 4) anon_id 투표 여부 5) 게시물 목록 | `matchups` by id, `matchup_items` by matchup_id, `votes` 집계, `votes` 존재여부(anon_id+matchup_id), `posts` where matchup_id |
| 게시물 `match/[id]/posts/[postId]/page.tsx` | 1) 게시물 1건(매치업 소속 검증) 2) 댓글 목록 | `posts` by id (+ matchup_id 검증), `post_comments` where post_id |

- anon_id는 클라이언트(localStorage+cookie)에서 읽어 쓰기 요청(투표/게시물/댓글/신고)에 포함.

---

## 3. 핵심 컴포넌트 목록 + 책임

| 컴포넌트 | 책임 | 비고 |
|----------|------|------|
| **MatchupCard** | 매치업 카드(제목/미리보기/링크) | 메인 목록 |
| **MatchupDetail** | 매치업 상단(제목, 좌/우 항목 표시) | /match/[id] |
| **VotePanel** | 좌/우 선택 버튼, votes insert, 1회 제한 | 클라이언트 컴포넌트 |
| **VoteResult** | 득표 수 또는 비율 표시 | 읽기 전용 |
| **PostList** | 게시물 목록(제목/작성일 등) | /match/[id] 하단 |
| **PostForm** | 게시물 작성(제목/본문/닉네임) + 쿨다운 안내 | /match/[id] |
| **PostDetail** | 게시물 본문 표시 | /posts/[postId] 상단 |
| **PostCommentList** | 게시물 댓글 목록 | /posts/[postId] |
| **PostCommentForm** | 게시물 댓글 작성(5~500자) + 쿨다운 | /posts/[postId] |
| **ReportButton** | 신고(후순위) | P1 |
| **BlindedNotice** | 블라인드 안내(후순위) | P1 |
| **AnonIdProvider(or hook)** | anon_id 생성/저장/제공 | 전역 |

---

## 4. 구현 순서(MVP 최소 관통 플로우)

1. DB·Supabase: 테이블/정책 적용 + 시드 데이터 insert
2. anon_id: UUID 생성 후 localStorage + cookie 저장
3. 메인: 매치업 목록 조회/표시 → /match/[id] 이동
4. 매치업: 매치업/아이템 조회 → 투표 → 결과 표시
5. 매치업: 게시물 목록 조회 + 게시물 작성(insert)
6. 게시물 상세: 게시물 조회 + 댓글 목록/작성(insert)
7. SEO 메타: 메인/매치업/게시물 상세에 title/description 설정
8. 반응형: 모바일/데스크톱 레이아웃 점검

---

## 5. SEO 메타(최소)

| 라우트 | title 제안 | description 제안 |
|--------|------------|------------------|
| `/` | 픽콜 — 대결 투표 커뮤니티 | 매치업에 투표하고 게시물을 작성해 보세요. |
| `/match/[id]` | {매치업 제목} — 픽콜 | 투표하고 관련 게시물을 확인/작성해 보세요. |
| `/match/[id]/posts/[postId]` | {게시물 제목} — {매치업 제목} | 게시물 상세와 댓글 |

