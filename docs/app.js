/* ============================================================
   Jigar Tools — Product Site · JavaScript
   ============================================================ */

(function () {
  'use strict';

  /* ---- Utility: throttle ---- */
  function throttle(fn, wait) {
    let last = 0;
    return function (...args) {
      const now = Date.now();
      if (now - last >= wait) { last = now; fn.apply(this, args); }
    };
  }

  /* ============================================================
     HEADER — scroll shadow & hamburger menu
     ============================================================ */
  const header    = document.getElementById('site-header');
  const hamburger = document.getElementById('hamburger');
  const mobileNav = document.getElementById('mobile-nav');

  // Scroll shadow on header
  const onScroll = throttle(() => {
    header.classList.toggle('scrolled', window.scrollY > 20);
  }, 60);
  window.addEventListener('scroll', onScroll, { passive: true });

  // Hamburger toggle
  hamburger.addEventListener('click', () => {
    const open = hamburger.classList.toggle('open');
    hamburger.setAttribute('aria-expanded', open);
    mobileNav.classList.toggle('open', open);
    mobileNav.setAttribute('aria-hidden', !open);
  });

  // Close mobile nav when a link is clicked
  mobileNav.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('open');
      hamburger.setAttribute('aria-expanded', 'false');
      mobileNav.classList.remove('open');
      mobileNav.setAttribute('aria-hidden', 'true');
    });
  });

  // Close mobile nav on outside click
  document.addEventListener('click', (e) => {
    if (!header.contains(e.target) && mobileNav.classList.contains('open')) {
      hamburger.classList.remove('open');
      hamburger.setAttribute('aria-expanded', 'false');
      mobileNav.classList.remove('open');
      mobileNav.setAttribute('aria-hidden', 'true');
    }
  });

  /* ============================================================
     SMOOTH SCROLL — nav anchors
     ============================================================ */
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      const id = anchor.getAttribute('href').slice(1);
      if (!id) return;
      const target = document.getElementById(id);
      if (!target) return;
      e.preventDefault();
      const offset = header.offsetHeight + 16;
      const top = target.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
    });
  });

  /* ============================================================
     SCROLL REVEAL — elements enter on scroll
     ============================================================ */
  const revealItems = [];

  function initReveal() {
    // Section headers
    document.querySelectorAll('.section-header, .hero-eyebrow, .hero-title, .hero-desc, .hero-actions, .hero-stats').forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${i * 60}ms`;
      revealItems.push(el);
    });

    // Feature cards
    document.querySelectorAll('.feature-card').forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${i * 60}ms`;
      revealItems.push(el);
    });

    // Steps
    document.querySelectorAll('.step').forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${i * 80}ms`;
      revealItems.push(el);
    });

    // Doc cards
    document.querySelectorAll('.doc-card').forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${i * 50}ms`;
      revealItems.push(el);
    });

    // FAQ items
    document.querySelectorAll('.faq-item').forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${i * 40}ms`;
      revealItems.push(el);
    });

    // Terminal card + CTA content
    document.querySelectorAll('.terminal-card, .cta-content').forEach(el => {
      el.classList.add('reveal');
      revealItems.push(el);
    });
  }

  function checkReveal() {
    const vh = window.innerHeight;
    revealItems.forEach(el => {
      if (el.classList.contains('in-view')) return;
      const rect = el.getBoundingClientRect();
      if (rect.top < vh - 60) {
        el.classList.add('in-view');
      }
    });
  }

  // Only animate if user hasn't requested reduced motion
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    initReveal();
    window.addEventListener('scroll', throttle(checkReveal, 50), { passive: true });
    // Check immediately for items already in view
    requestAnimationFrame(checkReveal);
  } else {
    // No animations, make everything visible
    document.querySelectorAll('.reveal').forEach(el => el.classList.add('in-view'));
  }

  /* ============================================================
     TERMINAL — Live terminal simulation
     ============================================================ */
  const terminalBody = document.querySelector('.terminal-body');
  
  if (terminalBody) {
    const filesList = [
      'DCIM/Camera/IMG_20260620_121544.jpg',
      'Music/Favorites/Alan_Walker-Faded.mp3',
      'Download/Android_SDK_Update.zip',
      'Documents/Receipt_2026_06_18.pdf',
      'WhatsApp/Backups/msgstore.db.crypt14',
      'Documents/Resume_Arvind_Ji.pdf',
      'Movies/Video_Highlight_Goal.mp4',
      'Android/data/com.jigar.tools/config.ini',
      'Pictures/Screenshots/Screenshot_01.png',
      'Recordings/VoiceNote_20260620.m4a',
      'Downloads/JigarSmartSync_Latest.zip',
      'DCIM/Camera/VID_20260620_021045.mp4'
    ];

    function createLine(html, className = '') {
      const el = document.createElement('div');
      el.className = `t-line ${className}`;
      el.innerHTML = html;
      return el;
    }

    function sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    }

    async function typeCmd(lineEl, text) {
      const cmdSpan = lineEl.querySelector('.t-cmd');
      lineEl.classList.add('t-blink');
      for (let i = 0; i < text.length; i++) {
        cmdSpan.textContent += text[i];
        await sleep(40 + Math.random() * 80);
      }
      lineEl.classList.remove('t-blink');
    }

    async function startSimulation() {
      while (true) {
        terminalBody.innerHTML = '';
        
        // Line 1: prompt & type command
        const linePrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>');
        terminalBody.appendChild(linePrompt);
        await sleep(800);
        await typeCmd(linePrompt, '.\\JigarSmartSync.ps1');
        await sleep(400);

        // System verification logs
        const logs = [
          { text: '[SYSTEM] Device Connected & Verified!', class: 't-cyan' },
          { text: '[SYSTEM] Root Status: Non-Rooted Device', class: 't-dim' },
          { text: '[SYSTEM] BusyBox: Found (v1.36.1)', class: 't-dim' },
          { text: '[SYSTEM] Smart Virtual Drive → Z:\\ mapped', class: 't-green' },
          { text: '[SCAN]   Mapping Android storage... (100,513 files found)', class: 't-yellow' },
          { text: '[SYNC]   Queued 847 missing files for download', class: 't-dim' },
          { text: '[TITAN]  Engaging 20x Parallel Streams...', class: 't-violet' }
        ];

        for (const log of logs) {
          const el = createLine(log.text, log.class);
          terminalBody.appendChild(el);
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(200 + Math.random() * 150);
        }

        await sleep(400);

        // Titan Parallel Sync Phase
        const syncContainer = document.createElement('div');
        terminalBody.appendChild(syncContainer);

        let progress = 0;
        const totalFiles = 847;
        const totalSize = 2.45;

        while (progress <= 100) {
          syncContainer.innerHTML = '';
          
          // Generate progress bar
          const barWidth = 15;
          const filledChars = Math.round((progress / 100) * barWidth);
          const emptyChars = barWidth - filledChars;
          const barText = '▓'.repeat(filledChars) + '░'.repeat(emptyChars);
          
          const speed = (32.4 + Math.random() * 12.5).toFixed(1);
          const currentCount = Math.min(Math.round((progress / 100) * totalFiles), totalFiles);
          
          const progressLine = createLine(
            `<span class="t-yellow">${barText}</span>  [${progress}%] | ${currentCount}/${totalFiles} files | ${speed} MB/s`,
            't-green'
          );
          syncContainer.appendChild(progressLine);

          if (progress < 100) {
            const threadIndex1 = (Math.floor(progress / 7)) % filesList.length;
            const threadIndex2 = (threadIndex1 + 3) % filesList.length;
            const threadIndex3 = (threadIndex1 + 7) % filesList.length;
            
            const stream1 = createLine(`  ├─ [Thread-04] ${filesList[threadIndex1]} ...`, 't-dim');
            const stream2 = createLine(`  ├─ [Thread-09] ${filesList[threadIndex2]} ...`, 't-dim');
            const stream3 = createLine(`  └─ [Thread-15] ${filesList[threadIndex3]} ...`, 't-dim');
            
            syncContainer.appendChild(stream1);
            syncContainer.appendChild(stream2);
            syncContainer.appendChild(stream3);
          }

          terminalBody.scrollTop = terminalBody.scrollHeight;

          if (progress === 100) break;

          progress += Math.floor(Math.random() * 8) + 6;
          if (progress > 100) progress = 100;
          await sleep(250 + Math.random() * 150);
        }

        await sleep(600);

        // Completion lines
        const compLogs = [
          { text: `[SYSTEM] Successfully backed up ${totalFiles} files (${totalSize} GB).`, class: 't-green' },
          { text: '[SYSTEM] Smart Virtual Drive Z:\\ unmounted.', class: 't-dim' },
          { text: '[SYSTEM] Sync completed successfully.', class: 't-cyan' }
        ];

        for (const log of compLogs) {
          const el = createLine(log.text, log.class);
          terminalBody.appendChild(el);
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(250);
        }

        // Blinking prompt at the end
        const finalPrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>', 't-blink');
        terminalBody.appendChild(finalPrompt);
        terminalBody.scrollTop = terminalBody.scrollHeight;

        // Pause before loop restarts
        await sleep(5000);
      }
    }

    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            startSimulation();
            observer.disconnect();
          }
        });
      }, { threshold: 0.15 });
      observer.observe(document.querySelector('.terminal-card'));
    } else {
      startSimulation();
    }
  }

  /* ============================================================
     ACTIVE NAV LINK — highlight based on scroll position
     ============================================================ */
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav-link[href^="#"]');

  function updateActiveNav() {
    const scrollY = window.scrollY + header.offsetHeight + 40;
    let current = '';

    sections.forEach(section => {
      if (scrollY >= section.offsetTop) {
        current = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      const href = link.getAttribute('href').slice(1);
      link.classList.toggle('nav-link--active', href === current);
    });
  }

  window.addEventListener('scroll', throttle(updateActiveNav, 80), { passive: true });

  /* ============================================================
     FAQ — close others when one opens
     ============================================================ */
  const faqItems = document.querySelectorAll('.faq-item');
  faqItems.forEach(item => {
    item.addEventListener('toggle', () => {
      if (item.open) {
        faqItems.forEach(other => {
          if (other !== item && other.open) {
            other.removeAttribute('open');
          }
        });
      }
    });
  });

  /* ============================================================
     HERO STATS — count-up animation
     ============================================================ */
  function animateCounter(el, end, suffix, duration) {
    const start = 0;
    const startTime = performance.now();
    function tick(now) {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // ease-out cubic
      const eased = 1 - Math.pow(1 - progress, 3);
      const value = Math.round(start + (end - start) * eased);
      el.textContent = value + suffix;
      if (progress < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  }

  // Set up intersection observer for stat nums
  const statNums = document.querySelectorAll('.stat-num');
  const counters = [
    { el: statNums[0], end: 20, suffix: '×' },
  ];

  if ('IntersectionObserver' in window && statNums.length) {
    const statsObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          counters.forEach(({ el, end, suffix }) => {
            if (el && !el.dataset.animated) {
              el.dataset.animated = '1';
              animateCounter(el, end, suffix, 800);
            }
          });
          statsObserver.disconnect();
        }
      });
    }, { threshold: 0.5 });

    statsObserver.observe(document.querySelector('.hero-stats'));
  }

  /* ============================================================
     FEATURE CARDS — subtle mouse-follow glow
     ============================================================ */
  if (window.matchMedia('(pointer: fine)').matches) {
    document.querySelectorAll('.feature-card').forEach(card => {
      card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * 100;
        const y = ((e.clientY - rect.top) / rect.height) * 100;
        card.style.setProperty('--glow-x', `${x}%`);
        card.style.setProperty('--glow-y', `${y}%`);
        card.classList.add('glow-active');
      });
      card.addEventListener('mouseleave', () => {
        card.classList.remove('glow-active');
      });
    });
  }

  /* ============================================================
     BACK TO TOP — show after scrolling 400px
     ============================================================ */
  // Keyboard escape closes mobile menu
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && mobileNav.classList.contains('open')) {
      hamburger.classList.remove('open');
      hamburger.setAttribute('aria-expanded', 'false');
      mobileNav.classList.remove('open');
      mobileNav.setAttribute('aria-hidden', 'true');
    }
  });

  /* ============================================================
     CURRENT YEAR in footer (if needed)
     ============================================================ */
  const yearEls = document.querySelectorAll('[data-year]');
  yearEls.forEach(el => { el.textContent = new Date().getFullYear(); });

})();
