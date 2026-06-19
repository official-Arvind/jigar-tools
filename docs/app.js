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
     TERMINAL — Optimized & Accurate Terminal Simulation
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

    let isTerminalVisible = false;

    function createLine(html, className = '') {
      const el = document.createElement('div');
      el.className = `t-line ${className}`;
      el.innerHTML = html;
      return el;
    }

    function sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    }

    async function waitTillVisible() {
      while (!isTerminalVisible) {
        await sleep(500);
      }
    }

    async function typeCmd(lineEl, text) {
      await waitTillVisible();
      const cmdSpan = lineEl.querySelector('.t-cmd');
      lineEl.classList.add('t-blink');
      for (let i = 0; i < text.length; i++) {
        await waitTillVisible();
        cmdSpan.textContent += text[i];
        await sleep(30 + Math.random() * 60);
      }
      lineEl.classList.remove('t-blink');
    }

    async function startSimulation() {
      let scenarioIndex = 0;
      
      while (true) {
        await waitTillVisible();
        terminalBody.innerHTML = '';
        
        if (scenarioIndex === 0) {
          // --- SCENARIO 0: SETUP/INSTALL ---
          const linePrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(linePrompt);
          await sleep(600);
          await typeCmd(linePrompt, '.\\Jigar_Tools_Setup.bat');
          await sleep(300);
          await waitTillVisible();

          const setupLogs1 = [
            { text: '========================================================', class: 't-dim' },
            { text: '       JIGAR TOOLS - INITIAL SYSTEM AUDIT (v2.0 Gold)', class: 't-cyan' },
            { text: '========================================================', class: 't-dim' },
            { text: '[AUDIT] Checking Directory Content...', class: 't-dim' },
            { text: '  [OK] JigarSmartSync.ps1 found.', class: 't-green' },
            { text: '  [OK] JigarSmartRestore.ps1 found.', class: 't-green' },
            { text: '[AUDIT] Checking Assets...', class: 't-dim' },
            { text: '  [OK] logo.ico found.', class: 't-green' },
            { text: '[AUDIT] Checking PowerShell Environment...', class: 't-dim' },
            { text: '  [OK] PS 5.1+ Active.', class: 't-green' },
            { text: '[AUDIT] Checking ADB Availability...', class: 't-dim' },
            { text: '  [WARN] ADB not in system PATH.', class: 't-yellow' },
            { text: '[+] Registering Jigar Tools to System PATH...', class: 't-dim' },
            { text: '  [DONE] Path Registered.', class: 't-green' },
            { text: '[+] Planting the Flower (Desktop Shortcut)...', class: 't-dim' },
            { text: '========================================================', class: 't-dim' },
            { text: ' [SUCCESS] Setup Complete.', class: 't-green' },
            { text: ' [ACTION]  Entering the God Mode Menu...', class: 't-cyan' },
            { text: '========================================================', class: 't-dim' },
            { text: 'Press any key to continue . . .', class: 't-dim' }
          ];

          for (const log of setupLogs1) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(80 + Math.random() * 50);
          }

          await sleep(1500); // Simulate prompt pause
          await waitTillVisible();
          terminalBody.innerHTML = '';

          // Launch Master Control Center
          const menuLogs = [
            { text: '========================================================', class: 't-dim' },
            { text: '       JIGAR TOOLS v2.0 Gold Edition  -  CONTROL CENTER', class: 't-cyan' },
            { text: '       Local Version: v2.0-Gold (Internal)', class: 't-dim' },
            { text: '========================================================', class: 't-dim' },
            { text: '  ARSENAL:', class: 't-dim' },
            { text: '  [1] JIGARSYNC BACKUP     (20x Threads + 3-Stage Fallback)', class: 't-cyan' },
            { text: '  [2] JIGAR SMART RESTORE  (Full / Selective Folder Restore)', class: 't-dim' },
            { text: '  [3] DEVICE STATUS        (Check Connection)', class: 't-dim' },
            { text: '  [4] CHECK FOR UPDATES    (GitHub Auto-Updater)', class: 't-dim' },
            { text: '  [5] EXIT                 (Kills ADB server + closes)', class: 't-dim' },
            { text: '========================================================', class: 't-dim' }
          ];

          for (const log of menuLogs) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(50);
          }
          await sleep(600);

          const choiceLine = createLine('<span class="t-prompt"> Choose your weapon (1-5):</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(choiceLine);
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(800);
          await typeCmd(choiceLine, '1');
          await sleep(400);

        } else if (scenarioIndex === 1) {
          // --- SCENARIO 1: SYNC (SUCCESS) ---
          const linePrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(linePrompt);
          await sleep(600);
          await typeCmd(linePrompt, '.\\JigarSmartSync.ps1');
          await sleep(300);
          await waitTillVisible();

          const syncLogs = [
            { text: ' ==============================================================', class: 't-dim' },
            { text: '   JIGAR SMART SYNC v2.0 Gold Edition  (20x THREADS + TITAN)', class: 't-cyan' },
            { text: ' ==============================================================', class: 't-dim' },
            { text: '   Log: Logs\\Sync_2026-06-20_02-56-03.log', class: 't-dim' },
            { text: '[SYSTEM] Device Connected & Verified!', class: 't-green' },
            { text: '[SYSTEM] Probing device capabilities...', class: 't-dim' },
            { text: '[SYSTEM] Root Status: Non-Rooted Device', class: 't-yellow' },
            { text: '[SYSTEM] BusyBox     : Found at \'/system/xbin/busybox\' (v1.36.1)', class: 't-green' },
            { text: '[SYSTEM] Device Model : pixel_8_pro', class: 't-cyan' },
            { text: '[SYSTEM] Folder Name  : pixel_8_pro', class: 't-cyan' },
            { text: '[CONFIG] Previous backup location found: D:\\Backups', class: 't-dim' },
            { text: '[SYSTEM] Backup Destination: D:\\Backups\\pixel_8_pro', class: 't-green' },
            { text: '[SYSTEM] Smart Virtual Drive → Z:\\ mapped', class: 't-green' },
            { text: '[SYSTEM] Loaded 12 custom ignore rules from INI file.', class: 't-dim' },
            { text: '[SCAN] Mapping Android Storage... (Please Wait)', class: 't-yellow' }
          ];

          for (const log of syncLogs) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(100 + Math.random() * 80);
          }

          await sleep(800);
          await waitTillVisible();
          terminalBody.appendChild(createLine('[SCAN] Found 100513 total files on Android.', 't-green'));
          terminalBody.appendChild(createLine('[SCAN] Mapping Local PC Backup...', 't-yellow'));
          await sleep(400);
          terminalBody.appendChild(createLine('[SCAN] Found 99666 files currently on PC.', 't-green'));
          terminalBody.appendChild(createLine('[FILTER] Customize which folders/files to EXCLUDE from this backup?', 't-yellow'));
          terminalBody.appendChild(createLine('         (Opens picker - press N to backup everything)', 't-dim'));
          await sleep(600);
          terminalBody.appendChild(createLine('[FILTER] Building Android file tree for selection...', 't-cyan'));
          await sleep(500);
          terminalBody.appendChild(createLine('[FILTER] 0 item(s) marked for exclusion.', 't-green'));
          terminalBody.appendChild(createLine('[SYNC] Queued 847 missing or modified files for download.', 't-violet'));
          terminalBody.appendChild(createLine('[SYNC] Pre-allocating directory trees natively...', 't-dim'));
          await sleep(300);
          terminalBody.appendChild(createLine('[SYNC] Engaging 20x Parallel Titan Streams...', 't-yellow'));
          terminalBody.scrollTop = terminalBody.scrollHeight;

          await sleep(400);
          await waitTillVisible();

          const syncContainer = document.createElement('div');
          terminalBody.appendChild(syncContainer);

          let progress = 0;
          const totalFiles = 847;

          while (progress <= 100) {
            await waitTillVisible();
            syncContainer.innerHTML = '';
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
              
              syncContainer.appendChild(createLine(`  ├─ [Thread-04] ${filesList[threadIndex1]} ...`, 't-dim'));
              syncContainer.appendChild(createLine(`  ├─ [Thread-09] ${filesList[threadIndex2]} ...`, 't-dim'));
              syncContainer.appendChild(createLine(`  └─ [Thread-15] ${filesList[threadIndex3]} ...`, 't-dim'));
            }

            terminalBody.scrollTop = terminalBody.scrollHeight;
            if (progress === 100) break;
            progress += Math.floor(Math.random() * 9) + 7;
            if (progress > 100) progress = 100;
            await sleep(200 + Math.random() * 100);
          }

          await sleep(600);
          await waitTillVisible();

          const compLogs = [
            { text: ' ==============================================================', class: 't-dim' },
            { text: '   SYNC COMPLETED', class: 't-green' },
            { text: `   Total Processed : ${totalFiles} file(s)`, class: 't-dim' },
            { text: '   Total Size      : 2.45 GB', class: 't-dim' },
            { text: '   Speed Average   : 38.6 MB/s', class: 't-dim' },
            { text: ' ==============================================================', class: 't-dim' },
            { text: '[SYSTEM] Smart Virtual Drive Z:\\ unmounted.', class: 't-dim' },
            { text: '[SYSTEM] Sync completed successfully.', class: 't-cyan' }
          ];

          for (const log of compLogs) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(150);
          }

        } else if (scenarioIndex === 2) {
          // --- SCENARIO 2: RESTORE (SUCCESS) ---
          const linePrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(linePrompt);
          await sleep(600);
          await typeCmd(linePrompt, '.\\JigarSmartRestore.ps1');
          await sleep(300);
          await waitTillVisible();

          const restoreLogs1 = [
            { text: ' ==============================================================', class: 't-dim' },
            { text: '   JIGAR SMART RESTORE v2.0 Gold Edition  (20x THREADS + TITAN)', class: 't-cyan' },
            { text: ' ==============================================================', class: 't-dim' },
            { text: '   Log: Logs\\Restore_2026-06-20_02-58-12.log', class: 't-dim' },
            { text: '[SYSTEM] Device Connected & Verified!', class: 't-green' },
            { text: '[SYSTEM] Device Model : pixel_8_pro', class: 't-cyan' },
            { text: '[SYSTEM] Probing device capabilities...', class: 't-dim' },
            { text: '[SYSTEM] Root Status: Non-Rooted Device', class: 't-yellow' },
            { text: '[SYSTEM] BusyBox     : Found at \'/system/xbin/busybox\' (v1.36.1)', class: 't-green' },
            { text: '[RESTORE] Available backups in: D:\\Backups', class: 't-yellow' },
            { text: '  -------------------------------------------------------', class: 't-dim' },
            { text: '  [1] pixel_8_pro_backup', class: 't-dim' },
            { text: '  [2] pixel_8_pro_backup_Gold', class: 't-dim' },
            { text: '  [3] Browse for another folder...', class: 't-dim' },
            { text: '  -------------------------------------------------------', class: 't-dim' }
          ];

          for (const log of restoreLogs1) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(100 + Math.random() * 50);
          }
          await sleep(600);
          await waitTillVisible();

          const lineSelect = createLine('<span class="t-prompt">[INPUT] Select option [1-3]:</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(lineSelect);
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(800);
          await typeCmd(lineSelect, '2');
          await sleep(400);
          await waitTillVisible();

          terminalBody.appendChild(createLine('[RESTORE] Selected: D:\\Backups\\pixel_8_pro_backup_Gold', 't-green'));
          terminalBody.appendChild(createLine('[SCAN] Mapping Backup Files on PC... (Please Wait)', 't-yellow'));
          await sleep(600);
          terminalBody.appendChild(createLine('[SCAN] Found 1204 total files in backup.', 't-green'));
          terminalBody.appendChild(createLine('[SCAN] Mapping Android Device Storage... (Please Wait)', 't-yellow'));
          await sleep(500);
          terminalBody.appendChild(createLine('[SCAN] Found 1056 files currently on Android.', 't-green'));
          terminalBody.appendChild(createLine('[FILTER] Restore only specific folders/files from this backup?', 't-yellow'));
          terminalBody.appendChild(createLine('         (Opens picker - press N to restore everything)', 't-dim'));
          await sleep(600);
          terminalBody.appendChild(createLine('[FILTER] Building backup file tree for selection...', 't-cyan'));
          await sleep(400);
          terminalBody.appendChild(createLine('[FILTER] 1204 item(s) selected for restore.', 't-green'));
          terminalBody.appendChild(createLine('[RESTORE] Queued 148 missing or modified files for push.', 't-magenta'));
          terminalBody.appendChild(createLine('[RESTORE] Pre-allocating directory trees on device...', 't-dim'));
          await sleep(300);
          terminalBody.appendChild(createLine('[RESTORE] Engaging 20x Parallel Titan Streams...', 't-yellow'));
          terminalBody.scrollTop = terminalBody.scrollHeight;

          await sleep(400);
          await waitTillVisible();

          const restoreContainer = document.createElement('div');
          terminalBody.appendChild(restoreContainer);

          let progress = 0;
          const totalFiles = 148;

          while (progress <= 100) {
            await waitTillVisible();
            restoreContainer.innerHTML = '';
            const barWidth = 15;
            const filledChars = Math.round((progress / 100) * barWidth);
            const emptyChars = barWidth - filledChars;
            const barText = '▓'.repeat(filledChars) + '░'.repeat(emptyChars);
            
            const speed = (38.2 + Math.random() * 10.2).toFixed(1);
            const currentCount = Math.min(Math.round((progress / 100) * totalFiles), totalFiles);
            
            const progressLine = createLine(
              `<span class="t-yellow">${barText}</span>  [${progress}%] | ${currentCount}/${totalFiles} files | ${speed} MB/s`,
              't-green'
            );
            restoreContainer.appendChild(progressLine);

            if (progress < 100) {
              const threadIndex1 = (Math.floor(progress / 5)) % filesList.length;
              const threadIndex2 = (threadIndex1 + 2) % filesList.length;
              const threadIndex3 = (threadIndex1 + 4) % filesList.length;
              
              restoreContainer.appendChild(createLine(`  ├─ [Thread-02] ${filesList[threadIndex1]} ...`, 't-dim'));
              restoreContainer.appendChild(createLine(`  ├─ [Thread-07] ${filesList[threadIndex2]} ...`, 't-dim'));
              restoreContainer.appendChild(createLine(`  └─ [Thread-12] ${filesList[threadIndex3]} ...`, 't-dim'));
            }

            terminalBody.scrollTop = terminalBody.scrollHeight;
            if (progress === 100) break;
            progress += Math.floor(Math.random() * 12) + 9;
            if (progress > 100) progress = 100;
            await sleep(200 + Math.random() * 100);
          }

          await sleep(600);
          await waitTillVisible();

          const restoreCompleteLogs = [
            { text: '[RESTORE] Refreshing Android Media Library...', class: 't-dim' },
            { text: '[SYSTEM] MediaScanner invoked successfully on 148 files.', class: 't-green' },
            { text: '[SYSTEM] Smart Virtual Drive Y:\\ unmounted.', class: 't-dim' },
            { text: '[SYSTEM] Restore completed successfully!', class: 't-cyan' }
          ];

          for (const log of restoreCompleteLogs) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(200);
          }

        } else if (scenarioIndex === 3) {
          // --- SCENARIO 3: SYNC (ERRORS & GRACEFUL ABORT) ---
          const linePrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(linePrompt);
          await sleep(600);
          await typeCmd(linePrompt, '.\\JigarSmartSync.ps1');
          await sleep(300);
          await waitTillVisible();

          const syncLogs = [
            { text: ' ==============================================================', class: 't-dim' },
            { text: '   JIGAR SMART SYNC v2.0 Gold Edition  (20x THREADS + TITAN)', class: 't-cyan' },
            { text: ' ==============================================================', class: 't-dim' },
            { text: '[SYSTEM] Device Connected & Verified!', class: 't-cyan' },
            { text: '[SYSTEM] Smart Virtual Drive → Z:\\ mapped', class: 't-green' },
            { text: '[SCAN]   Mapping Android storage... (100,513 files found)', class: 't-yellow' },
            { text: '[TITAN]  Engaging 20x Parallel Streams...', class: 't-violet' }
          ];

          for (const log of syncLogs) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(100 + Math.random() * 80);
          }

          await sleep(400);
          await waitTillVisible();

          const syncContainer = document.createElement('div');
          terminalBody.appendChild(syncContainer);

          let progress = 0;
          const totalFiles = 847;

          while (progress <= 38) {
            await waitTillVisible();
            syncContainer.innerHTML = '';
            const barWidth = 15;
            const filledChars = Math.round((progress / 100) * barWidth);
            const emptyChars = barWidth - filledChars;
            const barText = '▓'.repeat(filledChars) + '░'.repeat(emptyChars);
            
            const speed = (30.1 + Math.random() * 8.5).toFixed(1);
            const currentCount = Math.min(Math.round((progress / 100) * totalFiles), totalFiles);
            
            const progressLine = createLine(
              `<span class="t-yellow">${barText}</span>  [${progress}%] | ${currentCount}/${totalFiles} files | ${speed} MB/s`,
              't-green'
            );
            syncContainer.appendChild(progressLine);

            const threadIndex1 = (Math.floor(progress / 5)) % filesList.length;
            const threadIndex2 = (threadIndex1 + 2) % filesList.length;
            const threadIndex3 = (threadIndex1 + 4) % filesList.length;
            
            syncContainer.appendChild(createLine(`  ├─ [Thread-04] ${filesList[threadIndex1]} ...`, 't-dim'));
            syncContainer.appendChild(createLine(`  ├─ [Thread-09] ${filesList[threadIndex2]} ...`, 't-dim'));
            syncContainer.appendChild(createLine(`  └─ [Thread-15] ${filesList[threadIndex3]} ...`, 't-dim'));

            terminalBody.scrollTop = terminalBody.scrollHeight;
            
            progress += Math.floor(Math.random() * 6) + 4;
            await sleep(350 + Math.random() * 150);
          }

          await sleep(300);
          await waitTillVisible();

          // Simulated Error: connection lost
          terminalBody.appendChild(createLine('<span style="color: #f87171;">[ERROR] adb.exe: device offline (connection lost!)</span>'));
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(600);
          await waitTillVisible();

          // Graceful Abort Warning
          terminalBody.appendChild(createLine('[WARN]  Titan threads interrupted. Initiating cleanup...', 't-yellow'));
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(500);
          await waitTillVisible();

          // subst cleanup
          terminalBody.appendChild(createLine('[SYSTEM] subst Z: /D executed.', 't-dim'));
          terminalBody.appendChild(createLine('[SYSTEM] Virtual Drive Z:\\ successfully unmounted.', 't-green'));
          terminalBody.appendChild(createLine('<span style="color: #f87171;">[SYSTEM] Sync aborted. 248/847 files transferred.</span>'));
          terminalBody.scrollTop = terminalBody.scrollHeight;

        } else if (scenarioIndex === 4) {
          // --- SCENARIO 4: UNINSTALL ---
          const linePrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(linePrompt);
          await sleep(600);
          await typeCmd(linePrompt, '.\\Jigar_Tools_Uninstall.bat');
          await sleep(300);
          await waitTillVisible();

          const uninstallLogs = [
            { text: ' ============================================================', class: 't-dim' },
            { text: '     JIGAR TOOLS  |  UNINSTALLER v2.0', class: 't-yellow' },
            { text: ' ============================================================', class: 't-dim' },
            { text: '   This will PERMANENTLY remove Jigar Tools from your system.', class: 't-dim' },
            { text: '   Your backup data choices will be asked separately.', class: 't-dim' },
            { text: ' ============================================================', class: 't-dim' }
          ];

          for (const log of uninstallLogs) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(100);
          }
          await sleep(500);
          await waitTillVisible();

          const lineSelect = createLine('<span class="t-prompt"> Are you sure you want to continue? [Y/N]:</span> <span class="t-cmd"></span>');
          terminalBody.appendChild(lineSelect);
          terminalBody.scrollTop = terminalBody.scrollHeight;
          await sleep(800);
          await typeCmd(lineSelect, 'Y');
          await sleep(400);
          await waitTillVisible();

          const uninstallLogs2 = [
            { text: ' ============================================================', class: 't-dim' },
            { text: '  STEP 1 |  Removing from System PATH', class: 't-dim' },
            { text: ' ============================================================', class: 't-dim' },
            { text: '  [DONE] Jigar Tools removed from System PATH.', class: 't-green' },
            { text: ' ============================================================', class: 't-dim' },
            { text: '  STEP 2 |  Deleting Desktop Shortcut', class: 't-dim' },
            { text: ' ============================================================', class: 't-dim' },
            { text: '  [DONE] Shortcut deleted: C:\\Users\\Arvind\\Desktop\\Jigar Tools.lnk', class: 't-green' },
            { text: ' ============================================================', class: 't-dim' },
            { text: '  STEP 3 |  ADB Server Cleanup', class: 't-dim' },
            { text: ' ============================================================', class: 't-dim' },
            { text: '  [DONE] ADB server stopped.', class: 't-green' },
            { text: '[INFO] Deleting settings.json... (Success)', class: 't-green' },
            { text: '[INFO] Uninstallation complete. Jigar Tools removed.', class: 't-cyan' }
          ];

          for (const log of uninstallLogs2) {
            await waitTillVisible();
            terminalBody.appendChild(createLine(log.text, log.class));
            terminalBody.scrollTop = terminalBody.scrollHeight;
            await sleep(100 + Math.random() * 50);
          }
        }

        // Blinking prompt at the end
        const finalPrompt = createLine('<span class="t-prompt">PS&gt;</span> <span class="t-cmd"></span>', 't-blink');
        terminalBody.appendChild(finalPrompt);
        terminalBody.scrollTop = terminalBody.scrollHeight;

        // Advance to next scenario
        scenarioIndex = (scenarioIndex + 1) % 5;

        // Pause before loop restarts
        await sleep(5000);
      }
    }

    startSimulation();

    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          isTerminalVisible = entry.isIntersecting;
        });
      }, { threshold: 0.1 });
      observer.observe(document.querySelector('.terminal-card'));
    } else {
      isTerminalVisible = true;
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
