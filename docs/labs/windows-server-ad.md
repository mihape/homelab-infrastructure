# Windows Server / Active Directory lab — in progress

**Last reported status:** 2026-09-19. **Environment:** Proxmox VM 124.

## Confirmed milestone

Windows Server has been installed in VM 124 as the starting point of a personal Active Directory learning lab. **No AD DS role installation, domain-controller promotion, domain, OU, GPO, DNS integration or client domain join is claimed as complete.** This is **homelab learning**, not production or professional AD administration.

## Planned lab sequence (not completed work)

1. Confirm OS version, updates, licensing/evaluation status, VM backup and available resources.
2. Design a **separate lab subnet or otherwise isolated test network** before enabling any AD-related DNS/DHCP services. Do not introduce a lab DHCP server onto the live household LAN or redirect household DNS accidentally.
3. Assign a predictable lab address and decide the DNS namespace and name-resolution flow.
4. Configure AD DS and DNS, promote a test domain controller and check health.
5. Join a test Windows client; create OUs, users, groups and a limited GPO.
6. Reproduce a safe DNS, sign-in or GPO failure; collect logs, document diagnosis, correction and validation.
7. Add PowerShell commands and evidence after actually running them; capture only sanitized screenshots.

## Evidence to add as each step is finished

- Sanitized network/VM diagram and brief architecture decisions.
- Role and client versions, test objectives, executed commands and expected vs observed results.
- DNS and AD health checks; a tested rollback or restore, not just a snapshot label.
- At least one ticket-style incident and a short runbook.

**Publication rule:** Never commit real credentials, domain secrets, identifying user data or the internal work environment. Do not present planned steps as completed work.
