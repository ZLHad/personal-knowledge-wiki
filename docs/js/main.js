/* ========================================
   Personal Knowledge Wiki - Landing Page
   Minimal vanilla JS interactions
   ======================================== */

(function () {
  'use strict';

  // --- Theme Toggle ---
  const html = document.documentElement;
  const themeToggle = document.getElementById('theme-toggle');
  const stored = localStorage.getItem('pk-theme');
  if (stored) html.setAttribute('data-theme', stored);

  themeToggle?.addEventListener('click', () => {
    const next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('pk-theme', next);
  });

  // --- Navbar Scroll State ---
  const navbar = document.getElementById('navbar');
  let ticking = false;
  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        navbar?.classList.toggle('scrolled', window.scrollY > 30);
        ticking = false;
      });
      ticking = true;
    }
  });

  // --- Mobile Nav Toggle ---
  const hamburger = document.getElementById('nav-hamburger');
  const navLinks = document.querySelector('.nav-links');
  hamburger?.addEventListener('click', () => {
    navLinks?.classList.toggle('open');
    const spans = hamburger.querySelectorAll('span');
    const isOpen = navLinks?.classList.contains('open');
    if (isOpen) {
      spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
      spans[1].style.opacity = '0';
      spans[2].style.transform = 'rotate(-45deg) translate(5px, -5px)';
    } else {
      spans[0].style.transform = '';
      spans[1].style.opacity = '';
      spans[2].style.transform = '';
    }
  });

  // Close mobile nav on link click
  navLinks?.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
      const spans = hamburger?.querySelectorAll('span');
      if (spans) {
        spans[0].style.transform = '';
        spans[1].style.opacity = '';
        spans[2].style.transform = '';
      }
    });
  });

  // --- Active Nav Highlight ---
  const sections = document.querySelectorAll('section[id]');
  const navItems = document.querySelectorAll('.nav-links a');

  const navObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.id;
        navItems.forEach(a => {
          a.classList.toggle('active', a.getAttribute('href') === '#' + id);
        });
      }
    });
  }, { rootMargin: '-40% 0px -60% 0px' });

  sections.forEach(s => navObserver.observe(s));

  // --- Scroll Animations (AOS) ---
  const aosElements = document.querySelectorAll('[data-aos]');
  const aosObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        aosObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

  aosElements.forEach(el => aosObserver.observe(el));

  // --- Tab Switcher ---
  const tabBtns = document.querySelectorAll('.tab-btn');
  const tabPanels = document.querySelectorAll('.tab-panel');

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const tabId = btn.dataset.tab;
      tabBtns.forEach(b => b.classList.remove('active'));
      tabPanels.forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      document.getElementById('tab-' + tabId)?.classList.add('active');
    });
  });

  // --- Floating Graph Nodes Animation ---
  const graphNodes = document.querySelectorAll('.graph-node:not(.graph-node-center)');
  graphNodes.forEach((node, i) => {
    const delay = i * 0.5;
    const duration = 3 + Math.random() * 2;
    node.style.animation = `float ${duration}s ease-in-out ${delay}s infinite alternate`;
  });

  // Add float keyframes dynamically
  const style = document.createElement('style');
  style.textContent = `
    @keyframes float {
      0% { transform: translate(0, 0); }
      100% { transform: translate(${Math.random() > 0.5 ? '' : '-'}${3 + Math.random() * 5}px, ${Math.random() > 0.5 ? '' : '-'}${3 + Math.random() * 5}px); }
    }
  `;
  document.head.appendChild(style);

})();
