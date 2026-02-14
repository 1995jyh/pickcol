# 개발 체크리스트 — 픽콜 MVP

> 이 문서는 “무엇을 언제까지 해야 하는지”를 단계별로 정리한 마스터 체크리스트입니다.
> 매 대화마다 STATUS.md의 ‘다음 액션’이 여기 체크리스트와 연결되도록 운영합니다.

---

## 0. 이미 완료된 것(현 시점)
- [x] GitHub 레포 생성/연결
- [x] docs 문서 정리 및 푸시(PRD/ROUTES 등 일부)
- [x] Supabase 프로젝트 생성

---

## 1. 디자인(Figma) — 먼저 진행 ✅
### 1.1 파일/구조
- [ ] Figma 파일 생성: `Pickcol_MVP`
- [ ] Pages 구성: `01_Wireframe`, `02_Components`, `03_Handoff`

### 1.2 3페이지(데스크톱/모바일)
- [ ] 메인(`/`) 데스크톱 프레임
- [ ] 메인(`/`) 모바일 프레임
- [ ] 매치업(`/match/[id]`) 데스크톱 프레임 (투표 + 게시물 목록/작성)
- [ ] 매치업(`/match/[id]`) 모바일 프레임
- [ ] 게시물(`/match/[id]/posts/[postId]`) 데스크톱 프레임
- [ ] 게시물(`/match/[id]/posts/[postId]`) 모바일 프레임

### 1.3 공통 컴포넌트(최소)
- [ ] Button(Primary/Secondary/Disabled)
- [ ] Input / Textarea
- [ ] Card(매치업 카드)
- [ ] VoteBlock(좌/우 + 결과)
- [ ] PostListItem
- [ ] CommentBlock

### 1.4 상태(최소 3종)
- [ ] Loading(스켈레톤 또는 로딩)
- [ ] Empty(게시물/댓글 없음)
- [ ] Error(간단 안내)

---

## 2. 문서 동기화(디자인 확정 후)
- [ ] PRD/ROUTES/UI 문서가 “3페이지 + 게시물 구조”로 일치하는지 확인
- [ ] STATUS.md(진행/DoD)가 현재 구조로 업데이트

---

## 3. DB(Supabase)
- [ ] matchups/matchup_items/votes/reports 테이블 및 정책 확인
- [ ] posts/post_comments 테이블 생성
- [ ] RLS 정책(B안): 읽기 공개 + 익명 쓰기 최소 허용
- [ ] 시드 데이터 삽입(매치업 3~5개)

---

## 4. 프론트엔드(Next.js)
- [ ] Next.js 프로젝트 생성 + env 설정
- [ ] 라우팅 3개 페이지 구성
- [ ] 메인: 매치업 목록 조회
- [ ] 매치업: 투표/결과 + 게시물 목록/작성
- [ ] 게시물 상세: 댓글 목록/작성

---

## 5. QA(체크)
- [ ] DoD 10개 항목 전부 검증
- [ ] 모바일/데스크톱 레이아웃 점검
- [ ] 기본 SEO(title/description) 확인

---

## 6. 배포
- [ ] 배포(예: Vercel)
- [ ] 환경변수 설정
- [ ] 기본 도메인/OG 확인
