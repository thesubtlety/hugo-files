+++
title = "Resources"
categories = "misc"
+++

# Security Reference Wiki

A collection of enduring references on security, risk, and adversarial thinking. In short:

- We have no idea if anything we do actually works[[1](https://magoo.medium.com/next50-ea33c5db5930)]. Measurement and root causes remain security's fundamental unsolved problem
- The industry thinks training fixes people but research shows it makes things worse [[2](https://arxiv.org/pdf/2112.07498)]. Use passkeys/webauthn/yubikeys.
- Most breaches don't matter for most orgs. [[3](https://www.cisa.gov/sites/default/files/publications/CISA-OCE_Cost_of_Cyber_Incidents_Study-FINAL_508.pdf)] 85% fail to meet accounting materiality thresholds and the median cost-to-revenue ratio: 0.37%
- Only 12% of patches matter for APT defense. But immediate patching = 4.9x lower compromise odds vs. 1 month delay. [[4](https://arxiv.org/pdf/2205.07759)]
- While useful, EDRs are fundamentally ineffective against actual APT actors[[5](https://www.mdpi.com/2624-800X/1/3/21)]

## Red Teaming & Adversarial Assessment

- [An Adversary's View of Your Digital System](https://www.osti.gov/servlets/purl/1252941) `2015 [PDF]` - Sandia National Labs - Adversary-based assessment methodology. Attack graphs and identifying critical paths. Nice Generic Threat Matrix (GTM).
- [Red Teaming Handbook (3rd Edition)](https://assets.publishing.service.gov.uk/media/61702155e90e07197867eb93/20210625-Red_Teaming_Handbook.pdf) `2021 [PDF]` - UK Ministry of Defence - Guide to red team mindset and formal methodologies. Apply fast, simple red teaming techniques as part of everyday routines rather than waiting for formal engagements
- [10 Red Teaming Lessons Learned Over 20 Years](https://oodaloop.com/analysis/ooda-original/10-red-teaming-lessons-learned-over-20-years/) `2015 [Website]` - Matt Devost - Asymmetry, OODA loops, and avoiding artificial constraints. 10th man rule - if nine analysts reach the same conclusion, the tenth must disagree and explore unlikely scenarios. A red team should never compromise integrity to satisfy sponsors - speak truth to power even when findings are unpopular.
- [Adversarial Red Team Assessment Framework](https://www.dst.defence.gov.au/sites/default/files/publications/documents/DST-Group-TR-3335.pdf) `2017 [PDF]` - Australian Defence Science and Technology Group. Cognitive bias mitigation strategy. Red Teaming Umbrella framework as a spectrum from simple critical analysis to complex field exercises - Critical Analysis, Tabletop, Functional/Attack pathing, Computational/Purple teaming, Cyber/"Red Teaming", Wargaming (Physical element), Field Exercises (live tests)
- [Six Rules for Wargaming](https://warontherocks.com/2015/11/six-rules-for-wargaming-the-lessons-of-millennium-challenge-02/) `2015 [Website]` - Lessons from Millennium Challenge 02's red team victory. Validation should NEVER come from a single wargame. Never allow concept developers to run their own analysis, "akin to allowing students to grade their own tests.""

## Risk Measurement & Cybersecurity Economics

- [Cybersecurity is not very important](http://www.dtc.umn.edu/~odlyzko/doc/cyberinsecurity.pdf) `2019 [PDF]` - Andrew Odlyzko - Contrarian view on risk, resilience, and the muddle-through approach. Complexity and "security through obscurity" are essential elements of imperfect security. We haven't suffered major tech catastrophes despite decades of insecurity, suggesting threats are manageable within acceptable risk tolerance.
- [Defense Acquisition and Operational Risk](https://nps.edu/documents/103424423/106950799/DRMI+Working+Paper+2011-3.pdf) `2011 [PDF]` - Naval Postgraduate School - Risk management frameworks. Without knowledge of decision maker preferences, there is no risk. Kaplan-Garrick risk definition (eg what can go wrong, how likely, what consequences) is incomplete. A fourth question must be asked - "How do you feel about it?"
- [Measuring Security (And Risk) - Geer](https://all.net/Metricon/measuringsecurity.tutorial.pdf) `2006 [PDF]` - Dan Geer- Foundational work on security measurement. Security metrics must be "decision support, possibly under fire". Early investment pays exponentially - empirical data shows 21%/15%/12% returns on security investment at design/implementation/maintenance stages. Design-stage security being 100x more cost-effective than maintenance-stage fixes.
- [Next50: Measuring and Managing Organizational Security](https://magoo.medium.com/next50-ea33c5db5930) `2018 [Medium]` - Ryan McGeehan (Magoo) - Modern enterprise security measurement. Information security industry is stalling due to lack of a "measurement revolution" comparable to meteorology's post-1950 transformation. Security teams operate irrationally because they lack classification methods for breach root causes, transparency into breach causation, and probabilistic forecasting.
- [Cost of a Cyber Incident](https://www.cisa.gov/sites/default/files/publications/CISA-OCE_Cost_of_Cyber_Incidents_Study-FINAL_508.pdf) `2020 [PDF]` - CISA systematic review - Per-incident costs, aggregate losses, and defensible estimates. Incident costs have extreme variability with heavy-tailed distributions where the mean is a poor indicator. 85% of cyber incidents fail to meet financial materiality thresholds (of 2-10%). The median cost-to-revenue ratio across all sectors is only 0.37%. Per-record cost estimates are flawed because breach costs don't correlate strongly with breach size for large incidents.

## Phishing & Security Awareness

- [On Fire Drills and Phishing Tests](https://security.googleblog.com/2024/05/on-fire-drills-and-phishing-tests.html) `2024 [Google Blog]` - Google Security - Why phishing tests don't work and what to do instead. No evidence exists that phishing tests reduce successful phishing incidents. Traditional tests cause harmful side effects: they bypass systematic security controls, degrade trust between users and security teams, create incident response burden, and make employees feel "tricked." Alternative: "phishing fire drills" - pre-announced training emails that clearly identify themselves, focusing on education and practicing reporting. Fix tools, not people - use phishing-resistant authenticators.
- [The Ineffectiveness of Phishing Security Education](https://arxiv.org/pdf/2112.07498) `2021 [arXiv PDF]` - 14,000 participant study showing repeat clickers fail despite interventions. Embedded phishing training is counterproductive. Training fosters false sense of security or over-reliance on institutional defense. Use employees as collective detection mechanism is practical, efficient, and sustainable. Tested with 14,000 people over 15 months.

## Incident Response & Detection

- [Empirical Assessment of EDR Systems Against APTs](https://www.mdpi.com/2624-800X/1/3/21) `2021 [Journal Article]` - Testing 11 endpoint detection tools against advanced attack vectors. State-of-the-art EDRs failed to prevent and log the bulk of APT attacks tested. 11 EDR products using 20 diverse attack vectors, 10 attacks were completely successful with no alerts issued, 3 were successful with low-significance alerts, and only 6 were detected correctly.
- [Incident Response Scenarios](https://www.thesubtlety.com/incident-response-scenarios/) `[Website]` - Practical tabletop exercises for IR teams with scenarios from @Magoo, not affiliated
- [Canary Tokens at Scale (Tularosa Study)](https://www.usenix.org/system/files/sec21-ferguson-walter.pdf) `2021 [USENIX PDF]` - USENIX research on deploying deception at enterprise scale. Cyber deception significantly impedes attacker progress (tested with 130 red teamers). Physical presence of deception and psychological awareness of deception technologies affected behavior - effective defensive strategy at scale
- [Thinkst Canary](https://thinkst.com/ts/) `[Website]` - Honeypot/canary tokens (free and paid)

## Threat Intelligence 
- [China's Offensive Cyber Ecosystem](https://ethz.ch/content/dam/ethz/special-interest/gess/cis/center-for-securities-studies/pdfs/before-vegas-cyberdefense-report.pdf) `2024 [PDF]` - ETH Zurich - Analysis of Chinese bug bounty programs and hacking contests. Chinese security agencies gain exclusive access to zero-days granting them first access to vulnerabilities discovered by civilian researchers (who must report within 2 days under 2021 RMSV regulations), then outsources actual operations to private contractors. 
- [Patch Management: Only 12% of Public Exploits Get Patched](https://arxiv.org/pdf/2205.07759) `2022 [arXiv PDF]` - Empirical study on patch deployment rates. Performing only 12% of all possible updates - only patching publicly known vulnerabilities exploited in documented APT campaigns wouldn't significantly change compromise odds compared to organizations updating for all versions. Update immediately faces 4.9x lower odds of compromise than those waiting one month and 9.1x lower than those waiting three months.

## Reference
- [APT Groups and Operations](https://www.vx-underground.org/apts.html) `[Website]` - VX-Underground comprehensive APT reference - largest publicly accessible collections of APT malware samples and campaign documentation,
- [Security Mindmaps](https://www.amanhardikar.com/mindmaps.html) `[Website]` - Aman Hardikar - Visual knowledge maps for security domains
- [Infosec Reference](https://rmusser.net/docs/#/) `[Website]` - Comprehensive knowledge base by rmusser - technical references

## Leadership & Organizational Strategy

- [Doing a Job - Admiral Hyman Rickover](https://govleaders.org/rickover.htm) `1982 [Website]` - Classic leadership text on responsibility and standards. "Ownership without formal structure" - eliminate job descriptions and organizational charts, giving subordinates authority and responsibility early while defining roles broadly so people are "limited only by their own ability." "When doing a job—any job—one must feel that he owns it"
- [Trying Too Hard](https://brianlangis.wordpress.com/wp-content/uploads/2018/02/williams-trying_too_hard.pdf) `1981 [PDF]` - Essay on organizational effectiveness. "Confidence in a forecast rises with the amount of information that goes into it, but the accuracy of the forecast stays the same." Stop trying to forecast every threat scenario and instead focus on measuring current vulnerabilities and value 
- [Strategy is About What You Don't Do - Jason Chan](https://www.youtube.com/watch?v=rXG6ExQbIZo) `[YouTube]` - Strategic focus and prioritization
- **Turn the Ship Around** (L. David Marquet) `2013 [Book]` - "Intent-based leadership" uses language shift from "request permission" to "I intend to..." - forces subordinates to think like leaders while maintaining accountability. 
- **Drive** (Daniel Pink) `2009 [Book]` - Great book on intent-based leadership and motivation. Extrinsic rewards (money, bonuses) actually reduce performance for complex cognitive work. Autonomy-Mastery-Purpose (AMP) shows that for complex work requiring creativity, the key is to "pay enough to take the issue of money off the table" then motivate through autonomy (control over time/technique), mastery (progress at meaningful skills), and purpose (contribution to mission larger than self).

## Technical Papers & Detailed Analysis

- [This World of Ours](https://www.usenix.org/system/files/1401_08-12_mickens.pdf) `2014 [USENIX PDF]` - James Mickens - The security threat model spectrum. "Mossad or not-Mossad" threat model -  security threat models should be binary rather than elaborate. Either you're facing nation-state adversary (Mossad) who will defeat any defenses regardless, or you're not (in which case basic security hygiene suffices)
- [Security Analysis of System](https://www.usenix.org/system/files/usenixsecurity23-hielscher.pdf) `2023 [USENIX PDF]` - USENIX Security 2023 - Deep technical security analysis. Security managers are fully aware their measures cause significant friction reducing productivity and increasing vulnerability, and they can identify underlying causes. But organizations prioritize compliance with external standards over usability. Regulatory requirements prevent implementing more usable security solutions.
- [Measuring Information Security](https://www.youtube.com/watch?v=PGLYEDpNu60) `2025 [YouTube]` - Video lecture on security metrics. 40 elite Chinese hackers from late 1990s-2000s red hacker groups formed the foundation of China's modern cyber ecosystem.  Individuals moved from grassroots patriotic hacktivists in informal collectives (Green Army, Xfocus, 0x557, NCPH) to industry leaders, founding  cybersecurity firms (NSFOCUS, Knownsec, Pangu Lab), leading security teams at tech giants (Alibaba, Tencent, Baidu), and in some cases transitioning into state APT operations (APT17, APT27, APT41). "New School" era with structured CTF competitions, bug bounties, university programs, state alignment. 
- [Learning the wrong lessons from Offense (Haroon Meer)](https://www.youtube.com/watch?v=AQfbPpkaq88) `2016 [YouTube]` 
- [Attack Driven Defense - Zane Lackey](https://www.youtube.com/watch?v=BSDIhZYR4E4) `2014 [YouTube]`
- [Building and Leading Corporate Red Teams by Dale Pearson](https://www.youtube.com/watch?v=2kWMIffjNXI) `2018 [YouTube]`