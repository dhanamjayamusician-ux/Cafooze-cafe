const revealElements = document.querySelectorAll(".reveal");
const siteHeader = document.querySelector(".site-header");
const mobileHeaderQuery = window.matchMedia("(max-width: 820px)");
let lastScrollY = window.scrollY;

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        revealObserver.unobserve(entry.target);
      }
    });
  },
  {
    threshold: 0.16,
    rootMargin: "0px 0px -40px 0px"
  }
);

revealElements.forEach((element) => {
  revealObserver.observe(element);
});

const handleHeaderVisibility = () => {
  if (!siteHeader) {
    return;
  }

  if (!mobileHeaderQuery.matches) {
    siteHeader.classList.remove("is-hidden");
    lastScrollY = window.scrollY;
    return;
  }

  const currentScrollY = window.scrollY;
  const scrollingDown = currentScrollY > lastScrollY;
  const pastThreshold = currentScrollY > 96;

  if (scrollingDown && pastThreshold) {
    siteHeader.classList.add("is-hidden");
  } else {
    siteHeader.classList.remove("is-hidden");
  }

  lastScrollY = currentScrollY;
};

window.addEventListener("scroll", handleHeaderVisibility, { passive: true });
window.addEventListener("resize", handleHeaderVisibility);
handleHeaderVisibility();
