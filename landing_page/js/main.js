// ── Helper: Get active configuration ──
function getActiveConfig() {
  let activeConfig = null;
  const localSaved = localStorage.getItem('AMAR_KUSHTIA_LANDING_CONFIG');
  if (localSaved) {
    try {
      activeConfig = JSON.parse(localSaved);
    } catch (e) {}
  }
  if (!activeConfig && typeof LANDING_CONFIG !== 'undefined') {
    activeConfig = LANDING_CONFIG;
  }
  return activeConfig;
}

// ── Sync Configuration to UI & DOM Elements ──
function syncConfigToUI(config) {
  if (!config) return;

  const hero = config.hero || {};
  const links = config.links || {};
  const creator = config.creator || {};

  const apkUrl = hero.apkDownloadUrl || 'assets/amar_kushtia.apk';
  const playUrl = hero.playStoreUrl || 'https://play.google.com/store/apps';
  const version = hero.appVersion || 'v1.0.4';
  const size = hero.appSize || '১৮ MB';

  // 1. Update all APK Download Buttons and Links
  const cleanVersion = version.replace(/[^a-zA-Z0-9._-]/g, '');
  document.querySelectorAll('.apk-download-btn').forEach((el) => {
    el.href = apkUrl;
    if (apkUrl.startsWith('http://') || apkUrl.startsWith('https://')) {
      el.target = '_blank';
      el.rel = 'noopener';
    } else {
      el.removeAttribute('target');
      el.setAttribute('download', `Amar_Kushtia_${cleanVersion || 'v1.0.4'}.apk`);
    }
  });

  // 2. Update all Google Play Store Buttons and Links
  document.querySelectorAll('.play-store-btn').forEach((el) => {
    el.href = playUrl;
    el.target = '_blank';
    el.rel = 'noopener';
  });

  // Explicit ID references for modal and hero download triggers
  const modalApk = document.getElementById('modalApkLink');
  if (modalApk) {
    modalApk.href = apkUrl;
    if (!apkUrl.startsWith('http://') && !apkUrl.startsWith('https://')) {
      modalApk.setAttribute('download', `Amar_Kushtia_${cleanVersion || 'v1.0.4'}.apk`);
    }
  }
  const modalPlay = document.getElementById('modalPlayLink');
  if (modalPlay) {
    modalPlay.href = playUrl;
  }

  // 3. Update I18N Data with dynamic version & size so translations retain config
  if (typeof I18N_DATA !== 'undefined') {
    if (I18N_DATA.bn) {
      I18N_DATA.bn.hero_apk_title = `APK ডাউনলোড (${version})`;
      I18N_DATA.bn.cta_apk = `সরাসরি APK ডাউনলোড (${version})`;
      I18N_DATA.bn.modal_apk = `সরাসরি APK ডাউনলোড (${version} • ${size})`;
      if (hero.rating) I18N_DATA.bn.hero_rating = hero.rating;
      if (hero.appSize) I18N_DATA.bn.hero_size = `নিরাপদ ও হালকা (${hero.appSize})`;
    }
    if (I18N_DATA.en) {
      I18N_DATA.en.hero_apk_title = `Download APK (${version})`;
      I18N_DATA.en.cta_apk = `Direct APK Download (${version})`;
      I18N_DATA.en.modal_apk = `Direct APK Download (${version} • ${size})`;
      if (hero.rating) I18N_DATA.en.hero_rating = hero.rating;
      if (hero.appSize) I18N_DATA.en.hero_size = `Safe & Light (${hero.appSize})`;
    }
  }

  // 4. Update QR Code Image
  const qrImg = document.getElementById('ctaQrCodeImg');
  if (qrImg) {
    const qrData = encodeURIComponent(hero.qrCodeData || apkUrl || 'https://amarkushtia.app');
    qrImg.src = `https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${qrData}&color=0B5233`;
  }

  // 5. Update Footer External Links
  const linkRailway = document.getElementById('footerRailwayTicket');
  if (linkRailway && links.railwayTicket) linkRailway.href = links.railwayTicket;

  const linkTracking = document.getElementById('footerTrainTracking');
  if (linkTracking && links.liveTracking) linkTracking.href = links.liveTracking;

  const linkPortal = document.getElementById('footerKushtiaPortal');
  if (linkPortal && links.kushtiaPortal) linkPortal.href = links.kushtiaPortal;

  const linkEmail = document.getElementById('footerSupportEmail');
  if (linkEmail && links.supportEmail) linkEmail.href = `mailto:${links.supportEmail}`;

  // 6. Update Stats targets
  if (config.stats) {
    const statElements = document.querySelectorAll('.stat-number');
    config.stats.forEach((st, idx) => {
      if (statElements[idx]) {
        statElements[idx].setAttribute('data-target', st.target);
        if (st.suffix) statElements[idx].setAttribute('data-suffix', st.suffix);
      }
    });
  }

  // 7. Update Copyright text
  const copyrightEl = document.getElementById('footerCopyright');
  if (copyrightEl && creator.copyrightYear) {
    const curLang = localStorage.getItem('amar_kushtia_lang') || 'bn';
    copyrightEl.textContent = curLang === 'bn'
      ? `© ${creator.copyrightYear} আমার কুষ্টিয়া (Amar Kushtia) • সর্বস্বত্ব সংরক্ষিত।`
      : `© ${creator.copyrightYear} Amar Kushtia • All Rights Reserved.`;
  }

  // 8. Sync Screenshots
  const screenKeys = ['home', 'train', 'hospital', 'blood', 'tourism'];
  screenKeys.forEach((k) => {
    const customImg = localStorage.getItem('AMAR_KUSHTIA_IMG_' + k) || config?.screenshots?.[k];
    if (customImg) {
      // Hero 3D Phone Screen
      const heroImg = document.getElementById('heroImg' + k.charAt(0).toUpperCase() + k.slice(1));
      if (heroImg) {
        heroImg.src = customImg;
        heroImg.classList.remove('hidden');
      }

      // Gallery Card Screen
      const galleryImg = document.getElementById('galleryImg' + k.charAt(0).toUpperCase() + k.slice(1));
      if (galleryImg) {
        galleryImg.src = customImg;
        galleryImg.classList.remove('hidden');
        if (galleryImg.nextElementSibling) {
          galleryImg.nextElementSibling.classList.add('hidden');
        }
      }
    }
  });
}

// Global exposure
window.getActiveConfig = getActiveConfig;
window.syncConfigToUI = syncConfigToUI;

document.addEventListener('DOMContentLoaded', () => {
  // ── 0. Initial Sync & Bilingual Setup ──
  const activeConfig = getActiveConfig();
  syncConfigToUI(activeConfig);

  const initialLang = localStorage.getItem('amar_kushtia_lang') || 'bn';
  if (typeof applyLanguage === 'function') {
    applyLanguage(initialLang);
  }

  // Language button event listeners
  document.querySelectorAll('.lang-btn-bn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      applyLanguage('bn');
      syncConfigToUI(getActiveConfig());
    });
  });

  document.querySelectorAll('.lang-btn-en').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      applyLanguage('en');
      syncConfigToUI(getActiveConfig());
    });
  });

  // Cross-tab real-time sync with Admin panel
  window.addEventListener('storage', (e) => {
    if (e.key === 'AMAR_KUSHTIA_LANDING_CONFIG' || (e.key && e.key.startsWith('AMAR_KUSHTIA_IMG_'))) {
      const cfg = getActiveConfig();
      syncConfigToUI(cfg);
      const curLang = localStorage.getItem('amar_kushtia_lang') || 'bn';
      if (typeof applyLanguage === 'function') {
        applyLanguage(curLang);
      }
    }
  });

  // ── 1. 3D Tilt Effect on Phone Mockup ──
  const heroCard = document.getElementById('phoneMockup');
  const heroContainer = document.getElementById('heroContainer');

  if (heroCard && heroContainer) {
    heroContainer.addEventListener('mousemove', (e) => {
      const rect = heroContainer.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      const centerX = rect.width / 2;
      const centerY = rect.height / 2;

      const rotateX = ((y - centerY) / centerY) * -12;
      const rotateY = ((x - centerX) / centerX) * 14;

      heroCard.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
    });

    heroContainer.addEventListener('mouseleave', () => {
      heroCard.style.transform = 'rotateX(6deg) rotateY(-8deg)';
    });
  }

  // ── 2. Interactive Phone Screen Switcher ──
  const screenTabs = document.querySelectorAll('.screen-tab-btn');
  const screenContents = document.querySelectorAll('.app-screen-content');

  screenTabs.forEach((tab) => {
    tab.addEventListener('click', () => {
      const targetScreen = tab.getAttribute('data-screen');

      // Update Tab Styles
      screenTabs.forEach((btn) => {
        btn.classList.remove('bg-emerald-700', 'text-white', 'shadow-md', 'shadow-emerald-700/25');
        btn.classList.add('bg-white', 'text-slate-700', 'border', 'border-slate-200', 'hover:bg-slate-50');
      });

      tab.classList.remove('bg-white', 'text-slate-700', 'border', 'border-slate-200', 'hover:bg-slate-50');
      tab.classList.add('bg-emerald-700', 'text-white', 'shadow-md', 'shadow-emerald-700/25');

      // Update Screen Contents with smooth transition
      screenContents.forEach((content) => {
        if (content.id === targetScreen) {
          content.classList.add('active');
        } else {
          content.classList.remove('active');
        }
      });
    });
  });

  // ── 3. Number Counter Animation on Scroll ──
  const statsSection = document.getElementById('statsSection');
  const statNumbers = document.querySelectorAll('.stat-number');
  let animated = false;

  if (statsSection && statNumbers.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting && !animated) {
          animated = true;
          const currentLang = localStorage.getItem('amar_kushtia_lang') || 'bn';
          
          statNumbers.forEach((counter) => {
            const target = +counter.getAttribute('data-target');
            const suffixKey = counter.getAttribute('data-suffix-key');
            let suffix = counter.getAttribute('data-suffix') || '';
            if (suffixKey && typeof I18N_DATA !== 'undefined' && I18N_DATA[currentLang]?.[suffixKey]) {
              suffix = I18N_DATA[currentLang][suffixKey];
            }

            const duration = 1800;
            const stepTime = 20;
            const steps = duration / stepTime;
            const increment = target / steps;
            let current = 0;

            const timer = setInterval(() => {
              current += increment;
              const langNow = localStorage.getItem('amar_kushtia_lang') || 'bn';
              if (current >= target) {
                counter.innerText = (langNow === 'bn' ? target.toLocaleString('bn-BD') : target.toLocaleString('en-US')) + suffix;
                clearInterval(timer);
              } else {
                const val = Math.floor(current);
                counter.innerText = (langNow === 'bn' ? val.toLocaleString('bn-BD') : val.toLocaleString('en-US')) + suffix;
              }
            }, stepTime);
          });
        }
      });
    }, { threshold: 0.3 });

    observer.observe(statsSection);
  }

  // ── 4. FAQ Accordion ──
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach((item) => {
    const questionBtn = item.querySelector('.faq-question');
    const answer = item.querySelector('.faq-answer');
    const icon = item.querySelector('.faq-icon');

    if (questionBtn && answer) {
      questionBtn.addEventListener('click', () => {
        const isOpen = !answer.classList.contains('hidden');

        // Close other FAQs
        faqItems.forEach((other) => {
          const otherAns = other.querySelector('.faq-answer');
          const otherIcon = other.querySelector('.faq-icon');
          if (otherAns) otherAns.classList.add('hidden');
          if (otherIcon) otherIcon.style.transform = 'rotate(0deg)';
        });

        if (!isOpen) {
          answer.classList.remove('hidden');
          if (icon) icon.style.transform = 'rotate(180deg)';
        }
      });
    }
  });

  // ── 5. Download APK / QR Modal ──
  const modal = document.getElementById('downloadModal');
  const openModalBtns = document.querySelectorAll('.trigger-download-modal');
  const closeModalBtn = document.getElementById('closeModalBtn');

  if (modal) {
    openModalBtns.forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        document.body.style.overflow = 'hidden';
      });
    });

    if (closeModalBtn) {
      closeModalBtn.addEventListener('click', () => {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        document.body.style.overflow = '';
      });
    }

    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        document.body.style.overflow = '';
      }
    });
  }

  // ── 6. Mobile Navigation Menu Toggle ──
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const mobileNavMenu = document.getElementById('mobileNavMenu');

  if (mobileMenuBtn && mobileNavMenu) {
    mobileMenuBtn.addEventListener('click', () => {
      mobileNavMenu.classList.toggle('hidden');
    });

    const mobileLinks = mobileNavMenu.querySelectorAll('a');
    mobileLinks.forEach(link => {
      link.addEventListener('click', () => {
        mobileNavMenu.classList.add('hidden');
      });
    });
  }

  // ── 7. Back To Top Button ──
  const backToTopBtn = document.getElementById('backToTopBtn');
  if (backToTopBtn) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 400) {
        backToTopBtn.classList.remove('opacity-0', 'pointer-events-none');
        backToTopBtn.classList.add('opacity-100');
      } else {
        backToTopBtn.classList.add('opacity-0', 'pointer-events-none');
        backToTopBtn.classList.remove('opacity-100');
      }
    });

    backToTopBtn.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  // ══════════════════════════════════════════════════════════
  // ── 8. FULLSCREEN SCREENSHOT LIGHTBOX MODAL ──
  // ══════════════════════════════════════════════════════════
  const lightboxModal = document.getElementById('screenshotLightboxModal');
  const lightboxTitle = document.getElementById('lightboxTitle');
  const lightboxSub = document.getElementById('lightboxSub');
  const lightboxMainImg = document.getElementById('lightboxMainImg');
  const lightboxIndexBadge = document.getElementById('lightboxIndexBadge');
  const lightboxDotsContainer = document.getElementById('lightboxDotsContainer');
  const closeLightboxBtn = document.getElementById('closeLightboxBtn');
  const lightboxPrevBtn = document.getElementById('lightboxPrevBtn');
  const lightboxNextBtn = document.getElementById('lightboxNextBtn');

  const LIGHTBOX_SCREENS = [
    {
      key: 'home',
      defaultImg: 'assets/screenshots/home.png',
      fallbackImg: 'assets/screenshots/screen_home.png',
      title_bn: 'হোম ও নাগরিক ড্যাশবোর্ড',
      sub_bn: 'জরুরি হেল্পলাইন, বাস ভাড়ার হিসাব ও সকল সেবার সহজ ড্যাশবোর্ড',
      title_en: 'Home & Citizen Dashboard',
      sub_en: 'Emergency helplines, bus fare calculator & all citizen services'
    },
    {
      key: 'train',
      defaultImg: 'assets/screenshots/train.png',
      fallbackImg: 'assets/screenshots/screen_train.png',
      title_bn: 'পশ্চিমাঞ্চল ট্রেন সময়সূচি ও টিকিট',
      sub_bn: 'টাইম টেবিল নং-৫৪ অনুসারে ৯৫টি আন্তঃনগর ও মেইল ট্রেনের শিডিউল',
      title_en: 'Western Railway Schedule & Tickets',
      sub_en: '95 intercity & mail trains schedule as per Timetable No-54'
    },
    {
      key: 'hospital',
      defaultImg: 'assets/screenshots/hospital.png',
      fallbackImg: 'assets/screenshots/screen_hospital.png',
      title_bn: 'হাসপাতাল ও স্বাস্থ্যসেবা',
      sub_bn: 'কুষ্টিয়া ২৫০ শয্যা বিশিষ্ট জেনারেল হাসপাতাল ও সকল ক্লিনিকের তথ্য',
      title_en: 'Hospitals & Healthcare Directory',
      sub_en: 'Kushtia 250 Bed General Hospital & all clinics directory'
    },
    {
      key: 'tourism',
      defaultImg: 'assets/screenshots/home.png',
      fallbackImg: 'assets/screenshots/train.png',
      title_bn: 'নাগরিক সেবা ও জরুরি বিভাগ',
      sub_bn: 'কুষ্টিয়া জেলার ৬টি উপজেলার প্রশাসনিক ও নাগরিক সেবা',
      title_en: 'Citizen & Emergency Services',
      sub_en: 'Administrative and emergency services across 6 upazilas'
    }
  ];

  let currentLightboxIdx = 0;

  function updateLightboxContent(idx) {
    currentLightboxIdx = idx;
    const item = LIGHTBOX_SCREENS[idx];
    const currentLang = localStorage.getItem('amar_kushtia_lang') || 'bn';

    // Image source: check localStorage first, then default
    const customImg = localStorage.getItem('AMAR_KUSHTIA_IMG_' + item.key);
    const chosenSrc = customImg || item.defaultImg;
    
    if (lightboxMainImg) {
      lightboxMainImg.onerror = function() {
        if (item.fallbackImg && this.src !== item.fallbackImg) {
          this.src = item.fallbackImg;
        } else if (this.src !== 'assets/screenshots/home.png') {
          this.src = 'assets/screenshots/home.png';
        }
      };
      lightboxMainImg.src = chosenSrc;
    }

    // Title & Subtitle based on language
    if (lightboxTitle) {
      lightboxTitle.innerText = currentLang === 'bn' ? item.title_bn : item.title_en;
    }
    if (lightboxSub) {
      lightboxSub.innerText = currentLang === 'bn' ? item.sub_bn : item.sub_en;
    }

    // Index Badge
    if (lightboxIndexBadge) {
      if (currentLang === 'bn') {
        const bnDigits = ['১', '২', '৩', '৪'];
        lightboxIndexBadge.innerText = `${bnDigits[idx]} / ৪`;
      } else {
        lightboxIndexBadge.innerText = `${idx + 1} / 4`;
      }
    }

    // Update Dots Container
    if (lightboxDotsContainer) {
      lightboxDotsContainer.innerHTML = '';
      LIGHTBOX_SCREENS.forEach((screen, dIdx) => {
        const dot = document.createElement('button');
        dot.className = `h-2.5 rounded-full transition-all duration-300 ${
          dIdx === idx 
            ? 'w-7 bg-emerald-700' 
            : 'w-2.5 bg-slate-300 hover:bg-emerald-400'
        }`;
        dot.title = currentLang === 'bn' ? screen.title_bn : screen.title_en;
        dot.addEventListener('click', () => updateLightboxContent(dIdx));
        lightboxDotsContainer.appendChild(dot);
      });
    }
  }

  function openScreenshotLightbox(idx) {
    if (!lightboxModal) return;
    updateLightboxContent(idx);
    lightboxModal.classList.remove('hidden');
    lightboxModal.classList.add('flex');
    document.body.style.overflow = 'hidden';
  }

  function closeScreenshotLightbox() {
    if (!lightboxModal) return;
    lightboxModal.classList.add('hidden');
    lightboxModal.classList.remove('flex');
    document.body.style.overflow = '';
  }

  // Global exposure
  window.openScreenshotLightbox = openScreenshotLightbox;
  window.closeScreenshotLightbox = closeScreenshotLightbox;

  if (closeLightboxBtn) {
    closeLightboxBtn.addEventListener('click', closeScreenshotLightbox);
  }

  if (lightboxPrevBtn) {
    lightboxPrevBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      const prevIdx = (currentLightboxIdx - 1 + LIGHTBOX_SCREENS.length) % LIGHTBOX_SCREENS.length;
      updateLightboxContent(prevIdx);
    });
  }

  if (lightboxNextBtn) {
    lightboxNextBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      const nextIdx = (currentLightboxIdx + 1) % LIGHTBOX_SCREENS.length;
      updateLightboxContent(nextIdx);
    });
  }

  if (lightboxModal) {
    lightboxModal.addEventListener('click', (e) => {
      if (e.target === lightboxModal) {
        closeScreenshotLightbox();
      }
    });
  }

  // Keyboard navigation for Lightbox
  window.addEventListener('keydown', (e) => {
    if (lightboxModal && !lightboxModal.classList.contains('hidden')) {
      if (e.key === 'Escape') {
        closeScreenshotLightbox();
      } else if (e.key === 'ArrowLeft') {
        const prevIdx = (currentLightboxIdx - 1 + LIGHTBOX_SCREENS.length) % LIGHTBOX_SCREENS.length;
        updateLightboxContent(prevIdx);
      } else if (e.key === 'ArrowRight') {
        const nextIdx = (currentLightboxIdx + 1) % LIGHTBOX_SCREENS.length;
        updateLightboxContent(nextIdx);
      }
    }
  });
});
