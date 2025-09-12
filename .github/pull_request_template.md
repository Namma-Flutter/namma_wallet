## 📝 Pull Request Checklist

Please ensure the following before submitting your PR:

- [ ] **Avoid returning `Widget` from functions or getters.**  
  Instead, encapsulate reusable UI into separate `StatelessWidget` classes.  
  (Returning widgets from functions is an anti-pattern: it causes unnecessary rebuilds, makes debugging harder, and prevents proper DevTools tree inspection.)

- [ ] **Always use `StatelessWidget`** for static UI components.  
  Widget classes (with `const` constructors where possible) improve performance and hot-reload behavior.

- [ ] **Model classes must be generated using [`dart_mappable`](https://pub.dev/packages/dart_mappable)**.  
  Do not hand-write `toJson` / `fromJson` or equality methods—always rely on code generation (`build_runner`).

- [ ] **Follow [Conventional Commits](https://www.conventionalcommits.org/) and branch naming conventions.**  
  Example commit: `feat: add login screen`  
  Example branch: `feature/login-screen`

- [ ] **Code is formatted** before committing.  
  Run `fvm dart format .` (or ensure your IDE does this automatically).

- [ ] **Follow naming conventions for widgets and views.**  
  Use "view" suffix for main/page widgets (`HomeView`, file: `home_view.dart`) and "widget" suffix for smaller reusable components (`TicketCardWidget`, file: `ticket_card_widget.dart`).

---

## 📌 Description

<!-- Provide a brief summary of the changes. -->

---

## ✅ Related Issues

<!-- Link related issues here, e.g., Fixes #123 -->
