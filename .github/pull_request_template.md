# 📌 Description

<!-- Provide a brief summary of the changes. -->

---

## ✅ Related Issues

<!-- Link related issues here, e.g., Fixes #123 -->

---

## 📝 Pull Request Checklist

Please ensure the following before submitting your PR:

- [ ] **Base branch is `main`.**  
  This repository only runs branch/commit checks for PRs targeting `main`.

- [ ] **Avoid returning `Widget` from functions or getters.**  
  Instead, encapsulate reusable UI into separate `StatelessWidget` classes.  
  (Returning widgets from functions is an anti-pattern: it causes unnecessary rebuilds, makes debugging harder, and prevents proper DevTools tree inspection.)

- [ ] **Always use `StatelessWidget`** for static UI components.  
  Widget classes (with `const` constructors where possible) improve performance and hot-reload behavior.

- [ ] **Model classes must be generated using [`dart_mappable`](https://pub.dev/packages/dart_mappable)**.  
  Do not hand-write `toJson` / `fromJson` or equality methods—always rely on code generation (`build_runner`).

- [ ] **Follow [Conventional Commits](https://www.conventionalcommits.org/) and branch naming conventions.**  
  - Allowed commit types: `feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert`  
  - Example commit: `feat: add login screen`  
  - Allowed branch names: `main | master | develop | feature/<slug> | feat/<slug> | bugfix/<slug> | fix/<slug> | hotfix/<slug> | release/<slug> | chore/<slug>`  
    where `<slug>` is lowercase letters, numbers, dots, underscores, or dashes (e.g., `feature/login-screen`).

- [ ] **Code is formatted** before committing.  
  Run `fvm dart format .` (or ensure your IDE does this automatically).

- [ ] **Follow naming conventions for widgets and views.**  
  Use "view" suffix for main/page widgets (`HomeView`, file: `home_view.dart`) and "widget" suffix for smaller reusable components (`TicketCardWidget`, file: `ticket_card_widget.dart`).

- [ ] **Static checks pass locally.**  
  Run: `fvm flutter analyze` and (if applicable) `fvm flutter test`.

- [ ] **Screenshots / recordings** added for UI changes.

- [ ] **Breaking changes** are called out clearly and migration notes included.

- [ ] **No secrets or sensitive data** committed. Environment variables and keys are handled securely.

---

## 🔍 Validation Notes (optional)

- How this was manually tested (devices, emulators, platforms):
- Any known limitations or follow-ups:
