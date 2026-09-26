/**
 * আমার কুষ্টিয়া — বহুভাষিক (Bilingual) ট্রান্সলেশন ডিকশনারি
 * বাংলা (bn) এবং ইংরেজি (en) ভাষার জন্য সম্পূর্ণ ট্রান্সলেশন ডেটা
 */

const I18N_DATA = {
  bn: {
    // Brand & Header
    brand_name: "আমার কুষ্টিয়া",
    brand_official: "Official",
    brand_tagline: "কুষ্টিয়াবাসীর ডিজিটাল প্ল্যাটফর্ম",
    nav_features: "ফিচারসমূহ",
    nav_train: "রেলওয়ে ও লাইভ ট্র্যাক",
    nav_services: "নাগরিক সেবা",
    nav_screens: "অ্যাপ স্ক্রিন",
    nav_faq: "প্রশ্নোত্তর",
    nav_creator: "ক্রিয়েটর",
    nav_download: "অ্যাপ ডাউনলোড",

    // Hero Section
    hero_badge: "কুষ্টিয়াবাসীর অল-ইন-ওয়ান আধুনিক ডিজিটাল অ্যাপ",
    hero_title_line1: "কুষ্টিয়া জেলার সকল সেবা ও তথ্য —",
    hero_title_highlight: "এখন আপনার হাতের মুঠোয়!",
    hero_desc: "পশ্চিমাঞ্চল রেলওয়ের নতুন সময়সূচি (টাইম টেবিল নং-৫৪) ও লাইভ ট্র্যাকিং, বিশেষজ্ঞ ডাক্তার ও হাসপাতাল, জরুরি রক্তদাতা, পর্যটন ও দর্শনীয় স্থান এবং ৬টি উপজেলার জরুরি সেবা — সম্পূর্ণ বিজ্ঞাপনমুক্ত এক ক্লিকে।",
    hero_apk_sub: "সরাসরি অ্যান্ড্রয়েড ফাইল",
    hero_apk_title: "APK ডাউনলোড (v1.0.4)",
    hero_play_sub: "উপলব্ধ রয়েছে",
    hero_play_title: "Google Play Store",
    hero_rating: "৪.৯ রেটিং",
    hero_adfree: "১০০% বিজ্ঞাপনমুক্ত",
    hero_offline: "অফলাইন সুবিধা",
    hero_size: "নিরাপদ ও হালকা (১৮ MB)",

    // Hero 3D Phone Badges & Switcher
    badge_train_title: "ট্রেন লাইভ ট্র্যাকিং",
    badge_train_sub: "টাইম টেবিল নং-৫৪",
    badge_blood_title: "জরুরি রক্তদাতা",
    badge_blood_sub: "তাত্ক্ষণিক যোগাযোগ",
    badge_doctor_title: "বিশেষজ্ঞ ডাক্তার",
    badge_doctor_sub: "চেম্বার ও সিরিয়াল",

    tab_home: "হোম পেজ",
    tab_train: "রেলওয়ে শিডিউল",
    tab_blood: "রক্তসেবা",
    tab_tourism: "ঐতিহ্য ও লালন",
    tab_hint: "স্ক্রিন দেখতে বাটনগুলোতে ক্লিক করুন",

    // Value Pillars
    pillar1_title: "১০০% ফ্রি ও বিজ্ঞাপনমুক্ত",
    pillar1_desc: "কোনো বিরক্তিকর পপআপ বা ভিডিও অ্যাড নেই। শুধুমাত্র দরকারি নাগরিক তথ্য ও সেবা।",
    pillar2_title: "অফলাইন ও সুপার ফাস্ট",
    pillar2_desc: "ইন্টারনেট না থাকলেও ট্রেনের সময়সূচি, বাস কাউন্টার ও জরুরি নম্বর তাত্ক্ষণিক পাবেন।",
    pillar3_title: "যাচাইকৃত স্থানীয় তথ্য",
    pillar3_desc: "কুষ্টিয়ার স্থানীয় প্রশাসন, হাসপাতাল ও সাধারণ নাগরিকদের দ্বারা নিয়মিত হালনাগাদকৃত ডাটা।",

    // Features Section
    feat_tag: "প্রয়োজনীয় সকল ফিচার",
    feat_title: "একটি অ্যাপেই কুষ্টিয়া জেলার",
    feat_highlight: "সমগ্র ডিজিটাল নাগরিক সেবা",
    feat_sub: "দৈনন্দিন জীবনের প্রতিটি পদক্ষেপে কুষ্টিয়াবাসীর সর্বোচ্চ সুবিধার্থে আধুনিক ইন্টারফেসে সাজানো হয়েছে এই অ্যাপ।",

    feat1_tag: "টাইম টেবিল নং-৫৪",
    feat1_title: "রেলওয়ে ও লাইভ ট্র্যাকিং",
    feat1_desc: "পশ্চিমাঞ্চলের ১৭৭টি আন্তঃনগর, মেইল ও লোকাল ট্রেনের সময়সূচি। পোড়াদহ ও কুষ্টিয়া কোর্ট স্টপেজের বিস্তারিত সময় এবং সরাসরি লাইভ জিপিএস ট্র্যাকিং পোর্টাল।",
    feat1_item1: "২-পাক্ষিক রুট ফিল্টার (From ➔ To)",
    feat1_item2: "১২ ঘণ্টার সহজ সময় (AM/PM)",
    feat1_item3: "সরাসরি অফিসিয়াল টিকিট বুকিং লিংক",

    feat2_tag: "স্বাস্থ্য ও চিকিৎসা",
    feat2_title: "বিশেষজ্ঞ ডাক্তার ও হাসপাতাল",
    feat2_desc: "কুষ্টিয়া সদর হাসপাতালসহ সকল প্রাইভেট ক্লিনিকের বিশেষজ্ঞ চিকিৎসকদের ডিগ্রি, চেম্বার বসার সময় এবং সরাসরি সিরিয়াল দেওয়ার ফোন নম্বর।",
    feat2_item1: "বিষয়ভিত্তিক বিশেষজ্ঞ তালিকা (মেডিসিন, গাইনি ইত্যাদি)",
    feat2_item2: "২৪/৭ অ্যাম্বুলেন্স চালকদের নম্বর",
    feat2_item3: "ডায়াগনস্টিক সেন্টার ও ফার্মেসি তথ্য",

    feat3_tag: "জরুরি রক্তসেবা",
    feat3_title: "লাইভ রক্তদাতা নেটওয়ার্ক",
    feat3_desc: "রক্তের জরুরি মুহূর্তে যেকোনো গ্রুপের রক্তদাতার সন্ধান। রক্তের গ্রুপ ও উপজেলা অনুযায়ী ফিল্টার করে সরাসরি এক ট্যাপে কল করার সুবিধা।",
    feat3_item1: "A+, B+, AB+, O+ সহ সকল গ্রুপের ডোনার",
    feat3_item2: "নতুন রক্তদাতা হিসেবে রেজিস্ট্রেশন সুবিধা",
    feat3_item3: "স্থানীয় স্বেচ্ছাসেবী ব্লাড ক্লাব তালিকা",

    feat4_tag: "পর্যটন ও ঐতিহ্য",
    feat4_title: "কুষ্টিয়ার ইতিহাস ও দর্শনীয় স্থান",
    feat4_desc: "লালন শাহের মাজার, শিলাইদহ কুঠিবাড়ি, মীর মশাররফ হোসেনের বাস্তুভিটা, হার্ডিঞ্জ ব্রিজ, লালন শাহ সেতুসহ জেলার সকল দর্শনীয় স্থানের বিবরণ ও যাতায়াত পথ।",
    feat4_item1: "পৌঁছানোর বিস্তারিত গাইডলাইন",
    feat4_item2: "হোটেল ও মোটেল বুকিং সহায়তা",
    feat4_item3: "বিখ্যাত তিলের খাজা ও কুলফি মালাই তথ্য",

    feat5_tag: "৬টি উপজেলা",
    feat5_title: "উপজেলা ভিত্তিক সেবা ও প্রশাসন",
    feat5_desc: "কুষ্টিয়া সদর, কুমারখালী, খোকসা, ভেড়ামারা, মিরপুর এবং দৌলতপুর — প্রতিটি উপজেলার প্রশাসন, পুলিশ, ভূমি অফিস এবং জনপ্রতিনিধিদের সাথে যোগাযোগের নম্বর।",
    feat5_item1: "ইউএনও, এসি ল্যান্ড ও ওসি ফোন নম্বর",
    feat5_item2: "ইউনিয়ন পরিষদ ও পৌরসভা তথ্য",
    feat5_item3: "পল্লী বিদ্যুৎ ও বিদ্যুৎ অভিযোগ কেন্দ্র",

    feat6_tag: "২৪/৭ জরুরি হেল্পলাইন",
    feat6_title: "জরুরি সাহায্য ও ফায়ার সার্ভিস",
    feat6_desc: "যেকোনো বিপদে পুলিশ কন্ট্রোল রুম, কুষ্টিয়া ফায়ার সার্ভিস স্টেশন, বিদ্যুৎ কন্ট্রোল রুম ও জাতীয় হেল্পলাইন ৯৯৯, ৩৩৩, ১০৯-এ সরাসরি ডায়াল।",
    feat6_item1: "এক ট্যাপে সরাসরি কল সংযোগ",
    feat6_item2: "ফায়ার সার্ভিস ও সিভিল ডিফেন্স",
    feat6_item3: "নারী ও শিশু নির্যাতন প্রতিরোধ সেল",

    // Stats Section
    stat1_title: "পশ্চিমাঞ্চলের ট্রেনের শিডিউল",
    stat1_sub: "টাইম টেবিল নং-৫৪ অনুসারে",
    stat1_suffix: "+",
    stat2_title: "উপজেলার ১০০% কভারেজ",
    stat2_sub: "সদর, কুমারখালী, ভেড়ামারা ইত্যাদি",
    stat2_suffix: "টি",
    stat3_title: "জরুরি যোগাযোগ নম্বর",
    stat3_sub: "ডাক্তার, পুলিশ, ফায়ার সার্ভিস",
    stat3_suffix: "+",
    stat4_title: "সন্তুষ্ট ব্যবহারকারী",
    stat4_sub: "কুষ্টিয়াবাসীর আস্থা ও ভালোবাসা",
    stat4_suffix: "+",

    // Screens Gallery
    gallery_tag: "ইউজার ইন্টারফেস",
    gallery_title: "সহজ, আধুনিক ও দ্রুতগতির অভিজ্ঞতা",
    gallery_desc: "প্রতিটি বয়সের মানুষের ব্যবহারের উপযোগী করে সহজবোধ্য বাংলা ভাষায় সাজানো প্রতিটি স্ক্রিন। স্ক্রিনে ক্লিক করে বড় আকারে দেখুন।",
    gallery_click_zoom: "বড় করে দেখুন",
    screen1_title: "হোম ড্যাশবোর্ড",
    screen1_sub: "সব সেবার দ্রুত সংযোগ",
    screen2_title: "ট্রেন শিডিউল ও ট্র্যাকিং",
    screen2_sub: "সঠিক সময় ও লাইভ অবস্থান",
    screen3_title: "হাসপাতাল ও স্বাস্থ্যসেবা",
    screen3_sub: "২৫০ শয্যা বিশিষ্ট হাসপাতাল ও ডাক্তার তালিকা",
    screen4_title: "কুষ্টিয়ার ইতিহাস ও পর্যটন",
    screen4_sub: "লালন ও রবীন্দ্রনাথের স্মৃতিভূমি",

    // Testimonials
    testi_title: "ব্যবহারকারীদের অভিমত",
    testi_sub: "কুষ্টিয়াবাসীর প্রাত্যহিক জীবনের বিশ্বস্ত ডিজিটাল সহযোগী",
    testi1_text: "“পোড়াদহ জংশনে প্রায়ই ট্রেনে যাতায়াত করতে হয়। টাইম টেবিল নং-৫৪ এবং লাইভ ট্র্যাকিং যুক্ত থাকায় ট্রেন কখন আসছে তা এখন ঘরে বসেই জানতে পারি। দারুণ অ্যাপ!”",
    testi1_name: "তারেক রহমান",
    testi1_role: "ব্যবসায়ী, পোড়াদহ",
    testi2_text: "“গত মাসে গভীর রাতে এক রোগীর জন্য জরুরি রক্তের প্রয়োজন হয়েছিল। অ্যাপ থেকে ও-পজিটিভ রক্তদাতার নম্বর নিয়ে সরাসরি যোগাযোগ করে রক্ত জোগাড় করতে পেরেছিলাম।”",
    testi2_name: "রাশেদুল ইসলাম",
    testi2_role: "শিক্ষার্থী, কুষ্টিয়া সরকারি কলেজ",
    testi3_text: "“অ্যাপটির সবচেয়ে ভালো দিক হলো কোনো বিরক্তিকর বিজ্ঞাপন নেই! ডাক্তারদের চেম্বারের সঠিক সময় এবং সকল জরুরি হেল্পলাইন এক জায়গায় পাওয়া যায়।”",
    testi3_name: "ফারহানা আক্তার",
    testi3_role: "গৃহিণী, কুমারখালী",

    // CTA Banner
    cta_badge: "ফ্রি ডাউনলোড • মাত্র ১৮ মেগাবাইট",
    cta_title: "আজই আপনার ফোনে ইন্সটল করুন <br><span class=\"text-amber-300\">“আমার কুষ্টিয়া”</span> অ্যাপ!",
    cta_desc: "কুষ্টিয়ার সকল তথ্য ও নাগরিক সুবিধা রাখুন সবসময় সাথে। কোনো সাবস্ক্রিপশন ফি বা হিডেন চার্জ নেই।",
    cta_apk: "সরাসরি APK ডাউনলোড (v1.0.4)",
    cta_play: "Google Play Store",
    cta_sub: "অ্যান্ড্রয়েড ৬.০ বা তদূর্ধ্ব যেকোনো ডিভাইসে দ্রুত কাজ করে।",
    cta_qr_title: "স্ক্যান করে ডাউনলোড করুন",
    cta_qr_sub: "মোবাইল ক্যামেরা দিয়ে স্ক্যান করুন",

    // FAQ
    faq_tag: "সচরাচর প্রশ্নাবলি",
    faq_title: "সাধারণ জিজ্ঞাসাসমূহ",
    faq1_q: "১. “আমার কুষ্টিয়া” অ্যাপটি কি সম্পূর্ণ বিনামূল্যে ব্যবহার করা যায়?",
    faq1_a: "হ্যাঁ, অ্যাপটি কুষ্টিয়া জেলার সাধারণ মানুষের উপকারের জন্য সম্পূর্ণ বিনামূল্যে তৈরি করা হয়েছে। এতে কোনো মাসিক বা লুকানো চার্জ নেই।",
    faq2_q: "২. ট্রেনের সময়সূচি কি বাংলাদেশ রেলওয়ের সর্বশেষ আপডেট অনুযায়ী?",
    faq2_a: "হ্যাঁ, বাংলাদেশ রেলওয়ে পশ্চিমাঞ্চলের অফিসিয়াল টাইম টেবিল নং-৫৪ (কার্যকরের তারিখ: ১০.০৩.২০২৫ ইং) অনুসারে সকল ট্রেনের সঠিক সময়সূচি, স্টপেজ ও বন্ধের দিন সংযোজন করা হয়েছে।",
    faq3_q: "৩. ইন্টারনেট সংযোগ ছাড়া কি অ্যাপটি ব্যবহার করা যাবে?",
    faq3_a: "হ্যাঁ! একবার অ্যাপ ইন্সটল হয়ে গেলে ট্রেনের সময়সূচি, জরুরি নম্বর, বাস সার্ভিস ও স্থানীয় দর্শনীয় স্থানসমূহের বিবরণ সম্পূর্ণ অফলাইনে দেখা সম্ভব।",
    faq4_q: "৪. কীভাবে আমি রক্তদাতা হিসেবে তালিকায় নাম যুক্ত করতে পারি?",
    faq4_a: "অ্যাপের 'জরুরি রক্তসেবা' সেকশনে গিয়ে 'রক্তদাতা হিসেবে নিবন্ধন' অপশনে ক্লিক করে আপনার নাম, রক্তের গ্রুপ, উপজেলা ও যোগাযোগের নম্বর দিয়ে সহজেই ডোনার হিসেবে যুক্ত হতে পারবেন।",
    faq5_q: "৫. অ্যাপে কি কোনো বিজ্ঞাপন দেখানো হয়?",
    faq5_a: "না, অ্যাপটি সম্পূর্ণ বিজ্ঞাপনমুক্ত (Ad-Free)। ইউজারদের নিরবচ্ছিন্ন সেবা প্রদানে কোনো ব্যানার বা বিরক্তিকর পপআপ বিজ্ঞাপন রাখা হয়নি।",

    // Footer
    footer_desc: "কুষ্টিয়া জেলার ইতিহাস, ঐতিহ্য, নাগরিক সেবা, চিকিৎসা এবং যোগাযোগের একটি নির্ভরযোগ্য সমন্বিত ডিজিটাল মোবাইল অ্যাপ।",
    footer_crafted: "Crafted with ❤️ by",
    footer_links_title: "জরুরি লিংক",
    footer_portals_title: "সরকারি ও অফিসিয়াল সেবা",
    footer_railway_ticket: "বাংলাদেশ রেলওয়ে ই-টিকেট",
    footer_train_tracking: "ট্রেন কোথায় (লাইভ ট্র্যাকিং)",
    footer_kushtia_portal: "জেলা প্রশাসন কুষ্টিয়া পোর্টাল",
    footer_copyright: "© ২০২৬ আমার কুষ্টিয়া (Amar Kushtia) • সর্বস্বত্ব সংরক্ষিত।",
    footer_privacy: "গোপনীয়তা নীতি",
    footer_terms: "ব্যবহারের শর্তাবলি",
    footer_contact: "যোগাযোগ",

    // Modal
    modal_title: "“আমার কুষ্টিয়া” ডাউনলোড করুন",
    modal_desc: "আপনার অ্যান্ড্রয়েড ফোনে সরাসরি ইন্সটল করতে নিচের যেকোনো একটি অপশন বেছে নিন।",
    modal_apk: "সরাসরি APK ডাউনলোড (v1.0.4 • 18 MB)",
    modal_play: "Google Play Store থেকে পান",
    modal_security: "১০০% নিরাপদ, ভাইরাস ও ম্যালওয়্যার মুক্ত",

    // Creator Page
    creator_page_title: "বেলায়েত হোসেন — প্রোডাক্ট ডিজাইনার ও ফ্লাটার ডেভেলপার",
    creator_badge: "ক্রিয়েটর পোর্টফোলিও",
    creator_back_app: "মূল অ্যাপ পেজ",
    creator_nav_about: "পরিচিতি",
    creator_nav_skills: "দক্ষতা",
    creator_nav_projects: "প্রজেক্টসমূহ",
    creator_nav_connect: "কানেক্ট",
    creator_status_badge: "✦ কাজ ও প্রজেক্টের জন্য প্রস্তুত (Available for Work)",
    creator_name: "বেলায়েত হোসেন",
    creator_role: "Product Designer · Flutter Developer · Instructor",
    creator_bio_short: "ডিজাইন ও প্রযুক্তির মেলবন্ধনে এক নিবেদিতপ্রাণ ক্রিয়েটর। পিক্সেল-পারফেক্ট ইউআই/ইউএক্স থেকে শুরু করে প্রডাকশন-রেডি ফ্লাটার ও আধুনিক ওয়েব অ্যাপ্লিকেশন তৈরি এবং নতুন প্রজন্মের ডিজাইনার ও ডেভেলপারদের প্রশিক্ষণে নিবেদিত।",
    creator_btn_portfolio: "পোর্টফোলিও ওয়েবসাইট",
    creator_btn_support: "সাপোর্ট করুন",
    creator_btn_talk: "মেসেজ পাঠান",
    creator_btn_app: "আমার কুষ্টিয়া অ্যাপ",
    creator_stat1_num: "৫+",
    creator_stat1_title: "বছরের বাস্তব অভিজ্ঞতা",
    creator_stat1_sub: "প্রোডাক্ট ডিজাইন ও ফ্লাটার",
    creator_stat2_num: "৪০+",
    creator_stat2_title: "সফল প্রজেক্ট ডেলিভারি",
    creator_stat2_sub: "ওয়েব, অ্যাপ ও ডিজাইন সিস্টেম",
    creator_stat3_num: "১০,০০০+",
    creator_stat3_title: "সক্রিয় অ্যাপ ব্যবহারকারী",
    creator_stat3_sub: "আমার কুষ্টিয়া ও অন্যান্য অ্যাপ",
    creator_stat4_num: "১০০%",
    creator_stat4_title: "কোয়ালিটি ও একাগ্রতা",
    creator_stat4_sub: "ইউজার-ফ্রেন্ডলি ডিজিটাল এক্সপেরিয়েন্স",
    creator_about_tag: "আমার যাত্রা ও দর্শন",
    creator_about_heading: "সহজ ও কার্যকরী ডিজিটাল সমাধান তৈরিতে প্রতিশ্রুতিবদ্ধ",
    creator_about_p1: "প্রযুক্তি কেবল কোডিং নয়, মানুষের বাস্তব জীবনের সমস্যার সহজ ও নান্দনিক সমাধান তৈরি করা। ‘আমার কুষ্টিয়া’ অ্যাপটি গড়ে তোলা হয়েছে ঠিক এই উদ্দেশ্যেই—যেন কুষ্টিয়া জেলার প্রতিটি মানুষ এক ক্লিকেই প্রয়োজনীয় রেলওয়ে সময়সূচি, স্বাস্থ্যসেবা ও জরুরি তথ্য নিজের হাতের মুঠোয় পেয়ে যান।",
    creator_about_p2: "আমার কাজের মূল ভিত্তি হলো মিনিমালিজম, নিখুঁত টাইপোগ্রাফি ও অফলাইন-ফার্স্ট পারফরম্যান্স। পাশাপাশি দেশি-বিদেশি বিভিন্ন ক্লায়েন্ট প্রজেক্ট ও কমিউনিটিতে মেন্টর হিসেবে নতুনদের পথপ্রদর্শনে কাজ করে যাচ্ছি।",
    creator_skills_tag: "বিশেষজ্ঞতা ও প্রযুক্তি",
    creator_skills_heading: "যেসব বিষয়ে আমি কাজ করি",
    creator_skills_sub: "আধুনিক ডিজাইন স্ট্যান্ডার্ড এবং স্কেলেবল মোবাইল আর্কিটেকচার নিয়ে নিয়মিত কাজ করছি।",
    creator_social_tag: "যুক্ত থাকুন",
    creator_social_heading: "সোশ্যাল মিডিয়া ও প্রফেশনাল নেটওয়ার্ক",
    creator_projects_tag: "নির্বাচিত কাজসমূহ",
    creator_projects_heading: "ফিচার্ড প্রজেক্ট ও কেস স্টাডি",
    creator_cta_heading: "নতুন কোনো আইডিয়া বা প্রজেক্ট নিয়ে আলোচনা করতে চান?",
    creator_cta_sub: "ফ্রিল্যান্স প্রজেক্ট, কনসালটেন্সি বা ‘আমার কুষ্টিয়া’ অ্যাপ সংক্রান্ত যেকোনো মতামতের জন্য সরাসরি যোগাযোগ করতে পারেন。"
  },

  en: {
    // Brand & Header
    brand_name: "Amar Kushtia",
    brand_official: "Official",
    brand_tagline: "Digital Platform of Kushtia",
    nav_features: "Features",
    nav_train: "Railway & Tracking",
    nav_services: "Citizen Services",
    nav_screens: "Screens",
    nav_faq: "FAQ",
    nav_creator: "Creator",
    nav_download: "Download App",

    // Hero Section
    hero_badge: "All-in-One Modern Digital App for Kushtia",
    hero_title_line1: "All Services & Info of Kushtia District —",
    hero_title_highlight: "Now in the Palm of Your Hand!",
    hero_desc: "Western Railway's latest timetable (No-54) & live train tracking, specialist doctors & hospitals, emergency blood donors, heritage & tourism, and emergency citizen services across 6 upazilas — 100% ad-free in one click.",
    hero_apk_sub: "Direct Android File",
    hero_apk_title: "Download APK (v1.0.4)",
    hero_play_sub: "Available on",
    hero_play_title: "Google Play Store",
    hero_rating: "4.9 Rating",
    hero_adfree: "100% Ad-Free",
    hero_offline: "Offline Support",
    hero_size: "Safe & Light (18 MB)",

    // Hero 3D Phone Badges & Switcher
    badge_train_title: "Live Train Tracking",
    badge_train_sub: "Timetable No-54",
    badge_blood_title: "Emergency Donors",
    badge_blood_sub: "Instant Contact",
    badge_doctor_title: "Specialist Doctors",
    badge_doctor_sub: "Chambers & Serial",

    tab_home: "Home Screen",
    tab_train: "Train Schedule",
    tab_blood: "Blood Donors",
    tab_tourism: "Heritage & Lalon",
    tab_hint: "Click the buttons to view interactive screens",

    // Value Pillars
    pillar1_title: "100% Free & Ad-Free",
    pillar1_desc: "No annoying popups or video advertisements. Purely essential citizen services and local information.",
    pillar2_title: "Offline & Ultra Fast",
    pillar2_desc: "Access train schedules, bus counters, and emergency phone numbers instantly even without internet.",
    pillar3_title: "Verified Local Data",
    pillar3_desc: "Regularly verified and updated data by Kushtia local administration, hospitals, and citizens.",

    // Features Section
    feat_tag: "ALL ESSENTIAL FEATURES",
    feat_title: "All Digital Citizen Services of",
    feat_highlight: "Kushtia District in One App",
    feat_sub: "Carefully designed with a modern and intuitive interface to assist citizens at every stage of daily life.",

    feat1_tag: "Timetable No-54",
    feat1_title: "Railway & Live Tracking",
    feat1_desc: "Complete schedules for 177 Intercity, Mail & Local trains in Western Railway. Detailed timings for Poradah & Kushtia Court stops with live GPS tracking.",
    feat1_item1: "Two-way Route Filter (From ➔ To)",
    feat1_item2: "12-hour format with AM/PM",
    feat1_item3: "Direct official e-ticket booking link",

    feat2_tag: "Healthcare & Medicine",
    feat2_title: "Specialist Doctors & Hospitals",
    feat2_desc: "Directory of specialist doctors, degrees, chamber schedules, and direct phone serial booking for Kushtia Sadar Hospital and private clinics.",
    feat2_item1: "Department-wise specialist list (Medicine, Gynae, etc.)",
    feat2_item2: "24/7 Ambulance drivers' contact numbers",
    feat2_item3: "Diagnostic centers & pharmacy directory",

    feat3_tag: "Emergency Blood Services",
    feat3_title: "Live Blood Donor Network",
    feat3_desc: "Find blood donors of any group during emergencies. Filter by blood group and upazila to call directly with a single tap.",
    feat3_item1: "Donors for all blood groups (A+, B+, AB+, O+)",
    feat3_item2: "Simple registration as a volunteer donor",
    feat3_item3: "Directory of local voluntary blood donation clubs",

    feat4_tag: "Tourism & Heritage",
    feat4_title: "History & Landmarks of Kushtia",
    feat4_desc: "Explore Lalon Shah's Shrine, Shilaidaha Kuthibari, Mir Mosharraf Hossain's Residence, Hardinge Bridge, and all heritage landmarks with travel guides.",
    feat4_item1: "Detailed directions & transport guide",
    feat4_item2: "Hotel & guest house booking support",
    feat4_item3: "Famous local sweets (Tiler Khaja & Kulfi Malai)",

    feat5_tag: "6 Upazilas",
    feat5_title: "Upazila Administration & Services",
    feat5_desc: "Kushtia Sadar, Kumarkhali, Khoksa, Bheramara, Mirpur, and Daulatpur — contacts for local administration, police, land offices, and representatives.",
    feat5_item1: "Direct phone numbers for UNO, AC Land & OC",
    feat5_item2: "Union Parishad & Municipality details",
    feat5_item3: "Palli Bidyut & electricity complaint centers",

    feat6_tag: "24/7 Emergency Helplines",
    feat6_title: "Emergency Aid & Fire Service",
    feat6_desc: "Instant dial for Police Control Room, Kushtia Fire Station, Electricity Control Room, and national hotlines 999, 333, 109.",
    feat6_item1: "One-tap direct calling facility",
    feat6_item2: "Fire Service & Civil Defence stations",
    feat6_item3: "Women & children assistance cell",

    // Stats Section
    stat1_title: "Western Railway Trains",
    stat1_sub: "As per Timetable No-54",
    stat1_suffix: "+",
    stat2_title: "Upazilas 100% Covered",
    stat2_sub: "Sadar, Kumarkhali, Bheramara etc.",
    stat2_suffix: "",
    stat3_title: "Emergency Contacts",
    stat3_sub: "Doctors, Police, Fire Service",
    stat3_suffix: "+",
    stat4_title: "Satisfied Users",
    stat4_sub: "Trusted by Kushtia Citizens",
    stat4_suffix: "+",

    // Screens Gallery
    gallery_tag: "USER INTERFACE",
    gallery_title: "Simple, Modern & High-Speed Experience",
    gallery_desc: "Thoughtfully designed for citizens of all age groups with clean, intuitive screens. Click any screen to view full size.",
    gallery_click_zoom: "Click to Zoom",
    screen1_title: "Home Dashboard",
    screen1_sub: "Quick access to all essential services",
    screen2_title: "Train Schedule & Tracking",
    screen2_sub: "Accurate timings & live positions",
    screen3_title: "Hospitals & Healthcare",
    screen3_sub: "250 Bed General Hospital & specialist doctors directory",
    screen4_title: "History & Tourism",
    screen4_sub: "Heritage land of Lalon & Tagore",

    // Testimonials
    testi_title: "What Citizens Are Saying",
    testi_sub: "Trusted daily digital companion for people of Kushtia",
    testi1_text: "“I travel frequently via Poradah Junction. With Timetable No-54 and live tracking, I can check train arrival times right from home. Outstanding app!”",
    testi1_name: "Tarek Rahman",
    testi1_role: "Businessman, Poradah",
    testi2_text: "“Last month late at night a patient urgently required blood. I found an O-positive donor's number directly in the app and contacted him in minutes.”",
    testi2_name: "Rashedul Islam",
    testi2_role: "Student, Kushtia Govt College",
    testi3_text: "“The best part of this app is zero annoying ads! Doctor chamber hours and emergency helplines are available in one single clean place.”",
    testi3_name: "Farhana Akhter",
    testi3_role: "Homemaker, Kumarkhali",

    // CTA Banner
    cta_badge: "FREE DOWNLOAD • ONLY 18 MB",
    cta_title: "Install on Your Phone Today: <br><span class=\"text-amber-300\">“Amar Kushtia”</span> App!",
    cta_desc: "Keep all Kushtia citizen services & information in your pocket. No subscription fee or hidden charges.",
    cta_apk: "Direct APK Download (v1.0.4)",
    cta_play: "Google Play Store",
    cta_sub: "Works smoothly on Android 6.0 and above devices.",
    cta_qr_title: "Scan to Download",
    cta_qr_sub: "Scan with your smartphone camera",

    // FAQ
    faq_tag: "FREQUENTLY ASKED QUESTIONS",
    faq_title: "Common Inquiries & Answers",
    faq1_q: "1. Is the “Amar Kushtia” app completely free to use?",
    faq1_a: "Yes, the app is built completely free of cost for the benefit of Kushtia residents. There are no monthly subscriptions or hidden charges.",
    faq2_q: "2. Is the train schedule updated according to Bangladesh Railway's latest timetable?",
    faq2_a: "Yes, all train timings, stoppages, and off-days are fully updated according to Western Railway official Timetable No-54 (Effective: 10.03.2025).",
    faq3_q: "3. Can the app be used without an active internet connection?",
    faq3_a: "Yes! Once installed, train schedules, emergency hotlines, bus counters, and tourist spots are accessible completely offline.",
    faq4_q: "4. How can I register myself as a blood donor?",
    faq4_a: "Navigate to the 'Emergency Blood Services' section in the app and tap 'Register as Blood Donor' to submit your blood group, upazila, and contact number.",
    faq5_q: "5. Does the app display any advertisements?",
    faq5_a: "No, the app is 100% ad-free. No banner ads, interstitial popups, or video ads are included.",

    // Footer
    footer_desc: "A reliable, integrated digital mobile app for history, heritage, healthcare, and citizen services of Kushtia district.",
    footer_crafted: "Crafted with ❤️ by",
    footer_links_title: "Quick Links",
    footer_portals_title: "Official Services & Portals",
    footer_railway_ticket: "Bangladesh Railway E-Ticket",
    footer_train_tracking: "Train Kothai (Live Tracking)",
    footer_kushtia_portal: "District Administration Portal",
    footer_copyright: "© 2026 Amar Kushtia • All rights reserved.",
    footer_privacy: "Privacy Policy",
    footer_terms: "Terms of Use",
    footer_contact: "Contact Us",

    // Modal
    modal_title: "Download “Amar Kushtia”",
    modal_desc: "Choose one of the options below to install directly on your Android phone.",
    modal_apk: "Direct APK Download (v1.0.4 • 18 MB)",
    modal_play: "Get it on Google Play Store",
    modal_security: "100% Safe, Virus & Malware Free",

    // Creator Page
    creator_page_title: "Belayet Hossain — Product Designer & Flutter Developer",
    creator_badge: "Creator Portfolio",
    creator_back_app: "Back to App",
    creator_nav_about: "About",
    creator_nav_skills: "Skills",
    creator_nav_projects: "Projects",
    creator_nav_connect: "Connect",
    creator_status_badge: "✦ Available for Work & Collaborations",
    creator_name: "Belayet Hossain",
    creator_role: "Product Designer · Flutter Developer · Instructor",
    creator_bio_short: "A passionate creator at the intersection of design and technology. I craft purposeful digital experiences — from pixel-perfect UI to production-ready Flutter & web apps — and share knowledge as an instructor helping the next generation of designers & developers.",
    creator_btn_portfolio: "View Portfolio",
    creator_btn_support: "Support Me",
    creator_btn_talk: "Send Message",
    creator_btn_app: "Amar Kushtia App",
    creator_stat1_num: "5+",
    creator_stat1_title: "Years Experience",
    creator_stat1_sub: "Product Design & Flutter",
    creator_stat2_num: "40+",
    creator_stat2_title: "Projects Shipped",
    creator_stat2_sub: "Web, Mobile & Design Systems",
    creator_stat3_num: "10,000+",
    creator_stat3_title: "Active App Users",
    creator_stat3_sub: "Amar Kushtia & Apps",
    creator_stat4_num: "100%",
    creator_stat4_title: "Quality Focused",
    creator_stat4_sub: "User-Centered Design",
    creator_about_tag: "My Journey & Philosophy",
    creator_about_heading: "Committed to Crafting Meaningful Digital Experiences",
    creator_about_p1: "Technology is not just about writing code; it is about solving real human problems with simplicity and elegance. 'Amar Kushtia' was built with this single mission—ensuring every citizen of Kushtia can access railway schedules, medical care, and emergency services instantly.",
    creator_about_p2: "My core design philosophy centers around minimalism, refined typography, and offline-first performance. Beyond creating digital products, I actively mentor aspiring designers and developers to build their careers.",
    creator_skills_tag: "Expertise & Tools",
    creator_skills_heading: "What I Specialize In",
    creator_skills_sub: "Working with modern design systems and scalable multi-platform app architectures.",
    creator_social_tag: "Get Connected",
    creator_social_heading: "Social & Professional Networks",
    creator_projects_tag: "Selected Works",
    creator_projects_heading: "Featured Projects & Case Studies",
    creator_cta_heading: "Have an exciting project or want to collaborate?",
    creator_cta_sub: "Feel free to reach out for freelance inquiries, consultancy, or discussions regarding Amar Kushtia."
  }
};

// Global Helper to get current language
function getCurrentLanguage() {
  return localStorage.getItem('amar_kushtia_lang') || 'bn';
}

// Function to apply translation across the page
function applyLanguage(lang) {
  if (!I18N_DATA[lang]) lang = 'bn';
  localStorage.setItem('amar_kushtia_lang', lang);
  document.documentElement.lang = lang;

  const data = I18N_DATA[lang];

  // 1. Text elements with data-i18n
  document.querySelectorAll('[data-i18n]').forEach((el) => {
    const key = el.getAttribute('data-i18n');
    if (data[key] !== undefined) {
      if (data[key].includes('<br>') || data[key].includes('<span')) {
        el.innerHTML = data[key];
      } else {
        el.textContent = data[key];
      }
    }
  });

  // 2. Language Switcher Buttons State
  const bnBtns = document.querySelectorAll('.lang-btn-bn');
  const enBtns = document.querySelectorAll('.lang-btn-en');

  if (lang === 'bn') {
    bnBtns.forEach((btn) => {
      btn.classList.add('bg-emerald-700', 'text-white', 'shadow-xs');
      btn.classList.remove('text-slate-600', 'hover:text-emerald-700');
    });
    enBtns.forEach((btn) => {
      btn.classList.remove('bg-emerald-700', 'text-white', 'shadow-xs');
      btn.classList.add('text-slate-600', 'hover:text-emerald-700');
    });
  } else {
    enBtns.forEach((btn) => {
      btn.classList.add('bg-emerald-700', 'text-white', 'shadow-xs');
      btn.classList.remove('text-slate-600', 'hover:text-emerald-700');
    });
    bnBtns.forEach((btn) => {
      btn.classList.remove('bg-emerald-700', 'text-white', 'shadow-xs');
      btn.classList.add('text-slate-600', 'hover:text-emerald-700');
    });
  }

  // 3. Stats numbers update (formatted in locale)
  const statNumbers = document.querySelectorAll('.stat-number');
  statNumbers.forEach((counter) => {
    const target = +counter.getAttribute('data-target');
    const suffixKey = counter.getAttribute('data-suffix-key');
    let suffix = counter.getAttribute('data-suffix') || '';
    if (suffixKey && data[suffixKey] !== undefined) {
      suffix = data[suffixKey];
    }
    
    if (lang === 'bn') {
      counter.innerText = target.toLocaleString('bn-BD') + suffix;
    } else {
      counter.innerText = target.toLocaleString('en-US') + suffix;
    }
  });

  // Re-sync dynamic config links and attributes if main.js is loaded
  if (typeof window.syncConfigToUI === 'function' && typeof window.getActiveConfig === 'function') {
    window.syncConfigToUI(window.getActiveConfig());
  }
}

// Explicit global exposure
window.applyLanguage = applyLanguage;
window.getCurrentLanguage = getCurrentLanguage;

