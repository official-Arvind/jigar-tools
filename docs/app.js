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
     TERMINAL — typewriter effect for the last line
     ============================================================ */
  const terminalLines = document.querySelectorAll('.t-line');
  if (terminalLines.length) {
    // Stagger terminal line visibility
    terminalLines.forEach((line, i) => {
      line.style.opacity = '0';
      line.style.transition = 'opacity 200ms ease';
      setTimeout(() => {
        line.style.opacity = '1';
      }, 600 + i * 200);
    });
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
