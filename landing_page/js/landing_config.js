/**
 * আমার কুষ্টিয়া ল্যান্ডিং পেজ কনফিগারেশন ফাইল
 * এখান থেকে আপনি খুব সহজেই অ্যাপের লিংক, ভার্সন, পরিসংখ্যান ও তথ্য পরিবর্তন করতে পারবেন।
 */
const LANDING_CONFIG = {
  // অ্যাপের সাধারণ তথ্য
  appName: "আমার কুষ্টিয়া",
  appTagline: "কুষ্টিয়াবাসীর ডিজিটাল প্ল্যাটফর্ম",
  
  // হিরো সেকশন ও ডাউনলোড তথ্য
  hero: {
    badge: "কুষ্টিয়াবাসীর অল-ইন-ওয়ান আধুনিক ডিজিটাল সহকারী • বেটা ১.০ লাইভ!",
    titleLine1: "কুষ্টিয়া জেলার সকল সেবা ও তথ্য —",
    titleHighlight: "এখন আপনার হাতের মুঠোয়!",
    subtitle: "পশ্চিমাঞ্চল রেলওয়ের নতুন সময়সূচি (টাইম টেবিল নং-৫৪) ও লাইভ ট্র্যাকিং, বিশেষজ্ঞ ডাক্তার ও হাসপাতাল, জরুরি রক্তদাতা, পর্যটন ও দর্শনীয় স্থান এবং ৬টি উপজেলার জরুরি সেবা — সম্পূর্ণ বিজ্ঞাপনমুক্ত এক ক্লিকে।",
    appVersion: "v1.0.0-beta.1",
    releaseChannel: "beta",
    betaBadgeActive: true,
    appSize: "৩২ MB",
    rating: "৫.০ রেটিং",
    totalDownloads: "৫,০০০+ ডাউনলোড",
    apkDownloadUrl: "https://github.com/error5299/amar_kushtia/releases/download/v1.0.0-beta.1/app-release.apk",
    playStoreUrl: "https://play.google.com/store/apps",
    qrCodeData: "https://github.com/error5299/amar_kushtia/releases/latest"
  },

  // পরিসংখ্যান (Stats Counter)
  stats: [
    { target: 177, suffix: "+", title: "পশ্চিমাঞ্চলের ট্রেনের শিডিউল", subtitle: "টাইম টেবিল নং-৫৪ অনুসারে" },
    { target: 6, suffix: "টি", title: "উপজেলার ১০০% কভারেজ", subtitle: "সদর, কুমারখালী, ভেড়ামারা ইত্যাদি" },
    { target: 1000, suffix: "+", title: "জরুরি যোগাযোগ নম্বর", subtitle: "ডাক্তার, পুলিশ, ফায়ার সার্ভিস" },
    { target: 10000, suffix: "+", title: "সন্তুষ্ট ব্যবহারকারী", subtitle: "কুষ্টিয়াবাসীর আস্থা ও ভালোবাসা" }
  ],

  // জরুরি লিংকসমূহ
  links: {
    railwayTicket: "https://eticket.railway.gov.bd",
    liveTracking: "https://trainkothai.com",
    kushtiaPortal: "http://www.kushtia.gov.bd",
    supportEmail: "support@amarkushtia.app"
  },

  // অ্যাপের আসল স্ক্রিনশটসমূহ (assets/screenshots/ ফোল্ডারে রাখুন বা লিংক দিন)
  screenshots: {
    home: "assets/screenshots/home.png",
    train: "assets/screenshots/train.png",
    hospital: "assets/screenshots/hospital.png",
    blood: "assets/screenshots/hospital.png",
    tourism: "assets/screenshots/train.png",
    doctors: "assets/screenshots/hospital.png",
    services: "assets/screenshots/home.png",
  },

  // ক্রিয়েটর ও কপিরাইট
  creator: {
    name: "Belayet Hossain",
    copyrightYear: "২০২৬"
  }
};
