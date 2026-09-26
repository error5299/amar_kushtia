// Amar Kushtia — Standalone Firebase Admin Portal Application
// Supports Firebase v10 Modular / Compat SDK

// 1. Default / Stored Firebase Configuration
const DEFAULT_FIREBASE_CONFIG = {
  apiKey: "AIzaSyBu0wkC-2XDL2x1ysoWS9otqE4cViOWtrU",
  authDomain: "amar-kushtia-419ec.firebaseapp.com",
  projectId: "amar-kushtia-419ec",
  storageBucket: "amar-kushtia-419ec.firebasestorage.app",
  messagingSenderId: "873618382819",
  appId: "1:873618382819:web:04cc5a7d519cfcc9474ad6"
};

let app, auth, db;
let currentTab = 'dashboard';
let currentEditingId = null;
let allRecords = [];
let allCategories = [];
let allUsers = [];

const DEFAULT_CATEGORIES = [
  { id: 'emergency', titleBn: 'জরুরি সেবা', titleEn: 'Emergency Services', subtitleBn: 'পুলিশ, ফায়ার ও অ্যাম্বুলেন্স', subtitleEn: 'Police, Fire & Ambulance', iconName: 'emergency', colorHex: '#EF4444', bgColorHex: '#FEE2E2', sortOrder: 1, isActive: true },
  { id: 'healthcare', titleBn: 'স্বাস্থ্যসেবা ও হাসপাতাল', titleEn: 'Healthcare & Hospitals', subtitleBn: 'জেনারেল হাসপাতাল, ক্লিনিক ও ডায়াগনস্টিক', subtitleEn: 'General Hospital, Clinics & Diag.', iconName: 'hospital', colorHex: '#0284C7', bgColorHex: '#E0F2FE', sortOrder: 2, isActive: true },
  { id: 'police', titleBn: 'আইনশৃঙ্খলা ও থানা', titleEn: 'Police & Security', subtitleBn: 'মডেল থানা, ফাঁড়ি ও পুলিশ কন্ট্রোল', subtitleEn: 'Thana, Police Outposts & Control', iconName: 'police', colorHex: '#1E40AF', bgColorHex: '#DBEAFE', sortOrder: 3, isActive: true },
  { id: 'fire', titleBn: 'ফায়ার সার্ভিস ও সিভিল ডিফেন্স', titleEn: 'Fire Service & Civil Defence', subtitleBn: 'দমকল স্টেশন ও উদ্ধারকারী দল', subtitleEn: 'Fire Stations & Rescue Operations', iconName: 'fire', colorHex: '#EA580C', bgColorHex: '#FFEDD5', sortOrder: 4, isActive: true },
  { id: 'transport', titleBn: 'পরিবহন ও যোগাযোগ', titleEn: 'Transport & Rail', subtitleBn: 'ট্রেন সময়সূচী ও আন্তঃজেলা বাস কাউন্টার', subtitleEn: 'Train Timetable & Bus Counters', iconName: 'train', colorHex: '#059669', bgColorHex: '#D1FAE5', sortOrder: 5, isActive: true },
  { id: 'tourism', titleBn: 'দর্শনীয় স্থান ও পর্যটন', titleEn: 'Tourism & Heritage', subtitleBn: 'লালন মাজার, শিলাইদহ কুঠিবাড়ি ও ঐতিহ্য', subtitleEn: 'Lalon Shrine, Shilaidaha & Heritage', iconName: 'tourism', colorHex: '#D97706', bgColorHex: '#FEF3C7', sortOrder: 6, isActive: true },
  { id: 'government', titleBn: 'প্রশাসন ও সরকারি অফিস', titleEn: 'Government & Administration', subtitleBn: 'ডিসি অফিস, ইউএনও, ভূমি ও পৌরসভা', subtitleEn: 'DC Office, UNO, Land & Municipal', iconName: 'government', colorHex: '#0F766E', bgColorHex: '#CCFBF1', sortOrder: 7, isActive: true },
  { id: 'education', titleBn: 'শিক্ষা প্রতিষ্ঠান', titleEn: 'Education Institutions', subtitleBn: 'বিশ্ববিদ্যালয়, কলেজ ও বিশিষ্ট বিদ্যালয়', subtitleEn: 'Universities, Colleges & Schools', iconName: 'education', colorHex: '#7C3AED', bgColorHex: '#EDE9FE', sortOrder: 8, isActive: true },
  { id: 'food', titleBn: 'খাবার ও মিষ্টান্ন', titleEn: 'Food & Sweets', subtitleBn: 'তিলের খাজা, কুলফি মালাই ও ঐতিহ্যবাহী খাবার', subtitleEn: 'Tiler Khaja, Kulfi Malai & Sweets', iconName: 'food', colorHex: '#B45309', bgColorHex: '#FFEDD5', sortOrder: 9, isActive: true },
  { id: 'craft', titleBn: 'হস্তশিল্প ও ঐতিহ্য', titleEn: 'Craft & Heritage', subtitleBn: 'কুমারখালীর তাঁত বস্ত্র ও মৃৎশিল্প', subtitleEn: 'Kumarkhali Handloom & Pottery', iconName: 'craft', colorHex: '#4338CA', bgColorHex: '#E0E7FF', sortOrder: 10, isActive: true },
  { id: 'agriculture', titleBn: 'কৃষি ও প্রাণিসম্পদ', titleEn: 'Agriculture & Livestock', subtitleBn: 'কৃষি অফিস, বীজ ও কৃষক তথ্য কেন্দ্র', subtitleEn: 'Agriculture Office & Farmer Info', iconName: 'agriculture', colorHex: '#15803D', bgColorHex: '#DCFCE7', sortOrder: 11, isActive: true },
  { id: 'blood_bank', titleBn: 'রক্তদান ও ব্লাড ব্যাংক', titleEn: 'Blood Bank & Donors', subtitleBn: 'জরুরি রক্তদাতা ও ব্লাড ব্যাংক যোগাযোগ', subtitleEn: 'Emergency Blood Donors & Banks', iconName: 'blood', colorHex: '#DC2626', bgColorHex: '#FEE2E2', sortOrder: 12, isActive: true }
];

// Initialize Firebase from LocalStorage or Defaults
function initFirebase() {
  const savedConfig = localStorage.getItem('amar_kushtia_firebase_config');
  let config = DEFAULT_FIREBASE_CONFIG;

  if (savedConfig) {
    try {
      config = JSON.parse(savedConfig);
    } catch (e) {
      console.error('Failed to parse saved Firebase config', e);
    }
  }

  populateConfigInputs(config);

  if (!config.apiKey || !config.projectId) {
    updateFirebaseStatus(false, 'কনফিগার করা হয়নি');
    return false;
  }

  try {
    if (firebase.apps.length === 0) {
      app = firebase.initializeApp(config);
    } else {
      app = firebase.app();
    }
    auth = firebase.auth();
    db = firebase.firestore();

    // Enable offline persistence if supported
    db.enablePersistence({ synchronizeTabs: true }).catch((err) => {
      if (err.code === 'failed-precondition') {
        console.warn('Persistence failed: Multiple tabs open');
      } else if (err.code === 'unimplemented') {
        console.warn('Persistence not supported by browser');
      }
    });

    updateFirebaseStatus(true, config.projectId);
    setupAuthListener();
    loadAllData();
    loadCategories();

    // Anonymous sign in silently so unauthenticated writes always succeed
    if (auth && !auth.currentUser) {
      auth.signInAnonymously().catch((e) => console.log('Anonymous sign-in note:', e));
    }
    return true;
  } catch (err) {
    console.error('Firebase Init Error:', err);
    updateFirebaseStatus(false, 'ত্রুটি: ' + err.message);
    return false;
  }
}

function updateFirebaseStatus(isConnected, text) {
  const chip = document.getElementById('firebase-status-chip');
  const textEl = document.getElementById('firebase-status-text');
  if (chip && textEl) {
    if (isConnected) {
      chip.className = 'status-chip connected';
      textEl.textContent = 'সংযুক্ত: ' + text;
    } else {
      chip.className = 'status-chip disconnected';
      textEl.textContent = text;
    }
  }
}

function populateConfigInputs(config) {
  setVal('cfg-apiKey', config.apiKey || '');
  setVal('cfg-authDomain', config.authDomain || '');
  setVal('cfg-projectId', config.projectId || '');
  setVal('cfg-storageBucket', config.storageBucket || '');
  setVal('cfg-messagingSenderId', config.messagingSenderId || '');
  setVal('cfg-appId', config.appId || '');
}

// 2. Auth State Listener
function setupAuthListener() {
  if (!auth) return;

  auth.onAuthStateChanged((user) => {
    const authWrapper = document.getElementById('auth-wrapper');
    const userEmailEl = document.getElementById('admin-user-email');

    if (user) {
      if (authWrapper) authWrapper.style.display = 'none';
      if (userEmailEl) userEmailEl.textContent = user.isAnonymous ? 'সরাসরি অ্যাডমিন সেশন' : user.email;
    }
    loadAllData();
    loadCategories();
  });
}

// Direct Dashboard Access Without Credentials
window.enterDirectly = function() {
  const authWrapper = document.getElementById('auth-wrapper');
  if (authWrapper) authWrapper.style.display = 'none';
  if (auth && !auth.currentUser) {
    auth.signInAnonymously().catch(e => console.warn('Anonymous sign-in:', e));
  }
  loadAllData();
  loadCategories();
  showToast('সরাসরি অ্যাডমিন ড্যাশবোর্ডে প্রবেশ করা হয়েছে', 'success');
};

// Auth Actions
document.getElementById('login-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('login-email').value.trim();
  const pass = document.getElementById('login-password').value;
  const errorEl = document.getElementById('login-error');

  if (!auth) {
    errorEl.textContent = 'অনুগ্রহ করে প্রথমে "ফায়ারবেজ সেটিংস" থেকে প্রজেক্ট কনফিগারেশন সংরক্ষণ করুন।';
    errorEl.style.display = 'block';
    return;
  }

  try {
    errorEl.style.display = 'none';
    await auth.signInWithEmailAndPassword(email, pass);
    showToast('সফলভাবে লগইন করা হয়েছে!', 'success');
  } catch (err) {
    errorEl.textContent = 'লগইন ব্যর্থ হয়েছে: ' + err.message;
    errorEl.style.display = 'block';
  }
});

document.getElementById('logout-btn')?.addEventListener('click', () => {
  if (auth) {
    auth.signOut().then(() => {
      showToast('লগআউট সফল হয়েছে', 'success');
    });
  }
});

// 3. Tab Navigation
function switchTab(tabId) {
  currentTab = tabId;
  document.querySelectorAll('.sidebar-item').forEach((item) => {
    item.classList.toggle('active', item.getAttribute('data-tab') === tabId);
  });
  document.querySelectorAll('.view-tab').forEach((tab) => {
    tab.classList.toggle('active', tab.id === `view-${tabId}`);
  });

  const titles = {
    dashboard: 'সারসংক্ষেপ ও পরিসংখ্যান',
    categories: 'কুষ্টিয়া জেলা সেবা ও বিভাগসমূহ (Services & Divisions)',
    records: 'সকল তথ্য ও রেকর্ড ব্যবস্থাপনা',
    healthcare: 'হাসপাতালের ফি ও ওয়ার্ড ট্যারিফ',
    surgeries: 'সার্জারি শিডিউল ব্যবস্থাপনা',
    transport: 'ট্রেনের সময়সূচী ব্যবস্থাপনা',
    iu_halls: 'ইসলামী বিশ্ববিদ্যালয় আবাসিক হল',
    hotlines: 'জাতীয় ও জরুরি হটলাইন',
    travel_guide: 'ভ্রমণ গাইড ব্যবস্থাপনা (Travel Guide CMS)',
    notices: 'ব্যানার নোটিশ ও গুরুত্বপূর্ণ ঘোষণা',
    notifications: 'জরুরি ব্রডকাস্ট ও পুশ নোটিফিকেশন',
    users: 'আমার কুষ্টিয়া অ্যাপের নিবন্ধিত নাগরিক ও ব্যবহারকারী',
    app_updates: 'অ্যাপ ভার্সন রিলিজ ও আপডেট ব্যবস্থাপনা (App Updates)',
    settings: 'ফায়ারবেজ প্রজেক্ট কনফিগারেশন',
    seed: 'প্রাথমিক ডেটাবেজ সিডিং'
  };
  const titleEl = document.getElementById('current-page-title');
  if (titleEl && titles[tabId]) {
    titleEl.textContent = titles[tabId];
  }

  // Refresh tab specific data
  if (tabId === 'categories') renderCategoriesTable();
  if (tabId === 'records') renderRecordsTable();
  if (tabId === 'healthcare') renderHealthcareTable();
  if (tabId === 'surgeries') renderSurgeriesTable();
  if (tabId === 'transport') renderTransportTable();
  if (tabId === 'iu_halls') renderIUHallsTable();
  if (tabId === 'hotlines') renderHotlinesTable();
  if (tabId === 'travel_guide') renderTravelGuide();
  if (tabId === 'notices') loadGlobalNotice();
  if (tabId === 'notifications') renderNotificationsList();
  if (tabId === 'users') renderUsersTable();
  if (tabId === 'app_updates') loadAppUpdateConfig();
}

// Universal Merge Helper: Guarantees that editing 1 item NEVER loses other canonical seed items!
function mergeCollectionWithSeed(firestoreDocs, seedArray = []) {
  const map = new Map();
  if (Array.isArray(seedArray)) {
    seedArray.forEach(item => {
      if (item && item.id) map.set(item.id, { ...item });
    });
  }
  if (Array.isArray(firestoreDocs)) {
    firestoreDocs.forEach(doc => {
      if (doc && doc.id) {
        if (doc._deleted === true || doc.isDeleted === true) {
          map.delete(doc.id);
        } else {
          const existing = map.get(doc.id) || {};
          map.set(doc.id, { ...existing, ...doc });
        }
      }
    });
  }
  return Array.from(map.values());
}

// 4. Data Loading & Firestore Listeners
function loadAllData() {
  if (!db) return;

  // Listen to Master Records in Realtime (Merged with Seed Data so records never disappear!)
  db.collection('records').onSnapshot((snapshot) => {
    const cloudDocs = [];
    snapshot.forEach((doc) => {
      cloudDocs.push({ id: doc.id, ...doc.data() });
    });
    allRecords = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.masterRecords : []));
    updateDashboardStats();
    if (currentTab === 'records') renderRecordsTable();
  }, (error) => {
    console.error('Firestore records listen error:', error);
    showToast('রেকর্ড লোড করতে সমস্যা হয়েছে: ' + error.message, 'error');
  });

  // Listen to Registered Users in Realtime
  db.collection('users').onSnapshot((snapshot) => {
    allUsers = [];
    snapshot.forEach((doc) => {
      allUsers.push({ id: doc.id, ...doc.data() });
    });
    updateDashboardStats();
    if (currentTab === 'users') renderUsersTable();
  }, (error) => {
    console.error('Firestore users listen error:', error);
  });
}

function updateDashboardStats() {
  document.getElementById('stat-total-records').textContent = allRecords.length;
  const activeCount = allRecords.filter(r => r.isActive !== false).length;
  document.getElementById('stat-active-records').textContent = activeCount;

  const categories = new Set(allRecords.map(r => r.categoryId)).size;
  document.getElementById('stat-categories').textContent = categories;

  const upazilas = new Set(allRecords.map(r => r.upazilaId)).size;
  document.getElementById('stat-upazilas').textContent = upazilas;

  const statUsers = document.getElementById('stat-total-users');
  if (statUsers) statUsers.textContent = allUsers.length;
}

// 5. Render Master Records Table
function renderRecordsTable() {
  const tbody = document.getElementById('records-table-body');
  if (!tbody) return;

  const search = (document.getElementById('records-search')?.value || '').toLowerCase().trim();
  const upazilaFilter = document.getElementById('records-filter-upazila')?.value || 'all';
  const categoryFilter = document.getElementById('records-filter-category')?.value || 'all';

  const filtered = allRecords.filter((rec) => {
    const titleBn = (rec.titleBn || rec.nameBn || '').toLowerCase();
    const titleEn = (rec.titleEn || rec.nameEn || '').toLowerCase();
    const id = (rec.id || '').toLowerCase();
    const phone = (rec.phonePrimary || (Array.isArray(rec.contactNumbers) ? rec.contactNumbers.join(' ') : (rec.contactNumbers || ''))).toLowerCase();
    const address = (rec.addressBn || rec.address || '').toLowerCase();

    const matchesSearch = !search || 
      titleBn.includes(search) ||
      titleEn.includes(search) ||
      id.includes(search) ||
      phone.includes(search) ||
      address.includes(search);

    const matchesUpazila = upazilaFilter === 'all' || rec.upazilaId === upazilaFilter;
    const matchesCategory = categoryFilter === 'all' || rec.categoryId === categoryFilter;
    return matchesSearch && matchesUpazila && matchesCategory;
  });

  document.getElementById('records-count-badge').textContent = `${filtered.length} টি রেকর্ড`;

  if (filtered.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">
          <i class="fas fa-folder-open" style="font-size: 36px; margin-bottom: 8px; display: block;"></i>
          কোনো তথ্য পাওয়া যায়নি। নতুন রেকর্ড যোগ করতে "+ নতুন তথ্য যুক্ত করুন" বাটনে ক্লিক করুন।
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = filtered.map((rec) => {
    const contacts = rec.phonePrimary || (Array.isArray(rec.contactNumbers) ? rec.contactNumbers.join(', ') : (rec.contactNumbers || '—'));
    const isActive = rec.isActive !== false;
    const displayName = rec.titleBn || rec.nameBn || '—';
    const subTitle = rec.titleEn || rec.nameEn || rec.addressBn || '';

    return `
      <tr>
        <td><strong>${rec.id}</strong></td>
        <td>
          <div style="font-weight: 600; color: var(--text-main);">${displayName}</div>
          <div style="font-size: 11px; color: var(--text-muted);">${subTitle}</div>
        </td>
        <td><span class="badge badge-primary">${getCategoryNameBn(rec.categoryId)}</span></td>
        <td><span class="badge badge-gray">${getUpazilaNameBn(rec.upazilaId)}</span></td>
        <td><span style="font-family: monospace; font-size: 12px;">${contacts}</span></td>
        <td>
          <span class="badge ${isActive ? 'badge-success' : 'badge-danger'}">
            ${isActive ? 'সক্রিয় (Active)' : 'নিষ্ক্রিয় (Draft)'}
          </span>
        </td>
        <td>
          <div class="action-btns">
            <button class="action-btn edit" onclick="openEditRecordModal('${rec.id}')" title="সম্পাদনা করুন">
              <i class="fas fa-edit"></i>
            </button>
            <button class="action-btn" onclick="toggleRecordStatus('${rec.id}', ${isActive})" title="স্ট্যাটাস পরিবর্তন">
              <i class="fas ${isActive ? 'fa-eye-slash' : 'fa-eye'}"></i>
            </button>
            <button class="action-btn delete" onclick="deleteRecord('${rec.id}')" title="মুছে ফেলুন">
              <i class="fas fa-trash-alt"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// Helper: Clean Google Maps Embed URL (Extracts iframe src or cleans raw URL)
function cleanMapEmbedUrl(raw) {
  if (!raw) return '';
  raw = raw.trim();
  // If user pasted an iframe tag, extract the src attribute
  const iframeMatch = raw.match(/<iframe[^>]+src=["']([^"']+)["']/i);
  if (iframeMatch && iframeMatch[1]) {
    return iframeMatch[1].trim();
  }
  return raw;
}

function updateMapEmbedPreview(raw) {
  const url = cleanMapEmbedUrl(raw);
  const wrapper = document.getElementById('map-embed-preview-wrapper');
  const iframe = document.getElementById('map-embed-preview-frame');
  if (!wrapper || !iframe) return;

  if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
    iframe.src = url;
    wrapper.style.display = 'block';
  } else {
    iframe.src = '';
    wrapper.style.display = 'none';
  }
}

function updateImagePreview(urlsText) {
  const container = document.getElementById('image-preview-container');
  if (!container) return;

  if (!urlsText || !urlsText.trim()) {
    container.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); font-size: 12px; padding: 10px;">কোনো ছবি যুক্ত করা হয়নি</div>';
    return;
  }

  // Split by newlines or commas
  const urls = urlsText.split(/[\n,]+/).map(s => s.trim()).filter(Boolean);
  if (urls.length === 0) {
    container.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); font-size: 12px; padding: 10px;">কোনো ছবি যুক্ত করা হয়নি</div>';
    return;
  }

  container.innerHTML = urls.map((url, idx) => `
    <div class="image-preview-item">
      <img src="${url}" alt="Preview ${idx + 1}" onerror="this.src='https://placehold.co/300x200?text=Invalid+Image+URL';" />
      <span class="image-badge">ছবি ${idx + 1}</span>
    </div>
  `).join('');
}

// Safe DOM helpers to prevent any null reference errors
function setVal(id, val) {
  const el = document.getElementById(id);
  if (!el) return;
  if (el.type === 'checkbox') {
    el.checked = Boolean(val);
  } else {
    el.value = (val !== null && val !== undefined) ? val : '';
  }
}

function getVal(id, defaultVal = '') {
  const el = document.getElementById(id);
  if (!el) return defaultVal;
  if (el.type === 'checkbox') return el.checked;
  return el.value ? el.value.trim() : defaultVal;
}

// 6. Record Form (Add / Edit)
function openAddRecordModal() {
  currentEditingId = null;
  const titleEl = document.getElementById('record-modal-title');
  if (titleEl) titleEl.textContent = 'নতুন তথ্য / রেকর্ড যুক্ত করুন';
  const form = document.getElementById('record-form');
  if (form) form.reset();
  
  const idEl = document.getElementById('rec-id');
  if (idEl) {
    idEl.disabled = false;
    idEl.value = 'rec_' + Date.now().toString(36);
  }
  setVal('rec-isActive', true);
  updateImagePreview('');
  updateMapEmbedPreview('');
  document.body.classList.add('modal-open');
  const modal = document.getElementById('record-modal');
  if (modal) modal.classList.add('active');
}

function openEditRecordModal(id) {
  try {
    const rec = allRecords.find(r => r.id === id);
    if (!rec) {
      console.warn('Record not found in local memory, id:', id);
      showToast('রেকর্ডটি মেমোরিতে পাওয়া যায়নি: ' + id, 'warning');
      return;
    }

    currentEditingId = id;
    const titleEl = document.getElementById('record-modal-title');
    if (titleEl) titleEl.textContent = `রেকর্ড সম্পাদনা: ${rec.titleBn || rec.nameBn || id}`;

    const idEl = document.getElementById('rec-id');
    if (idEl) {
      idEl.value = rec.id;
      idEl.disabled = true;
    }

    setVal('rec-titleBn', rec.titleBn || rec.nameBn || '');
    setVal('rec-titleEn', rec.titleEn || rec.nameEn || '');
    setVal('rec-categoryId', rec.categoryId || 'emergency');
    setVal('rec-subcategoryId', rec.subcategoryId || '');
    setVal('rec-upazilaId', rec.upazilaId || 'kushtia_sadar');

    const contactStr = Array.isArray(rec.contactNumbers) ? rec.contactNumbers.join(', ') : (rec.phonePrimary || '');
    setVal('rec-contactNumbers', contactStr);

    const hotlineStr = Array.isArray(rec.emergencyHotlines) ? rec.emergencyHotlines.join(', ') : '';
    setVal('rec-emergencyHotlines', hotlineStr);

    setVal('rec-addressBn', rec.addressBn || '');
    setVal('rec-addressEn', rec.addressEn || '');
    setVal('rec-latitude', rec.latitude || '');
    setVal('rec-longitude', rec.longitude || '');
    setVal('rec-shortDescriptionBn', rec.shortDescriptionBn || '');
    setVal('rec-shortDescriptionEn', rec.shortDescriptionEn || '');
    setVal('rec-descriptionBn', rec.descriptionBn || '');
    setVal('rec-descriptionEn', rec.descriptionEn || '');
    setVal('rec-openingHoursBn', rec.openingHoursBn || rec.openingHours || '');
    setVal('rec-feesNoticeBn', rec.feesNoticeBn || '');
    setVal('rec-website', rec.website || '');
    setVal('rec-directionsUrl', rec.directionsUrl || '');
    setVal('rec-mapEmbedUrl', rec.mapEmbedUrl || '');

    const imgList = Array.isArray(rec.imageUrls) ? rec.imageUrls.join('\n') : '';
    setVal('rec-imageUrls', imgList);
    updateImagePreview(imgList);
    updateMapEmbedPreview(rec.mapEmbedUrl || '');

    setVal('rec-verifiedBadgeStatus', rec.verifiedBadgeStatus || rec.verificationStatus || 'Verified');
    setVal('rec-isFeatured', rec.isFeatured === true);
    setVal('rec-isActive', rec.isActive !== false);

    document.body.classList.add('modal-open');
    const modal = document.getElementById('record-modal');
    if (modal) modal.classList.add('active');
  } catch (err) {
    console.error('Error opening edit record modal:', err);
    showToast('মোডাল খুলতে সমস্যা: ' + err.message, 'error');
  }
}

function closeRecordModal() {
  document.body.classList.remove('modal-open');
  const modal = document.getElementById('record-modal');
  if (modal) modal.classList.remove('active');
}

// Attach to window so onclick always finds them
window.openAddRecordModal = openAddRecordModal;
window.openEditRecordModal = openEditRecordModal;
window.closeRecordModal = closeRecordModal;

// Live Preview Listeners
document.getElementById('rec-imageUrls')?.addEventListener('input', (e) => {
  updateImagePreview(e.target.value);
});

document.getElementById('rec-mapEmbedUrl')?.addEventListener('input', (e) => {
  updateMapEmbedPreview(e.target.value);
});

// Save Record to Firestore
document.getElementById('record-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) {
    showToast('ফায়ারবেজ সংযুক্ত নেই!', 'error');
    return;
  }

  const id = getVal('rec-id');
  if (!id) {
    showToast('আইডি খালি রাখা যাবে না', 'error');
    return;
  }

  const contacts = getVal('rec-contactNumbers').split(',').map(s => s.trim()).filter(Boolean);
  const hotlines = getVal('rec-emergencyHotlines').split(',').map(s => s.trim()).filter(Boolean);
  const images = getVal('rec-imageUrls').split(/[\n,]+/).map(s => s.trim()).filter(Boolean);
  const rawMap = getVal('rec-mapEmbedUrl');
  const cleanMap = cleanMapEmbedUrl(rawMap);

  const titleBn = getVal('rec-titleBn');
  const titleEn = getVal('rec-titleEn');

  const recordData = {
    id: id,
    nameBn: titleBn,
    titleBn: titleBn,
    nameEn: titleEn,
    titleEn: titleEn,
    categoryId: getVal('rec-categoryId', 'emergency'),
    subcategoryId: getVal('rec-subcategoryId'),
    upazilaId: getVal('rec-upazilaId', 'kushtia_sadar'),
    contactNumbers: contacts,
    phonePrimary: contacts.length > 0 ? contacts[0] : null,
    emergencyHotlines: hotlines,
    addressBn: getVal('rec-addressBn'),
    addressEn: getVal('rec-addressEn'),
    latitude: parseFloat(getVal('rec-latitude')) || null,
    longitude: parseFloat(getVal('rec-longitude')) || null,
    shortDescriptionBn: getVal('rec-shortDescriptionBn'),
    shortDescriptionEn: getVal('rec-shortDescriptionEn'),
    descriptionBn: getVal('rec-descriptionBn'),
    descriptionEn: getVal('rec-descriptionEn'),
    openingHoursBn: getVal('rec-openingHoursBn'),
    openingHours: getVal('rec-openingHoursBn'),
    feesNoticeBn: getVal('rec-feesNoticeBn'),
    website: getVal('rec-website') || null,
    directionsUrl: getVal('rec-directionsUrl') || null,
    mapEmbedUrl: cleanMap || null,
    imageUrls: images,
    photos: images,
    imageUrl: images.length > 0 ? images[0] : null,
    verifiedBadgeStatus: getVal('rec-verifiedBadgeStatus', 'Verified'),
    verificationStatus: getVal('rec-verifiedBadgeStatus', 'Verified'),
    isFeatured: getVal('rec-isFeatured') === true,
    isActive: getVal('rec-isActive') !== false,
    updatedAt: new Date().toISOString()
  };

  try {
    await db.collection('records').doc(id).set(recordData, { merge: true });
    closeRecordModal();
    showToast('রেকর্ড সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
  } catch (err) {
    console.error('Error saving record:', err);
    showToast('সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

// Toggle Status & Delete
async function toggleRecordStatus(id, currentActive) {
  if (!db) return;
  try {
    await db.collection('records').doc(id).update({
      isActive: !currentActive,
      updatedAt: new Date().toISOString()
    });
    showToast('স্ট্যাটাস পরিবর্তন করা হয়েছে', 'success');
  } catch (err) {
    showToast('স্ট্যাটাস আপডেট ব্যর্থ: ' + err.message, 'error');
  }
}

async function deleteRecord(id) {
  if (!confirm(`আপনি কি নিশ্চিত যে "${id}" রেকর্ডটি মুছে ফেলতে চান?`)) return;
  if (!db) return;

  try {
    await db.collection('records').doc(id).delete();
    showToast('রেকর্ড সফলভাবে মুছে ফেলা হয়েছে', 'success');
  } catch (err) {
    showToast('মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

// ==========================================
// 6B. Categories / Divisions Management CRUD
// ==========================================

function loadCategories() {
  if (!db) return;

  db.collection('categories').onSnapshot((snapshot) => {
    const cloudDocs = [];
    snapshot.forEach((doc) => {
      cloudDocs.push({ id: doc.id, ...doc.data() });
    });

    allCategories = mergeCollectionWithSeed(cloudDocs, DEFAULT_CATEGORIES);
    allCategories.sort((a, b) => (Number(a.sortOrder) || 99) - (Number(b.sortOrder) || 99));
    updateCategoriesBadge();
    updateCategoryDropdowns();
    if (currentTab === 'categories') renderCategoriesTable();
  }, (err) => {
    console.error('Categories listen error:', err);
  });
}

async function autoSeedCategories() {
  if (!db) return;
  try {
    const batch = db.batch();
    for (const cat of DEFAULT_CATEGORIES) {
      batch.set(db.collection('categories').doc(cat.id), cat);
    }
    await batch.commit();
    console.log('Default categories auto-seeded successfully');
  } catch (e) {
    console.warn('Auto-seed categories notice:', e);
  }
}

function updateCategoriesBadge() {
  const badge = document.getElementById('categories-count-badge');
  if (badge) badge.textContent = allCategories.length;
  const countEl = document.getElementById('cat-total-count');
  if (countEl) countEl.textContent = allCategories.length;
}

function updateCategoryDropdowns() {
  const recCatSelect = document.getElementById('rec-categoryId');
  const filterCatSelect = document.getElementById('records-filter-category');
  if (!recCatSelect || allCategories.length === 0) return;

  const currentVal = recCatSelect.value;
  recCatSelect.innerHTML = allCategories.map(c => `
    <option value="${c.id}">${c.titleBn} (${c.titleEn || c.id})</option>
  `).join('');
  if (currentVal && allCategories.some(c => c.id === currentVal)) {
    recCatSelect.value = currentVal;
  }

  if (filterCatSelect) {
    const currFilter = filterCatSelect.value;
    filterCatSelect.innerHTML = `
      <option value="all">সকল ক্যাটাগরি</option>
      ${allCategories.map(c => `<option value="${c.id}">${c.titleBn}</option>`).join('')}
    `;
    if (currFilter) filterCatSelect.value = currFilter;
  }
}

function renderCategoriesTable() {
  const tbody = document.getElementById('categories-table-body');
  if (!tbody) return;

  const search = (document.getElementById('categories-search')?.value || '').toLowerCase().trim();
  const filtered = allCategories.filter(c => {
    return !search ||
      (c.titleBn && c.titleBn.toLowerCase().includes(search)) ||
      (c.titleEn && c.titleEn.toLowerCase().includes(search)) ||
      (c.id && c.id.toLowerCase().includes(search));
  });

  if (filtered.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-muted);">
          কোনো বিভাগ বা সেবা পাওয়া যায়নি। নতুন বিভাগ যোগ করতে উপরের বাটনে ক্লিক করুন।
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = filtered.map(cat => {
    const isActive = cat.isActive !== false;
    const color = cat.colorHex || '#1E5638';
    const bg = cat.bgColorHex || '#E2F0E8';
    const iconClass = getCategoryFaIcon(cat.iconName || cat.id);

    return `
      <tr>
        <td>
          <div style="width: 36px; height: 36px; border-radius: 8px; background: ${bg}; color: ${color}; display: flex; align-items: center; justify-content: center; font-size: 16px;">
            <i class="${iconClass}"></i>
          </div>
        </td>
        <td><code>${cat.id}</code></td>
        <td><strong>${cat.titleBn || '—'}</strong></td>
        <td>${cat.titleEn || '—'}</td>
        <td style="font-size: 12px; color: var(--text-muted);">${cat.subtitleBn || cat.subtitleEn || '—'}</td>
        <td><span class="badge badge-gray">${cat.sortOrder || 1}</span></td>
        <td>
          <span class="badge ${isActive ? 'badge-success' : 'badge-danger'}">
            ${isActive ? 'সক্রিয় (Active)' : 'নিষ্ক্রিয় (Draft)'}
          </span>
        </td>
        <td>
          <div class="action-btns">
            <button class="action-btn edit" onclick="openEditCategoryModal('${cat.id}')" title="সম্পাদনা করুন">
              <i class="fas fa-edit"></i>
            </button>
            <button class="action-btn" onclick="toggleCategoryStatus('${cat.id}', ${isActive})" title="${isActive ? 'নিষ্ক্রিয় করুন' : 'সক্রিয় করুন'}" style="color: ${isActive ? 'var(--warning)' : 'var(--success)'}">
              <i class="fas ${isActive ? 'fa-eye-slash' : 'fa-eye'}"></i>
            </button>
            <button class="action-btn delete" onclick="deleteCategory('${cat.id}')" title="মুছে ফেলুন">
              <i class="fas fa-trash-alt"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

function getCategoryFaIcon(name) {
  const n = (name || '').toLowerCase().replace(/^(fa-|fas |far )/, '');
  const map = {
    emergency: 'fas fa-ambulance',
    ambulance: 'fas fa-ambulance',
    hospital: 'fas fa-hospital',
    police: 'fas fa-shield-alt',
    fire: 'fas fa-fire-extinguisher',
    train: 'fas fa-train',
    bus: 'fas fa-bus',
    tourism: 'fas fa-camera',
    government: 'fas fa-landmark',
    education: 'fas fa-school',
    food: 'fas fa-utensils',
    craft: 'fas fa-paint-brush',
    agriculture: 'fas fa-seedling',
    blood: 'fas fa-tint',
    bolt: 'fas fa-bolt',
    phone: 'fas fa-phone-volume',
    map: 'fas fa-map-marked-alt'
  };
  return map[n] || 'fas fa-th-large';
}

function openAddCategoryModal() {
  document.getElementById('category-modal-title').textContent = 'নতুন সেবা / বিভাগ যোগ করুন';
  const form = document.getElementById('category-form');
  if (form) form.reset();
  const idEl = document.getElementById('cat-id');
  if (idEl) {
    idEl.disabled = false;
    idEl.value = 'cat_' + Date.now().toString(36);
  }
  setVal('cat-colorHex', '#1E5638');
  setVal('cat-colorPicker', '#1E5638');
  setVal('cat-bgColorHex', '#E2F0E8');
  setVal('cat-sortOrder', (allCategories.length + 1).toString());
  setVal('cat-isActive', true);

  document.body.classList.add('modal-open');
  const modal = document.getElementById('category-modal');
  if (modal) modal.classList.add('active');
}

function openEditCategoryModal(id) {
  const cat = allCategories.find(c => c.id === id);
  if (!cat) return;

  document.getElementById('category-modal-title').textContent = `বিভাগ সম্পাদনা: ${cat.titleBn}`;
  const idEl = document.getElementById('cat-id');
  if (idEl) {
    idEl.value = cat.id;
    idEl.disabled = true;
  }
  setVal('cat-titleBn', cat.titleBn || '');
  setVal('cat-titleEn', cat.titleEn || '');
  setVal('cat-subtitleBn', cat.subtitleBn || '');
  setVal('cat-subtitleEn', cat.subtitleEn || '');
  setVal('cat-iconName', cat.iconName || 'emergency');
  setVal('cat-colorHex', cat.colorHex || '#1E5638');
  setVal('cat-colorPicker', cat.colorHex || '#1E5638');
  setVal('cat-bgColorHex', cat.bgColorHex || '#E2F0E8');
  setVal('cat-sortOrder', (cat.sortOrder || 1).toString());
  setVal('cat-isActive', cat.isActive !== false);

  document.body.classList.add('modal-open');
  const modal = document.getElementById('category-modal');
  if (modal) modal.classList.add('active');
}

function closeCategoryModal() {
  document.body.classList.remove('modal-open');
  const modal = document.getElementById('category-modal');
  if (modal) modal.classList.remove('active');
}

window.openAddCategoryModal = openAddCategoryModal;
window.openEditCategoryModal = openEditCategoryModal;
window.closeCategoryModal = closeCategoryModal;
window.deleteCategory = deleteCategory;
window.toggleCategoryStatus = toggleCategoryStatus;
window.toggleRecordStatus = toggleRecordStatus;
window.deleteRecord = deleteRecord;

document.getElementById('category-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) {
    showToast('ফায়ারবেজ সংযুক্ত নেই!', 'error');
    return;
  }

  const id = getVal('cat-id').toLowerCase().replace(/\s+/g, '_');
  if (!id) {
    showToast('আইডি খালি রাখা যাবে না', 'error');
    return;
  }

  const catData = {
    id: id,
    titleBn: getVal('cat-titleBn'),
    titleEn: getVal('cat-titleEn'),
    subtitleBn: getVal('cat-subtitleBn'),
    subtitleEn: getVal('cat-subtitleEn'),
    iconName: getVal('cat-iconName', 'emergency'),
    colorHex: getVal('cat-colorHex', '#1E5638'),
    bgColorHex: getVal('cat-bgColorHex', '#E2F0E8'),
    sortOrder: parseInt(getVal('cat-sortOrder', '1'), 10) || 1,
    isActive: getVal('cat-isActive') !== false,
    updatedAt: new Date().toISOString()
  };

  try {
    await db.collection('categories').doc(id).set(catData, { merge: true });
    closeCategoryModal();
    showToast('সেবা / বিভাগ সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
  } catch (err) {
    console.error('Error saving category:', err);
    showToast('বিভাগ সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

async function deleteCategory(id) {
  if (!confirm(`আপনি কি নিশ্চিত যে "${id}" বিভাগটি স্থায়ীভাবে মুছে ফেলতে চান?\nনাগরিক মোবাইল অ্যাপ থেকেও এই বিভাগটি অপসারণ হবে।`)) return;
  if (!db) return;

  try {
    await db.collection('categories').doc(id).delete();
    showToast('বিভাগ সফলভাবে মুছে ফেলা হয়েছে', 'success');
  } catch (err) {
    showToast('মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

async function toggleCategoryStatus(id, currentActive) {
  if (!db) return;
  try {
    await db.collection('categories').doc(id).update({
      isActive: !currentActive,
      updatedAt: new Date().toISOString()
    });
    showToast(`বিভাগ ${!currentActive ? 'সক্রিয়' : 'নিষ্ক্রিয়'} করা হয়েছে`, 'success');
  } catch (err) {
    showToast('স্ট্যাটাস পরিবর্তন ব্যর্থ: ' + err.message, 'error');
  }
}

// ==========================================
// 7. Relational Tables CRUD (Healthcare, Surgeries, Transport, IU Halls, Hotlines)
// ==========================================

// --- A. Healthcare Fees ---
let currentHealthcareData = [];

function openAddHealthcareModal() {
  document.getElementById('healthcare-modal-title').textContent = 'নতুন বেড / ফি যুক্ত করুন';
  document.getElementById('healthcare-form').reset();
  document.getElementById('hf-id').value = 'hf_' + Date.now().toString(36);
  document.body.classList.add('modal-open');
  document.getElementById('healthcare-modal').classList.add('active');
}

function openEditHealthcareModal(id) {
  const item = currentHealthcareData.find(d => d.id === id);
  if (!item) return;
  document.getElementById('healthcare-modal-title').textContent = 'বেড / ফি সম্পাদনা';
  document.getElementById('hf-id').value = item.id;
  document.getElementById('hf-facilityNameBn').value = item.facilityNameBn || '';
  document.getElementById('hf-bedTypeBn').value = item.bedTypeBn || '';
  document.getElementById('hf-feeBdt').value = item.feeBdt !== undefined ? item.feeBdt : 0;
  document.getElementById('hf-isFree').checked = item.isFree === true;
  document.getElementById('hf-noteBn').value = item.noteBn || '';
  document.body.classList.add('modal-open');
  document.getElementById('healthcare-modal').classList.add('active');
}

function closeHealthcareModal() {
  document.body.classList.remove('modal-open');
  document.getElementById('healthcare-modal').classList.remove('active');
}

document.getElementById('healthcare-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('hf-id').value.trim() || 'hf_' + Date.now().toString(36);
  const data = {
    id: id,
    facilityNameBn: document.getElementById('hf-facilityNameBn').value.trim(),
    bedTypeBn: document.getElementById('hf-bedTypeBn').value.trim(),
    feeBdt: parseFloat(document.getElementById('hf-feeBdt').value) || 0,
    isFree: document.getElementById('hf-isFree').checked,
    noteBn: document.getElementById('hf-noteBn').value.trim(),
    updatedAt: new Date().toISOString()
  };
  try {
    await db.collection('healthcare_fees').doc(id).set(data, { merge: true });
    closeHealthcareModal();
    showToast('হাসপাতাল ফি সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
    renderHealthcareTable();
  } catch (err) {
    showToast('সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

async function renderHealthcareTable() {
  const tbody = document.getElementById('healthcare-table-body');
  if (!tbody || !db) return;
  try {
    const snap = await db.collection('healthcare_fees').get();
    const cloudDocs = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    currentHealthcareData = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.healthcareFees : []));
    if (currentHealthcareData.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো ডেটা নেই। "+ নতুন বেড/ফি যোগ করুন" বাটনে ক্লিক করুন।</td></tr>`;
      return;
    }
    tbody.innerHTML = currentHealthcareData.map(d => `
      <tr>
        <td><strong>${d.facilityNameBn || '—'}</strong></td>
        <td>${d.bedTypeBn || '—'}</td>
        <td><span class="badge ${d.isFree ? 'badge-success' : 'badge-warning'}">${d.isFree ? 'ফ্রি' : '৳' + d.feeBdt}</span></td>
        <td>${d.noteBn || '—'}</td>
        <td style="text-align: right;">
          <div class="action-btns" style="justify-content: flex-end;">
            <button class="action-btn edit" onclick="openEditHealthcareModal('${d.id}')" title="সম্পাদনা করুন"><i class="fas fa-edit"></i></button>
            <button class="action-btn delete" onclick="deleteRelationalItem('healthcare_fees', '${d.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
          </div>
        </td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="5" style="color: red;">ত্রুটি: ${e.message}</td></tr>`;
  }
}

// --- B. Surgery Schedules ---
let currentSurgeryData = [];

function openAddSurgeryModal() {
  document.getElementById('surgery-modal-title').textContent = 'নতুন সার্জারি শিডিউল যুক্ত করুন';
  document.getElementById('surgery-form').reset();
  document.getElementById('sg-id').value = 'sg_' + Date.now().toString(36);
  document.body.classList.add('modal-open');
  document.getElementById('surgery-modal').classList.add('active');
}

function openEditSurgeryModal(id) {
  const item = currentSurgeryData.find(d => d.id === id);
  if (!item) return;
  document.getElementById('surgery-modal-title').textContent = 'সার্জারি শিডিউল সম্পাদনা';
  document.getElementById('sg-id').value = item.id;
  document.getElementById('sg-departmentBn').value = item.departmentBn || '';
  document.getElementById('sg-surgeryTypeBn').value = item.surgeryTypeBn || '';
  document.getElementById('sg-scheduleDaysBn').value = item.scheduleDaysBn || '';
  document.getElementById('sg-wardOrOtBn').value = item.wardOrOtBn || '';
  document.body.classList.add('modal-open');
  document.getElementById('surgery-modal').classList.add('active');
}

function closeSurgeryModal() {
  document.body.classList.remove('modal-open');
  document.getElementById('surgery-modal').classList.remove('active');
}

document.getElementById('surgery-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('sg-id').value.trim() || 'sg_' + Date.now().toString(36);
  const data = {
    id: id,
    departmentBn: document.getElementById('sg-departmentBn').value.trim(),
    surgeryTypeBn: document.getElementById('sg-surgeryTypeBn').value.trim(),
    scheduleDaysBn: document.getElementById('sg-scheduleDaysBn').value.trim(),
    wardOrOtBn: document.getElementById('sg-wardOrOtBn').value.trim(),
    _deleted: false,
    isDeleted: false,
    updatedAt: new Date().toISOString()
  };
  try {
    await db.collection('surgery_schedules').doc(id).set(data, { merge: true });
    closeSurgeryModal();
    showToast('সার্জারি শিডিউল সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
    renderSurgeriesTable();
  } catch (err) {
    showToast('সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

async function renderSurgeriesTable() {
  const tbody = document.getElementById('surgeries-table-body');
  if (!tbody || !db) return;
  try {
    const snap = await db.collection('surgery_schedules').get();
    const cloudDocs = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    currentSurgeryData = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.surgerySchedules : []));
    if (currentSurgeryData.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো ডেটা নেই। "+ নতুন সার্জারি শিডিউল যোগ করুন" বাটনে ক্লিক করুন।</td></tr>`;
      return;
    }
    tbody.innerHTML = currentSurgeryData.map(d => `
      <tr>
        <td><strong>${d.departmentBn || '—'}</strong></td>
        <td>${d.surgeryTypeBn || '—'}</td>
        <td><span class="badge badge-primary">${d.scheduleDaysBn || '—'}</span></td>
        <td>${d.wardOrOtBn || '—'}</td>
        <td style="text-align: right;">
          <div class="action-btns" style="justify-content: flex-end;">
            <button class="action-btn edit" onclick="openEditSurgeryModal('${d.id}')" title="সম্পাদনা করুন"><i class="fas fa-edit"></i></button>
            <button class="action-btn delete" onclick="deleteRelationalItem('surgery_schedules', '${d.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
          </div>
        </td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="5" style="color: red;">ত্রুটি: ${e.message}</td></tr>`;
  }
}

// --- C. Transport Schedules ---
let currentTransportData = [];

function openAddTransportModal() {
  document.getElementById('transport-modal-title').textContent = 'নতুন ট্রেন শিডিউল যুক্ত করুন';
  document.getElementById('transport-form').reset();
  document.getElementById('tr-id').value = 'tr_' + Date.now().toString(36);
  document.body.classList.add('modal-open');
  document.getElementById('transport-modal').classList.add('active');
}

function openEditTransportModal(id) {
  const item = currentTransportData.find(d => d.id === id);
  if (!item) return;
  document.getElementById('transport-modal-title').textContent = 'ট্রেন শিডিউল সম্পাদনা';
  document.getElementById('tr-id').value = item.id;
  document.getElementById('tr-trainNumber').value = item.trainNumber || '';
  document.getElementById('tr-trainNameBn').value = item.trainNameBn || '';
  document.getElementById('tr-routeBn').value = item.routeBn || '';
  document.getElementById('tr-offDayBn').value = item.offDayBn || '';
  document.body.classList.add('modal-open');
  document.getElementById('transport-modal').classList.add('active');
}

function closeTransportModal() {
  document.body.classList.remove('modal-open');
  document.getElementById('transport-modal').classList.remove('active');
}

document.getElementById('transport-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('tr-id').value.trim() || 'tr_' + Date.now().toString(36);
  const data = {
    id: id,
    trainNumber: document.getElementById('tr-trainNumber').value.trim(),
    trainNameBn: document.getElementById('tr-trainNameBn').value.trim(),
    routeBn: document.getElementById('tr-routeBn').value.trim(),
    offDayBn: document.getElementById('tr-offDayBn').value.trim(),
    updatedAt: new Date().toISOString()
  };
  try {
    await db.collection('transport_schedules').doc(id).set(data, { merge: true });
    closeTransportModal();
    showToast('ট্রেন শিডিউল সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
    renderTransportTable();
  } catch (err) {
    showToast('সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

async function renderTransportTable() {
  const tbody = document.getElementById('transport-table-body');
  if (!tbody || !db) return;
  try {
    const snap = await db.collection('transport_schedules').get();
    const cloudDocs = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    currentTransportData = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.trainSchedules : []));
    if (currentTransportData.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো ডেটা নেই। "+ নতুন ট্রেন শিডিউল যোগ করুন" বাটনে ক্লিক করুন।</td></tr>`;
      return;
    }
    tbody.innerHTML = currentTransportData.map(d => `
      <tr>
        <td><span class="badge badge-primary">${d.trainNumber || '—'}</span></td>
        <td><strong>${d.trainNameBn || '—'}</strong></td>
        <td>${d.routeBn || '—'}</td>
        <td><span class="badge badge-danger">${d.offDayBn || 'নাই'}</span></td>
        <td style="text-align: right;">
          <div class="action-btns" style="justify-content: flex-end;">
            <button class="action-btn edit" onclick="openEditTransportModal('${d.id}')" title="সম্পাদনা করুন"><i class="fas fa-edit"></i></button>
            <button class="action-btn delete" onclick="deleteRelationalItem('transport_schedules', '${d.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
          </div>
        </td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="5" style="color: red;">ত্রুটি: ${e.message}</td></tr>`;
  }
}

// --- D. IU Halls ---
let currentIUHallData = [];

function openAddIUHallModal() {
  document.getElementById('iu-hall-modal-title').textContent = 'নতুন ইবি আবাসিক হল যুক্ত করুন';
  document.getElementById('iu-hall-form').reset();
  document.getElementById('iuh-id').value = 'hall_' + Date.now().toString(36);
  document.body.classList.add('modal-open');
  document.getElementById('iu-hall-modal').classList.add('active');
}

function openEditIUHallModal(id) {
  const item = currentIUHallData.find(d => d.id === id);
  if (!item) return;
  document.getElementById('iu-hall-modal-title').textContent = 'ইবি আবাসিক হল সম্পাদনা';
  document.getElementById('iuh-id').value = item.id;
  document.getElementById('iuh-hallNameBn').value = item.hallNameBn || '';
  document.getElementById('iuh-studentTypeBn').value = item.studentTypeBn || 'ছাত্র';
  document.getElementById('iuh-provostNameBn').value = item.provostNameBn || '';
  document.getElementById('iuh-contactPhone').value = item.contactPhone || '';
  document.body.classList.add('modal-open');
  document.getElementById('iu-hall-modal').classList.add('active');
}

function closeIUHallModal() {
  document.body.classList.remove('modal-open');
  document.getElementById('iu-hall-modal').classList.remove('active');
}

document.getElementById('iu-hall-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('iuh-id').value.trim() || 'hall_' + Date.now().toString(36);
  const data = {
    id: id,
    hallNameBn: document.getElementById('iuh-hallNameBn').value.trim(),
    studentTypeBn: document.getElementById('iuh-studentTypeBn').value,
    provostNameBn: document.getElementById('iuh-provostNameBn').value.trim(),
    contactPhone: document.getElementById('iuh-contactPhone').value.trim(),
    _deleted: false,
    isDeleted: false,
    updatedAt: new Date().toISOString()
  };
  try {
    await db.collection('iu_halls').doc(id).set(data, { merge: true });
    closeIUHallModal();
    showToast('ইবি হলের তথ্য সংরক্ষণ করা হয়েছে!', 'success');
    renderIUHallsTable();
  } catch (err) {
    showToast('সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

async function renderIUHallsTable() {
  const tbody = document.getElementById('iu-halls-table-body');
  if (!tbody || !db) return;
  try {
    const snap = await db.collection('iu_halls').get();
    const cloudDocs = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    currentIUHallData = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.iuHalls : []));
    if (currentIUHallData.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো ডেটা নেই। "+ নতুন হল যোগ করুন" বাটনে ক্লিক করুন।</td></tr>`;
      return;
    }
    tbody.innerHTML = currentIUHallData.map(d => `
      <tr>
        <td><strong>${d.hallNameBn || '—'}</strong></td>
        <td><span class="badge badge-gray">${d.studentTypeBn || '—'}</span></td>
        <td>${d.provostNameBn || '—'}</td>
        <td>${d.contactPhone || '—'}</td>
        <td style="text-align: right;">
          <div class="action-btns" style="justify-content: flex-end;">
            <button class="action-btn edit" onclick="openEditIUHallModal('${d.id}')" title="সম্পাদনা করুন"><i class="fas fa-edit"></i></button>
            <button class="action-btn delete" onclick="deleteRelationalItem('iu_halls', '${d.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
          </div>
        </td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="5" style="color: red;">ত্রুটি: ${e.message}</td></tr>`;
  }
}

// --- E. National Hotlines ---
let currentHotlineData = [];

function openAddHotlineModal() {
  document.getElementById('hotline-modal-title').textContent = 'নতুন জাতীয় হটলাইন যোগ করুন';
  document.getElementById('hotline-form').reset();
  document.getElementById('hl-id').value = 'hl_' + Date.now().toString(36);
  document.body.classList.add('modal-open');
  document.getElementById('hotline-modal').classList.add('active');
}

function openEditHotlineModal(id) {
  const item = currentHotlineData.find(d => d.id === id);
  if (!item) return;
  document.getElementById('hotline-modal-title').textContent = 'হটলাইন সম্পাদনা';
  document.getElementById('hl-id').value = item.id;
  document.getElementById('hl-hotlineNumber').value = item.number || item.hotlineNumber || '';
  document.getElementById('hl-titleBn').value = item.titleBn || '';
  document.getElementById('hl-titleEn').value = item.titleEn || '';
  document.getElementById('hl-descriptionBn').value = item.descriptionBn || '';
  document.body.classList.add('modal-open');
  document.getElementById('hotline-modal').classList.add('active');
}

function closeHotlineModal() {
  document.body.classList.remove('modal-open');
  document.getElementById('hotline-modal').classList.remove('active');
}

document.getElementById('hotline-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('hl-id').value.trim() || 'hl_' + Date.now().toString(36);
  const data = {
    id: id,
    number: document.getElementById('hl-hotlineNumber').value.trim(),
    hotlineNumber: document.getElementById('hl-hotlineNumber').value.trim(),
    titleBn: document.getElementById('hl-titleBn').value.trim(),
    titleEn: document.getElementById('hl-titleEn').value.trim(),
    descriptionBn: document.getElementById('hl-descriptionBn').value.trim(),
    _deleted: false,
    isDeleted: false,
    updatedAt: new Date().toISOString()
  };
  try {
    await db.collection('national_hotlines').doc(id).set(data, { merge: true });
    closeHotlineModal();
    showToast('হটলাইন সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
    renderHotlinesTable();
  } catch (err) {
    showToast('সংরক্ষণ ব্যর্থ: ' + err.message, 'error');
  }
});

async function renderHotlinesTable() {
  const tbody = document.getElementById('hotlines-table-body');
  if (!tbody || !db) return;
  try {
    const snap = await db.collection('national_hotlines').get();
    const cloudDocs = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    currentHotlineData = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.nationalHotlines : []));
    if (currentHotlineData.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো ডেটা নেই। "+ নতুন হটলাইন যোগ করুন" বাটনে ক্লিক করুন।</td></tr>`;
      return;
    }
    tbody.innerHTML = currentHotlineData.map(d => `
      <tr>
        <td><span class="badge badge-danger" style="font-size: 14px; font-weight: 700;">${d.number || d.hotlineNumber || '—'}</span></td>
        <td><strong>${d.titleBn || '—'}</strong></td>
        <td>${d.titleEn || '—'}</td>
        <td>${d.descriptionBn || '—'}</td>
        <td style="text-align: right;">
          <div class="action-btns" style="justify-content: flex-end;">
            <button class="action-btn edit" onclick="openEditHotlineModal('${d.id}')" title="সম্পাদনা করুন"><i class="fas fa-edit"></i></button>
            <button class="action-btn delete" onclick="deleteRelationalItem('national_hotlines', '${d.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
          </div>
        </td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="5" style="color: red;">ত্রুটি: ${e.message}</td></tr>`;
  }
}

async function deleteRelationalItem(collectionName, docId) {
  if (!confirm(`আপনি কি এই রেকর্ডটি মুছে ফেলতে চান?`)) return;
  if (!db) return;
  try {
    await db.collection(collectionName).doc(docId).set({ _deleted: true, isDeleted: true }, { merge: true });
    showToast('সফলভাবে মুছে ফেলা হয়েছে', 'success');
    if (collectionName === 'healthcare_fees') renderHealthcareTable();
    if (collectionName === 'surgery_schedules') renderSurgeriesTable();
    if (collectionName === 'transport_schedules') renderTransportTable();
    if (collectionName === 'iu_halls') renderIUHallsTable();
    if (collectionName === 'national_hotlines') renderHotlinesTable();
  } catch (e) {
    showToast('মুছতে ব্যর্থ: ' + e.message, 'error');
  }
}

// Explicit window bindings for all HTML onclick handlers
window.openAddHealthcareModal = openAddHealthcareModal;
window.openEditHealthcareModal = openEditHealthcareModal;
window.closeHealthcareModal = closeHealthcareModal;

window.openAddSurgeryModal = openAddSurgeryModal;
window.openEditSurgeryModal = openEditSurgeryModal;
window.closeSurgeryModal = closeSurgeryModal;

window.openAddTransportModal = openAddTransportModal;
window.openEditTransportModal = openEditTransportModal;
window.closeTransportModal = closeTransportModal;

window.openAddIUHallModal = openAddIUHallModal;
window.openEditIUHallModal = openEditIUHallModal;
window.closeIUHallModal = closeIUHallModal;

window.openAddHotlineModal = openAddHotlineModal;
window.openEditHotlineModal = openEditHotlineModal;
window.closeHotlineModal = closeHotlineModal;

window.deleteRelationalItem = deleteRelationalItem;
window.toggleRecordStatus = toggleRecordStatus;
window.deleteRecord = deleteRecord;
window.switchTab = switchTab;

// 8. One-Click Database Seeding Function
async function seedAllCanonicalData() {
  if (!db) {
    showToast('ফায়ারবেজ ডাটাবেজ সংযুক্ত নেই!', 'error');
    return;
  }

  const btn = document.getElementById('seed-btn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> ডাটাবেজে সিড করা হচ্ছে...';

  try {
    const batch = db.batch();

    // 1. Seed Upazilas
    for (const upz of SEED_DATA.upazilas) {
      batch.set(db.collection('upazilas').doc(upz.id), upz);
    }

    // 2. Seed Healthcare Fees
    for (const fee of SEED_DATA.healthcareFees) {
      batch.set(db.collection('healthcare_fees').doc(fee.id), fee);
    }

    // 3. Seed Surgeries
    for (const surg of SEED_DATA.surgerySchedules) {
      batch.set(db.collection('surgery_schedules').doc(surg.id), surg);
    }

    // 4. Seed Train Schedules
    for (const train of SEED_DATA.trainSchedules) {
      batch.set(db.collection('transport_schedules').doc(train.id), train);
    }

    // 5. Seed IU Halls
    for (const hall of SEED_DATA.iuHalls) {
      batch.set(db.collection('iu_halls').doc(hall.id), hall);
    }

    // 6. Seed Hotlines
    for (const hl of SEED_DATA.nationalHotlines) {
      batch.set(db.collection('national_hotlines').doc(hl.id), hl);
    }

    // 7. Seed Core Master Records
    if (SEED_DATA.masterRecords) {
      for (const rec of SEED_DATA.masterRecords) {
        batch.set(db.collection('records').doc(rec.id), rec);
      }
    }

    // 8. Seed Travel Guide Local Routes
    if (SEED_DATA.localRoutes) {
      for (const route of SEED_DATA.localRoutes) {
        batch.set(db.collection('travel_local_routes').doc(route.id), route);
      }
    }

    // 9. Seed Travel Guide Destinations
    if (SEED_DATA.travelDestinations) {
      for (const dest of SEED_DATA.travelDestinations) {
        batch.set(db.collection('travel_destinations').doc(dest.id), dest);
      }
    }

    // 10. Seed Travel Guide Bus Operators
    if (SEED_DATA.busOperators) {
      for (const opr of SEED_DATA.busOperators) {
        batch.set(db.collection('travel_bus_operators').doc(opr.id), opr);
      }
    }

    // 11. Seed Categories
    for (const cat of DEFAULT_CATEGORIES) {
      batch.set(db.collection('categories').doc(cat.id), cat);
    }

    // 12. Seed Global Notice
    if (SEED_DATA.globalNotice) {
      batch.set(db.collection('app_config').doc('global_notice'), SEED_DATA.globalNotice);
    }

    await batch.commit();
    showToast('ভ্রমণ গাইড, রেকর্ড, নোটিশ ও সকল ক্যানোনিকাল ডাটা ফায়ারবেজে সফলভাবে সিড করা হয়েছে!', 'success');
  } catch (err) {
    console.error('Seeding error:', err);
    showToast('সিডিং ব্যর্থ হয়েছে: ' + err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '<i class="fas fa-database"></i> সব ক্যানোনিকাল ডাটা সিড করুন (Seed Database)';
  }
}

// 9. Firebase Settings Form
document.getElementById('firebase-config-form')?.addEventListener('submit', (e) => {
  e.preventDefault();
  const config = {
    apiKey: document.getElementById('cfg-apiKey').value.trim(),
    authDomain: document.getElementById('cfg-authDomain').value.trim(),
    projectId: document.getElementById('cfg-projectId').value.trim(),
    storageBucket: document.getElementById('cfg-storageBucket').value.trim(),
    messagingSenderId: document.getElementById('cfg-messagingSenderId').value.trim(),
    appId: document.getElementById('cfg-appId').value.trim()
  };

  localStorage.setItem('amar_kushtia_firebase_config', JSON.stringify(config));
  showToast('ফায়ারবেজ কনফিগারেশন সংরক্ষণ করা হয়েছে! পেজ রিলোড হচ্ছে...', 'success');
  setTimeout(() => {
    window.location.reload();
  }, 1200);
});

// Helper Functions
function getCategoryNameBn(catId) {
  if (!catId) return 'অন্যান্য';
  const found = allCategories.find(c => c.id.toLowerCase() === catId.toLowerCase());
  if (found && found.titleBn) return found.titleBn;
  const map = {
    emergency: 'জরুরি সেবা',
    healthcare: 'স্বাস্থ্যসেবা',
    police: 'আইনশৃঙ্খলা ও থানা',
    fire: 'ফায়ার সার্ভিস',
    tourism: 'পর্যটন ও ঐতিহ্য',
    education: 'শিক্ষা প্রতিষ্ঠান',
    transport: 'পরিবহন ও যোগাযোগ',
    government: 'সরকারি অফিস',
    food: 'খাবার ও মিষ্টান্ন',
    craft: 'হস্তশিল্প ও ঐতিহ্য',
    agriculture: 'কৃষি ও প্রাণিসম্পদ',
    blood_bank: 'রক্তদান ও ব্লাড ব্যাংক'
  };
  return map[catId] || catId;
}

function getUpazilaNameBn(upzId) {
  const map = {
    kushtia_sadar: 'কুষ্টিয়া সদর',
    kumarkhali: 'কুমারখালী',
    bheramara: 'ভেড়ামারা',
    mirpur: 'মিরপুর',
    daulatpur: 'দৌলতপুর',
    khoksa: 'খোকসা'
  };
  return map[upzId] || upzId || 'কুষ্টিয়া';
}

function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
    <span>${message}</span>
  `;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(100%)';
    toast.style.transition = 'all 0.3s';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// ==========================================
// 10. Travel Guide CMS & Broadcast Notification Logic
// ==========================================

let allRoutes = [];
let allDestinations = [];
let allOperators = [];
let allNotifications = [];
let currentTravelSubtab = 'routes';

function switchTravelGuideSubtab(subtab) {
  currentTravelSubtab = subtab;
  document.querySelectorAll('.tg-subtab-content').forEach(el => el.style.display = 'none');
  const target = document.getElementById(`tg-subtab-${subtab}`);
  if (target) target.style.display = 'block';

  if (subtab === 'routes') renderRoutesTable();
  if (subtab === 'destinations') renderDestinationsTable();
  if (subtab === 'operators') renderOperatorsTable();
}

function renderTravelGuide() {
  if (!db) return;
  loadTravelGuideData();
  switchTravelGuideSubtab(currentTravelSubtab);
}

function loadTravelGuideData() {
  if (!db) return;

  // Local routes listener (Merged with Seed Data so routes never disappear)
  db.collection('travel_local_routes').onSnapshot(snap => {
    const cloudDocs = [];
    snap.forEach(d => cloudDocs.push({ id: d.id, ...d.data() }));
    allRoutes = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.localRoutes : []));
    if (currentTab === 'travel_guide' && currentTravelSubtab === 'routes') renderRoutesTable();
  }, err => console.warn('Routes listen note:', err));

  // Destinations listener (Merged with Seed Data so destinations never disappear)
  db.collection('travel_destinations').onSnapshot(snap => {
    const cloudDocs = [];
    snap.forEach(d => cloudDocs.push({ id: d.id, ...d.data() }));
    allDestinations = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.travelDestinations : []));
    if (currentTab === 'travel_guide' && currentTravelSubtab === 'destinations') renderDestinationsTable();
  }, err => console.warn('Destinations listen note:', err));

  // Operators listener (Merged with Seed Data so bus operators never disappear)
  db.collection('travel_bus_operators').onSnapshot(snap => {
    const cloudDocs = [];
    snap.forEach(d => cloudDocs.push({ id: d.id, ...d.data() }));
    allOperators = mergeCollectionWithSeed(cloudDocs, (typeof SEED_DATA !== 'undefined' ? SEED_DATA.busOperators : []));
    if (currentTab === 'travel_guide' && currentTravelSubtab === 'operators') renderOperatorsTable();
  }, err => console.warn('Operators listen note:', err));
}

function renderRoutesTable() {
  const tbody = document.getElementById('tg-routes-table-body');
  if (!tbody) return;

  if (allRoutes.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 24px;">কোনো বাস রুট পাওয়া যায়নি। নতুন রুট যোগ করুন বা সিড করুন।</td></tr>';
    return;
  }

  tbody.innerHTML = allRoutes.map(r => {
    const stopsCount = (r.stops && r.stops.length) ? r.stops.length : 0;
    const isPub = r.isPublished !== false;
    return `
      <tr>
        <td><code>${r.id}</code></td>
        <td>
          <strong>${r.nameBn || r.nameEn}</strong><br>
          <small style="color: var(--text-muted);">${r.nameEn || ''}</small>
        </td>
        <td>${r.origin || 'কুষ্টিয়া'} ➔ ${r.destination || ''}</td>
        <td><span class="badge blue">${stopsCount} টি স্টপ</span></td>
        <td><span class="badge ${isPub ? 'green' : 'amber'}">${isPub ? 'সক্রিয়' : 'খসড়া'}</span></td>
        <td style="text-align: right; white-space: nowrap;">
          <button class="action-btn" onclick="viewRouteFaresMatrix('${r.id}')" title="কাউন্টার-টু-কাউন্টার ভাড়া দেখুন" style="color: var(--primary);"><i class="fas fa-ticket-alt"></i></button>
          <button class="action-btn edit" onclick="editLocalRoute('${r.id}')" title="সম্পাদনা"><i class="fas fa-edit"></i></button>
          <button class="action-btn delete" onclick="deleteLocalRoute('${r.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
        </td>
      </tr>
    `;
  }).join('');
}

function renderDestinationsTable() {
  const tbody = document.getElementById('tg-destinations-table-body');
  if (!tbody) return;

  if (allDestinations.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো গন্তব্য নেই</td></tr>';
    return;
  }

  tbody.innerHTML = allDestinations.map(d => `
    <tr>
      <td><code>${d.id}</code></td>
      <td><strong>${d.nameBn}</strong> (${d.nameEn || ''})</td>
      <td>${d.division || '—'}</td>
      <td>${d.sortOrder || 1}</td>
      <td style="text-align: right; white-space: nowrap;">
        <button class="action-btn edit" onclick="openEditDestinationModal('${d.id}')" title="সম্পাদনা"><i class="fas fa-edit"></i></button>
        <button class="action-btn delete" onclick="deleteDestination('${d.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
      </td>
    </tr>
  `).join('');
}

function renderOperatorsTable() {
  const tbody = document.getElementById('tg-operators-table-body');
  if (!tbody) return;

  if (allOperators.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 24px;">কোনো বাস অপারেটর নেই</td></tr>';
    return;
  }

  tbody.innerHTML = allOperators.map(o => {
    const countersCount = (o.counters && o.counters.length) ? o.counters.length : 0;
    const dests = (o.destinationIds || []).join(', ');
    const bType = o.busType || 'AC & Non-AC';
    const status = o.serviceStatus || 'নিয়মিত';
    const logoHtml = o.logoUrl
      ? `<img src="${o.logoUrl}" alt="${o.nameBn}" style="width: 40px; height: 40px; border-radius: 8px; object-fit: contain; background: #fff; border: 1px solid var(--border); padding: 2px; flex-shrink: 0;" onerror="this.style.display='none'">`
      : `<div style="width: 40px; height: 40px; border-radius: 8px; background: #e8f5e9; color: var(--primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0;"><i class="fas fa-bus"></i></div>`;

    return `
      <tr>
        <td>
          <div style="display: flex; gap: 10px; align-items: center;">
            ${logoHtml}
            <div>
              <strong>${o.nameBn}</strong><br>
              <small style="color: var(--text-muted);">${o.nameEn || ''}</small>
            </div>
          </div>
          <div style="margin-top: 6px;">
            <span class="badge blue" style="font-size: 11px;">${bType}</span>
            <span class="badge green" style="font-size: 11px;">${status}</span>
          </div>
        </td>
        <td>
          <div>${o.descriptionBn || '—'}</div>
          ${o.startingPoint ? `<small style="color: #d97706;"><i class="fas fa-map-marker-alt"></i> ${o.startingPoint}</small><br>` : ''}
          ${o.websiteUrl ? `<a href="${o.websiteUrl}" target="_blank" style="font-size: 12px; color: var(--primary);"><i class="fas fa-globe"></i> ${o.websiteUrl}</a>` : ''}
        </td>
        <td><span class="badge badge-primary" style="font-weight: 600;">${countersCount} টি কাউন্টার</span></td>
        <td><small>${dests || 'সকল গন্তব্য'}</small></td>
        <td style="text-align: right; white-space: nowrap;">
          <button class="action-btn" onclick="openManageCountersModal('${o.id}')" title="কাউন্টারসমূহ পরিচালনা" style="color: var(--primary);"><i class="fas fa-store"></i></button>
          <button class="action-btn edit" onclick="openEditOperatorModal('${o.id}')" title="সম্পাদনা"><i class="fas fa-edit"></i></button>
          <button class="action-btn delete" onclick="deleteOperator('${o.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
        </td>
      </tr>
    `;
  }).join('');
}

// Modal Handlers
function openAddLocalRouteModal() {
  document.getElementById('route-id').value = '';
  document.getElementById('route-nameBn').value = '';
  document.getElementById('route-nameEn').value = '';
  document.getElementById('route-origin').value = 'কুষ্টিয়া বাস টার্মিনাল';
  document.getElementById('route-destination').value = '';
  document.getElementById('route-ratePerKm').value = '2.40';
  document.getElementById('route-sameReverseFare').checked = true;
  document.getElementById('route-notes').value = '';
  document.getElementById('route-stops-input').value = '';
  document.getElementById('route-fares-input').value = '';
  document.getElementById('route-fares-count').innerText = '০ টি জোড়া';
  document.getElementById('route-modal-title').innerHTML = '<i class="fas fa-bus" style="color: var(--primary);"></i> <span>নতুন লোকাল বাস রুট যোগ করুন</span>';
  document.getElementById('route-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function closeRouteModal() {
  const modal = document.getElementById('route-modal');
  modal.classList.remove('active');
  modal.style.display = '';
  document.body.classList.remove('modal-open');
}

// Edit existing route
function editLocalRoute(id) {
  const route = allRoutes.find(r => r.id === id);
  if (!route) {
    showToast('রুট পাওয়া যায়নি: ' + id, 'error');
    return;
  }

  document.getElementById('route-id').value = route.id;
  document.getElementById('route-nameBn').value = route.nameBn || '';
  document.getElementById('route-nameEn').value = route.nameEn || '';
  document.getElementById('route-origin').value = route.origin || '';
  document.getElementById('route-destination').value = route.destination || '';
  document.getElementById('route-ratePerKm').value = route.ratePerKm || 2.40;
  document.getElementById('route-sameReverseFare').checked = route.sameReverseFare !== false;
  document.getElementById('route-notes').value = route.notes || '';

  // Format stops as "নাম (কিমি)"
  if (route.stops && route.stops.length > 0) {
    const stopsStr = route.stops.map(s => {
      const kmVal = (s.km !== undefined && s.km !== null) ? ` (${s.km})` : '';
      return `${s.nameBn || s.nameEn}${kmVal}`;
    }).join(', ');
    document.getElementById('route-stops-input').value = stopsStr;
  } else {
    document.getElementById('route-stops-input').value = '';
  }

  // Format fares
  if (route.fares && route.fares.length > 0) {
    const stopMap = {};
    (route.stops || []).forEach(s => {
      stopMap[s.id] = s.nameBn || s.nameEn;
    });

    const faresStr = route.fares.map(f => {
      const fromName = stopMap[f.fromStopId] || f.label?.split('-')[0]?.trim() || f.fromStopId;
      const toName = stopMap[f.toStopId] || f.label?.split('-')[1]?.trim() || f.toStopId;
      return `${fromName}-${toName}: ${f.fare}`;
    }).join(', ');
    document.getElementById('route-fares-input').value = faresStr;
    document.getElementById('route-fares-count').innerText = `${route.fares.length} টি জোড়া`;
  } else {
    document.getElementById('route-fares-input').value = '';
    document.getElementById('route-fares-count').innerText = '০ টি জোড়া';
  }

  document.getElementById('route-modal-title').innerHTML = `<i class="fas fa-edit" style="color: var(--primary);"></i> <span>রুট সম্পাদন: ${route.nameBn || route.nameEn}</span>`;
  document.getElementById('route-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

// Auto calculate stop-to-stop fares from stops input with kilometers
function autoCalculateFaresFromInput() {
  const stopsInput = document.getElementById('route-stops-input').value;
  const ratePerKm = parseFloat(document.getElementById('route-ratePerKm').value) || 2.40;
  
  if (!stopsInput.trim()) {
    showToast('দয়া করে প্রথমে স্টপ তালিকা লিখুন', 'warning');
    return;
  }

  const rawStops = stopsInput.split(',').map(s => s.trim()).filter(Boolean);
  const parsedStops = [];
  
  rawStops.forEach((item, idx) => {
    const kmMatch = item.match(/\(([\d\.]+)\s*(?:km|কিমি)?\)/i);
    let km = null;
    let name = item;
    if (kmMatch) {
      km = parseFloat(kmMatch[1]);
      name = item.replace(/\(([\d\.]+)\s*(?:km|কিমি)?\)/i, '').trim();
    } else {
      km = idx * 2.0; // fallback spacing if no km specified
    }
    parsedStops.push({ name, km });
  });

  const farePairs = [];
  for (let i = 0; i < parsedStops.length; i++) {
    for (let j = i + 1; j < parsedStops.length; j++) {
      const dist = Math.abs(parsedStops[j].km - parsedStops[i].km);
      const fare = Math.round(dist * ratePerKm);
      farePairs.push(`${parsedStops[i].name}-${parsedStops[j].name}: ${fare}`);
    }
  }

  document.getElementById('route-fares-input').value = farePairs.join(', ');
  document.getElementById('route-fares-count').innerText = `${farePairs.length} টি জোড়া`;
  showToast(`মোট ${farePairs.length} টি কাউন্টার-টু-কাউন্টার জোড়া হিসাব সম্পন্ন (${ratePerKm} টাকা/কিমি)`, 'success');
}

// View All Counter-to-Counter Fares Matrix Modal
let currentViewingRoute = null;
function viewRouteFaresMatrix(id) {
  const route = allRoutes.find(r => r.id === id);
  if (!route) return;

  currentViewingRoute = route;
  document.getElementById('fare-matrix-title').innerText = `${route.nameBn || route.nameEn} — কাউন্টার-টু-কাউন্টার ভাড়ার পূর্ণাঙ্গ তালিকা`;
  document.getElementById('fare-matrix-filter').value = '';
  renderFareMatrixTable(route);

  document.getElementById('fare-matrix-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function closeFareMatrixModal() {
  const modal = document.getElementById('fare-matrix-modal');
  modal.classList.remove('active');
  modal.style.display = '';
  document.body.classList.remove('modal-open');
  currentViewingRoute = null;
}

function renderFareMatrixTable(route, filterQuery = '') {
  const tbody = document.getElementById('fare-matrix-table-body');
  const summaryEl = document.getElementById('fare-matrix-summary');
  if (!tbody) return;

  const stopMap = {};
  (route.stops || []).forEach(s => {
    stopMap[s.id] = s;
  });

  let pairs = [];
  if (route.fares && route.fares.length > 0) {
    pairs = route.fares.map((f, idx) => {
      const fromStop = stopMap[f.fromStopId];
      const toStop = stopMap[f.toStopId];
      const fromName = fromStop?.nameBn || f.label?.split('-')[0]?.trim() || f.fromStopId;
      const toName = toStop?.nameBn || f.label?.split('-')[1]?.trim() || f.toStopId;
      let dist = '—';
      if (fromStop && toStop && fromStop.km !== undefined && toStop.km !== undefined) {
        dist = Math.abs(toStop.km - fromStop.km).toFixed(1);
      }
      return {
        idx: idx + 1,
        fromName,
        toName,
        dist,
        fare: f.fare
      };
    });
  }

  if (filterQuery.trim()) {
    const q = filterQuery.trim().toLowerCase();
    pairs = pairs.filter(p => p.fromName.toLowerCase().includes(q) || p.toName.toLowerCase().includes(q));
  }

  summaryEl.innerText = `মোট ভাড়ার জোড়া: ${pairs.length} টি`;

  if (pairs.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 24px; color: var(--text-muted);">কোনো ভাড়ার তথ্য পাওয়া যায়নি।</td></tr>';
    return;
  }

  tbody.innerHTML = pairs.map(p => `
    <tr>
      <td><code>${p.idx}</code></td>
      <td><strong>${p.fromName}</strong></td>
      <td><strong>${p.toName}</strong></td>
      <td><span class="badge blue">${p.dist} কিমি</span></td>
      <td style="text-align: right;"><strong style="font-size: 14px; color: var(--primary);">৳ ${p.fare}</strong></td>
    </tr>
  `).join('');
}

function filterFareMatrix() {
  if (!currentViewingRoute) return;
  const q = document.getElementById('fare-matrix-filter').value;
  renderFareMatrixTable(currentViewingRoute, q);
}

// Make functions globally available for inline onclick
window.editLocalRoute = editLocalRoute;
window.deleteLocalRoute = deleteLocalRoute;
window.viewRouteFaresMatrix = viewRouteFaresMatrix;
window.closeFareMatrixModal = closeFareMatrixModal;
window.filterFareMatrix = filterFareMatrix;
window.autoCalculateFaresFromInput = autoCalculateFaresFromInput;
window.openAddLocalRouteModal = openAddLocalRouteModal;
window.closeRouteModal = closeRouteModal;

// Destinations
window.openAddDestinationModal = openAddDestinationModal;
window.openEditDestinationModal = openEditDestinationModal;
window.closeDestinationModal = closeDestinationModal;
window.deleteDestination = deleteDestination;

// Bus Operators
window.openAddOperatorModal = openAddOperatorModal;
window.openEditOperatorModal = openEditOperatorModal;
window.closeOperatorModal = closeOperatorModal;
window.deleteOperator = deleteOperator;

// Counters
window.openManageCountersModal = openManageCountersModal;
window.closeCountersModal = closeCountersModal;
window.openAddCounterModal = openAddCounterModal;
window.openEditCounterModal = openEditCounterModal;
window.closeCounterEditModal = closeCounterEditModal;
window.deleteCounter = deleteCounter;

// Notice
window.loadGlobalNotice = loadGlobalNotice;

// Save Local Route Form Handler
document.getElementById('route-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) {
    showToast('ডাটাবেজ সংযোগ পাওয়া যায়নি', 'error');
    return;
  }

  const id = document.getElementById('route-id').value.trim() || `LR-${Date.now().toString().slice(-4)}`;
  const ratePerKm = parseFloat(document.getElementById('route-ratePerKm').value) || 2.40;
  const sameReverseFare = document.getElementById('route-sameReverseFare').checked;
  const stopsRaw = document.getElementById('route-stops-input').value.split(',').map(s => s.trim()).filter(Boolean);

  // Parse stops with distances
  const stops = stopsRaw.map((item, idx) => {
    const kmMatch = item.match(/\(([\d\.]+)\s*(?:km|কিমি)?\)/i);
    let km = null;
    let name = item;
    if (kmMatch) {
      km = parseFloat(kmMatch[1]);
      name = item.replace(/\(([\d\.]+)\s*(?:km|কিমি)?\)/i, '').trim();
    }
    return {
      id: `${id}-STP-${idx + 1}`,
      nameBn: name,
      nameEn: name,
      sequence: idx + 1,
      ...(km !== null ? { km } : {}),
      isActive: true
    };
  });

  // Parse fares
  const faresRaw = document.getElementById('route-fares-input').value.split(',').map(f => f.trim()).filter(Boolean);
  const stopByName = {};
  stops.forEach(s => {
    stopByName[s.nameBn.trim()] = s;
  });

  let fares = [];
  if (faresRaw.length > 0) {
    faresRaw.forEach(pair => {
      const parts = pair.split(':');
      if (parts.length === 2) {
        const routeLabel = parts[0].trim();
        const fareVal = parseFloat(parts[1].trim()) || 0;
        const [orig, dest] = routeLabel.split('-').map(x => x.trim());
        const fromStop = stopByName[orig] || stops.find(s => s.nameBn === orig) || stops[0];
        const toStop = stopByName[dest] || stops.find(s => s.nameBn === dest) || stops[stops.length - 1];

        fares.push({
          fromStopId: fromStop?.id || 'START',
          toStopId: toStop?.id || 'END',
          fare: fareVal,
          label: routeLabel
        });
      }
    });
  }

  // If no manual fares were entered but kilometers are present on all stops, auto-generate pairs
  if (fares.length === 0 && stops.length >= 2 && stops.every(s => s.km !== undefined)) {
    for (let i = 0; i < stops.length; i++) {
      for (let j = i + 1; j < stops.length; j++) {
        const dist = Math.abs(stops[j].km - stops[i].km);
        fares.push({
          fromStopId: stops[i].id,
          toStopId: stops[j].id,
          fare: Math.round(dist * ratePerKm)
        });
      }
    }
  }

  // Also preserve existing canonical fares if editing LR-001 and user didn't overwrite fares
  if (id === 'LR-001' && fares.length <= 1) {
    const existing = allRoutes.find(r => r.id === 'LR-001');
    if (existing && existing.fares && existing.fares.length > 1) {
      fares = existing.fares;
    }
  }

  const routeData = {
    id,
    nameBn: document.getElementById('route-nameBn').value.trim(),
    nameEn: document.getElementById('route-nameEn').value.trim(),
    origin: document.getElementById('route-origin').value.trim(),
    destination: document.getElementById('route-destination').value.trim(),
    notes: document.getElementById('route-notes').value.trim(),
    ratePerKm,
    sameReverseFare,
    stops,
    fares,
    isActive: true,
    isPublished: true,
    updatedAt: firebase.firestore.FieldValue.serverTimestamp()
  };

  try {
    await db.collection('travel_local_routes').doc(id).set(routeData, { merge: true });
    showToast('বাস রুট এবং ভাড়ার তালিকা সফলভাবে সংরক্ষিত হয়েছে!', 'success');
    closeRouteModal();
    loadTravelGuideData();
  } catch (err) {
    showToast('রুট সংরক্ষণে ব্যর্থ: ' + err.message, 'error');
  }
});

// --- Destination Modal Handlers ---
function openAddDestinationModal() {
  document.getElementById('dest-id').value = '';
  document.getElementById('dest-nameBn').value = '';
  document.getElementById('dest-nameEn').value = '';
  document.getElementById('dest-division').value = '';
  document.getElementById('dest-sortOrder').value = (allDestinations.length + 1).toString();
  document.getElementById('destination-modal-title').textContent = 'নতুন গন্তব্য যোগ করুন';
  document.getElementById('destination-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function openEditDestinationModal(id) {
  const dest = allDestinations.find(d => d.id === id);
  if (!dest) {
    showToast('গন্তব্য পাওয়া যায়নি: ' + id, 'error');
    return;
  }
  document.getElementById('dest-id').value = dest.id;
  document.getElementById('dest-nameBn').value = dest.nameBn || '';
  document.getElementById('dest-nameEn').value = dest.nameEn || '';
  document.getElementById('dest-division').value = dest.division || '';
  document.getElementById('dest-sortOrder').value = dest.sortOrder || 1;
  document.getElementById('destination-modal-title').textContent = 'গন্তব্য সম্পাদনা: ' + (dest.nameBn || dest.id);
  document.getElementById('destination-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function closeDestinationModal() {
  document.getElementById('destination-modal').classList.remove('active');
  document.body.classList.remove('modal-open');
}

// Save Destination
document.getElementById('destination-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('dest-id').value || `DST-${(allDestinations.length + 1).toString().padStart(3, '0')}`;
  const data = {
    id,
    nameBn: document.getElementById('dest-nameBn').value.trim(),
    nameEn: document.getElementById('dest-nameEn').value.trim(),
    division: document.getElementById('dest-division').value.trim(),
    sortOrder: parseInt(document.getElementById('dest-sortOrder').value) || 1,
    isActive: true
  };
  try {
    await db.collection('travel_destinations').doc(id).set(data, { merge: true });
    showToast('গন্তব্য সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
    closeDestinationModal();
    loadTravelGuideData();
  } catch (err) {
    showToast('সংরক্ষণে ব্যর্থ: ' + err.message, 'error');
  }
});

function updateOperatorLogoPreview(url) {
  const preview = document.getElementById('opr-logo-preview');
  if (!preview) return;
  if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
    preview.innerHTML = `<img src="${url}" style="width: 100%; height: 100%; object-fit: contain;" onerror="this.onerror=null; this.parentElement.innerHTML='<i class=\\'fas fa-bus\\' style=\\'color: var(--text-muted);\\'></i>';">`;
  } else {
    preview.innerHTML = `<i class="fas fa-bus" style="color: var(--text-muted); font-size: 18px;"></i>`;
  }
}
window.updateOperatorLogoPreview = updateOperatorLogoPreview;

function addRouteToOperatorInput(routeName) {
  const input = document.getElementById('opr-destinationIds');
  if (!input) return;
  const current = input.value.split(',').map(s => s.trim()).filter(Boolean);
  if (!current.includes(routeName)) {
    current.push(routeName);
    input.value = current.join(', ');
  }
}
window.addRouteToOperatorInput = addRouteToOperatorInput;

// --- Bus Operator Modal Handlers ---
function openAddOperatorModal() {
  document.getElementById('opr-id').value = '';
  document.getElementById('opr-nameBn').value = '';
  document.getElementById('opr-nameEn').value = '';
  document.getElementById('opr-busType').value = 'এসি ও নন-এসি';
  document.getElementById('opr-contactPrimary').value = '';
  document.getElementById('opr-serviceStatus').value = 'নিয়মিত চলাচল (Regular)';
  document.getElementById('opr-startingPoint').value = 'মজমপুর গেট';
  document.getElementById('opr-logoUrl').value = '';
  updateOperatorLogoPreview('');
  document.getElementById('opr-destinationIds').value = '';
  document.getElementById('opr-descriptionBn').value = '';
  document.getElementById('opr-websiteUrl').value = '';
  document.getElementById('opr-counters-input').value = '';
  document.getElementById('operator-modal-title').textContent = 'নতুন বাস অপারেটর যোগ করুন';
  document.getElementById('operator-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function openEditOperatorModal(id) {
  const opr = allOperators.find(o => o.id === id);
  if (!opr) {
    showToast('বাস অপারেটর পাওয়া যায়নি: ' + id, 'error');
    return;
  }
  document.getElementById('opr-id').value = opr.id;
  document.getElementById('opr-nameBn').value = opr.nameBn || '';
  document.getElementById('opr-nameEn').value = opr.nameEn || '';
  document.getElementById('opr-busType').value = opr.busType || '';
  document.getElementById('opr-contactPrimary').value = opr.contactPrimary || opr.phonePrimary || '';
  document.getElementById('opr-serviceStatus').value = opr.serviceStatus || 'নিয়মিত চলাচল (Regular)';
  document.getElementById('opr-startingPoint').value = opr.startingPoint || opr.startingCounterName || '';
  document.getElementById('opr-logoUrl').value = opr.logoUrl || '';
  updateOperatorLogoPreview(opr.logoUrl || '');
  document.getElementById('opr-destinationIds').value = Array.isArray(opr.destinationIds) ? opr.destinationIds.join(', ') : (opr.destinationIds || '');
  document.getElementById('opr-descriptionBn').value = opr.descriptionBn || '';
  document.getElementById('opr-websiteUrl').value = opr.websiteUrl || '';

  if (opr.counters && opr.counters.length > 0) {
    const rawCounters = opr.counters.map(c => `${c.name || c.addressBn || 'কাউন্টার'}: ${c.phonePrimary || c.phone || ''}`).join(', ');
    document.getElementById('opr-counters-input').value = rawCounters;
  } else {
    document.getElementById('opr-counters-input').value = '';
  }

  document.getElementById('operator-modal-title').textContent = 'বাস অপারেটর সম্পাদনা: ' + (opr.nameBn || opr.id);
  document.getElementById('operator-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function closeOperatorModal() {
  document.getElementById('operator-modal').classList.remove('active');
  document.body.classList.remove('modal-open');
}

// Save Operator
document.getElementById('operator-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const id = document.getElementById('opr-id').value || `OPR-${(allOperators.length + 1).toString().padStart(3, '0')}`;
  const existingOpr = allOperators.find(o => o.id === id);

  const countersRaw = document.getElementById('opr-counters-input').value.split(',').map(c => c.trim()).filter(Boolean);
  let counters = existingOpr && existingOpr.counters ? [...existingOpr.counters] : [];

  if (countersRaw.length > 0) {
    counters = countersRaw.map((raw, idx) => {
      const parts = raw.split(':');
      const existing = (existingOpr && existingOpr.counters && existingOpr.counters[idx]) || {};
      return {
        id: existing.id || `CTR-${id}-${idx + 1}`,
        name: parts[0]?.trim() || 'কাউন্টার',
        addressBn: parts[0]?.trim() || '',
        phonePrimary: parts[1]?.trim() || '',
        phone: parts[1]?.trim() || '',
        upazilaId: existing.upazilaId || 'UPZ-002',
        googleMapsUrl: existing.googleMapsUrl || ''
      };
    });
  }

  const destInput = document.getElementById('opr-destinationIds').value;
  const destinationIds = destInput ? destInput.split(',').map(s => s.trim()).filter(Boolean) : [];

  const data = {
    id,
    nameBn: document.getElementById('opr-nameBn').value.trim(),
    nameEn: document.getElementById('opr-nameEn').value.trim(),
    busType: document.getElementById('opr-busType').value,
    contactPrimary: document.getElementById('opr-contactPrimary').value.trim(),
    phonePrimary: document.getElementById('opr-contactPrimary').value.trim(),
    serviceStatus: document.getElementById('opr-serviceStatus').value.trim() || 'নিয়মিত চলাচল (Regular)',
    startingPoint: document.getElementById('opr-startingPoint').value.trim() || 'মজমপুর গেট',
    startingCounterName: document.getElementById('opr-startingPoint').value.trim() || 'মজমপুর গেট',
    logoUrl: document.getElementById('opr-logoUrl').value.trim(),
    destinationIds: destinationIds,
    descriptionBn: document.getElementById('opr-descriptionBn').value.trim(),
    websiteUrl: document.getElementById('opr-websiteUrl').value.trim(),
    counters,
    isActive: true,
    updatedAt: firebase.firestore.FieldValue.serverTimestamp()
  };

  try {
    await db.collection('travel_bus_operators').doc(id).set(data, { merge: true });
    showToast('বাস অপারেটর সফলভাবে সংরক্ষণ করা হয়েছে!', 'success');
    closeOperatorModal();
    loadTravelGuideData();
  } catch (err) {
    showToast('সংরক্ষণে ব্যর্থ: ' + err.message, 'error');
  }
});

// --- Bus Counter Management ---
let currentManagingOperatorId = null;

function openManageCountersModal(operatorId) {
  currentManagingOperatorId = operatorId;
  const opr = allOperators.find(o => o.id === operatorId);
  if (!opr) {
    showToast('অপারেটর পাওয়া যায়নি: ' + operatorId, 'error');
    return;
  }

  document.getElementById('counters-operator-name').textContent = `${opr.nameBn} (${opr.nameEn || ''})`;
  renderCountersTable(opr);
  document.getElementById('counters-modal').classList.add('active');
  document.body.classList.add('modal-open');
}

function closeCountersModal() {
  document.getElementById('counters-modal').classList.remove('active');
  document.body.classList.remove('modal-open');
  currentManagingOperatorId = null;
}

function renderCountersTable(opr) {
  const tbody = document.getElementById('counters-table-body');
  if (!tbody) return;

  const counters = opr.counters || [];
  if (counters.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px; color: var(--text-muted);">কোনো কাউন্টার যোগ করা হয়নি। "+ নতুন কাউন্টার যোগ করুন" বাটনে ক্লিক করুন।</td></tr>';
    return;
  }

  tbody.innerHTML = counters.map((cnt, idx) => {
    const cid = cnt.id || `CTR-${opr.id}-${idx + 1}`;
    const upzName = getUpazilaNameBn(cnt.upazilaId || 'UPZ-002');
    const phone = cnt.phonePrimary || cnt.phone || '—';
    const secPhone = cnt.phoneSecondary ? `<br><small style="color: var(--text-muted);">বিকল্প: ${cnt.phoneSecondary}</small>` : '';
    const maps = cnt.googleMapsUrl || cnt.mapsUrl || cnt.mapUrl;
    const isStart = cnt.isStartingPoint === true || cnt.isStartingPoint === 'true';
    return `
      <tr>
        <td>
          <strong>${cnt.name || 'কাউন্টার'}</strong>
          ${isStart ? ' <span class="badge green" style="font-size: 10px;">মূল বোর্ডিং পয়েন্ট</span>' : ''}
          ${cnt.addressBn || cnt.address ? `<br><small style="color: var(--text-muted);">${cnt.addressBn || cnt.address}</small>` : ''}
        </td>
        <td><span class="badge badge-gray">${upzName}</span></td>
        <td><code>${phone}</code>${secPhone}</td>
        <td>${maps ? `<a href="${maps}" target="_blank" style="color: var(--primary);"><i class="fas fa-map-marker-alt"></i> গুগল ম্যাপস</a>` : '—'}</td>
        <td style="text-align: right; white-space: nowrap;">
          <button class="action-btn edit" onclick="openEditCounterModal('${opr.id}', '${cid}')" title="সম্পাদনা"><i class="fas fa-edit"></i></button>
          <button class="action-btn delete" onclick="deleteCounter('${opr.id}', '${cid}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
        </td>
      </tr>
    `;
  }).join('');
}

function openAddCounterModal() {
  if (!currentManagingOperatorId) return;
  document.getElementById('cnt-id').value = '';
  document.getElementById('cnt-operator-id').value = currentManagingOperatorId;
  document.getElementById('cnt-name').value = '';
  document.getElementById('cnt-upazilaId').value = 'UPZ-002';
  document.getElementById('cnt-phone').value = '';
  document.getElementById('cnt-phoneSecondary').value = '';
  document.getElementById('cnt-isStartingPoint').value = 'false';
  document.getElementById('cnt-address').value = '';
  document.getElementById('cnt-mapsUrl').value = '';
  document.getElementById('counter-edit-modal-title').textContent = 'নতুন কাউন্টার যোগ করুন';
  document.getElementById('counter-edit-modal').classList.add('active');
}

function openEditCounterModal(operatorId, counterId) {
  const opr = allOperators.find(o => o.id === operatorId);
  if (!opr || !opr.counters) return;

  const cnt = opr.counters.find(c => c.id === counterId || String(c.id) === String(counterId));
  if (!cnt) return;

  document.getElementById('cnt-id').value = cnt.id || counterId;
  document.getElementById('cnt-operator-id').value = operatorId;
  document.getElementById('cnt-name').value = cnt.name || '';
  document.getElementById('cnt-upazilaId').value = cnt.upazilaId || 'UPZ-002';
  document.getElementById('cnt-phone').value = cnt.phonePrimary || cnt.phone || '';
  document.getElementById('cnt-phoneSecondary').value = cnt.phoneSecondary || '';
  document.getElementById('cnt-isStartingPoint').value = (cnt.isStartingPoint === true || cnt.isStartingPoint === 'true') ? 'true' : 'false';
  document.getElementById('cnt-address').value = cnt.addressBn || cnt.address || '';
  document.getElementById('cnt-mapsUrl').value = cnt.googleMapsUrl || cnt.mapsUrl || cnt.mapUrl || '';
  document.getElementById('counter-edit-modal-title').textContent = 'কাউন্টার সম্পাদনা: ' + (cnt.name || 'কাউন্টার');
  document.getElementById('counter-edit-modal').classList.add('active');
}

function closeCounterEditModal() {
  document.getElementById('counter-edit-modal').classList.remove('active');
}

// Save Counter handler
document.getElementById('counter-edit-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) return;
  const operatorId = document.getElementById('cnt-operator-id').value;
  const counterId = document.getElementById('cnt-id').value;
  const opr = allOperators.find(o => o.id === operatorId);
  if (!opr) return;

  let counters = [...(opr.counters || [])];
  const newCounter = {
    id: counterId || `CTR-${operatorId}-${Date.now().toString(36)}`,
    operatorId: operatorId,
    name: document.getElementById('cnt-name').value.trim(),
    upazilaId: document.getElementById('cnt-upazilaId').value,
    phonePrimary: document.getElementById('cnt-phone').value.trim(),
    phone: document.getElementById('cnt-phone').value.trim(),
    phoneSecondary: document.getElementById('cnt-phoneSecondary').value.trim(),
    isStartingPoint: document.getElementById('cnt-isStartingPoint').value === 'true',
    addressBn: document.getElementById('cnt-address').value.trim(),
    address: document.getElementById('cnt-address').value.trim(),
    googleMapsUrl: document.getElementById('cnt-mapsUrl').value.trim(),
    mapsUrl: document.getElementById('cnt-mapsUrl').value.trim(),
    mapUrl: document.getElementById('cnt-mapsUrl').value.trim()
  };

  const existingIdx = counters.findIndex(c => c.id === counterId);
  if (existingIdx >= 0) {
    counters[existingIdx] = { ...counters[existingIdx], ...newCounter };
  } else {
    counters.push(newCounter);
  }

  try {
    await db.collection('travel_bus_operators').doc(operatorId).update({
      counters: counters,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    });
    opr.counters = counters;
    showToast('কাউন্টার সংরক্ষিত হয়েছে!', 'success');
    closeCounterEditModal();
    renderCountersTable(opr);
    renderOperatorsTable();
  } catch (err) {
    showToast('কাউন্টার সংরক্ষণে ব্যর্থ: ' + err.message, 'error');
  }
});

async function deleteCounter(operatorId, counterId) {
  if (!confirm('আপনি কি এই কাউন্টারটি মুছে ফেলতে চান?')) return;
  const opr = allOperators.find(o => o.id === operatorId);
  if (!opr || !opr.counters) return;

  const updatedCounters = opr.counters.filter(c => c.id !== counterId);
  try {
    await db.collection('travel_bus_operators').doc(operatorId).update({
      counters: updatedCounters,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    });
    opr.counters = updatedCounters;
    showToast('কাউন্টার মুছে ফেলা হয়েছে', 'info');
    renderCountersTable(opr);
    renderOperatorsTable();
  } catch (err) {
    showToast('কাউন্টার মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

// --- Global Notice Banner Handlers ---
async function loadGlobalNotice() {
  if (!db) return;
  try {
    const doc = await db.collection('app_config').doc('global_notice').get();
    let notice = doc.exists ? doc.data() : (typeof SEED_DATA !== 'undefined' ? SEED_DATA.globalNotice || {} : {});

    if (document.getElementById('notice-active')) {
      document.getElementById('notice-active').checked = notice.isActive !== false;
    }
    if (document.getElementById('notice-isUrgent')) {
      document.getElementById('notice-isUrgent').checked = notice.isUrgent === true;
    }
    if (document.getElementById('notice-titleBn')) {
      document.getElementById('notice-titleBn').value = notice.titleBn || '';
    }
    if (document.getElementById('notice-titleEn')) {
      document.getElementById('notice-titleEn').value = notice.titleEn || '';
    }
    if (document.getElementById('notice-textBn')) {
      document.getElementById('notice-textBn').value = notice.textBn || '';
    }
    if (document.getElementById('notice-textEn')) {
      document.getElementById('notice-textEn').value = notice.textEn || '';
    }
    if (document.getElementById('notice-date')) {
      document.getElementById('notice-date').value = notice.publishedDate || notice.date || new Date().toISOString().split('T')[0];
    }
  } catch (err) {
    console.error('Error loading global notice:', err);
  }
}

document.getElementById('global-notice-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) {
    showToast('ফায়ারবেজ সংযুক্ত নেই!', 'error');
    return;
  }
  const noticeData = {
    isActive: document.getElementById('notice-active').checked,
    isUrgent: document.getElementById('notice-isUrgent').checked,
    titleBn: document.getElementById('notice-titleBn').value.trim(),
    titleEn: document.getElementById('notice-titleEn').value.trim(),
    textBn: document.getElementById('notice-textBn').value.trim(),
    textEn: document.getElementById('notice-textEn').value.trim(),
    publishedDate: document.getElementById('notice-date').value || new Date().toISOString().split('T')[0],
    updatedAt: firebase.firestore.FieldValue.serverTimestamp()
  };

  try {
    await db.collection('app_config').doc('global_notice').set(noticeData, { merge: true });
    showToast('ব্যানার নোটিশ সফলভাবে সংরক্ষণ ও প্রকাশ করা হয়েছে!', 'success');
  } catch (err) {
    showToast('নোটিশ সংরক্ষণে ব্যর্থ: ' + err.message, 'error');
  }
});

async function deleteLocalRoute(id) {
  if (!confirm('আপনি কি নিশ্চিত যে এই রুটটি মুছে ফেলতে চান?')) return;
  try {
    await db.collection('travel_local_routes').doc(id).set({
      _deleted: true,
      isDeleted: true,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    showToast('রুট মুছে ফেলা হয়েছে', 'info');
    loadTravelGuideData();
  } catch (err) {
    showToast('মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

async function deleteDestination(id) {
  if (!confirm('এই গন্তব্য মুছে ফেলতে চান?')) return;
  try {
    await db.collection('travel_destinations').doc(id).set({
      _deleted: true,
      isDeleted: true,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    showToast('গন্তব্য মুছে ফেলা হয়েছে', 'info');
    loadTravelGuideData();
  } catch (err) {
    showToast('মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

async function deleteOperator(id) {
  if (!confirm('এই অপারেটর মুছে ফেলতে চান?')) return;
  try {
    await db.collection('travel_bus_operators').doc(id).set({
      _deleted: true,
      isDeleted: true,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    showToast('অপারেটর মুছে ফেলা হয়েছে', 'info');
    loadTravelGuideData();
  } catch (err) {
    showToast('মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

// Push Notification Broadcaster Logic
function renderNotificationsList() {
  if (!db) return;
  db.collection('notifications')
    .orderBy('createdAt', 'desc')
    .limit(15)
    .onSnapshot(snap => {
      allNotifications = [];
      snap.forEach(d => allNotifications.push({ id: d.id, ...d.data() }));
      const tbody = document.getElementById('sent-notifications-table-body');
      if (!tbody) return;

      if (allNotifications.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 24px;">এখনো কোনো নোটিফিকেশন পাঠানো হয়নি</td></tr>';
        return;
      }

      tbody.innerHTML = allNotifications.map(n => {
        let timeStr = '—';
        if (n.createdAt && n.createdAt.toDate) {
          timeStr = n.createdAt.toDate().toLocaleString('bn-BD');
        }
        return `
          <tr>
            <td><small>${timeStr}</small></td>
            <td><span class="badge ${n.type === 'emergency' ? 'red' : 'blue'}">${n.type || 'general'}</span></td>
            <td><strong>${n.titleBn || ''}</strong></td>
            <td>${n.bodyBn || ''}</td>
            <td style="text-align: right;">
              <button class="action-btn delete" onclick="deleteNotification('${n.id}')" title="মুছে ফেলুন"><i class="fas fa-trash"></i></button>
            </td>
          </tr>
        `;
      }).join('');
    }, err => console.warn('Notifications listen note:', err));
}

document.getElementById('broadcast-notification-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) {
    showToast('ডাটাবেজ সংযোগ পাওয়া যায়নি', 'error');
    return;
  }

  const btn = document.getElementById('send-notif-btn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> প্রেরণ করা হচ্ছে...';

  const notifId = `NTF-${Date.now()}`;
  const notifData = {
    id: notifId,
    titleBn: document.getElementById('notif-titleBn').value.trim(),
    titleEn: document.getElementById('notif-titleEn').value.trim(),
    bodyBn: document.getElementById('notif-bodyBn').value.trim(),
    bodyEn: document.getElementById('notif-bodyEn').value.trim(),
    type: document.getElementById('notif-type').value,
    targetRoute: document.getElementById('notif-targetRoute').value,
    imageUrl: document.getElementById('notif-imageUrl').value.trim(),
    createdAt: firebase.firestore.FieldValue.serverTimestamp()
  };

  try {
    await db.collection('notifications').doc(notifId).set(notifData);
    showToast('সকল মোবাইল ব্যবহারকারীর কাছে নোটিফিকেশন সফলভাবে পাঠানো হয়েছে!', 'success');
    document.getElementById('broadcast-notification-form').reset();
  } catch (err) {
    showToast('নোটিফিকেশন পাঠাতে ব্যর্থ: ' + err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '<i class="fas fa-paper-plane"></i> <span>সকল ব্যবহারকারীকে নোটিফিকেশন পাঠান</span>';
  }
});

async function deleteNotification(id) {
  if (!confirm('এই নোটিফিকেশন রেকর্ডটি মুছে ফেলতে চান?')) return;
  try {
    await db.collection('notifications').doc(id).delete();
    showToast('নোটিফিকেশন মুছে ফেলা হয়েছে', 'info');
  } catch (err) {
    showToast('মুছতে ব্যর্থ: ' + err.message, 'error');
  }
}

// 13. App Users & Citizens Management
async function loadUsersData() {
  if (!db) return;
  try {
    const snap = await db.collection('users').get();
    allUsers = [];
    snap.forEach((doc) => {
      allUsers.push({ id: doc.id, ...doc.data() });
    });
    updateDashboardStats();
    renderUsersTable();
    showToast('ব্যবহারকারী তালিকা আপডেট হয়েছে', 'info');
  } catch (err) {
    console.error('Failed to load users:', err);
    showToast('ব্যবহারকারী লোড করতে সমস্যা: ' + err.message, 'error');
  }
}

function renderUsersTable() {
  const tbody = document.getElementById('users-table-body');
  const countBadge = document.getElementById('users-count-badge');
  if (!tbody) return;

  const search = (document.getElementById('users-search-input')?.value || '').toLowerCase();
  const roleFilter = document.getElementById('users-role-filter')?.value || 'all';

  const filtered = allUsers.filter((u) => {
    const name = (u.displayName || '').toLowerCase();
    const email = (u.email || '').toLowerCase();
    const phone = (u.phoneNumber || '').toLowerCase();
    const matchesSearch = !search || name.includes(search) || email.includes(search) || phone.includes(search);
    const matchesRole = roleFilter === 'all' || (u.role || 'citizen') === roleFilter;
    return matchesSearch && matchesRole;
  });

  if (countBadge) {
    countBadge.textContent = `মোট ${filtered.length} জন নাগরিক`;
  }

  if (filtered.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-muted);">
          <i class="fas fa-user-slash" style="font-size: 28px; margin-bottom: 10px; display: block; opacity: 0.5;"></i>
          কোনো ব্যবহারকারী বা নাগরিক পাওয়া যায়নি।
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = filtered.map((u, idx) => {
    const photo = u.photoURL || `https://ui-avatars.com/api/?name=${encodeURIComponent(u.displayName || u.email || 'Citizen')}&background=0B5233&color=fff`;
    const name = u.displayName || 'নাম নেই';
    const email = u.email || '—';
    const platform = u.platform || 'Android / Mobile';
    const role = u.role || 'citizen';
    const isAdmin = role === 'admin';

    // Format dates
    const createdStr = u.createdAt && u.createdAt.toDate ? u.createdAt.toDate().toLocaleString('bn-BD') : (u.createdAt ? new Date(u.createdAt).toLocaleDateString() : '—');
    const lastActiveStr = u.lastLoginAt && u.lastLoginAt.toDate ? u.lastLoginAt.toDate().toLocaleString('bn-BD') : (u.lastLoginAt ? new Date(u.lastLoginAt).toLocaleDateString() : 'সদ্য সক্রিয়');

    return `
      <tr>
        <td>
          <img src="${photo}" alt="${name}" style="width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 1.5px solid var(--border);">
        </td>
        <td>
          <strong style="color: var(--text-primary); font-size: 14px;">${name}</strong>
          ${u.phoneNumber ? `<div style="font-size: 11px; color: var(--text-muted);"><i class="fas fa-phone-alt"></i> ${u.phoneNumber}</div>` : ''}
        </td>
        <td>
          <span style="font-family: monospace; font-size: 12.5px; color: var(--text-secondary);">${email}</span>
        </td>
        <td>
          <span class="badge" style="background: rgba(59, 130, 246, 0.12); color: #2563EB; font-size: 11.5px;">
            <i class="fas ${platform.toLowerCase().includes('web') ? 'fa-globe' : 'fa-mobile-alt'}"></i> ${platform}
          </span>
        </td>
        <td>
          <span class="badge ${isAdmin ? 'badge-primary' : 'badge-info'}" style="font-size: 11.5px;">
            <i class="fas ${isAdmin ? 'fa-shield-alt' : 'fa-user'}"></i> ${isAdmin ? 'অ্যাডমিন' : 'নাগরিক'}
          </span>
        </td>
        <td style="font-size: 12px; color: var(--text-muted);">${createdStr}</td>
        <td style="font-size: 12px; color: var(--primary); font-weight: 500;">${lastActiveStr}</td>
        <td style="text-align: right;">
          <button class="btn btn-sm ${isAdmin ? 'btn-secondary' : 'btn-primary'}" onclick="toggleUserRole('${u.id}', '${isAdmin ? 'citizen' : 'admin'}')" title="${isAdmin ? 'নাগরিক রোলে পরিবর্তন করুন' : 'অ্যাডমিন অনুমতি দিন'}">
            <i class="fas ${isAdmin ? 'fa-user-minus' : 'fa-user-shield'}"></i> ${isAdmin ? 'রিমুভ' : 'মেক অ্যাডমিন'}
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

window.filterUsersTable = function() {
  renderUsersTable();
};

window.toggleUserRole = async function(userId, newRole) {
  if (!db) return;
  const isGranting = newRole === 'admin';
  const confirmMsg = isGranting
    ? 'আপনি কি এই নাগরিককে অ্যাডমিন অ্যাক্সেস দিতে চান? তিনি সমস্ত ডাটা এডিট ও ম্যানেজ করতে পারবেন।'
    : 'আপনি কি এই ইউজারের অ্যাডমিন ক্ষমতা বাতিল করে সাধারণ নাগরিক করতে চান?';

  if (!confirm(confirmMsg)) return;

  try {
    await db.collection('users').doc(userId).set({
      role: newRole,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    // Also sync admins collection if admin
    if (isGranting) {
      await db.collection('admins').doc(userId).set({
        uid: userId,
        grantedAt: firebase.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
    } else {
      await db.collection('admins').doc(userId).delete().catch(() => {});
    }

    showToast(isGranting ? 'অ্যাডমিন রোল সফলভাবে প্রদান করা হয়েছে!' : 'রোল পরিবর্তন সম্পন্ন হয়েছে', 'success');
  } catch (err) {
    showToast('রোল আপডেট ব্যর্থ: ' + err.message, 'error');
  }
};

// ==========================================
// 12. App Version Release & Update Management
// ==========================================
window.loadAppUpdateConfig = async function() {
  const defaultVersion = {
    latestVersion: '1.0.0-beta.1',
    latestBuildNumber: 1,
    releaseDate: new Date().toISOString().split('T')[0],
    releaseTitleBn: 'আমার কুষ্টিয়া বেটা ১.০ রিলিজ হয়েছে!',
    releaseTitleEn: 'Amar Kushtia Beta 1.0 is Out!',
    releaseNotesBn: '• কুষ্টিয়া জেলার বাস কাউন্টারের নতুন মোবাইল নম্বর ও তথ্য আপডেট\n• সম্পূর্ণ অ্যাপের ট্রানজিশন ও ইমেজ ক্যাশিং অপ্টিমাইজেশন (জিরো ল্যাগ)\n• সেটিংসে সরাসরি অ্যাপ আপডেট যাচাই ও রিলিজ সিস্টেম যুক্ত',
    releaseNotesEn: '• Added updated bus counter contacts across Kushtia\n• Major UI rendering and startup lag optimizations\n• Integrated live app release management',
    apkDownloadUrl: '',
    playStoreUrl: '',
    minSupportedBuildNumber: 1,
    channel: 'beta',
    isForceUpdate: false
  };

  if (!db) {
    populateAppUpdateForm(defaultVersion);
    return;
  }

  try {
    const doc = await db.collection('app_config').doc('version_info').get();
    let data = defaultVersion;
    if (doc.exists) {
      data = { ...defaultVersion, ...doc.data() };
    }
    populateAppUpdateForm(data);
  } catch (err) {
    console.error('Error fetching version_info:', err);
    populateAppUpdateForm(defaultVersion);
  }
};

function populateAppUpdateForm(data) {
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.value = val !== undefined && val !== null ? val : '';
  };

  setVal('upd-latestVersion', data.latestVersion || '1.0.0-beta.1');
  setVal('upd-latestBuildNumber', data.latestBuildNumber || 1);
  setVal('upd-channel', data.channel || 'beta');
  setVal('upd-releaseDate', data.releaseDate || new Date().toISOString().split('T')[0]);
  setVal('upd-releaseTitleBn', data.releaseTitleBn || '');
  setVal('upd-releaseTitleEn', data.releaseTitleEn || '');
  setVal('upd-releaseNotesBn', data.releaseNotesBn || '');
  setVal('upd-releaseNotesEn', data.releaseNotesEn || '');
  setVal('upd-apkDownloadUrl', data.apkDownloadUrl || '');
  setVal('upd-playStoreUrl', data.playStoreUrl || '');
  setVal('upd-minSupportedBuildNumber', data.minSupportedBuildNumber || 1);

  const forceEl = document.getElementById('upd-isForceUpdate');
  if (forceEl) forceEl.checked = data.isForceUpdate === true;

  // Update Live Preview Card
  const prevVer = document.getElementById('preview-version');
  if (prevVer) prevVer.textContent = 'v' + (data.latestVersion || '1.0.0-beta.1');

  const prevChannel = document.getElementById('preview-channel');
  if (prevChannel) {
    prevChannel.textContent = (data.channel || 'beta').toUpperCase();
    prevChannel.className = data.channel === 'stable' ? 'badge badge-success' : 'badge badge-warning';
  }

  const prevBuild = document.getElementById('preview-build');
  if (prevBuild) prevBuild.textContent = 'Build Code: ' + (data.latestBuildNumber || 1);

  const prevDate = document.getElementById('preview-date');
  if (prevDate) prevDate.textContent = data.releaseDate || 'অজানা';

  const prevTitle = document.getElementById('preview-title');
  if (prevTitle) prevTitle.textContent = data.releaseTitleBn || data.releaseTitleEn || 'আমার কুষ্টিয়া আপডেট';

  const prevForce = document.getElementById('preview-force');
  if (prevForce) {
    if (data.isForceUpdate) {
      prevForce.textContent = 'বাধ্যতামূলক (Force)';
      prevForce.className = 'badge badge-danger';
    } else {
      prevForce.textContent = 'ঐচ্ছিক (Optional)';
      prevForce.className = 'badge badge-success';
    }
  }

  const prevApk = document.getElementById('preview-apk-link');
  if (prevApk) {
    if (data.apkDownloadUrl) {
      prevApk.href = data.apkDownloadUrl;
      prevApk.textContent = data.apkDownloadUrl;
    } else {
      prevApk.removeAttribute('href');
      prevApk.textContent = 'সেট করা নেই';
    }
  }
}

// App Update Form Submission Handler
document.getElementById('app-update-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  if (!db) {
    showToast('ফায়ারবেজ সংযুক্ত নেই! সেটিংস চেক করুন', 'error');
    return;
  }

  const submitBtn = document.getElementById('save-app-update-btn');
  if (submitBtn) {
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> প্রকাশ করা হচ্ছে...';
  }

  const updateData = {
    latestVersion: document.getElementById('upd-latestVersion').value.trim(),
    latestBuildNumber: parseInt(document.getElementById('upd-latestBuildNumber').value, 10) || 1,
    channel: document.getElementById('upd-channel').value,
    releaseDate: document.getElementById('upd-releaseDate').value || new Date().toISOString().split('T')[0],
    releaseTitleBn: document.getElementById('upd-releaseTitleBn').value.trim(),
    releaseTitleEn: document.getElementById('upd-releaseTitleEn').value.trim(),
    releaseNotesBn: document.getElementById('upd-releaseNotesBn').value.trim(),
    releaseNotesEn: document.getElementById('upd-releaseNotesEn').value.trim(),
    apkDownloadUrl: document.getElementById('upd-apkDownloadUrl').value.trim(),
    playStoreUrl: document.getElementById('upd-playStoreUrl').value.trim(),
    minSupportedBuildNumber: parseInt(document.getElementById('upd-minSupportedBuildNumber').value, 10) || 1,
    isForceUpdate: document.getElementById('upd-isForceUpdate').checked,
    updatedAt: firebase.firestore.FieldValue.serverTimestamp()
  };

  try {
    await db.collection('app_config').doc('version_info').set(updateData, { merge: true });
    showToast('অ্যাপ আপডেট কনফিগারেশন সফলভাবে রিলিজ ও ক্লাউডে সেভ হয়েছে!', 'success');
    populateAppUpdateForm(updateData);
  } catch (err) {
    showToast('আপডেট সেভ করতে ব্যর্থ: ' + err.message, 'error');
  } finally {
    if (submitBtn) {
      submitBtn.disabled = false;
      submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> <span>নতুন আপডেট রিলিজ ও প্রকাশ করুন</span>';
    }
  }
});

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  initFirebase();
});

