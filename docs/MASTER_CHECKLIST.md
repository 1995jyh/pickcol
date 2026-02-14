# MASTER CHECKLIST — 픽콜(가칭)

> 원칙: 이 문서가 “프로젝트 진행의 기준”입니다.
> 매 작업 후: (1) 체크박스 업데이트 → (2) git commit → (3) git push

## 0) 현재 상태 요약
- [x] 서브에이전트/커맨드 세팅 + /pipeline 실행
- [x] PRD/DB/UI/SEO/STATUS 문서 생성
- [x] Supabase 테이블 생성 + 시드 데이터 1세트 삽입
- [x] GitHub 공개 레포에 docs/.cursor 업로드

---

## 1) 기획 확정(PRD)
- [ ] 결정사항(DECISIONS) 최종 확정(anon_id, 중복투표, 댓글, 신고, 블라인드)
- [ ] MVP 포함/제외 최종 확정(특히 /match/new)
- [ ] 완료정의(DoD) 확정

---

## 2) DB(Supabase)
- [x] 테이블 생성(matchups, matchup_items, votes, comments, reports)
- [x] 인덱스 생성
- [ ] 투표 데이터 꼬임 방지(복합 FK) 적용 확인
- [ ] RLS 전략 확정(개발용 fast → 공개운영용 safe 전환 계획)

---

## 3) UI/라우트(Next.js 설계)
- [ ] /app 라우트 트리 확정
- [ ] 핵심 컴포넌트 리스트 확정
- [ ] 상태/예외 처리(loading/error/empty/blinded) 설계 확정

---

+## 4) Figma(최소 3페이지)
+- [ ] 메인 페이지(홈) 와이어프레임
+- [ ] 콘텐츠별 매치업 페이지 와이어프레임 (상단: 매치업/투표, 하단: 게시물 목록 포함)
+- [ ] 게시물 상세 페이지 와이어프레임
+
+> 참고: 블라인드/삭제 안내 화면은 후순위(Next)로 이동

---

## 5) 개발(구현)
### 5-1) 프로젝트 세팅
- [ ] Next.js(App Router + TS) 프로젝트 생성
- [ ] ESLint/Prettier 기본 적용
- [ ] Supabase env 연결(.env.local, 절대 커밋 금지)

### 5-2) MVP 관통 플로우
- [ ] 홈: 매치업 목록 조회 + 카드 UI
- [ ] 상세: 좌/우 항목 표시
- [ ] 상세: 투표(insert) + 결과 표시
- [ ] 상세: 댓글 조회/작성
- [ ] 상세: 신고(insert)
- [ ] 블라인드 처리(최소 동작)

### 5-3) QA
- [ ] 핵심 플로우 회귀 체크 1회
- [ ] 스팸 최소 방어(쿨다운/레이트리밋 중 하나)

---

## 6) 배포/SEO(후순위)
- [ ] Cloudtype 배포
- [ ] robots/sitemap
- [ ] Search Console 연결
- [ ] AdSense(Next)
