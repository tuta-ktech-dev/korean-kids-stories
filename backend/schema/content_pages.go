package schema

import (
	"log"

	"github.com/pocketbase/pocketbase/core"
)

// defaultContentPages defines Privacy Policy and Terms of Service to seed (Korean)
var defaultContentPages = []struct {
	slug    string
	title   string
	content string
	locale  string
}{
	{
		slug:   "privacy",
		title:  "개인정보 처리방침",
		locale: "ko",
		content: `<h2>1. 개인정보의 수집 및 이용 목적</h2>
<p>꼬마 한동화(이하 "앱")는 다음과 같은 목적으로 개인정보를 수집·이용합니다.</p>
<ul>
<li>회원 가입 및 관리: 본인 식별, 서비스 이용 계약 이행</li>
<li>콘텐츠 서비스 제공: 독서 진행 상황, 즐겨찾기, 메모 등 저장</li>
<li>맞춤형 서비스: 관심 분야 기반 추천, 개인화된 경험 제공</li>
<li>고객 지원: 문의 및 신고 접수·처리</li>
</ul>

<h2>2. 수집하는 개인정보 항목</h2>
<p>앱은 서비스 이용 시 아래 정보를 수집할 수 있습니다.</p>
<ul>
<li>필수: 이메일, 비밀번호(암호화 저장), 닉네임</li>
<li>선택: 프로필 사진, OAuth 제공자 정보(소셜 로그인 시)</li>
<li>자동 수집: 기기 정보, 이용 로그, IP 주소(서비스 운영 목적)</li>
</ul>

<h2>3. 개인정보의 보유 및 이용 기간</h2>
<p>회원 탈퇴 시 또는 수집 목적 달성 후 지체 없이 파기합니다. 단, 관계 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관합니다.</p>

<h2>4. 개인정보의 제3자 제공</h2>
<p>앱은 이용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 법령에 의한 경우 예외로 합니다.</p>

<h2>5. 아동 개인정보 보호</h2>
<p>본 앱은 만 14세 미만 아동의 개인정보를 별도로 수집하지 않으며, 가입 시 연령 확인 절차를 진행합니다.</p>

<h2>6. 개인정보 보호 책임자</h2>
<p>개인정보 관련 문의: 앱 내 설정 > 문의하기 또는 이메일을 통해 연락 가능합니다.</p>

<h2>7. 시행일</h2>
<p>본 개인정보 처리방침은 2025년 1월 1일부터 시행됩니다.</p>`,
	},
	{
		slug:   "terms",
		title:  "이용약관",
		locale: "ko",
		content: `<h2>제1조 (목적)</h2>
<p>본 약관은 꼬마 한동화(이하 "서비스")의 이용 조건 및 절차, 이용자와 운영자 간의 권리·의무를 규정합니다.</p>

<h2>제2조 (정의)</h2>
<ul>
<li>"서비스": 한동화, 역사 이야기 등 아동용 스토리 콘텐츠 제공 앱</li>
<li>"이용자": 서비스에 접속하여 약관에 따라 이용하는 자</li>
<li>"콘텐츠": 스토리, 챕터, 이미지, 오디오 등 서비스 내 모든 자료</li>
</ul>

<h2>제3조 (약관의 효력)</h2>
<p>약관은 서비스 화면에 게시하거나 기타의 방법으로 공지하며, 이용자가 회원가입을 완료한 시점부터 효력이 발생합니다.</p>

<h2>제4조 (서비스의 제공)</h2>
<p>서비스는 무료·유료 콘텐츠를 제공할 수 있으며, 일부 기능은 회원가입 후 이용 가능합니다.</p>

<h2>제5조 (이용자의 의무)</h2>
<p>이용자는 다음 행위를 해서는 안 됩니다.</p>
<ul>
<li>타인의 정보 도용 및 부정 사용</li>
<li>저작권 등 지식재산권 침해</li>
<li>서비스 운영 방해, 시스템 해킹 시도</li>
<li>법령 및 공서양속에 위반되는 행위</li>
</ul>

<h2>제6조 (서비스 이용 제한)</h2>
<p>운영자는 약관 위반 시 사전 통지 후 서비스 이용을 제한하거나 회원 자격을 상실시킬 수 있습니다.</p>

<h2>제7조 (면책)</h2>
<p>운영자는 천재지변, 기술적 장애 등 불가항력으로 인한 서비스 중단에 대해 책임을 지지 않습니다.</p>

<h2>제8조 (분쟁 해결)</h2>
<p>서비스와 관련된 분쟁은 대한민국 법을 적용하며, 관할 법원은 민사소송법에 따릅니다.</p>

<h2>제9조 (시행일)</h2>
<p>본 약관은 2025년 1월 1일부터 시행됩니다.</p>`,
	},
}

// SeedContentPages creates default Privacy Policy and Terms if they don't exist
func SeedContentPages(app core.App) {
	col, err := app.FindCollectionByNameOrId("content_pages")
	if err != nil {
		return
	}

	for _, d := range defaultContentPages {
		filter := `slug="` + escapeFilter(d.slug) + `" && locale="` + escapeFilter(d.locale) + `"`
		existing, err := app.FindRecordsByFilter(col.Id, filter, "", 1, 0)
		if err != nil || len(existing) > 0 {
			continue
		}
		rec := core.NewRecord(col)
		rec.Set("slug", d.slug)
		rec.Set("title", d.title)
		rec.Set("content", d.content)
		rec.Set("locale", d.locale)
		rec.Set("active", true)
		if err := app.Save(rec); err != nil {
			log.Printf("content_pages: seed %s(%s) failed: %v", d.slug, d.locale, err)
		} else {
			log.Printf("content_pages: seeded %s (%s)", d.slug, d.locale)
		}
	}
}

// EnsureContentPagesCollection ensures the content_pages collection exists
// Used for Privacy Policy, Terms of Service, etc. - editable in admin
func EnsureContentPagesCollection(app core.App) {
	collection, err := app.FindCollectionByNameOrId("content_pages")
	if err != nil {
		collection = core.NewBaseCollection("content_pages")
	}

	changes := false
	// Public read. Only admin can create/update/delete (admin bypasses rules).
	if SetRules(collection, "", "", LockRule, LockRule, LockRule) {
		changes = true
	}

	// slug: privacy, terms, about, faq, ...
	if AddTextField(collection, "slug", true) {
		changes = true
	}
	if AddTextField(collection, "title", true) {
		changes = true
	}
	if f := collection.Fields.GetByName("content"); f == nil {
		collection.Fields.Add(&core.EditorField{
			Name:     "content",
			Required: false,
		})
		changes = true
	}
	// locale for i18n (optional: ko, en, vi)
	if AddTextField(collection, "locale", false) {
		changes = true
	}
	// active: hide draft pages
	if AddBoolField(collection, "active") {
		changes = true
	}

	if EnsureIndex(collection, "idx_content_pages_slug_locale", true, "slug,locale", "") {
		changes = true
	}

	if AddSystemFields(collection) {
		changes = true
	}

	if changes {
		SaveCollection(app, collection)
	}
}
