# PRD — 픽콜(가칭) MVP

## 1. MVP 목표 5줄 요약

| 구분 | 내용 |
|------|------|
| **대상** | 대결(이상형 월드컵 스타일) 콘텐츠를 즐기는 일반 사용자. 비로그인 참여 가능. |
| **핵심 루프** | 매치업 목록 보기 → 상세에서 좌/우 중 선택 투표 → 댓글 작성/열람 → 재방문·공유. |
| **가치** | 짧은 시간에 투표·댓글로 참여감을 주고, SEO 유입 페이지를 최소로 확보. |
| **수익** | MVP 단계에서는 수익화 미적용. AdSense 등은 Next 단계에서 도입. |
| **제약** | 2~3주 내 구현 가능 범위로 한정. 회원가입·관리자 대시보드는 Next. |

---

## 2. 결정사항(DECISIONS)

| 항목 | 결정 내용 |
|------|------------|
| **익명 식별** | `anon_id`(UUID)를 클라이언트에서 1회 생성 후 **localStorage + cookie**에 저장. 투표·댓글·신고 시 동일 값으로 식별. |
| **투표** | 매치업당 **anon_id 1회만** 투표 가능. 제출 후 **변경 불가**. DB에 unique(anon_id, matchup_id) 등으로 보장. |
| **댓글** | 본문 **5~500자**. **10초 쿨다운**(동일 anon_id 기준). 닉네임 없으면 표시명 **'익명'**. |
| **신고 사유** | **SPAM** / **HATE** / **NSFW** / **ILLEGAL** / **OTHER** 5종만 허용. |
| **블라인드** | **서로 다른 anon_id** 기준 신고 **5건 이상**이면 해당 매치업 blinded 처리. 블라인드된 매치업 URL 직접 접근 시 **안내문 + noindex**. |
| **매치업 생성** | **MVP에서 제외**(Next로 이동). MVP는 **시드 데이터**로만 매치업을 채워 시작. |

---

## 3. MVP 기능 목록

- **Phase**: `MVP` = 2~3주 내 구현, `Next` = 이후 단계.
- 코드/DB 식별자는 영어, 설명은 한국어.

| 우선순위 | Phase | 화면 | 기능 | 데이터(Supabase) | 권한 | 수용기준(AC) |
|----------|--------|------|------|------------------|------|--------------|
| P0 | MVP | 전역 | 익명 식별(anon_id) | — | 클라이언트 | UUID 생성 후 localStorage + cookie에 저장하고, 투표/댓글/신고 시 동일 anon_id로 식별된다. |
| P0 | MVP | 홈 | 매치업 목록 노출(카드 형태, 최신순) | `matchups` 조회, 페이지네이션, blinded 제외 | 공개 읽기 | 최신 매치업이 카드로 보이고, 클릭 시 상세로 이동한다. 블라인드된 항목은 목록에 안 보인다. |
| P0 | MVP | 매치업 상세 | 좌/우 항목 표시(텍스트+이미지 URL) | `matchups`, `matchup_items` 조회 | 공개 읽기 | 상세 페이지에서 좌/우 2개 항목이 명확히 구분되어 보인다. |
| P0 | MVP | 매치업 상세 | 투표하기(좌/우 중 1개 선택, 1회만) | `votes` insert(anon_id, matchup_id, item_id), 집계 반영 | anon_id 1회/매치업 | 동일 anon_id로 해당 매치업에 1회만 투표 가능하며, 제출 후 변경 불가. 투표 시 결과가 갱신되어 보인다. |
| P0 | MVP | 매치업 상세 | 투표 결과 표시(비율 또는 득표수) | `votes` 집계 | 공개 읽기 | 상세 진입 시 또는 투표 후 좌/우 각각 득표 수 또는 비율이 표시된다. |
| P0 | MVP | 매치업 상세 | 댓글 목록 조회 | `comments` 조회, 정렬(최신순) | 공개 읽기 | 해당 매치업의 댓글이 목록으로 보인다. |
| P0 | MVP | 매치업 상세 | 댓글 작성(5~500자, 쿨다운, 닉네임) | `comments` insert(anon_id, body, nickname) | 익명 | 5~500자만 허용. 닉네임 없으면 표시명 '익명'. 동일 anon_id 기준 10초 쿨다운 후 재등록 가능. 등록 시 목록에 반영된다. |
| P1 | MVP | 매치업 상세 | 신고하기(사유: SPAM/HATE/NSFW/ILLEGAL/OTHER) | `reports` insert(anon_id, matchup_id, reason) | 익명 | 신고 버튼 클릭 시 사유 5종(SPAM, HATE, NSFW, ILLEGAL, OTHER) 중 선택 후 제출 가능하다. |
| P1 | MVP | 전역 | 블라인드 처리(서로 다른 anon_id 5건 이상) | `matchups.blinded_at`, `reports` distinct anon_id 카운트 | RLS/서버 | 서로 다른 anon_id로 신고 5건 이상이면 해당 매치업을 blinded 처리. 목록/상세에서 제외. |
| P1 | MVP | 매치업 상세(블라인드) | 블라인드 안내 페이지 | — | — | 블라인드된 매치업 URL 직접 접근 시 안내문 표시 + 메타 noindex. |
| P1 | MVP | 홈/상세 | 반응형 레이아웃 | — | — | 모바일·데스크톱에서 레이아웃이 깨지지 않고 사용 가능하다. |
| P2 | MVP | — | 시드 데이터 | `matchups`, `matchup_items` 시드 | — | MVP는 매치업 생성 없이 시드 데이터로 시작. 목록/상세가 시드로 동작한다. |
| P2 | MVP | 홈/상세 | SEO 메타(타이틀, 설명) | — | — | 홈·매치업 상세 페이지에 고유한 `<title>`, `description` 메타가 설정되어 검색/공유 시 노출된다. 블라인드 페이지는 noindex. |
| P2 | MVP | — | DB·RLS 최소 설계 | `matchups`, `matchup_items`, `votes`, `comments`, `reports` 테이블 + RLS, votes unique(anon_id, matchup_id) | 읽기 공개, 쓰기 정책 최소 | Supabase Seoul 리전에 테이블 생성, 공개 읽기·anon_id 기반 쓰기 제한 정책 동작. |
| — | Next | — | 매치업 생성(폼) | `matchups`, `matchup_items` insert | — | MVP 이후. |
| — | Next | — | 로그인/회원가입 | `profiles`, auth | — | MVP 이후. |
| — | Next | — | 좋아요·정렬/필터(인기순 등) | — | — | MVP 이후. |
| — | Next | — | 관리자 신고 처리·블라인드 해제 | — | 관리자 | MVP 이후. |
| — | Next | — | AdSense 삽입·수익화 | — | — | MVP 이후. |
| — | Next | — | PWA·오프라인 캐시 | — | — | MVP 이후. |

---

## 4. 페이지/라우트 맵

| 라우트 | 목적 | 주요 컴포넌트 | SEO 메타 포인트 |
|--------|------|----------------|-----------------|
| `/` | 매치업 목록(홈) | `MatchupCard` 리스트, 페이지네이션 | 사이트명·한 줄 설명, `og:title`/`og:description` |
| `/match/[id]` | 매치업 상세(투표+댓글+신고) | 좌/우 항목, 투표 버튼, 결과 영역, `CommentList`/`CommentForm`, 신고 버튼 | 매치업 제목·요약을 `title`/`description`에 반영 |
| `/match/[id]` (blinded) | 블라인드 안내 | 안내문, 홈 링크 | `noindex` |

- 신고 UI는 상세 페이지 내 모달 또는 인라인 폼으로 처리(별도 라우트 없음).
- 블라인드된 매치업은 목록에서 제외. URL 직접 접근 시 블라인드 안내 페이지 + noindex.
- 매치업 생성(`/match/new`)은 Next 단계에서 도입.

---

## 5. 상태/예외 처리

| 상황 | 처리 방식 | 사용자 노출 |
|------|------------|-------------|
| anon_id 없음(첫 방문) | 클라이언트에서 UUID 생성 후 localStorage + cookie 저장 | — |
| 이미 투표한 매치업 재투표 시도 | 서버/DB에서 duplicate 무시 또는 409 반환 | "이미 투표했습니다" 등 문구, 투표 버튼 비활성 또는 결과만 표시 |
| 댓글 5자 미만 / 500자 초과 | 서버 검증 실패 시 400 | "5~500자로 입력해 주세요" |
| 댓글 10초 쿨다운 미만 재등록 | 서버에서 거부(429 또는 400) | "잠시 후 다시 시도해 주세요" 등 + 남은 초 표시 가능 |
| 블라인드된 매치업 상세 접근 | blinded 플래그로 판별 후 안내 페이지 렌더 | 안내문 + noindex, 홈으로 가기 링크 |
| 매치업/항목 없음(잘못된 id) | 404 | 404 페이지 또는 "찾을 수 없습니다" |
| API/DB 일시 오류 | 재시도 또는 에러 바운더리 | "일시적인 오류입니다. 잠시 후 다시 시도해 주세요." |

---

## 6. 입력 검증(Validation)

| 대상 | 규칙 | 클라이언트 | 서버 |
|------|------|------------|------|
| anon_id | UUID v4 형식 | 생성 시 검증, 저장 전 확인 | reports/votes/comments insert 시 형식 검증(선택) |
| 투표 | matchup_id, item_id 존재, anon_id당 1회 | 이미 투표 시 버튼 비활성 | unique(anon_id, matchup_id), FK 검증 |
| 댓글 body | 5~500자(공백만 X) | 길이·trim 체크 | 길이·trim, 필수 |
| 댓글 nickname | 0~50자, 없으면 '익명' 저장 | 선택 입력 | 없으면 '익명'으로 저장 |
| 신고 reason | enum: SPAM, HATE, NSFW, ILLEGAL, OTHER | 드롭다운만 허용 | enum/allowlist 검증 |
| 신고 | 동일 anon_id 동일 매치업 중복 신고 | 1회만 제출 가능하도록 UI | unique(anon_id, matchup_id) 또는 1회만 허용 정책 |

---

## 7. 이벤트/로그

| 이벤트 | 시점 | 로그/저장 위치 | 비고 |
|--------|------|----------------|------|
| anon_id 생성 | 최초 방문(저장소에 없을 때) | localStorage + cookie | 서버 전송 없음 |
| 투표 | 사용자가 좌/우 선택 후 제출 | `votes` 테이블(anon_id, matchup_id, item_id) | 집계용 |
| 댓글 작성 | 폼 제출 성공 시 | `comments` 테이블 | anon_id, body, nickname, matchup_id |
| 신고 제출 | 사유 선택 후 제출 | `reports` 테이블(anon_id, matchup_id, reason) | 블라인드 판단용 distinct anon_id 카운트 |
| 블라인드 처리 | 서로 다른 anon_id 신고 5건 도달 시 | `matchups.blinded_at` 갱신 | 트리거 또는 주기적 배치 중 택1 |

---

## 8. MVP 범위 요약

- **포함**: 익명 식별(anon_id), 매치업 목록/상세(시드 데이터), 투표(1회/매치업)·집계, 댓글(5~500자, 10초 쿨, 익명), 신고(5종 사유)·블라인드(서로 다른 anon_id 5건), 블라인드 안내 페이지+noindex, 반응형, SEO 메타, Supabase 테이블·RLS.
- **제외(Next)**: 매치업 생성, 로그인, 관리자 대시보드, 좋아요·고급 정렬, AdSense, PWA 오프라인.

---

## 9. MVP 완료 정의(DoD)

- [ ] **anon_id**: UUID 생성 후 localStorage + cookie 저장되고, 모든 참여 기능에서 동일 값이 전달된다.
- [ ] **목록/상세**: 시드 데이터 기준 매치업 목록(카드)과 상세(좌/우 항목)가 정상 노출된다.
- [ ] **투표**: 매치업당 anon_id 1회만 투표 가능하고, 제출 후 변경 불가·결과가 즉시 반영된다.
- [ ] **댓글**: 5~500자, 10초 쿨다운, 닉네임 없으면 '익명'으로 표시·저장된다.
- [ ] **신고**: SPAM/HATE/NSFW/ILLEGAL/OTHER 중 선택 제출 가능하고, 서로 다른 anon_id 5건 이상 시 블라인드 처리된다.
- [ ] **블라인드**: 블라인드된 매치업은 목록에 안 보이고, URL 직접 접근 시 안내문 + noindex가 적용된다.
- [ ] **검증**: 댓글 길이·쿨다운·투표 1회 제한이 서버(또는 DB 제약)에서 동작한다.
- [ ] **반응형**: 모바일·데스크톱에서 레이아웃이 깨지지 않는다.
- [ ] **SEO**: 홈·상세 페이지에 고유 title/description이 설정되어 있다.
- [ ] **DB·RLS**: Supabase 테이블(votes unique 포함)과 RLS 정책이 배포되어 읽기/쓰기가 의도대로 동작한다.

---

**관련 문서**: [DB_SCHEMA.md](./DB_SCHEMA.md) · [ROUTES_UI.md](./ROUTES_UI.md) · [SEO_NOTES.md](./SEO_NOTES.md) · [STATUS.md](./STATUS.md)

이 문서는 pm-planner에 의해 작성·갱신되었으며, 구현 시 AGENTS.md 및 `/docs` 규칙을 따른다.
