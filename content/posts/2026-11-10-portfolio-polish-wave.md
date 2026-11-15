---
title: "Week of 10 Nov: Risk-tiered merges for an AI software factory"
date: 2026-11-10
draft: false
ShowToc: false
tags: ["weekly-log", "mlops", "fintech"]
---

This week I treated the portfolio as a hiring surface again: an English site for ML Engineer / MLOps roles in fintech. Content first, PaperMod stays, and Posts becomes a weekly learning diary instead of an empty blog.

### Shipped & Built
* **[web-portfolio](https://github.com/JLaborda/web-portfolio):** custom domain [jlaborda.com](https://jlaborda.com) live; specs merged for hiring content (008) and this learning diary (009).
* **[web-portfolio](https://github.com/JLaborda/web-portfolio):** constitution amended to v4.0.0 to run the repo with a bot-based software factory (Spec Kit + TDD + GitHub Issues).

### Engineering Note: Not every PR deserves the same gate
Letting agents merge their own work is only safe if the gate matches the risk. Every PR is now classified green, yellow or red. Green content and code PRs are merged automatically after review; yellow ones (e.g. text that speaks in my name) wait for me; red ones — AWS/IAM/OIDC, CI, branch protection or constitution changes — always need a human. It is the same idea as risk-based approval in a fintech change process: automate the boring path, keep humans on the blast radius.

### Next Up
* Rewrite the SmartWealthAI credit / MLOps case study.
* Then start the fintech-sec-rag-agent case study, with a day-one architecture diagram.
* Keep studying for AWS MLA-C02.
