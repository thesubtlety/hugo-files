---
title: "On Red Teams, Threat Actors, and Why We're All Just Making This Up As We Go"
date: 2021-12-02T19:50:21-07:00
draft: true
---

# On Red Teams, Threat Actors, and Why We're All Just Making

**Disclaimer**: This is armchair punditry of the highest order. I'm wildly unqualified to make most of these assertions, but this is the internet, so here we are.

**"Simulate Real Adversaries"**

There's this persistent idea that red teams should exclusively simulate specific threat actors—replicate their TTPs, mirror their toolchains, basically LARPING as APT28 or whatever group is trendy this quarter. The [Diamond Model](https://web.archive.org/web/20200422214919/http://sixdub.net/?p=762) gave us a framework for analyzing intrusions, and everyone thinks they need to pretend to be a nation-state actor.

But this approach is limiting. Yes, some organizations want to know if they're vulnerable to a specific threat group's documented tactics. Fair enough. But most don't actually need that. And even if they did, threat groups aren't static—their tactics evolve. You're essentially defending against last year's attacks.

As sixdub pointed out back in the day, we should be questioning whether internal and external providers are actually replicating the "multifaceted aspects" of adversaries or just checking boxes. Maybe the industry has matured past this in the last five years. Maybe not. Your mileage may vary.

**What These Groups Actually Are**

Let's get real about what we're dealing with here:
APTs are, as the grugq put it, "[literally the instantiation of a nation state's will.](https://medium.com/@thegrugq/cyber-ignore-the-penetration-testers-900e76a49500)" They're not a toolchain. They're not a malware family. They're a nation-state's will with resources to match.
Red Teams (consultant or internal) are the instantiation of an organization's desire to answer business risk questions. You get what you pay for. More money and time = better assurance about your actual business risks.

Cybercrime groups are people trying to get paid, cause chaos, or occasionally satisfy some misguided curiosity about what happens when you click the Big Red Button.

**But They're All Just People**

Here's really - these are all just humans sitting at keyboards. Their resources vary. Their sophistication varies. Their capabilities vary. Fundamentally, they're all just people exploiting the same shared technology stacks we all rely on.

Yes, elite groups are using sophisticated techniques that most lawful practitioners rarely touch. But compromise ultimately happens because people are incentivized to achieve a goal against a victim. The means vary, but the underlying mechanisms? Pretty much the same across the board.

**How Work Surfaces (Or Doesn't)**

The way we learn about these groups' work depends entirely on who they are: Red teams have career incentives to publish. Research leads to visibility, which leads to higher earnings and better jobs. This creates an interesting dynamic where vulns are independently discovered by multiple teams. But cybercriminals don't exactly publish quarterly reports. We learn about their work through AV/EDR telemetry, honeypots, VirusTotal uploads, malware analysis, threat intel reports, and the occasional leak. APT groups don't publish either, but we've had some great leaks: Shadow Brokers dumping NSA toolkits, Vault7 revealing CIA capabilities. Strangely, we haven't seen equivalent public releases of Russian, Chinese, or Israeli toolkits. Make of that what you will.

**The Dual-Use Conversation We Keep Having**

Every time these toolkits leak, observers clutch their pearls about the dangers of dual-use technology. Cue conversations about Wassenaar, arms control, policy, censorship, and whether we should regulate vulnerability research. But the thing is: these capabilities are inevitable. You can't un-invent knowledge. The cat's out of the bag, and it's never going back in.

**So What's a Red Team Actually For?**
Strip away the threat actor simulation theater, and a red team is really about
- Challenging assumptions
- Testing systems and controls
- Testing blue team response
- Finding systemic risks so you know where to focus defense spending

You're not an APT, no matter how cool your custom C2 framework is. We should stop pretending red teams are perfect threat actor simulators and start treating them as business risk assessment tools.