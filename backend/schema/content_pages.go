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
		content: `<h2>1. 개인정보를 수집하지 않습니다</h2>
<p>꼬마 한동화는 <strong>계정 기능이 없습니다</strong>. 이메일, 이름, 사진 등 어떤 개인정보도 수집하지 않습니다.</p>

<h2>2. 데이터 저장 위치</h2>
<p>독서 진행, 즐겨찾기, 메모 등 모든 데이터는 <strong>기기 내에만</strong> 저장됩니다. 서버로 전송되지 않습니다.</p>

<h2>3. 수집하지 않는 것</h2>
<p>기기 정보, 이용 로그, IP 주소, 제3자 분석, 광고 추적 - 모두 수집하지 않습니다.</p>

<h2>4. 데이터 삭제</h2>
<p>앱을 삭제하면 기기 내 데이터도 함께 제거됩니다.</p>

<h2>5. 아동 보호</h2>
<p>본 앱은 아동용입니다. 아동의 개인정보를 수집하지 않습니다.</p>

<h2>6. 문의</h2>
<p>문의: <a href="mailto:ichimoku.0902@gmail.com">ichimoku.0902@gmail.com</a></p>

<h2>7. 시행일</h2>
<p>본 개인정보 처리방침은 2025년 1월 1일부터 시행됩니다.</p>`,
	},
	{
		slug:   "terms",
		title:  "이용약관",
		locale: "ko",
		content: `<h2>제1조 (목적)</h2>
<p>본 약관은 꼬마 한동화(이하 "서비스")의 이용 조건 및 절차를 규정합니다.</p>

<h2>제2조 (정의)</h2>
<ul>
<li>"서비스": 한동화 등 아동용 스토리 콘텐츠 제공 앱 (계정 없이 이용)</li>
<li>"이용자": 앱을 설치하여 이용하는 자</li>
<li>"콘텐츠": 스토리, 챕터, 이미지, 오디오 등 서비스 내 모든 자료</li>
</ul>

<h2>제3조 (약관의 효력)</h2>
<p>앱을 설치·이용하는 시점부터 본 약관에 동의한 것으로 봅니다.</p>

<h2>제4조 (서비스 제공 방식)</h2>
<p>서비스는 <strong>무료 버전</strong>과 <strong>프리미엄(유료)</strong>을 제공합니다.</p>
<ul>
<li><strong>무료 버전</strong>: 이야기(동화) 오디오 청취가 하루 15분으로 제한됩니다. 읽기는 제한 없습니다.</li>
<li><strong>프리미엄</strong>: 앱 내 구매로 제한 없이 청취할 수 있습니다. 구매 정보는 기기에만 저장됩니다.</li>
</ul>
<p>콘텐츠 이용에는 인터넷 연결이 필요합니다.</p>

<h2>제5조 (이용자의 의무)</h2>
<p>다음 행위를 해서는 안 됩니다.</p>
<ul>
<li>저작권 등 지식재산권 침해</li>
<li>서비스 운영 방해, 무단 복제·배포</li>
<li>법령에 위반되는 행위</li>
</ul>

<h2>제6조 (환불)</h2>
<p>앱 내 구매 환불은 App Store 및 Google Play 정책에 따릅니다.</p>

<h2>제7조 (면책)</h2>
<p>운영자는 천재지변, 기술적 장애 등 불가항력으로 인한 서비스 중단에 대해 책임을 지지 않습니다.</p>

<h2>제8조 (분쟁 해결)</h2>
<p>서비스 관련 분쟁은 대한민국 법률을 적용합니다.</p>

<h2>제9조 (문의)</h2>
<p>문의: <a href="mailto:ichimoku.0902@gmail.com">ichimoku.0902@gmail.com</a></p>

<h2>제10조 (시행일)</h2>
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
