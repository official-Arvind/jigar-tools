/* ==========================================================================
   JIGAR TOOLS - v2.0-Gold Edition Documentation Javascript Logic
   Logic: Navigation, Accordions, Search, Interactive Demos, and Visualizers
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    // --- 1. TAB NAVIGATION ---
    const navItems = document.querySelectorAll('.nav-item');
    const sections = document.querySelectorAll('.content-section');
    const contentBody = document.getElementById('content-body');

    window.navigateTo = function(targetId) {
        // Remove active from all items and sections
        navItems.forEach(item => item.classList.remove('active'));
        sections.forEach(sec => sec.classList.remove('active-section'));

        // Add active to selected
        const activeNav = document.querySelector(`.nav-item[data-target="${targetId}"]`);
        if (activeNav) activeNav.classList.add('active');

        const activeSection = document.getElementById(targetId);
        if (activeSection) activeSection.classList.add('active-section');

        // Scroll content to top
        contentBody.scrollTop = 0;
        
        // Update URL hash
        window.location.hash = targetId;
        
        // Close mobile sidebar if open
        const sidebar = document.querySelector('.sidebar');
        if (sidebar) sidebar.classList.remove('menu-open');
    };

    // Handle clicks
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const target = item.getAttribute('data-target');
            navigateTo(target);
        });
    });

    // Check hash on load
    if (window.location.hash) {
        const hashTarget = window.location.hash.substring(1);
        if (document.getElementById(hashTarget)) {
            navigateTo(hashTarget);
        }
    }


    // --- 2. MOBILE MENU TOGGLE ---
    const mobileToggle = document.getElementById('mobile-menu-toggle');
    const sidebar = document.querySelector('.sidebar');

    if (mobileToggle && sidebar) {
        mobileToggle.addEventListener('click', () => {
            sidebar.classList.toggle('menu-open');
        });
        
        // Close sidebar if clicking outside on mobile
        document.addEventListener('click', (e) => {
            if (window.innerWidth <= 768 && 
                !sidebar.contains(e.target) && 
                !mobileToggle.contains(e.target) && 
                sidebar.classList.contains('menu-open')) {
                sidebar.classList.remove('menu-open');
            }
        });
    }


    // --- 3. FAQ ACCORDION ---
    const accordionHeaders = document.querySelectorAll('.accordion-header');
    
    accordionHeaders.forEach(header => {
        header.addEventListener('click', () => {
            const item = header.parentElement;
            const isActive = item.classList.contains('active');
            
            // Close all
            document.querySelectorAll('.accordion-item').forEach(i => i.classList.remove('active'));
            
            // Toggle active
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });


    // --- 4. REAL-TIME SEARCH FILTER ---
    const searchInput = document.getElementById('search-input');
    
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase().trim();
            
            // Search inside section text blocks
            sections.forEach(section => {
                const text = section.innerText.toLowerCase();
                const cards = section.querySelectorAll('.glass-card, .timeline-item, h3, p');
                
                if (query === '') {
                    // Show everything if search is empty
                    cards.forEach(c => c.style.opacity = '1');
                    cards.forEach(c => c.style.display = '');
                    return;
                }
                
                let foundMatch = false;
                cards.forEach(card => {
                    if (card.innerText.toLowerCase().includes(query)) {
                        card.style.display = '';
                        card.style.opacity = '1';
                        foundMatch = true;
                    } else {
                        // Fade/hide unmatched blocks within active section
                        card.style.opacity = '0.15';
                    }
                });
            });
        });
    }


    // --- 5. INTERACTIVE DEMO: FALLBACK PIPELINE VISUALIZER ---
    const nodes = [
        document.getElementById('node-1'),
        document.getElementById('node-2'),
        document.getElementById('node-3')
    ];
    const lines = [
        document.getElementById('line-1'),
        document.getElementById('line-2')
    ];
    
    let activeStageIndex = 0;
    
    function animatePipeline() {
        // Reset all nodes and lines
        nodes.forEach(node => {
            if (node) {
                node.classList.remove('active-node');
                node.style.transform = 'scale(1)';
            }
        });
        lines.forEach(line => {
            if (line) {
                line.style.backgroundColor = 'rgba(255, 255, 255, 0.06)';
                line.style.boxShadow = 'none';
            }
        });
        
        // Highlight active node
        const activeNode = nodes[activeStageIndex];
        if (activeNode) {
            activeNode.classList.add('active-node');
            activeNode.style.transform = 'scale(1.05)';
        }
        
        // Highlight active lines leading up to active node
        for (let i = 0; i < activeStageIndex; i++) {
            if (lines[i]) {
                lines[i].style.backgroundColor = 'var(--color-cyan)';
                lines[i].style.boxShadow = '0 0 10px var(--color-cyan)';
            }
            if (nodes[i]) {
                nodes[i].classList.add('active-node');
            }
        }
        
        // Cycle stages
        activeStageIndex = (activeStageIndex + 1) % 3;
    }
    
    // Run animation loop every 2.5 seconds
    if (nodes[0]) {
        setInterval(animatePipeline, 2500);
        // Run initial animation
        animatePipeline();
    }


    // --- 6. INTERACTIVE DEMO: WINFORMS TREEVIEW CHECKBOXES ---
    const checkboxes = document.querySelectorAll('.t-chk');
    
    checkboxes.forEach(chk => {
        chk.addEventListener('click', (e) => {
            e.stopPropagation();
            
            // Toggle checkbox classes: check-square / square
            if (chk.classList.contains('fa-square-check')) {
                chk.classList.replace('fa-square-check', 'fa-square');
                chk.style.color = 'var(--text-muted)';
                
                // If it's the root node, uncheck all children
                if (chk.parentElement.innerText.includes('storage/emulated/0')) {
                    uncheckAllNodes();
                }
            } else {
                chk.classList.replace('fa-square', 'fa-square-check');
                chk.style.color = 'var(--color-violet)';
                
                // If it's the root node, check all children
                if (chk.parentElement.innerText.includes('storage/emulated/0')) {
                    checkAllNodes();
                }
            }
        });
    });
    
    function checkAllNodes() {
        checkboxes.forEach(c => {
            c.classList.replace('fa-square', 'fa-square-check');
            c.style.color = 'var(--color-violet)';
        });
    }
    
    function uncheckAllNodes() {
        checkboxes.forEach(c => {
            c.classList.replace('fa-square-check', 'fa-square');
            c.style.color = 'var(--text-muted)';
        });
    }
});
