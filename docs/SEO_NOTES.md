# SEO·수익화 — 픽콜(가칭) MVP

MVP에서 반드시 할 SEO 최소 세트와 페이지별 메타 템플릿. 검색 유입 가능한 페이지 위주.

---

## 1. MVP SEO 필수 체크리스트

### 필수

| 항목 | 내용 |
|------|------|
| 홈 메타 | `<title>`, `<meta name="description">` 설정. 공유 시 og:title, og:description 동일 적용. |
| 상세 메타 | 매치업별 동적 title/description(제목 기반). |
| 블라인드 noindex | 블라인드된 매치업 URL 접근 시 `<meta name="robots" content="noindex, nofollow">` 적용. |
| 시맨틱 HTML | h1은 페이지당 1개(홈: 사이트명 또는 대표 문구, 상세: 매치업 제목). 목록은 ul/li 또는 article. |
| 정상 URL | 홈 `/`, 상세 `/match/[id]`. 대소문자·trailing slash 정책 일관. |

### 권장

| 항목 | 내용 |
|------|------|
| canonical | 홈·상세에 canonical URL 지정(중복 수집 완화). |
| 모바일 대응 | viewport 메타, 반응형으로 크롤러가 모바일 친화성 인식. |
| OG 이미지 | 공통 og:image 1장이라도 두면 공유 시 미리보기 개선. |

### Next(미적용)

- 자동 생성 태그/카테고리 페이지, 사이트맵 자동화, 고급 JSON-LD, AdSense 삽입.

---

## 2. 페이지별 메타 템플릿

| 페이지 | title | description | robots |
|--------|--------|-------------|--------|
| **홈** `/` | `{사이트명} — 대결 투표 커뮤니티` | `좌우 대결에 투표하고 댓글을 남겨보세요. {사이트명}.` | index, follow |
| **매치업 상세** `/match/[id]` | `{매치업 제목} — {사이트명}` | `{매치업 제목} 좌우 대결, 투표해 보세요.` | index, follow |
| **블라인드 안내** `/match/[id]` (blinded) | `콘텐츠 안내 — {사이트명}` | `해당 콘텐츠는 안내에 따라 비공개 처리되었습니다.` | noindex, nofollow |
| **404** | `페이지를 찾을 수 없습니다 — {사이트명}` | (선택) | noindex 권장 |

- **OG**: 위 title/description을 `og:title`, `og:description`에 동일 적용. `og:type`: website. `og:url`: 해당 페이지 절대 URL.

---

## 3. 구조화 데이터(JSON-LD) 적용 여부

| 유형 | MVP 적용 | 비고 |
|------|----------|------|
| WebSite | 권장(홈) | 사이트명, url, description. 검색 결과 보강에 도움. |
| ItemList | 선택 | 홈 매치업 목록을 ItemList로 둘 수 있음. Next에서 고려. |
| SingleAnswerPoll / Article | 선택 | 매치업 상세를 투표형 콘텐츠로 표현 가능. MVP는 생략 가능. |

**WebSite 초안(홈용)**:

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "{사이트명}",
  "url": "{홈 URL}",
  "description": "좌우 대결에 투표하고 댓글을 남겨보세요."
}
```

---

## 4. 인덱싱 제외(noindex) 페이지

| 페이지 | 사유 |
|--------|------|
| 블라인드된 매치업 상세 | 신고에 따른 비공개 처리. 안내문 + noindex. |
| 404 | 찾을 수 없음. noindex 권장. |

- `/match/new`(매치업 생성)는 Next 단계에서 추가 시 noindex 적용 권장.

---

## 5. 수익화(AdSense) — Next

- MVP에서는 미적용. Next에서 AdSense 삽입 시 정책 준수(클릭 유도 금지, 콘텐츠 정책 등).

---

**관련 문서**: [PRD_MVP.md](./PRD_MVP.md) · [ROUTES_UI.md](./ROUTES_UI.md)

이 문서는 seo-monetization에 의해 작성·갱신되었으며, AGENTS.md 규칙을 따른다.
