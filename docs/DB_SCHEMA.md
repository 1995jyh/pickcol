# DB 스키마 — 픽콜(가칭) MVP

PRD_MVP(§3 기능 목록, §6 입력 검증) 기반 Supabase(Postgres, Seoul) 스키마·RLS 초안. 익명 사용자는 `anon_id`(UUID)로 식별한다.

---

## 1. 테이블 목록 및 관계 요약

| 테이블 | 역할 | 관계 |
|--------|------|------|
| `matchups` | 매치업 1건(제목, 블라인드 시각) | 1:N → `matchup_items`, `votes`, `comments`, `reports` |
| `matchup_items` | 매치업당 좌/우 2개 항목(라벨, 이미지 URL) | N:1 → `matchups`, 1:N → `votes` |
| `votes` | 투표 1건(anon_id당 매치업당 1회) | N:1 → `matchups`, N:1 → `matchup_items` |
| `comments` | 댓글(anon_id, 본문 5~500자, 닉네임) | N:1 → `matchups` |
| `reports` | 신고(anon_id당 매치업당 1회, 사유 5종) | N:1 → `matchups` |

- **총 5개 테이블.** 확장 시 `profiles`, `matchup_created_by` 등 추가 가능.

---

## 2. 테이블 정의

### 2.1 matchups

| 컬럼 | 타입 | PK | FK | 제약/기본값 | 비고 |
|------|------|----|----|-------------|------|
| id | uuid | ✓ | — | default gen_random_uuid() | |
| title | text | | | not null | 매치업 제목 |
| blinded_at | timestamptz | | | null | 서로 다른 anon_id 신고 5건 도달 시 설정 |
| created_at | timestamptz | | | default now(), not null | |
| updated_at | timestamptz | | | default now(), not null | |

- **인덱스**: `created_at DESC` (목록 최신순), `(blinded_at)` where blinded_at is null (목록에서 비블라인드만 조회 시).

### 2.2 matchup_items

| 컬럼 | 타입 | PK | FK | 제약/기본값 | 비고 |
|------|------|----|----|-------------|------|
| id | uuid | ✓ | — | default gen_random_uuid() | |
| matchup_id | uuid | | matchups(id) on delete cascade | not null | |
| position | text | | | not null, check (position in ('left','right')) | 좌/우 구분 |
| label | text | | | not null | 항목 텍스트 |
| image_url | text | | | null | |
| created_at | timestamptz | | | default now(), not null | |

- **유니크**: (matchup_id, position) — 매치업당 left/right 각 1개.
- **유니크(추가)**: (id, matchup_id) — votes가 (item_id, matchup_id)로 참조할 수 있게 DB가 보장.
- **인덱스**: matchup_id (FK·조인용).

### 2.3 votes

| 컬럼 | 타입 | PK | FK | 제약/기본값 | 비고 |
|------|------|----|----|-------------|------|
| id | uuid | ✓ | — | default gen_random_uuid() | |
| anon_id | uuid | | — | not null | 클라이언트에서 전달 |
| matchup_id | uuid | | matchups(id) on delete cascade | not null | |
| item_id | uuid | | matchup_items(id) on delete cascade | not null | |
| created_at | timestamptz | | | default now(), not null | |

- **유니크**: (anon_id, matchup_id) — 매치업당 anon_id 1회만 투표.
- **FK(추가)**: (item_id, matchup_id) → matchup_items(id, matchup_id)
- **인덱스**: (matchup_id, item_id) — 항목별 득표 집계용.
- **비고**: DB가 item_id의 matchup 소속을 강제하므로 앱 검증 부담이 줄어듦.

### 2.4 comments

| 컬럼 | 타입 | PK | FK | 제약/기본값 | 비고 |
|------|------|----|----|-------------|------|
| id | uuid | ✓ | — | default gen_random_uuid() | |
| matchup_id | uuid | | matchups(id) on delete cascade | not null | |
| anon_id | uuid | | — | not null | |
| body | text | | | not null, check (length(trim(body)) between 5 and 500) | 5~500자 |
| nickname | text | | | not null default '익명', check (length(nickname) <= 50) | 없으면 '익명' |
| created_at | timestamptz | | | default now(), not null | 10초 쿨다운은 앱에서 검증 |

- **인덱스**: (matchup_id, created_at DESC) — 상세 페이지 댓글 목록.

### 2.5 reports

| 컬럼 | 타입 | PK | FK | 제약/기본값 | 비고 |
|------|------|----|----|-------------|------|
| id | uuid | ✓ | — | default gen_random_uuid() | |
| anon_id | uuid | | — | not null | |
| matchup_id | uuid | | matchups(id) on delete cascade | not null | |
| reason | text | | | not null, check (reason in ('SPAM','HATE','NSFW','ILLEGAL','OTHER')) | 5종만 |
| created_at | timestamptz | | | default now(), not null | |

- **유니크**: (anon_id, matchup_id) — 매치업당 anon_id 1회만 신고.
- **인덱스**: (matchup_id) — 블라인드 판단 시 distinct anon_id 카운트용.

---

## 3. 핵심 제약조건 요약

| 구분 | 내용 |
|------|------|
| 중복 투표 방지 | `votes` 테이블 unique(anon_id, matchup_id). |
| 투표 item 소속 보장 | `votes`의 (item_id, matchup_id) FK로 "해당 매치업의 항목에만 투표" 강제. |
| 중복 신고 방지 | `reports` 테이블 unique(anon_id, matchup_id). |
| 댓글 길이 | `comments.body` check: trim 후 5~500자. |
| 댓글 닉네임 | `comments.nickname` default '익명', length ≤ 50. |
| 신고 사유 | `reports.reason` check: SPAM, HATE, NSFW, ILLEGAL, OTHER만 허용. |
| 항목 개수 | `matchup_items` unique(matchup_id, position) → 매치업당 left/right 각 1개. |
| 블라인드 | `matchups.blinded_at` 설정은 트리거 또는 백엔드에서 “서로 다른 anon_id 신고 5건” 조건으로 수행. |

---

## 4. RLS 정책

- Supabase 기본: **RLS 활성화**, 정책 없으면 접근 거부.
- MVP는 **익명 참여**만 가정; `auth.uid()` 없이 `anon_id`를 요청 본문으로 전달.

| 테이블 | SELECT | INSERT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| matchups | 허용(전체). 목록용 조회는 앱에서 blinded_at is null 필터. | 거부(시드/Next에서만) | 거부(블라인드 처리만 서버/트리거) | 거부 |
| matchup_items | 허용(전체) | 거부 | 거부 | 거부 |
| votes | 허용(전체. 집계·이미 투표 여부 확인용) | 허용(anon_id는 body로 전달) | 거부 | 거부 |
| comments | 허용(전체) | 허용(anon_id, body, nickname 등 body로 전달) | 거부 | 거부 |
| reports | 거부(클라이언트는 읽지 않음. 관리자/Next에서만) | 허용(anon_id, matchup_id, reason) | 거부 | 거부 |

- **정책 표현 예시**  
  - `matchups` SELECT: `true`.  
  - `votes` INSERT: `true` (중복은 unique 제약으로 방지).  
  - `comments` INSERT: `true`.  
  - `reports` SELECT: `false` 또는 정책 없음. INSERT: `true`.

---

## 5. 블라인드 처리(서로 다른 anon_id 5건)

- **조건**: 동일 `matchup_id`에 대해 **서로 다른** `anon_id`로 신고가 5건 이상이면 해당 매치업을 블라인드.
- **구현 옵션**  
  1. **트리거**: `reports` INSERT 후, 해당 `matchup_id`에 대해 `count(distinct anon_id) >= 5`이면 `matchups.blinded_at = now()` 갱신. (트리거는 `SECURITY DEFINER`로 두어 RLS 우회.)  
  2. **백엔드(Edge Function/API)**: 주기적 또는 신고 제출 시 위 조건 체크 후 `matchups` 업데이트.
- 블라인드된 행은 목록 조회 시 `where blinded_at is null`로 제외. 상세 URL 직접 접근 시 앱에서 안내문 + noindex 처리.

---

## 6. 마이그레이션·시드

- 테이블 생성 순서: `matchups` → `matchup_items` → `votes`, `comments`, `reports`.
- MVP 기간에는 매치업 생성 UI 없이 **시드 데이터**만 `matchups`, `matchup_items`에 insert.
- Supabase Seoul 리전에 적용, 필요 시 `docs/` 또는 리포지터리 내 SQL 파일로 마이그레이션 보관.

---

**관련 문서**: [PRD_MVP.md](./PRD_MVP.md) · [ROUTES_UI.md](./ROUTES_UI.md)

이 문서는 data-architect에 의해 PRD_MVP 기반으로 작성·갱신되었으며, AGENTS.md 규칙을 따른다.
