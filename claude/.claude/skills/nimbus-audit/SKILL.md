---
name: nimbus-audit
description: Periodic health and security audit of the nimbus droplet, diffed against the 2026-09-17 baseline instead of re-auditing from scratch. Use when Jerry says "audit nimbus", "nimbus health", "is the box ok", "security check", or after an OS upgrade. nimbus only.
user_invocable: true
---

# nimbus Audit

Baseline and decisions live in memory `project_nimbus_ops_audit_2026-09-17`. Read it first. Report only drift from that
baseline, not the whole checklist again.

## Do not re-propose (decided)

- Tailscale-only SSH: declined, port 5914 stays public (fail2ban aggressive + US-only nft filter compensate).
- CIS accepted fails: MaxSessions, ftp/tnftp, accept_ra, PAM/password/umask/TMOUT, grub, /tmp partition, AIDE,
  apparmor enforce, LogLevel INFO, journald forward, ufw removal.
- Ollama on loopback and SSH on 5914 are intentional.

## 1. What Claude checks directly (sandboxed, read-only)

- `free -h` and `cat /proc/pressure/memory` (some avg10 near 0 is fine), `df -h /`
- Latest logs in `~/Services/monitor/logs/`: `health-check-*`, `monitor-*`, `security-audit-*` (weekly), `notify-unit-failure-*` (any unit failures since the last audit)
- `git -C ~/Services status --short` plus the eva, job-sweep and dotfiles repos: anything uncommitted or unpushed
- `systemctl` from the sandbox fails (no D-Bus); do not treat that as a finding.

## 2. What Jerry runs (sandbox cannot see host net/PID namespace)

Give these as a numbered list, one command per step, outputs saved to one file he can paste back:

1. `sudo ss -ltnup`
2. `sudo ufw status numbered`
3. `sudo sshd -T -C user=jerry,addr=8.8.8.8 | rg -i '^(port|passwordauthentication|permitrootlogin|maxsessions)'`
4. `sudo fail2ban-client status sshd`
5. `systemctl list-timers 'nimbus-*' --all`
6. `sudo journalctl -u nimbus-backup.service -n 20 --no-pager`
7. `sudo pro status | rg -i 'livepatch|usg'` and `cat /var/run/reboot-required 2>/dev/null`
8. Verify: confirm every command printed output with no permission errors.

Optional quarterly: `sudo usg audit cis_level1_server --results-file /tmp/usg-results.xml` (baseline 85.0).
fail2ban.log timestamps are UTC.

## 3. Report

One table: check | baseline | now | action. Only rows that drifted or need action get detail. Any fix that touches sshd,
ufw, fail2ban, systemd units or backups is a risky change: root cause, fix steps, verification, Codex adversarial review,
then Jerry's approval. Update the baseline memory with the new date and anything that changed.
