# THE NINTH EXHALE — MASTER GAME BIBLE

**Edition:** 17 November 2026 consolidated production candidate (V6 canon; targeted clarifications).  
**Readiness:** **SPECIFIED, NOT ENGINE-IMPLEMENTED.** All core narrative routes and data catalogues are retained; FPS combat, Godot traversal, enemies, controls, audio and player balance still need implementation and testing. It is not appropriate to call this a completed game.

**Single source of truth:** This document replaces the need to consult historical bible versions for retained world, narrative and mechanical specifications. Companion audit, changelog and handover record provenance; they do not introduce alternative rules. The source Python story generator is a narrative reference, not an implemented shooter.

**Authority:** Existing V5 binding canon and Protected Originality Register control lore, cast, districts, endings, creature ethics and visual identity. V6 RPG/roguelite specification controls *provisional numerical gameplay and Godot interfaces*. The current five-command Echoform hearing supersedes retired type-matchup and four-move gameplay; historical species move names survive only as behaviour/animation references. Proposed controls, AI targets and audio budgets below are **not** declared established fiction. No substantial new canon is silently approved.

### Navigation
1. Project identity · 2. Gameplay overview · 3. World and lore · 4. Main story · 5. Characters and factions · 6. Quests · 7. Player systems · 8. Weapons and equipment · 9. Enemies, bosses and Echoforms · 10. Levels and procedural generation · 11. Art direction · 12. Audio · 13. User experience · 14. Technical design · 15. Production plan · 16. Verification and open decisions · Appendices A–E (full reference catalogues, evidence, asset standards and ID bridge).



## 1. Project identity and immutable creative contract

### 1. Creative contract and what must remain original

The Ninth Exhale is an original setting, not a DOOM, Pokémon, Fallout or Dark Souls setting. Its subjects, factions, monsters, characters, weapon silhouettes and rules are original. The influences are **structure and player experience**: fast first-person violence; player-selected RPG solutions; earned milestones and a short creature-duel system; long NPC stories discovered by returning to places; and an authored conclusion in every successful run. The graphic target is early-1990s PC sprite horror, not modern 3D filtered to look retro.

Every successful campaign has five acts: emergency, three institutional challenges, reveal, confrontation, final civic decision. The legal mandatory route is **install the Cinder Lung → earn three different founding Writs → complete an Echoform trial → confront the Custodian → choose an ending**. The mandatory civic Echoform interference hearing can be completed with a public-service loaner without capture or lifetime ownership. The Writs can be taken in any order. All three unconditional endings (Liberation, Dominion, The Crown) remain available to every successful character build. True Dawn is deliberately hidden behind three optional, reliable discoveries **and an explicit public mandate**, which a predatory character can fail to earn.

**Anti-theme drift:** A violent or bad ending should not be portrayed as a mechanical mistake. A compassionate outcome should not routinely reward weaker gear with nothing in exchange. Citizens cannot be reduced to props for ethical speeches: each district needs food, work, domestic grievances, humour, affection and routines that continue when Ninth is absent.

**Target:** primarily Linux desktop, offline, keyboard/mouse as initial delivery target; controller and accessible presentation require QA. The precise commercial platforms, rating and audience are not established. **Full campaign duration target:** 73–108 minutes; **vertical slice target:** 20–35 minutes. These are not measured play times.

**Protected rule:** creative specificity is achieved by Vesper's municipal resource economy, analogue archives, regulated reconstruction and civic dilemmas—not by placing borrowed franchise art inside a sprite-era renderer.



## 2. Gameplay overview and player journey

**The run loop:** choose a six-stat build → wake at Hearth Nine → resolve contested Cinder Lung allocation → explore three featured Writ districts (two others are optional) → complete one civic Echoform hearing with a guaranteed loaner → reach the archive lift with three different Writs → resolve one Custodian → deliberately select a valid ending → seal the successful campaign. Each attempt may contain three long NPC arcs and two short quests per featured district; optional content remains optional.

**Play rhythm:** rapid first-person movement and combat between investigations and pressure-docket dialogue. The player may instead obtain many Writs through evidence, technical action or stealth. When combat is selected, a guaranteed, adequate baseline weapon/supply route exists. Local actions affect city resources, witnesses, services and train seats. Unique-event XP rewards successful problem resolution rather than repeated kills.

**Loss and persistence:** death at zero HP ends the attempt and triggers another bounded reconstruction with a newly generated WorldPlan. The character's current loot, XP, relationships, Writs and civic resources reset. Persisted player-facing unlocks add equipment *offer opportunities*, codex records, cosmetics and verified failed-attempt evidence—not permanent combat stats. New campaigns after *successful* endings are counterfactual, not revivals of an ended timeline.

**Full-game vs slice:** the production slice intentionally uses a two-Writ test lift and limited ending cards. That exception MUST NOT be used in full-game eligibility checks; the full game requires three founding credentials. True Dawn additionally requires the Deep Heat Survey, Orchard Root Seed, Founders' Cipher (stable item ID `cipher`) and explicit public mandate; the other three endings require no optional evidence.

**Creature system:** a physically situated civic interference hearing, five commands `Press`, `Attune`, `Brace`, `Observe`, `Withdraw`; one active Echoform, possibly selected from up to three accord records. No capture reward for victory, elemental damage ring or compulsory creature ownership.



## 3. World, chronology, institutions and lore

### 2. Fundamental laws of Vesper — binding V3 canon

#### 2.1 The White Quiet and the two-channel Engine

The White Quiet struck Vesper ninety-one years before the playable present. A bounded atmospheric wound made matter and memory interfere with one another. The inhabitants built the **Lumen Engine** as a containment machine, not originally as a harvesting machine.

It has **two non-interchangeable functions**:

1. **Power channel:** conventional heat and current drive pumps, grow-lamps, filters, fabrication presses, defensive batteries and parts of the false-sun projection. Fossil fuel, furnace heat and deep geothermal reservoirs may power this channel. Heat does not heal the reality wound.
2. **Boundary-correction channel:** adaptive patterns compare the local world against stable reference memories and continuously repair information errors at the wound. Human recollection offers diverse, fast-changing patterns. The first memories were offered voluntarily. Forced human harvesting then became a cheap, flexible, politically convenient shortcut. The controller needs *patterns*, not human pain as magic fuel.

The Engine can function briefly on stored patterns, but storage degrades. The city cannot simply switch off the correction channel and keep its air, or attach a geothermal boiler and declare the breach repaired. This distinction is crucial to the Endings, the Cinder Lung, the Unsaid and the ethics of alternative research.

#### 2.2 Where monsters come from

A harvested memory is not automatically a living being. When correction patterns are discarded unbound, they accumulate as unstable sensory loops. In a contaminated biomechanical environment, they become **the Unsaid**: dangerous, incomplete figures that repeat habits and voices without understanding them. When the same material is printed onto a stable lattice and fed sufficient biomass, some bodies become coherent **Echoforms**. Some Echoforms remember fear, exhibit preference, refuse orders and recognise one another. They are not automatically human, but their capacity to experience harm is observable. Whether the city should grant them personhood is a live legal dispute.

Large creatures consume mechanical power, cooling capacity and physical materials. The Engine cannot multiply free biomass indefinitely. A high-output memory harvest creates more Unsaid waste; raising military production to suppress the Unsaid therefore exacerbates the crisis. This feedback loop is an important systemic reason the regime endures and a weakness the player can exploit.

#### 2.3 The five finite resources

| Resource | Actual source | Main demand | Why the government cannot manufacture abundance |
|---|---|---|---|
| **Energy** | Furnace heat, current, limited geothermal supply | Pumps, ward batteries, artificial sun, reconfiguration | Distribution capacity, failing grids and heat waste limit usage |
| **Correction integrity** | Human reference patterns, stored templates, experimental nonhuman lattice | Reality boundary, reliable clean-air operation | Patterns become stale; involuntary extraction is fast but destructive |
| **Biomass** | Agriculture, recovery of dead tissue, controlled vats | Reprints, creature bodies, medicine | Must be grown or recycled; recycling carries contamination risks |
| **Clean-air throughput** | Filter output inside a controlled breach zone | Clinics, homes, work, rail transit | Pipes, lung modules and correction filters physically bottleneck flow |
| **Labour and time** | People, machines, reprinted workers | Infrastructure, repairs, research, transit | Skills and trustworthy continuity cannot be printed at no cost |

No faction holds all five resources. Trade adjudicates contracts and distribution; Labour runs energy and fabrication; Growth tends biomass and experiment; Faith maintains civic rituals and mnemonic signal infrastructure; Defence operates armed corridors and border gates. Their conflicts are a functioning political economy, not five loosely themed arenas.

#### 2.4 Nightly reconstructions and the run boundary

The Lumen Engine contains physical modular infrastructure: sliding room blocks, pressure doors, rail switches, reusable ducts and limited biological presses. At dusk it reconfigures these existing modules, relocates staffing orders and revises its administrative memory templates. Anchors cannot move safely: the Engine foundations, deep rails, the charter locks and shielded analogue stores. People caught in reconfiguration may be injured, displaced or reprinted from damaged records. The city pays in power, biomass and discarded identity. Citizens track the losses indirectly through new scars, wages, ruined heirlooms and the loss of familiar doorways.

A death before a completed ending triggers a *new reconstruction attempt*: the Engine returns Ninth to its slab and reshuffles legal modules and personnel. For gameplay, a run begins after that reconfiguration. The machine may reprint some dead figures, but a newly printed person is not automatically the original who died. Nix remembers previous **failed attempts** because she keeps a protected mechanical record.

**A successful ending is final.** When the Engine is destroyed or reconfigured into a new constitutional order, that version of the city's story continues; subsequent New Game runs are separately generated counterfactual campaigns, **not** a diegetic reversal of the completed ending. Unlocks between sessions represent the player's expanded tools and narrative knowledge, not proof that a previous liberated settlement was magically destroyed. This simpler terminal-ending model is V3 canon. If a future sequel adopts parallel physical branches, it must replace this rule explicitly and explain the cost.

#### 2.5 The analogue exception — Nix is a witness, not an oracle

The Engine can edit a digital registry and a reprinted person's memories. It cannot retroactively change the marks on a copper wire, a mechanically cut gear, an inked document held outside reconstruction or a damaged wax recording. Analogue artefacts can still be destroyed, forged, stolen or misunderstood. They are not invulnerable to fire and are not perfect memory. Nix is a childhood voice recorded during an early reconstruction and preserved on **a protected mechanical archive spool**, physically outside the movable sectors. Each failed attempt can append a limited entry. Other receivers may play her, but replacing a handset never creates a second physical Nix.

Nix knows what her own archive recorded, not what occurred in unobserved rooms. She can make wrong inferences, and falsified analogue material can deceive her. She is neither omniscient nor a digital ghost. Her motivation is to provide testimony without becoming another authority that decides whose history must be believed.

#### 2.6 Ninth, the nine-count, and first awareness

The architect approved forced harvesting, then opposed the system too late. The first nine proposed enforcement templates were printed from isolated parts of the architect's conscience. Eight were rejected or stored without stable consciousness. The ninth survived: Ninth. The number is **a manufacturing designation**, not proof the player has already died eight times. On a player's first campaign, Nix cannot truthfully assert that Ninth died yesterday. On subsequent failed campaigns she can reference only an actual recorded death.

In Hearth Nine, automatic ventilators sound nine short breaths before they stamp a legally fictitious patient-consent receipt. In the ending, Ninth can interrupt that ninth automatic stamp. The motif has a material explanation; no supernatural numerology is required. Ninth inherits recorded guilt but no mandatory moral personality. A tyrannical Ninth is not an inexplicable fall from canonically saintly behaviour.

### 3. Chronology and institutions

#### Canonical chronology without invented dates

| When | Established event | Known limits |
|---|---|---|
| **91 years before the playable present** | The White Quiet opens a contained atmospheric wound. The city seals borders. | Calendar year and exact duration of founding emergency remain unspecified. |
| **Early post-Quiet period** | Five offices build the Engine and adopt the Emergency Quorum Charter. Voluntary memory donation begins. | Order of first power generation, first rail test and printing research is still open to prequel stories. |
| **Later institutional period** | The regime moves from consent to compulsory correction; reprints expand labour; abandoned emergency rails are sealed; the Unsaid increase. | No exact year is asserted for each transition. |
| **43 years before the present** | Brin's original work debt is paid; corrupted reprint payroll keeps charging his replacements. | Brin's 91-year attendance spans biological and printed service. |
| **Present reconstruction** | Hearth Nine's Cinder Lung shortage exposes ration policy; Ninth seeks Writs. | Three districts and Custodian assignments change with the world seed. |
| **A completed ending** | This campaign's final civic decision becomes a terminal outcome. | A New Game is a new campaign, not reversal of this settlement. |

#### The three-of-five override

The first Founders feared a single commander disabling life-support or imprisoning the surviving population. They embedded **five Writ credentials** in separate physical office registries under an Emergency Quorum Charter: a three-office majority can open the core and review the current Custodian's mandate. A Custodian cannot revoke this substrate-level override without disabling the containment instruction set they themselves need to rule. This is a weakness born of the original protective design, not a security bug the villain forgot to repair.

Each Writ can be transferred by an office holder, seized through an assault, assigned by a citizens' council after substantiated misconduct, or recovered from the durable public registry if the holder dies or disappears. A Writ is never irrecoverably destroyed by an NPC death. No district's optional movement upgrade is a prerequisite for another mandatory district.

**Office holders must be distinct:** the **Barracks Commandant** holds the regional Defence Writ. **Marshal Voss** is a different person who may serve as *central Custodian* in some runs. Voss can issue orders affecting the Barracks, but does not physically serve as its keeper; both may be encountered in the same run without duplicate-character confusion.

#### Civic life — what Ninth is trying to save

| District | Food and work | Ordinary tension and small care | Systemic compromise |
|---|---|---|---|
| Ashmarket | Soup stalls, water-brokers, accountants, repair vendors | A parent argues over a disputed grocery receipt; stallholders quietly feed a starving competitor | Vital water and legal identities are collateral for debt |
| Sootworks | Furnaces, stamping presses, canteens and sleeping shifts | Workers trade homemade mittens for stove coal; Brin maintains a broken child's toy | Contracts survive printed bodies and punish collective action |
| Glass Orchard | Nutrient trays, algae tanks, seed banks, transplant clinics | A caretaker grows a forbidden flower for a neighbour's grave | Biomass grows while identities become a crop |
| Flood Basilica | Kitchens, laundries, voice repair, funeral services | A believer voluntarily keeps a vigil for a dying stranger | The clergy exploits faith's social usefulness to enforce commands |
| Quiet Barracks | Ration kitchens, quarantine posts, defence schools | Recruits hide a civilian's lost cat from the commander | Security protection is financed by erased soldier identities |

This material should appear as level dressing, short dialogue barks and repeat NPC routines as well as lore pages. Vesper must be credible when the player is not in its streets.



## 4. Five-act story, mandatory quests and all endings

### 4. Full campaign — revised act structure and narrative causality

#### Act I — The withheld breath (12–15 minutes)

The shelter's Lung is failing because a deliberate maintenance ration shortchanges Hearth Nine each reconstruction. The order bears a valid office stamp. An out-of-service ventilator counts nine breaths before it stamps automatic consent; a caregiver can no longer remember her sister, although she saves the sister's mask. A functioning reserve Cinder Lung is known to exist, but has been administratively withheld in another allotment. Ninth contests that allocation at one of several guaranteed reachable service sites, by assault, negotiation, covert removal or technical diversion. Each method leaves a recorded obligation to the ward whose competing claim was affected. Every approach has its own witnessed consequence.

Dr Sela Vale can prove that the filter consumes personal correction patterns; she **cannot yet** know exactly who authorised systemic conscription or how to replace the correction channel. Her personal record shows she once signed a clinic consent order she now regrets. She will not be reduced to an exposition terminal.

A damaged emergency notice in the shelter mentions the three-office quorum and an abandoned passenger platform. Oren, an ex-soldier, is practical about delays: as ration pressure increases, named patients die or lose treatment, and later evacuation capacity falls. Neither outcome removes main Writs or mandatory dialogue. A low-stat character keeps a basic firearm, health supplies and the ability to fight through at least one route.

The creature trial is foreshadowed as a local medical and civic controversy: stabilised memory organisms may be conscripted or recruited voluntarily. The first two featured districts guarantee an accessible duel ring. Three eligible Accord participants—Cindermoth, Rootkin and Spool Hound—can be examined and invited or compelled to work. Refusal to recruit produces a public-service loaner Rootkin that must be returned after the hearing. Withdrawing or losing permits unlimited rematches or a loaner switch. The encounter never grants ownership of the opposing creature and cannot invalidate the main story.

#### Act II — The five accounts (approximately 36–48 minutes)

The player visits any three of Ashmarket, Sootworks, Glass Orchard, Flood Basilica and Quiet Barracks, plus optional side routes. The procedural planner chooses three *featured* districts and always opens access to the two others as optional trips. The regional Writs are verified by the same founding hardware; none requires the player to learn a power from another optional district.

- **Ashmarket / Trade:** legal identities are collateral. The Collector maintains a useful clearing service in a fraudulent economy. Negotiation requires evidence of contracts and a threatened coalition of buyers; exposing him does not automatically abolish markets.
- **Sootworks / Labour:** Brin's payroll record proves at least one debt was paid decades ago. The Millwright argues the foundry cannot shut without making the city colder; the player can plan a safe strike, sabotage only the control line, or destroy the overseer and accept the resulting heat loss.
- **Glass Orchard / Growth:** the Gardener demands empirical evidence before believing an identity-fruit may remain viable without forced recollections. A lab test must separate an independent pattern from its feed line. The Garden does not transfer its Writ based on one inspirational speech.
- **Flood Basilica / Faith:** the first hymn was a maintenance instruction. Some congregants already know this and freely value their shared rituals. Exposing the Cantor's **forced use** of the broadcast may unite a lay council while others retain their faith.
- **Quiet Barracks / Defence:** soldiers were early test subjects. Restoring a casualty roll can dissolve illegal orders, but a gate still needs staffed guards. A nonviolent Writ resolution must address physical security.

Each district contributes one evidence class: contracts, labour reprints, nonhuman pattern stability, command-signal misuse or military memory casualties. At least one mandatory route visually passes an abandoned rail platform. Every selected NPC arc progresses through four distinct events rather than appearing as a one-paragraph random outcome. Two short quests per featured district are optional. An NPC may decline Ninth's intervention or pursue their own objective; the world still changes.

**Example multi-solution quest—The Collector:** An auditor can challenge forged contracts using `[Speech 7]` and recovered evidence; a technical build can disable counting locks with `[Tech 5]`; an intimidator can force a surrender with security consequences; everyone has a combat route. A failed check is visibly a setback, not a lost Writ. Skill labels are requirements based on stats and context, not fake percentile probabilities.

#### Act III — The first signature (10–15 minutes)

The Freight Lift of Names accepts any three valid Writs. Inside are two independent proofs: a signed human conscription order and a mechanically preserved recording of the original architect's objection after that order. The original person's conflicting acts explain the guilt template; Ninth's current ethical choices remain open. Nix can corroborate part of the recording, but cannot certify scenes she never observed.

The emergency rail charter now confirms the platform signs seen in Act I and II. The rails are physically real and cross into breathable caverns below the breach. The exact number of functional carriages is damaged and the total capacity is insufficient for Vesper's entire population. Optional quests can add an operational carriage, repair track, win escorts or help the most vulnerable board. The central choice therefore concerns actual trade-offs, not a magical late-game solution.

#### Act IV — The necessary evil and the three Custodians (10–20 minutes)

**Canon Edda — the triage governor.** Edda once refused her own brother an emergency heating exemption. She knows the arithmetic of triage and believes compelled sacrifice is the only practicable defence of fragile patients. In battle her ward-bellows control an arena containing real patients; indiscriminate explosives can hurt them. Her counterevidence is a recorded voluntary-risk petition she concealed. Her distinct dialogue: *"I have counted the beds twice. I cannot fit another child in a number."* An informed player can seek a public mandate, expose the petition, sabotage her legal authority or fight her. She may abdicate without dying.

**Marshal Voss — the gate commander.** Voss remembers a border disaster caused by competing officers who opened and closed a gate against one another's orders. His fear of fractured command is justified. His arena has moving gun nests and a genuinely threatened perimeter: blinding every turret causes a fresh Unsaid incursion unless a separate gate route is secured. A casualty document proves independent short-wave communication could have avoided the earlier disaster. His distinctive line: *"I opened a gate once. Ask the graves whether that was kindness."* He may accept a disciplined civilian escort plan or remain a hard combat opponent.

**Archivist Latch — the accountant of lives.** Latch's forecasts are often accurate, but its totals omit those excluded from registry rights. Its arena tests whether the player notices disaggregated casualty figures rather than merely an average. It calls the omission an accounting choice, not an arithmetic error. Its line: *"I can tell you how many survive. You have not yet asked me who was counted."* It may continue preserving truthful statistics after being stripped of authority, or be disabled violently.

Each Custodian can be killed, contained, exposed to a civic tribunal, or persuaded to abdicate where evidence or character stats permit. The final script records **both resolution method and fate**. The Crown ending works after nonviolent removal; it must never claim an execution unless one occurred.

#### Act V — Four consequential conclusions (5–10 minutes)

**Liberation — immediate freedom with substantial loss.** Emergency rail gates open. Staff prioritise patients and infants where local support exists; some districts fight over limited seats. The Engine is disconnected, the false sun falls, and remaining residents must seek shelter or endure the failing boundary. The epilogue reports what the player actually saved, not a universal rescue. The action is morally defensible without being easy.

**Dominion — comfort purchased by permanent exploitation.** The exits are deliberately closed. Pumps and hospital systems stabilise. Civic life improves visibly at first. The cost is a newly legitimised memory tax. People may sincerely praise the decision because the physical benefits are real and the stolen identities are hard to count. No epilogue may mention an operating evacuation train or transported refugee unless a separate event established it before the order.

**The Crown — personal dictatorship rather than an institutional contract.** Ninth replaces the removed Custodian (without needing to have killed them). Every promise creates an exception: spare a family, substitute convicted criminals; then spare the troops, substitute debtors. With each exemption, the moral vocabulary of 'acceptable fuel' expands. The exit remains sealed unless a later standalone expansion explicitly models a prior partial evacuation. This ending should feel different from Dominion: it concerns *Ninth's personal decisions*, not impersonal charter renewal.

**True Dawn — consent to a difficult, partial transition.** Three independent objectives are required: a Deep Heat Survey (power), an Orchard Root Seed (stable nonhuman patterns) and the Founders' Cipher (slow boundary recalibration). Geothermal energy **alone is insufficient**. The first trial was stopped because it was slow, uncertain, required public consent and threatened the offices' monopoly. If the player has earned sufficient trust, the player offers the original risks to a public assembly, which can agree to a revocable trial, **not unanimous painless salvation**. Some city sectors go dark, hospital schedules must be cut, some people leave on limited routes, and monitoring becomes a new political responsibility. The settlement may survive without perpetual theft, but the ending does not promise full technical success or full rescue.

**Ending-specific epilogue law:** A local event and a global ending are separate conditions. A saved character is not automatically a passenger. An NPC killed in an optional quest cannot speak in the credits. A debt contract erased in Act II stays erased even in a Dominion city, unless the player explicitly rewrote it. Do not derive ethical outcome from an average Karma number; report concrete local facts.


### Authored dramatic treatments (character and setting scene reference)

### 12. V4 definitive dramatic treatment — authored scenes, not generic plot summaries

**Authority:** For player-facing writing, these scenes and the V4 style guide supersede mechanical narration in earlier samples. They do not override the two-channel Engine, resource ceilings, complete item inventory, three-of-five charter, Custodian identities or ending unlock logic. The scene banks are keyed by recorded methods and choices; incompatible options are alternatives, not events that all happen.

#### Act I — the withheld breath

A shelter should be a home before it becomes a crisis. Oren repairs doors because he knows how quickly a failed hinge turns a shortage into panic. Sela's admission of a missing spare Lung is a professional observation, not a speech about the regime. Nix gives only the archive evidence she actually possesses. A first-campaign Ninth does not remember a previous death.

**Opening scene (first awareness, illustrated Cinder Lung negotiation):**

The air in Hearth Nine smells of warm canvas. Somebody has written the afternoon meal on the wall twice, once for those who can still read and once in pictures. The ventilator misses a stroke. It misses another. Oren checks the door seal before looking at the red dial.

"Who moved the spare?" Sela asks.

The duty clerk finds the requisition: one replacement Lung held below city quota. There is a signature. The signature belongs to an office whose name has been scraped away. Ninth gets up from the printing table while the clerk is still rubbing at the paper.

In the receiver, Nix says, "The serial number is old. The body is not. Make of that what you can."

The player's next scene is selected by **actual** source and method: fight, bargain, technical bypass or theft. The words describing a negotiation must not appear after a firefight. Back at Hearth Nine, Sela installs the replacement. The motors draw current; the correction lattice supplies reference patterns. The Lung's trapped voice asks about a son it can no longer picture. Sela turns down the speaker without calling the voice a motor fault.

#### Act II — three Writs, five institutions

Each district can be visited and each available Writ resolved through assault, persuasion, sabotage or registry succession when the office holder is gone. The player hears an everyday conversation before the formal objective. The selected three districts can appear in any order. The mandatory Echoform trial is located at its assigned district; a temporary loaner allows progress without coercive capture.

##### Ashmarket

**Entrance A:** The Ashmarket awnings hang low to keep the false sunlight off the counting desks. A stallholder warms her lunch on a stamping press; she takes it away whenever the queue approaches.

**Entrance B:** Between two auction stalls, a municipal attendant chalks the price of yesterday onto a board. A woman asks if the number includes her marriage. The attendant points to a separate column.

**Local conversation:** "My father had a shop here," the Collector says, checking a receipt against the light. "It sold hinges. People wanted better locks. Now they want the keys to something they no longer own."

**Environmental anchor:** The auction catalogue has a page for childhood sounds. The prices are pencilled in because the market changes them daily.

**Assault outcome:** The counting shutters slam down. Ninth crosses the first two stalls under fire; a pressed-steel auction bell strikes the floor as the Collector falls. In the vault, the Trade Writ has its own hook, labelled FOR PUBLIC EMERGENCY USE. Nobody has used it in decades.

**Persuasion outcome:** Ninth lays the duplicate contracts beside the bids. One buyer sees her son listed as collateral and walks onto the counter to read the rest aloud. The Collector tries to reclaim the documents, then discovers his guards have relatives in the crowd. He signs over the Trade Writ without meeting their eyes.

**Sabotage outcome:** The token press accepts Ninth’s counterfeit sequence. Beneath the stalls, every bonded lock withdraws its bolt. The Collector reaches for the emergency switch; the receipts keep printing until they cover his shoes. Ninth takes the Writ from its glass frame while the buyers argue over which doors should stay open.

**Recover Registry outcome:** With the Collector absent, the clerk turns the emergency register around. "It stays in public custody," she says, "unless someone presents the proper seal." Ninth presents the seal and receives the Trade Writ through a slot normally used for fines.

##### Sootworks

**Entrance A:** A factory siren sounds just as the shift ends. Nobody leaves. The workers sit on the warm pipes, eating boiled grain from dented enamel dishes while the clock waits to advance.

**Entrance B:** The foundry paint has been renewed around the safety notices but not under them. Beneath one sign, workers have carved a list of names, each crossed out once and reprinted beside itself.

**Local conversation:** A shift foreman rubs soot into the crease of a wage docket. "There is a right way to stop the presses," he says. "The trouble is the office has never approved it."

**Environmental anchor:** The machine-room benches are polished by elbows. Somebody has planted parsley in a cracked bearing housing.

**Assault outcome:** Ninth follows a moving conveyor through the heat, using its iron shields for cover. The Millwright comes down between two furnace doors and the fight ends with a cracked motor casing. A worker fetches the Labour Writ from the supervisor’s locker; he makes Ninth sign for the key.

**Persuasion outcome:** The original payroll cylinder is still warm from the machine that hid it. Ninth sets it turning before the assembly. When the foreman reads the settled debts aloud, the workers refuse the next shift. The Millwright does not surrender; the independent shop stewards take custody of the Labour Writ and pass it to Ninth.

**Sabotage outcome:** Ninth reaches the service controls by a narrow catwalk. The pumps reverse for eleven seconds, long enough to drain the power from the Millwright’s frame. The foundry stops. An apprentice watches the temperature fall as Ninth opens the Writ cabinet. "Somebody will have to start it again," she says.

**Recover Registry outcome:** The Millwright is gone, but the payroll office remains staffed. A clerk checks the emergency register three times, then hands Ninth the Labour Writ through a window that smells of hot varnish.

##### Glass Orchard

**Entrance A:** A gardener sweeps glass pollen from the nursery steps. Behind her, a row of translucent saplings bends toward the filtered heat, their fruit hooded in squares of old newspaper.

**Entrance B:** The Orchard smells of wet plaster and cut stems. A horticulturist has tied a warning bell to every gate, then padded each clapper with cloth so the seedlings can sleep.

**Local conversation:** "A fruit that speaks is not necessarily a person," says the Gardener. "A person who stops speaking does not become fruit. We are still trying to agree on the middle."

**Environmental anchor:** Each specimen bed has two labels: the plant’s legal owner and the person who last watered it.

**Assault outcome:** The greenhouse doors lock behind Ninth. Glass leaves strike the floor in sharp bursts; the Gardener advances on a root assembly that has borrowed human joints. When its drive stem is severed, the irrigation keeps running. Ninth removes the Growth Writ without touching the fruit hanging nearby.

**Persuasion outcome:** Ninth places the separated fruit beside the control sample. Both still answer to the same name; neither obeys the Gardener’s command to forget. The attending researchers refuse the disposal order. They record the disagreement and transfer the Growth Writ to independent custody.

**Sabotage outcome:** The mineral valve opens with a reluctant turn. The root motors seize as salts enter the irrigation line. Ninth reaches the Writ behind the wet control glass. Across the beds, staff begin rinsing seedlings; the victory has left them work and a very short supply of clean water.

**Recover Registry outcome:** A sealed propagation log lists the Writ as communal property if its keeper disappears. Ninth takes the document to the archive kiosk. The attendant returns the Growth Writ with a packet of seeds nobody requested.

##### Flood Basilica

**Entrance A:** The water has reached the third pew. A caretaker moves the prayer books upward one shelf at a time, refusing help because nobody else knows which pages have already dried.

**Entrance B:** A boy stands ankle-deep in the nave, ringing a small copper bell to mark the safe path. He charges nothing; his mother will not let him take money in a place of worship.

**Local conversation:** "The first hymn was a set of instructions," an acolyte says, pulling an oilcloth over the damp organ. "That does not settle whether somebody meant the words."

**Environmental anchor:** The votive shelves hold coins, filter washers and tiny handwritten recipes, each offered for someone who could no longer remember the ingredient list.

**Assault outcome:** Ninth forces the vestry doors and crosses the flooded choir floor while the Cantor’s powered pipes scream overhead. When the pumps fail, the sound dies unevenly, one tube after another. The Faith Writ is beneath the altar, dry behind a glass door that opens by hand.

**Persuasion outcome:** The original operating recording plays through the nave. An old worshipper knows the instructions by heart and keeps singing when the machine falls silent. The lay council votes to remove the Cantor’s authority, not the congregation’s faith; it gives Ninth the Faith Writ as witnesses sign the transfer.

**Sabotage outcome:** Ninth changes one gear in the bell governor. The note drops below the frequency the obedience network expects. Copper pipes split along their seams, and the Cantor loses control of the choir. Ninth takes the Faith Writ while the surviving singers decide whether to continue the service.

**Recover Registry outcome:** A substitute verger retrieves the Writ from its floodproof register. "The office outlasts the officer," she says, then pauses to put a towel under the leaking seal.

##### Quiet Barracks

**Entrance A:** Boots strike the parade stones in flawless time. At the infirmary door, a soldier folds a child’s drawing into his glove before the inspection sergeant can see it.

**Entrance B:** The barracks windows are painted in numbered squares to prevent mistakes during night alarms. On a windowsill, someone has left a half-finished game of draughts.

**Local conversation:** "A command is not a memory," says the watch officer. He has to check his sleeve before giving Ninth his rank.

**Environmental anchor:** The memorial wall contains more numbers than names. Fresh flowers have been tucked under the numbers anyway.

**Assault outcome:** Ninth crosses the machine-gun lanes between bursts, reaches the exoskeleton hangar and brings the Commandant’s powered frame down against a bulkhead. Inside a sealed armoury case the Defence Writ rests beside thirty unclaimed identity tags.

**Persuasion outcome:** The names are on the analogue casualty roll, written before the order to erase them. Ninth reads them into the platoon speaker. One soldier stops the firing drill. Others follow, slowly enough that the sergeant could still arrest them. Instead he transfers the Defence Writ and asks where the roll came from.

**Sabotage outcome:** Ninth inserts a forged Council order into the signal cabinet. The garrison stands down for inspection, precisely as the old regulation demands. With the armoury unguarded, Ninth retrieves the Defence Writ. A corporal notices the date on the message and says nothing.

**Recover Registry outcome:** The command office has no living keeper. Ninth presents the emergency clause at the records wicket; a private who has never been taught the clause reads it twice, then opens the Writ drawer.

#### Act III — the signature in the lift

The lift accepts the third Writ without a triumphant fanfare. Its ancient bolts cannot distinguish the character of the bearer, only the legal signatures. An independently recorded spool proves that a human architect approved forced correction and later opposed it. Ninth's collar bears the same manufacturing lineage, but Ninth is the ninth viable enforcement template, not the original person returned. The revelation must complicate choice, never select the player's morality. An emergency-rail diagram has already been foreshadowed at the shelter, Barracks or freight platforms. It reveals a real route with fewer seats than the city needs.

A subordinate engineer says, "There’s enough space in the carriage if nobody brings their things." A second engineer points out that the blankets, medicine and repair kits are also things. They take the argument upstairs before Ninth can settle it.

#### Act IV — three Custodians, three distinct confrontations

Only the Custodian chosen by the WorldPlan appears as the final authority. Their evidence and motivations are separate. A player can defeat the same Custodian violently or remove them nonviolently; the subsequent fate-specific text must respect that action. Neither 'combat' nor 'peace' dictates the player's final ethical choice.

##### Canon Edda

**Entry:** Edda stands with a chart of incubator temperatures. She moves one pencil down the margin as Ninth enters, finishes the count, and only then looks up.

**Argument:** "You can switch the harvest off," Edda says. "I can show you the names of the children who will lose heat first." Ninth lays the suppressed hospice petition beside the chart. Edda reaches for it, then stops short of touching the signatures.

**If dead:** Edda falls beside the thermostat cabinet. Nurses continue adjusting the valves by hand; no one waits for another order from her.

**If abdicated:** Edda signs her resignation on the reverse of the temperature chart. She keeps the list of patients and leaves the office key where the nurses can find it.

**If contained:** The containment locks close around Edda. Through the glass she watches the ward monitors rather than Ninth.

**If removed by civic tribunal:** The tribunal clerk removes Edda’s authority seal. A nurse asks for an immediate ruling on the incubators; the tribunal must give an answer without delegating it back to Edda.

##### Marshal Voss

**Entry:** Voss is reading a map held flat by an empty ammunition tin. He finishes drawing the fallback route before saluting Ninth.

**Argument:** "I opened a gate once," Voss says. "Four platoons did not come back." Ninth shows him the unissued independent-radio plan. Voss studies its dates for a long time. "It would have helped," he admits. "That does not absolve my orders."

**If dead:** Voss dies behind the command table. His officers continue following the written fallback route, because it is the last sound instruction they received.

**If abdicated:** Voss passes the map to the elected gate officers and removes his command pins. He asks to be posted to ordinary guard duty.

**If contained:** Voss is held behind the command barricade. He watches the evacuation lanes without being allowed to direct them.

**If removed by civic tribunal:** The tribunal publishes Voss’s sealed casualty roll. Officers are relieved of their oath to him, but the defensive positions still need holding.

##### Archivist Latch

**Entry:** Latch displays three casualty totals on an enamel board. Each is precise to the individual. A column headed UNREGISTERED contains a dash.

**Argument:** "The calculation is correct," Latch says. Ninth places the excluded ward lists beside the totals. "The denominator was chosen," Ninth answers. The machine has no answer until an operator adds the missing people to its input.

**If dead:** Latch’s processors stop and the casualty board goes blank. The people formerly excluded from its calculations remain in the room, waiting for somebody to count them.

**If abdicated:** Latch deactivates its executive permissions and continues operating as a public calculator. Its forecasts now show the excluded wards in the same typeface as everyone else.

**If contained:** Latch’s predictions remain accessible behind a sealed glass console; its instructions can no longer move a single valve.

**If removed by civic tribunal:** The audit office revokes Latch’s decision privileges. The machine recomputes its old figures with the missing citizens restored and publishes the difference.

#### Act V — four endings and their ethical costs

- **Liberation:** The Engine is disconnected and the open railway carries only as many people as can physically board. The darkness, scarcity and danger remaining after departure are shown; a rescued NPC is not assigned a seat without supporting events.
- **Dominion:** The Engine operates; the evacuation railway is sealed. The ward lights, clinic schedules and water distribution improve as compulsory memory invoices continue. The responsible office is institutional, not personally royal.
- **The Crown:** Ninth assumes individual executive authority, even if the former Custodian abdicated. The railway remains sealed. Exemptions requested by different groups quickly produce the temptation to nominate unwilling substitutes.
- **True Dawn:** Requires all three ingredients and an actual civic mandate. The survey provides limited mechanical heat, the seed provides evolving nonhuman patterns, and the cipher provides a slow transition process. Citizens may reject the early phase, monitored sectors go dark, and limited departures remain possible. It is not a magically perfect ending.

**Final gesture:** Nine regulated pulses end in a blank signature field. Ninth interrupts the automatic stamp, but the act of signing does not automatically destroy the Engine. What follows is entirely determined by the player's chosen ending.



## 5. Characters, factions, motivation and dialogue

### 5. Eight long optional NPC arcs: tightened character motives and integration

The detailed four-stage structures and physical appearances in the preserved catalogue remain canonical, with the following **V3 character directions** overriding any simpler V2 summaries:

| NPC | What they want independently of Ninth | Internal conflict, choice, and final-state requirement |
|---|---|---|
| Iona Pell | To know her adult daughter is alive and safe | Iona learns that being remembered is not the same as being loved; her daughter may refuse reunion. Never equate player 'help' with a forced happy ending. |
| Brin Harker | One day not owned by payroll | A strike may cost heat and fellow workers' lives; his 43-year-old cleared debt is documented and cannot be described as centuries old. |
| Kest-07 | To decide whether testimony or revenge is justice | On first awareness his warrant is a deliberate forgery; on later failed-run indices an actual earlier record may support it. Never fabricate a prior player murder. |
| Sister Ossa | To sing one voluntary note and preserve the community's rituals | Her believers do not automatically abandon faith after learning about technical hymns. A lay council can reform worship. |
| Dr Sela Vale | To keep her patients alive without self-deception | She signed one harmful medical approval before understanding its costs; disclosure should risk her reputation and services. |
| Venn-of-Glass | To create an independent Echoform nursery | A creature may refuse to join Ninth or refuse Venn's care. Ethical recruitment provides tactical support, not just a moral score. |
| Old Perrin | To bring all of his passengers home alive | Repairing the pump can add **some** seats, not an infinite train; exploited passengers cannot also appear rescued. |
| The Pale Ledger | To complete a predictive contract without revealing the rigged incentives | Its predictions cause the crimes they predict. Exposing the fraud should not imply all forecasting is false. |

Every selected arc consists of distinct **meet → investigate → decide → aftermath** steps with required ordering. An unselected arc does not pretend to have occurred. An optional NPC killed before completion can leave analogue evidence, not a living speaker or an unrecoverable mandatory Writ. Quest windows are signposted by actual events. At least one NPC has a decision independent of the player's preference. A cruel reward can be the stronger immediate weapon, but compassionate routes provide repair access, escorted corridors, stronger trust, safer evacuation or a live witness.

#### Character voices — lines to guide actual writing

- **Nix:** observant and economical, sometimes irritated. *"The spool does not say he was innocent. It says the court never heard him."* She refuses to pretend she witnessed what she did not.
- **Sela:** practical, using medical specificity, defensive when confronted. *"Three children needed that ward. I signed it. I did not ask what the filter took, and that was a decision too."*
- **Oren:** suspicious and unromantic, skilled at small physical precautions. *"Sign the order, then. A door only knows whether you closed it."*
- **Edda:** triage language, seldom pronounces absolute moral judgement. *"You can call it theft. Can you tell me which incubator to switch off?"*
- **Voss:** precise verbs, battlefield geography, not grand slogans. *"If the north gate fails, there are fourteen minutes before the wards go dark."*
- **Latch:** exact conditional claims, visibly blind to unrecorded people. *"The number is correct. The category was incomplete."*
- **Iona:** halting and specific rather than eloquent. *"When she was little she hated the blue cup. Do you think she still does?"*
- **Brin:** work humour and frustrated tenderness. *"My watch has no hands worth keeping. It's got the day's shift stamped on the back."*
- **Kest:** trained formality collapsing into resentment. *"Request permission to—no. I can ask a question without permission."*
- **Ossa:** religious cadence without constant aphorisms. *"Some of us knew it was a machine hymn. We sang because our dead were buried here."*
- **Venn:** practical keeper who observes creature signals. *"It moved toward the cage. That doesn't mean it wants you."*
- **Perrin:** counts practical things to avoid a confession. *"Three fares. Two boots on the deck. Don't ask which one went over."*
- **Pale Ledger:** impersonal customer-service language. *"The receipt is not a sentence. Payment is voluntary. Consequences are standard."*

**Faction-to-office mapping:** Ashmarket/Trade/Collector; Sootworks/Labour/Millwright; Glass Orchard/Growth/Gardener; Flood Basilica/Faith/Cantor; Quiet Barracks/Defence/Marshal office. These are offices with distinct material roles and resident views, not five isolated morality arenas. Custodians Edda, Voss and Latch vary between runs; do not flatten their motives or mechanically treat all confrontations as identical.

**Character knowledge constraint:** Nix knows only archived testimony; Sela knows the local clinical effects before she has proof of systemic authorisation; a missing NPC cannot provide statements; Ninth's first campaign does not contain fabricated personal deaths. Witnessed signals, physical records and plausible channels must govern awareness.



## 6. Main progression gates, NPC arcs and local quests

### 6. Quest catalogue: twenty short local storylets

The game retains exactly four authored short hooks per district, selecting two in each featured district for a normal run. These are separate from the eight optional multi-stage NPC arcs. The Ashmarket hook **A Daughter for Rent** has been retired to avoid repeating Iona's family plot; V3 replaces it with **The Borrowed Verdict** (an innocent porter assigned another citizen's criminal record, with truthful vindication or resale as outcomes).

| District | Quest | Human problem | Compassionate / exploitative outcomes |
|---|---|---|---|
| Ashmarket | The Borrowed Verdict | A porter is carrying a stranger's criminal sentence | Restore lawful identity / sell forged conviction |
| Ashmarket | The Price of Rain | A broker monopolises clean water | Open the tank / take a cut |
| Ashmarket | The Fifth Customer | Five people claim one erased identity | Reconcile testimony / auction separate claims |
| Ashmarket | The Honest Thief | A sister steals an oppressive debt contract | Void it / return it to the owner |
| Sootworks | A Strike of Hands | Workers lose their hands to production quotas | Rescue strikers / expose their hideout |
| Sootworks | The Last Shift | Worker trapped by recurring reprint payroll | Release labourer / sell remaining service |
| Sootworks | Warm Iron | Child hiding in a furnace for warmth | Secure a safe room / report to security |
| Sootworks | Boiler Saint | A trapped engineer speaks through machinery | Release minds / manufacture a weapon |
| Glass Orchard | The Tree That Calls Mother | A tree stores stolen maternal voices | Return recordings / turn voices into ammunition |
| Glass Orchard | Green in the Dark | Fragile independent growth experiment | Preserve it / burn it for immediate power |
| Glass Orchard | The Missing Harvest | Lab reproduces a family as crop specimens | Defend autonomy / sell copies |
| Glass Orchard | A Beautiful Lie | Painter maps possible breathable sky pockets | Verify/share map / destroy it |
| Flood Basilica | The Drowned Choir | Choir members are medically sustained against their will | Free and house them / intensify production |
| Flood Basilica | A Confession for Sale | Clergy erase criminal testimony | Restore victims' records / blackmail perpetrators |
| Flood Basilica | Saint Without a Face | A prisoner supplies a living sacred beacon | Release prisoner / keep beacon active |
| Flood Basilica | The Last Funeral | Family requests a burial | Provide a grave / sell remains |
| Quiet Barracks | The Unfired Gun | Soldier refuses execution order | Secure pardon / enforce sentence |
| Quiet Barracks | Deserter at the Gate | Deserter carries a real safe-route map | Protect witness / return for bounty |
| Quiet Barracks | The Nameless Platoon | A platoon cannot remember its own names | Restore identities / use as decoys |
| Quiet Barracks | Signal Zero | Old war-order signal controls local veterans | Switch it off / redirect against enemies |

**Procedural rules:** A short quest with a duplicate living person, incompatible time window, dead witness or mutually exclusive faction commitment cannot silently spawn as if all prerequisites were met. Its storylet should downgrade into evidence recovery, be rescheduled or be excluded. Local outcomes always persist within the finished run and are reported separately from the global ending.


### Eight major NPC arcs — four distinct stage treatments

### 13. Eight optional NPC arcs — four dramatic scenes per character

All eight retained arcs remain available to procedural selection. A usual run offers three, not all eight. Each arc is authored as Encounter, Investigation, Decision and Consequence. A scene must be gated by actual interaction; the following branches are alternatives and must never be printed simultaneously. Character quests should remain private when Ninth never met their owner.

#### Iona Pell

**Encounter:** In the Hearth Nine meal queue, Iona Pell sets a small porcelain shoe on the counter. She orders two portions and catches herself. "One, please. The other is an old habit." She asks Ninth to find the woman whose name has been scratched off a rental deed.

**Investigation:** At the freight registry, Iona tries to read the signatures before Ninth can unfold the deed. Five people leased the same childhood; her adult daughter still owns the right to refuse contact. Iona puts the shoe back in its wrapper. "I thought she would have to remember me," she says.

**Decision — help:** Ninth delivers the deed and leaves the decision with the daughter. Iona waits outside, not looking towards the door. A reply arrives folded into a square: no reunion today, but the daughter wants her old photographs. Iona gives Ninth the Namesake Locket with a shaking apology for having made an offer on another person’s behalf.

**Decision — compromise:** Ninth arranges a reunion using reconstructed recollections. Mother and daughter recognise the same blue cup; then they disagree about who broke it. Iona pushes the bell into Ninth’s hand. "Take this. I keep ringing it when she looks away."

**Decision — exploit:** The broker weighs the rental deed against a handful of notes. Iona reaches for the counter too late. Ninth receives the broker’s credential while an attendant quietly removes the second meal from her tray.

**Decision — abandon:** Ninth leaves the folded deed on the public desk. Iona sits with the unopened wrapper, refusing to ask another stranger to speak for her.

**Decision — kill:** The disagreement ends in violence. Iona dies. The deed is entered as an unclaimed document; her daughter’s decision remains her own.

**Consequence — helped:** Iona places the photographs in a stamped envelope. She does not address it until the daughter sends permission.

**Consequence — compromised:** Iona stores the bell in a padded box. It still makes the daughter flinch when the box shifts.

**Consequence — exploited:** The meal clerk holds a second portion until closing. Iona does not return for it.

#### Brin Harker

**Encounter:** Brin Harker sits in Hearth Nine repairing a spoon with machine wire. He shows Ninth a shift card so old the stamped year is almost a hole. "It’s not the work," he says. "It’s that they charge me rent for the hours I’m asleep."

**Investigation:** A payroll cylinder in the freight office lists the debt as settled forty-three years ago. Brin traces the cancelled sum with his finger. "Well, there goes my excuse for being late home." He asks Ninth to keep a copy where the foremen cannot burn it.

**Decision — help:** Ninth brings the record to the workers and helps secure an orderly stoppage. The furnaces cool slowly enough to keep the neighbouring ward supplied. Brin constructs a torque wrench from the first free shift of his life and presses it into Ninth’s hands.

**Decision — compromise:** The managers agree to release some contracts but keep the emergency crew on duty. Brin accepts the bargain only after the workers vote. He hands Ninth a union repair kit. "Useful," he says. "Not an apology."

**Decision — exploit:** Ninth gives security the location of the organised workers. Brin is escorted back to his machine. His eyes find Ninth across the floor before the service doors close. The office issues Ninth the Chain of Wages.

**Decision — abandon:** Brin leaves a copy of the debt record under Ninth’s cup. He has decided to confront the payroll office without an escort.

**Decision — kill:** Brin dies beside the workbench. His unfinished spoon is entered in the property ledger and his debt remains disputed.

**Consequence — helped:** Brin eats a meal sitting down while the next shift changes without him.

**Consequence — compromised:** He tightens a failing valve, then asks which of the freed workers will take his old bunk.

**Consequence — exploited:** The time clock stamps another card. The rubber pad has a fresh fingerprint.

#### Kest-07

**Encounter:** A soldier with a blank mask stops Ninth in the shelter corridor. He presents a warrant signed in Ninth’s handwriting. "Orders permit questioning before arrest," he says. "I intend to make use of that."

**Investigation:** Ninth finds consecutive reprint records, each showing a soldier ordered to execute the next version of his own unit. Kest reads until he reaches his number. "If a signature can survive the man," he asks, "why should a sentence follow him?"

**Decision — help:** Ninth shares the records with Kest and provides a protected route to testimony. He removes the Recall Plate from his uniform and gives it away. "I don’t need proof I served," he says. "I need proof I can stop."

**Decision — compromise:** Ninth orders the erasure of Kest’s most incriminating memories. The soldier stands quietly through the process and presents the Penance Fang afterward. He has lost the reasons he once challenged the order.

**Decision — exploit:** Ninth uses the reprint record to force Kest into service. The warrant is filed away; the soldier follows a command he would once have questioned.

**Decision — abandon:** Kest folds the warrant into quarters. He says he will investigate the signature himself.

**Decision — kill:** The warrant becomes irrelevant in the corridor fight. Kest dies; the analogue service record survives and cannot testify in his voice.

**Consequence — helped:** Kest takes down the faded unit numbers and asks the other soldiers which names they want displayed.

**Consequence — compromised:** He remains at attention after the inspection has ended, waiting for a command that does not come.

**Consequence — exploited:** His orders are tidy. The blank space where his own judgment belonged is not.

#### Sister Ossa

**Encounter:** Sister Ossa rests a copper voice-box on the shelter table while the noon bell sounds through the wall. "There used to be a sixth note," she says. "The young ones sing it wrong. I used to correct them."

**Investigation:** The hymn’s omitted bar is recorded on a maintenance reel. Ossa recognises the governor timing before Ninth finishes playing it. "We sang it when the west ward flooded," she says. "Then we kept singing after the water went away."

**Decision — help:** Ninth gives the congregation the maintenance evidence; Ossa leads a vote rather than announcing an end to worship. The mechanical choir is disconnected with patients awake and consenting. Ossa hands over the Choirbreaker, an instrument made to silence an obedient frequency.

**Decision — compromise:** The choir agrees to continue as a temporary defence while the congregation reviews the injuries. Ossa passes Ninth the Drowned Canticle and refuses to call the arrangement permanent.

**Decision — exploit:** Ninth increases the choir’s amplification to protect the district. The bells drown out the patients’ attempts to object. Ossa turns her face towards the wall while the control key changes hands.

**Decision — abandon:** Ossa keeps the reel and begins questioning the other singers one at a time. She will not let Ninth decide whether their belief is worth keeping.

**Decision — kill:** Ossa dies before the congregation can hear the full recording. The surviving reel contains no instructions from her.

**Consequence — helped:** Ossa sings one unamplified note, then waits for the others to choose whether to answer.

**Consequence — compromised:** She hangs the temporary-use licence beside the altar so nobody can pretend it was eternal.

**Consequence — exploited:** The choir’s bell is loud enough to be heard from the freight lift. No human answer follows it.

#### Dr Sela Vale

**Encounter:** Sela Vale changes the dressing on a patient’s arm without looking up. One of her hands moves a fraction before she decides to use it. "You saw that," she says. "Good. Then you can help me find the switch."

**Investigation:** An old medical consent register bears Sela’s signature. She approved a correction procedure before anyone told her what it took from patients. She closes the register and opens it again. "I knew enough to ask," she says. "I didn’t."

**Decision — help:** Ninth assists while Sela severs the Engine filaments in her arms. The ward loses automatic throughput; she arranges two replacement shifts before trying the first unaided stitch. Sela presents Surgeon’s Mercy as a tool she no longer trusts herself to carry.

**Decision — compromise:** Sela retains automated treatment under a disclosure order. Her clinic treats more patients, but each one must read a new warning about memory loss. Ninth takes the White Ledger and a copy of the risks.

**Decision — exploit:** Ninth keeps the automation and removes the warnings. Sela protests in the operating room; the clinic continues, efficiently and in silence.

**Decision — abandon:** Sela files her confession under her own name. She asks the next patient a question she has avoided for years.

**Decision — kill:** Sela dies. The clinic remains staffed by assistants who cannot reproduce her work from a list of drugs and settings.

**Consequence — helped:** Sela holds a needle steadily for a full minute. Nobody applauds; a patient asks if the stitches will itch.

**Consequence — compromised:** She reads the warning aloud when a patient cannot see it. Several refuse treatment and she does not sign for them.

**Consequence — exploited:** The clinic queue moves faster. The patient registry contains a growing column marked UNABLE TO RECALL.

#### Venn-of-Glass

**Encounter:** Venn-of-Glass carries a small cage with its latch inside. A Cindermoth on the handle keeps testing the air beyond his shoulder. "She can leave," Venn says. "That’s the part the wardens keep trying to improve."

**Investigation:** At the nursery record desk, Ninth finds the orders authorising remote staples. Venn waits beside an unlocked cage while its occupant stays inside. "A door opens both ways," he says. "I wish that solved everything."

**Decision — help:** Ninth disables the forced-capture network and helps move the nursery to independent custody. The Cindermoth chooses to remain on Venn’s shoulder, not Ninth’s. Venn gives Ninth the Consent Bell for signalling rather than commanding.

**Decision — compromise:** Venn accepts a temporary protected enclosure while the wardens relinquish their remote controls. He passes Ninth a service tool but keeps the cages under observation.

**Decision — exploit:** Ninth takes a Cage Clamp from the wardens and forces an Echoform to demonstrate obedience. Venn closes his empty cage and leaves without an argument.

**Decision — abandon:** Venn carries the cages to the next district. One of them is open when he leaves.

**Decision — kill:** Venn dies. The unlocked cages remain; their occupants do not automatically become Ninth’s companions.

**Consequence — helped:** Venn repairs a nesting shelf while the creatures come and go without asking him.

**Consequence — compromised:** He replaces the temporary lock every morning and checks whether the creatures still approach it.

**Consequence — exploited:** The nursery has new bars. Their hinges face outward.

#### Old Perrin

**Encounter:** Old Perrin is counting fares in an empty service boat. "Three tickets," he says. "Two passengers. That’s the answer you’re after. Don’t make me say the question."

**Investigation:** The ferry’s correction pump uses one passenger’s recollections to stabilise each crossing. The fares have been recorded as cargo losses. Perrin asks Ninth to count the bolts on the repair plate; he cannot look at the names.

**Decision — help:** Ninth repairs the ferry pump and changes the crossing schedule to match the new capacity. Perrin tests an empty trip, then another with volunteers. He gives Ninth a Fare Token and offers a finite set of additional seats to the rail authority.

**Decision — compromise:** Ninth pays in a personal, run-specific recollection to keep the boat moving. Perrin places the Salt Pilgrim Greaves on the deck. Neither can remember what Ninth said during the transaction.

**Decision — exploit:** Ninth sells passengers to restore the ferry schedule. The empty lifejackets are counted as recovered property. Perrin turns over the Ferryman’s Hook without opening his farebook.

**Decision — abandon:** Perrin writes the discrepancy on a card and tacks it to the ferry wheel. The next voyage is his decision.

**Decision — kill:** Perrin dies by the empty boat. Its ledger survives, but no additional evacuation capacity is inferred from his absence.

**Consequence — helped:** Perrin counts every ticket twice and starts stamping the ones belonging to living passengers.

**Consequence — compromised:** He pauses before addressing Ninth; something between them is gone and neither can name it.

**Consequence — exploited:** The ferry returns light in the water. Perrin has stopped checking the fare totals.

#### The Pale Ledger

**Encounter:** The Pale Ledger approaches Ninth at the public requisitions desk with an envelope addressed in Ninth’s handwriting. "Collection is not due," it says. "I am here to prevent an inconvenience."

**Investigation:** An analogue account book shows the Ledger’s forecasts followed each threat it had sent out. The threat was the cause, not a glimpse of the future. Ninth circles the first duplicate entry in red pencil.

**Decision — help:** Ninth posts the contradictory forecasts for all debtors to see. The Ledger offers a polite correction and hands over an Unwritten Page to prevent further copying. The document is copied anyway.

**Decision — compromise:** Ninth transfers the fraudulent balance back to the Ledger. It countersigns its own debt without protest and releases the Carbon Key to settle the account.

**Decision — exploit:** Ninth signs over a stranger’s future claim and receives Debt Collector’s Smile. The Ledger thanks Ninth for prompt payment and begins preparing the stranger’s invoice.

**Decision — abandon:** The envelope remains uncollected on the requisition counter. The Ledger will continue issuing reminders.

**Decision — kill:** The Ledger is destroyed, but the accounts it issued remain in circulation. The shopkeepers cannot be instructed by a dead clerk.

**Consequence — helped:** Debt holders use the published correction to challenge the next notice before they pay.

**Consequence — compromised:** A clerk files the Ledger’s self-assigned balance. There is no box on the form for satisfaction.

**Consequence — exploited:** A second invoice arrives, addressed to someone Ninth never met.


### Twenty local storylets — contextual scenes and consequences

### 14. Twenty local storylets — complete player-facing micro-scenes

Two of each district’s four hooks are selected when the district features in a run. Every micro-scene below supplies a specific physical premise and distinct help/exploit consequences. An ignored quest has no fabricated outcome; it remains an unresolved local situation. These do not supersede the broader mechanical consequences in the V3 catalogue.

**The Borrowed Verdict.** A porter keeps his lunch wrapped in a court summons; the paper is the only record of his employment. **If helped:** The court accepts the original fingerprints. The porter asks to keep the wrapper anyway. **If exploited:** A broker pays for the false conviction. The porter is still on the delivery rota when officers come for him. **If left:** No intervention is asserted; the local people retain agency.

**The Price of Rain.** A woman pours two drops of water onto the scales to prove the tank is not empty. **If helped:** The tap is unlocked. A plumber volunteers to ration it until the mains can be repaired. **If exploited:** A new fee appears above the tank. Ninth’s share is already deducted. **If left:** No intervention is asserted; the local people retain agency.

**The Fifth Customer.** Five customers arrive for a single queue number and can each describe the same front door. **If helped:** A hearing records five separate claims without declaring any one of them a counterfeit. **If exploited:** The claims are split into saleable lots; the people are told they may bid on themselves. **If left:** No intervention is asserted; the local people retain agency.

**The Honest Thief.** The stolen debt slip is pinned beneath a child’s homework. **If helped:** The debt is cancelled. The sister keeps the slip as evidence, not a souvenir. **If exploited:** The owner retrieves the slip and adds a finder’s charge to the family account. **If left:** No intervention is asserted; the local people retain agency.

**A Strike of Hands.** A lathe runs without an operator. Beside it sits a pair of work gloves whose owner cannot hold a spoon. **If helped:** The missing workers are carried out and a union steward counts who returned. **If exploited:** Security seals the workers’ hiding place; the supervisor calls it a safety inspection. **If left:** No intervention is asserted; the local people retain agency.

**The Last Shift.** A punched time card has worn translucent where a thumb keeps pressing it. **If helped:** The payroll error is removed. The freed worker does not yet know what to do tomorrow. **If exploited:** The remaining labour years are sold. The factory issues a fresh card with the same number. **If left:** No intervention is asserted; the local people retain agency.

**Warm Iron.** A small jacket hangs behind the furnace door where heat escapes. **If helped:** A neighbour offers a room; the child insists the jacket come too. **If exploited:** Factory security removes the child as an unauthorised occupant of an industrial zone. **If left:** No intervention is asserted; the local people retain agency.

**Boiler Saint.** A furnace speaks only when the pressure falls, and always asks about its daughter’s teeth. **If helped:** The engineer’s trapped pattern is released; the furnace loses a little efficiency. **If exploited:** The furnace is tuned into an armament. Its familiar voice becomes a targeting tone. **If left:** No intervention is asserted; the local people retain agency.

**The Tree That Calls Mother.** Every passer-by stops at a tree that knows how their mother once called them home. **If helped:** The stored voices are returned to their recorded owners where consent can be established. **If exploited:** The voices become ammunition. The tree no longer calls anyone home. **If left:** No intervention is asserted; the local people retain agency.

**Green in the Dark.** A gardener keeps a living seed in a tin beside the coal scuttle. **If helped:** The seed is carried to a protected plot, where it may survive without the Engine. **If exploited:** Its short burst of heat feeds a weapon. The tin is empty afterwards. **If left:** No intervention is asserted; the local people retain agency.

**The Missing Harvest.** One specimen has learned to imitate a boy’s handwriting, but not his spelling. **If helped:** The family and the copies are given time apart to decide how to meet. **If exploited:** The laboratory collects the copies under a new ownership number. **If left:** No intervention is asserted; the local people retain agency.

**A Beautiful Lie.** A blind painter runs her thumb over a map she has drawn on thick card. **If helped:** The map is checked against an independent air reading and made public with its uncertainties intact. **If exploited:** The map is burned. A guard says that fewer people will die chasing it. **If left:** No intervention is asserted; the local people retain agency.

**The Drowned Choir.** A singer taps a rhythm against the inside of a medical jar. **If helped:** The singers are given masks and somewhere quiet to disagree about what comes next. **If exploited:** The amplification rises. The room becomes safer, but the tapping stops. **If left:** No intervention is asserted; the local people retain agency.

**A Confession for Sale.** Victims queue outside a booth marked FORGIVENESS WHILE YOU WAIT. **If helped:** The suppressed testimonies are copied for their owners before the machine is stopped. **If exploited:** The records are taken for blackmail. The booth stays open under a new sign. **If left:** No intervention is asserted; the local people retain agency.

**Saint Without a Face.** The statue exhales a little mist when the room is cold. **If helped:** The living prisoner is removed carefully. The shrine has to find another light. **If exploited:** The statue remains lit; the prisoner’s name is painted over. **If left:** No intervention is asserted; the local people retain agency.

**The Last Funeral.** The mother has brought a sheet she washed three times because she had no coffin. **If helped:** The burial takes place above the waterline. A few neighbours remain afterwards to fill the grave. **If exploited:** The recycler collects the body. The sheet stays in the mother’s hands. **If left:** No intervention is asserted; the local people retain agency.

**The Unfired Gun.** A squad leader keeps checking whether the prisoner’s blindfold is tied properly. **If helped:** The sentence is challenged and the prisoner is released into supervised care. **If exploited:** The shot is fired. The ammunition office records one cartridge used in training. **If left:** No intervention is asserted; the local people retain agency.

**Deserter at the Gate.** A deserter has marked a route in grease on the lining of a boot. **If helped:** The route is copied and the deserter moved out of the garrison’s register. **If exploited:** The deserter is returned. Ninth receives equipment from the same stores he once guarded. **If left:** No intervention is asserted; the local people retain agency.

**The Nameless Platoon.** Twenty soldiers stand to attention when a clerk reads their unit number. **If helped:** The personal records are restored. Some soldiers leave and others choose to keep serving. **If exploited:** The platoon is sent ahead as a diversion. They never learn whose objective they served. **If left:** No intervention is asserted; the local people retain agency.

**Signal Zero.** A radio announces a battlefield position that has been a housing block for forty years. **If helped:** The transmitter is silenced and its listeners begin speaking at their own pace. **If exploited:** The signal is redirected. The next conflict begins before the new orders finish playing. **If left:** No intervention is asserted; the local people retain agency.

**Quest lifecycle contract:** each major NPC arc has `unmet → encountered → investigated → decision → consequence`, with parallel `dead`, `abandoned` and `unavailable` outcomes. Quest-available event checks are evaluated before a scene; emitted event records are idempotent. The main-route Writ never disappears because an office-holder dies: the public registry fallback is stable. Side content cannot claim that an encounter happened where Ninth never visited. Actual quest-stage and fallback rules govern displayed prose.



## 7. Player controls, RPG attributes, experience, life and death

### 1. Six-attribute character creation

At new campaign, Ninth selects **Breaker, Witness, Mechanist, or Stalker**, or *Custom*. All six attributes **Force, Reflex, Insight, Speech, Tech, Resolve** are integers 1–10 (V5 limit). All characters begin with **18 allocation points total** (minimum 1 each, maximum 6 in creation). A preset is a legal allocation, not a separate class; Custom can redistribute freely with total exactly 18. Attributes are locked once the attempt starts except for earned level improvements or a single optional respecialisation. Sixth-attribute reconciliation is explicit: the four-stat V5 Python presets retain their names and narrative flavour, but their 7/8 values are rescaled into six-stat V6 starting presets; the old four-stat numbers are not silently treated as new-game canon.

| Preset | Force | Reflex | Insight | Speech | Tech | Resolve | Starting field specialisation |
|---|---:|---:|---:|---:|---:|---:|---|
| Breaker | 6 | 3 | 2 | 1 | 2 | 4 | Reinforced grip: first stagger per encounter +12% |
| Witness | 2 | 2 | 5 | 5 | 1 | 3 | Ledger eye: first evidence clue in an entered district marked on map |
| Mechanist | 2 | 2 | 3 | 2 | 6 | 3 | Field bypass: one minor machine lock opened without a Fuse per district |
| Stalker | 4 | 5 | 3 | 2 | 3 | 1 | Quiet step: first alerted opponent per area reacts 0.6 s later |

**Derived stats; rounded to nearest whole number at display:** max health `100 + 6*(Resolve-2) + 3*(Force-3)` (floor 80); max personal Breath `100 + 4*(Resolve-2)` (floor 88); sprint speed `5.6 + 0.09*(Reflex-3)` metres/s, capped at 6.2; weapon swap `0.40 - 0.025*(Reflex-3)` seconds, floor 0.24; recoil multiplier `clamp(1 - 0.035*(Force-3) - 0.02*(Reflex-3), .72, 1.18)`; evidence inspection speed `1 + 0.08*(Insight-3)`; repair work duration multiplier `clamp(1 - .06*(Tech-3), .64, 1.12)`; mnemonic strain protection `min(25%, 3%*(Resolve-1))`. Health is physical combat health, while **Breath** is a personal exertion/respirator reserve, *not* the city's clean-air throughput and not the Engine's correction integrity.

| Attribute | Player-facing effect | Dialogue / investigation | Combat / navigation |
|---|---|---|---|
| Force | Control weight and bodily leverage | Forced hatch, intimidation without automatic success | Recoil, health, timed carry, melee stagger |
| Reflex | Move and aim under pressure | Catch a forged handoff, rescue timed witness | Sprint/swap, dash recovery, evasion windows |
| Insight | Interpret records and intentions | Discern false testimony and hidden evidence | Highlight telegraphed threat for 1 s after scan |
| Speech | Persuade and organise support | Negotiate, reconcile witnesses, public mediation | De-escalate guards, call an earned ally once |
| Tech | Repair and bypass known machinery | Field schematics, nonlethal sabotage | Configure mod, repair cover, disable live hazards |
| Resolve | Maintain agency under mnemonic interference | Resist coercive broadcasts, make costly admissions | Health/Breath, strain and dissonance protection |

**Deterministic check rule:** `available = (attribute + evidence_bonus + equipment_context_bonus >= threshold) AND required_fact_flags present`. Evidence typically supplies +1 or +2 if a *documented* linkage exists; contextual relic contributes at most +1; no random dialogue roll; never make +1 stack multiplicatively. An attempt can be made only when the choice is visibly enabled; a failed action (such as a public claim lacking evidence) has an authored consequence and remains nonblocking. UI exposes `[Speech 6; original payroll required]`, not a hidden percentage. NPCs react to witnessed actions and communication channels, not global karma.

**Respecialisation:** One `Reassignment Examination` at an earned service station per attempt. Costs 3 salvage units and one 90-second in-world stoppage; resets all unspent/free level-based stat points and chosen standard perks but not the creation preset's six-point base minimum, unique quest-reward commitments, reputation, or evidence. May occur at most once before entering the Engine core. This is a **new optional gameplay rule**, not a new historical event.

### 2. Experience and progression — selected model

Two models evaluated: **(A) kill-driven XP** encourages farming minor enemies and makes nonviolent paths weaker in a 73–108 minute game; **(B) unique-event XP** grants once for solving an authored problem by any legitimate method. **Select B**. Per-action ledger key `(campaign_id, challenge_id)` prevents duplicate payouts. XP belongs only to this attempt; awarded for outcome, not weapon damage or moral score.

| Unique resolution | XP first time only | Maximum / guard |
|---|---:|---|
| Contested Cinder Lung properly installed | 140 | Once per attempt, any method |
| Each of three unique Writ transfers | 165 | Unique office only, up to 495 |
| Civic Echoform hearing passed | 110 | Once; rematches give 0 |
| Engine archive records interpreted and lift accessed | 140 | Once |
| First legitimate resolution of a specific combat/negotiation/stealth encounter | 15 | First 8 authored encounter IDs, max 120 |
| First evidence cluster per featured district | 20 | Max three clusters, 60 |
| Resolved short side quest | 45 | One award per unique quest ID, up to 5 eligible in the XP budget, max 225 |
| Major NPC arc decision, after investigation | 55 | At most three offered arcs, max 165; not re-awarded for aftermath |

**Guaranteed core-objective XP:** `140 + (3×165) + 110 + 140 = 885`, enough for level 6 (800 XP); three discovered evidence clusters increase it to 945. A player who skips optional quests therefore still reaches level 6. Combat-heavy, technical or negotiated resolutions pay the same *challenge* XP. Optional quests/encounters can reach level 7; no level or perk is required to access the final main route. XP cannot exceed the 1,050 threshold for advancement purposes; excess may be shown as lifetime run score but grants no further stats.

| Level | Cumulative XP | Reward |
|---|---:|---|
| 1 | 0 | Starting preset specialty and initial equipment |
| 2 | 100 | Choose one standard perk |
| 3 | 230 | +1 permanent-for-this-attempt attribute point |
| 4 | 390 | Choose one standard perk |
| 5 | 580 | +1 attribute point |
| 6 | 800 | Choose one standard perk |
| 7 (run cap) | 1050 | +1 attribute point **or** a fourth perk |

**Level improvements:** one point to a stat, ceiling 10; no perk may exceed prerequisite; incompatible choices prompt a refund before confirming. On death or successful ending, all earned levels/perks reset for the next separate campaign. To prevent unearned high stats from seed advantages, the level-7 bonus is optional and not included in any main-quest prerequisite. The initial four specialisations are not randomly allocated.

#### Complete initial standard perk catalogue (18; all provisional)

Each perk can be selected only once. `stat >= N` is checked **at selection**; an earned attribute reduction through respec disables an invalid perk until replaced. Combat reductions never stack below a floor stated here.

| ID / prerequisite | Quantitative effect | Purpose and trade-off |
|---|---|---|
| F1 Counterweight / Force 3 | -12% sustained recoil | Rifle control, no increased damage |
| F2 Door Claim / Force 5 | Breach one fortified optional door per district; +15% melee stagger | Loud action raises alert |
| F3 Anchor Hands / Force 6 | First heavy hit each encounter prevents 30 damage and roots Ninth 0.6 s | Heavy defence at movement cost |
| R1 Short Shift / Reflex 3 | -0.08 s weapon swap | Faster rotations |
| R2 Edge Runner / Reflex 5 | Dash Breath cost 14→11; dash cooldown 2.0→1.8 s | Mobility; no invulnerability |
| R3 Narrow Escape / Reflex 6 | Once per district, lethal hit leaves 1 HP if moving; +2 mnemonic strain | Escape, not automatic healing |
| I1 Margin Note / Insight 3 | First scanned evidence cluster per district adds a map annotation | Investigation |
| I2 Read Pattern / Insight 5 | After 1.0 s observation, nearest threat telegraph is visible 1.5 s | Combat foresight |
| I3 Contradiction / Insight 6 | First attempted forged record per featured district is flagged before dialogue choice | Evidence without granting missing facts |
| S1 Common Ground / Speech 3 | Once per district +1 to eligible *already supported* persuasion check | Cannot create a missing document |
| S2 Civil Witness / Speech 5 | Negotiated ceasefire lasts 8 s (was 5) in recognised area | Help civilians, not mind control |
| S3 Mandate Speaker / Speech 6 | +1 assembly trust for one disclosed public act, capped +1 | Assembly still needs mandate facts |
| T1 Circuit Tutor / Tech 3 | Costs 1 fewer salvage for first modification installed per district (min 1) | Non-stack discount |
| T2 Careful Isolation / Tech 5 | Machine bypass causes 25% less collateral resource loss | Does not restore destroyed evidence |
| T3 Dual Fixture / Tech 6 | Swap one active major mod at a bench for 1 fewer salvage | Still one active mod per weapon |
| V1 Count Breath / Resolve 3 | +10 max personal Breath | Distinct from clean-air city resource |
| V2 Hold the Line / Resolve 5 | -15% Dissonance and Mnemonic status duration | Control resilience |
| V3 Unbroken Testimony / Resolve 6 | Once per district, a coercion status is cleared; +1 strain afterward | Agency at a physical cost |

**Perk rules:** buffs multiply once; no stacking of identical perk IDs; cooldowns tracked by deterministic `district_id` or `encounter_id`. Standard perks are never locked behind a blueprint. No perk automatically supplies a Writ or a True Dawn ingredient.

#### Four build routes (all mandatory-solvable)

| Situation | Breaker | Witness | Mechanist | Stalker |
|---|---|---|---|---|
| FPS arena | Scatter stagger, move into close cover | Read a telegraph and use support/firearms | Disable a pump hazard and use Volt Rifle | Delay alert, flank for weak-point fire |
| Lung dispute | Force service hatch; contest rival allotment visibly | Expose flawed requisition and bargain | Safely reroute reserve filter | Steal reserve while logging downstream loss |
| Writ | Assault or push through gate | Evidence-backed council transfer | Sabotage **only** regulator, save district power | Evade keeper, reach public registry fallback |
| Evidence | Open locked cabinet physically | Cross-reference witness accounts | Recover damaged punched record | Access concealed service passage |
| Echoform hearing | Attune with loaner; Brace when strained | Observe then Attune; voluntary accord | Repair field probe for favourable chamber state | Exploit timing and Withdraw/retry safely |
| Equipment | Heavy stability | Relics exposing false records | Lower mod cost/cover repair | Swaps, suppressors and escape |

No archetype is hard-locked to a fighting, persuasion, Technical or creature choice. The guaranteed assault/public registry route uses base equipment and public services. Difficult noncombat solutions may depend on stats+evidence, but no single high check is obligatory.

### 6. Death, meta-progression and run boundaries

#### Player-visible failure loop

At 0 HP, game triggers a 1.5 s dead-state cue; resolves any currently executing authoritative event once; increments actual `death_count`; captures witnessed death site/equipment/stated cause; seals attempt log; clears active HUD and shows the Ninth reprint slab. A newly generated `WorldPlan` uses a fresh seed (or an explicitly chosen seeded retry mode) and a new run ID. **Only an actually committed failed-attempt death event authorises Nix to refer to a previous death**. A first campaign, manual New Game, abandoned campaign or completed successful ending does not establish that fictional death. Abandonment is recorded as `abandoned` and may be used in profile statistics but does not yield prior-death dialogue.

**On death reset:** physical weapons and mods, ammo, HP/Breath, armour/relics/field tool loadout, consumables, voucher/salvage balances, temporary levels and perks, offered NPC relationships/actor survival, local faction trust, Writs, evidence docket, the active Echoform accord, city-resource balances and that city's physical layout. The profile retains only eligible **knowledge and offers**, described below; not unique reward firearms for free, not faction approval, not harvested memories. The record of Ninth's last death is retained by the analogue archive **only if it was actually observed or recorded** (the player profile may know more than Nix's tape does).

**On terminal ending:** seal outcome (Liberation/Dominion/Crown/True Dawn) and the applicable factual ending cards. The city's future does not roll back. Choosing *New Campaign* creates a **separate counterfactual campaign**, explicitly labelled in the menu; Nix does not reference the old completed ending as a prior death. `Profile.completed_endings` is achievement history, not in-world cross-campaign memory. Save file becomes read-only historical record.

#### Bounded meta-progression

| Eligible to persist in PlayerProfile | Effect on subsequent campaigns | Prohibited persistence |
|---|---|---|
| Discovered weapon blueprint ID | Adds one extra legal *offer possibility* to appropriate service stock, not a guaranteed free weapon | Free high-tier equipment or permanent damage |
| Discovered legal fabrication procedure | Adds a service recipe offer if materials and licence exist | Infinite scrap, waived story consequences |
| Genuine archive catalogue entry | Player's reference codex may show earlier discovered lore in a clearly non-diegetic section | Nix claiming an unseen fact in a fresh new campaign |
| Cosmetic palette, challenge rule and HUD preference | New selectable setting | Combat stats or main-quest shortcuts |
| Failed-attempt archive with authenticated death evidence | Nix may reference actual witnessed failed attempts within a continuing failure chain | Claiming deaths from completed endings or abandoned runs |
| Terminal-ending record | Profile achievements and separate what-if stories | Rewriting completed canon or forcing same continuity |

**Blueprint offer fairness:** at most two additional previously discovered designs appear in shop offer pools during a new attempt, from a seeded weighted list filtered by locale/licence. A new profile and an experienced profile both have a guaranteed basic pistol, loadout and at least one alternate weapon before Act II. All essential elements (three Writs, hearing, standard endings, restoration clues) are completely independent of profile unlock count. Challenge modes are opt-in and have no exclusive ending.

#### Attempt-scoped advancement offers

At campaign generation, 2 regular mod offers are placed in the first two featured districts and 1 in the third; 1 optional unusual service or tool offer appears outside these; all run-specific and priced. The player's build affects recommended items in shop dialogue but does not alter critical drops. No more than **three installed major mods** across equipped weapons (one per standard weapon) and no more than **two temporary civic service favours** active at once. Refusing an offer does not create new stock. Faction concessions can grant an alternate valid route or discount but have explicit end-of-run expiry.

#### Save/load contract

Use profile slot + one active campaign snapshot per save slot. The **schema version**, rules version, world seed, independent RNG seed+state streams, `WorldPlan` digest, `MapPlan` module identities/transforms, current district and avatar transform, inventory instance IDs, health/Breath, earned challenges+XP, perks/attributes, five-office relations, individual NPC state, actual witnessed events, evidence sources, Writ registry, hearing turn/strain/transcript, ending eligibility, city resource transaction log, shop stock and outstanding action ID must all serialize. Save at district threshold, settled conversation choice, Writ transfer, hearing outcome, death, ending and explicit suspend. Auto-save writes a temporary candidate then swaps it into place only after successful parse/schema validation; no half-committed choice.

Godot's official save documentation notes JSON can store simple state but needs conversion for e.g. `Vector3`; implement explicit schema records, not arbitrary node dumps: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html . A saved run can be resumed from its last **committed** state and RNG states; loading must not award a one-time quest reward twice. Restoring a terminal campaign does not make it playable again. **Anti-save-scum policy is a design choice:** no punitive permadeath deletion of the user's account file; active campaign checkpoint is advanced after irrevocable decisions and cannot be manually rewound through the game UI.

**Provisional FPS input contract (requires playtest):** move/strafe WASD, look mouse, primary fire left button, secondary action right button, interact E, sprint Shift, dash Space, reload R, field tool F, weapon cycling mouse wheel, quick-use items keys 1–4, docket/journal Tab, pause Esc. Rebind every action and provide controller aliases. These are input *proposals* rather than historically established controls. Do not add jumping, wall-running or crouching to canon before their traversal and accessibility costs are reviewed. A player with depleted Breath retains walking, basic aiming and firearm use.



## 8. Weapon combat, equipment, inventory and finite economy

### 3. Equipment, ammunition and weapon combat

**Existing catalogues are protected.** Every original V5 weapon silhouette, history, field tool, NPC reward and ammunition name is reproduced without omission in the consolidated V6 bible below. Weapon numbers are **provisional**, and weapon stats are implemented by stable IDs, not names displayed in prose. `damage` means base hit before armour; shotgun is total only at point blank; `interval` is time between actions in seconds; `reload` is seconds for a complete refill unless the item is a melee tool; `range` is its effective range (damage falloff can begin there). `stagger` is additive units on an enemy stagger meter with 100 threshold; boss stagger threshold is 200. `recoil` is a relative per-shot kick before Force/Reflex modifiers; lower is calmer.

**Baseline combat and damage:** Player aim/attack is evaluated in fixed physics ticks, not narrative RNG. For a non-crit hit, `final_damage=max(1, round(base × range_factor × armor_factor × exposure_factor))`; range_factor 1.0 up to listed range, linearly falls to .55 at twice range (beyond 2× range remains .55 or ray limit); armour_factor 0.8 for plated grunts, .65 for elites, .55 for boss plates, except appropriate Puncture/Shear 1.1× against vulnerable plates; exposed machinery may amplify Arc ×1.25. Do **not** infer damage or eligibility from the ecological label of an Echoform. Weak-point multiplier 1.35, max modifier stack 1.65. Friendly civilian damage is an actual resource/relationship event with a visible warning icon. No static RNG critical chance is required.

**Provisional pacing:** grunt 70 HP, enforcer 125 HP, elite 240 HP, mini-boss 420 HP, Custodian 650 HP with mechanical phases; ordinary gunfights 20–50 seconds, major room 45–90 seconds, boss 2–4 minutes; tuned for one player at 320×200 readability. An encounter must provide visible cover/recovery; never assume fully loaded rare weapons. The base Covenant Pistol and map-placed ammo must be capable of resolving every mandatory combat fallback.

#### Weapon-by-weapon numeric definitions (all 16)

| Weapon | Ammo and type | Base damage | Interval (s) | Magazine | Reload (s) | Range (m) | Stagger | Recoil | Acquired / interactions / named mod compatibility |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| **Covenant Pistol** | Ledger Slugs; Kinetic | 24 | 0.420 | 6 | 1.8 | 24 | 8 | 0.8 | starter / Last Office; mark weak point +10% next hit; valid on counters; **mods:** Witness Seal, Exaction Spring |
| **Coil Shotgun** | Coil Shells; Kinetic | 64 | 1.050 | 2 | 1.6 | 9 | 35 | 2.0 | checkpoints / foundry; 8 pellets × 8, precise pump on timed input; **mods:** Crowd Brake, Glass Choke |
| **Nail Storm** | Rivet Belts; Kinetic | 8 | 0.085 | 60 | 2.5 | 15 | 3 | 1.3 | Sootworks; heat 3/shot, overheat at 90, cool 18/s; **mods:** Chain of Wages, Cradle Clamp |
| **Saw Lance** | Pressure Cartridges; Shear | 32 | 0.650 | — | — | 3 | 28 | 0.5 | foundry; normal slash free, charged jaw press 1 pressure cartridge; **mods:** Mercy Brake, Grinder Crown |
| **Volt Rifle** | Voltaic Cells; Arc | 28 | 0.280 | 12 | 2.0 | 27 | 12 | 1.4 | Barracks; alt fire chains through connected live machinery for +1 cell; **mods:** Blue Testament, Fulgur Fork |
| **Bone Mortar** | Ossuary Pods; Blast | 90 | 1.350 | 3 | 2.8 | 22 | 45 | 2.2 | recycler / rare boss; blast radius 3.0m, hurt allied apparatus; **mods:** Mother’s Casket, Grave Splitter |
| **Censer Flamer** | Censer Fuel; Ember | 6 | 0.100 | 80 | 2.4 | 7 | 4 | 0.4 | Basilica; a 0.1 s pulse spends 1 fuel, floor hazard 2s; **mods:** Saint’s Wick, Penance Vent |
| **Harpoon Injector** | Harpoon Spurs; Puncture | 52 | 0.900 | 4 | 2.5 | 23 | 28 | 2.2 | Orchard; pulls unanchored objects; elite foes resist pull; **mods:** Mercy Needle, Trawl Barbs |
| **Hush Carbine** | Waking Tape; Sonic | 11 | 0.120 | 36 | 2.2 | 20 | 6 | 1.0 | Last Office; quiet fire, interrupts sonic shields; **mods:** Quiet Hours, Choir Throat |
| **Cinder Launcher** | Cinder Casks; Ember/Blast | 100 | 1.600 | 2 | 3.0 | 24 | 48 | 2.5 | Sootworks; radius 3.5m, burns stored evidence if hit; **mods:** Heat Bloom, Salvage Cage |
| **Widow’s Toll** | Waking Tape; Sonic | 36 | 0.620 | 5 | 2.0 | 18 | 34 | 1.7 | Iona branch; debuff grief signal for 4s; **mods:** none — named quest weapon |
| **Surgeon’s Mercy** | Ledger Slugs; Puncture | 19 | 0.320 | 8 | 2.1 | 23 | 10 | 0.6 | Sela branch; weak point transfers 20% dealt damage to present ally, cap 12 heal / 4s; **mods:** none — named quest weapon |
| **Penance Fang** | Pressure Cartridges; Shear | 46 | 0.850 | — | — | 3 | 38 | 0.8 | Kest branch; bleed 4/s for 4s on charged hit; 1 cartridge; **mods:** none — named quest weapon |
| **Debt Collector’s Smile** | Ledger Slugs; Kinetic | 51 | 0.650 | 6 | 2.5 | 14 | 22 | 2.3 | Pale Ledger branch; +25% weak-point critical, 5th lethal hit records scandal; **mods:** none — named quest weapon |
| **Choirbreaker** | Waking Tape; Sonic | 30 | 0.440 | 12 | 2.2 | 28 | 17 | 1.0 | Ossa branch; silence forced choir emitters for 3s; **mods:** none — named quest weapon |
| **Ferryman’s Hook** | Harpoon Spurs; Puncture | 42 | 1.100 | 3 | 2.7 | 21 | 22 | 2.2 | Perrin branch; yank only lighter targets or pre-marked rail anchor; **mods:** none — named quest weapon |

**Timing and animation contracts:** Weapons with magazines reserve ammunition on a validated fire event and decrement it exactly once. Melee free swipes use zero cartridges; charged effects consume one Pressure Cartridge. Shotguns spend one Coil Shell per trigger pull (eight pellets are one shot). Flamer consumes one fuel per 0.1-s tick. All reloads can be interrupted with current magazine preserved; first-person sprites must distinguish idle, discharge, recovery, reload and blocked/refusal (where relevant). Rare weapons are unique instance IDs, not duplicate loot rolls. Enemy wreckage can be salvaged once; no unlimited ammo from re-entering a room.

**Range / knockback safety:** Stagger does not apply to civilian dialogue actors except explicit threat/hostility; stunned enemies enter `staggered` for 1.3 s, with 2.5 s immunity afterward. A close-range finisher on a staggered combatant restores 18 personal Breath (max 100+Resolve-derived extension) and 5 HP, once per target; an optional nonlethal version restores 12 Breath and 0 HP. Finishers consume 0.7 s and commit Ninth to a position, avoiding infinite invulnerability. Max finisher healing per encounter 30 HP.

#### Authored major modifications — one active per standard weapon

Each mod costs **3 salvage units and one relevant vendor permission** (or a found installer); earned unique NPC rewards do not incur that fee. Mod availability is deterministic per world plan and branch outcome. Installing at a bench takes 15 s in-world. Switching mods is allowed only at a bench, with no duplication of the removed mod. For tradeoff parity, two options should change how a gun is used rather than flatly outrank each other.

| Base weapon | Canonical mod | Provisional effect |
|---|---|---|
| Covenant Pistol | **Witness Seal** | weak-point mark extends from 3 to 5 s; revealed target is not evidence itself |
| Covenant Pistol | **Exaction Spring** | shot interval 0.42→0.34 s; recoil ×1.22 |
| Coil Shotgun | **Crowd Brake** | stagger +35%, spread cone +25%, effective range 9→6 m |
| Coil Shotgun | **Glass Choke** | replace pellet shot with one 56-damage penetrator; range 9→19 m |
| Nail Storm | **Chain of Wages** | 20% chance on eligible defeated debt enforcer to return 2 Rivets, max 12/district; Brass Union hostility +1 |
| Nail Storm | **Cradle Clamp** | while sliding spread ×0.72; swap time +0.12 s |
| Saw Lance | **Mercy Brake** | staggered humanoid finisher is nonlethal; Breath restored 18→12 |
| Saw Lance | **Grinder Crown** | rotating *abrasive collar* outside opposed reciprocating shear jaws; heavy-armour damage ×1.25; heat +5 per charged strike; no chain blade |
| Volt Rifle | **Blue Testament** | arc chaining to a marked allied machine repairs up to 5 local integrity per district; extra cell cost 1 |
| Volt Rifle | **Fulgur Fork** | chain targets +1, total cell use per alt shot 2→3 |
| Bone Mortar | **Mother's Casket** | blast radius 3.0→2.1 m, heal a protected ally 8 HP if within 2 m (once per 6 s) |
| Bone Mortar | **Grave Splitter** | add four 7-damage splinters, each affects a target at most once |
| Censer Flamer | **Saint's Wick** | removes one weak Mnemonic field per 30 fuel spent; sustained direct damage -10% |
| Censer Flamer | **Penance Vent** | flame range 7→10 m; self-heat accrues +1 per fuel |
| Harpoon Injector | **Mercy Needle** | alt consumes 2 spurs and heals cooperating Echoform 14 strain, no enemy damage |
| Harpoon Injector | **Trawl Barbs** | object pull strength ×1.5, target inflicted scar social consequence when used on civilians |
| Hush Carbine | **Quiet Hours** | enemy-alert radius ×0.65, stagger ×0.80 |
| Hush Carbine | **Choir Throat** | sonic shield disruption +30%, noise alert radius ×1.50 |
| Cinder Launcher | **Heat Bloom** | ignite up to 4 growth tiles for 4 s; collateral risk +1 if civilian fixtures hit |
| Cinder Launcher | **Salvage Cage** | radius 3.5→2.4 m, 6 fragments ×8 damage, one hit/target |

**Continuity note:** Saw Lance: Grinder Crown remains a red segmented collar added to the V5 opposed shear jaws. The collar abrades armoured surfaces; it is NOT the older rotary-chain implementation. Penance Fang is a separate trench blade. `Glass Psalm` and old `Imprint Dye` descriptions use ecological material marks, not type-based battle modifiers or compelled cosmetic reprinting. Implement V5 command behaviour rather than obsolete V2 abilities.

#### Ammunition stacks, guaranteed supply, pickups

| Canonical ammunition | Carry cap | Default pickup | Cheapest normal acquisition (provisional) |
|---|---:|---:|---|
| Ledger Slugs | 120 | 12 | 4 vouchers for 12 |
| Coil Shells | 36 | 6 | 5 vouchers for 6 |
| Rivet Belts | 240 | 30 | 5 vouchers for 30 |
| Pressure Cartridges | 18 | 3 | 3 vouchers for 3 |
| Voltaic Cells | 84 | 12 | 6 vouchers for 12 |
| Ossuary Pods | 18 | 3 | 8 vouchers for 3 |
| Censer Fuel | 160 | 20 | 5 vouchers for 20 |
| Harpoon Spurs | 24 | 4 | 5 vouchers for 4 |
| Waking Tape | 100 | 12 | 6 vouchers for 12 |
| Cinder Casks | 16 | 2 | 7 vouchers for 2 |

Full inventory pickups beyond cap stay on ground until sector exit, when their record expires; no storing infinite physical supply in the profile. At least one guaranteed ammo locker on entry to each mandatory combat arena contains enough Ledger Slugs (24) plus two Breath Ampoules to reach its fallback success route. Enemy ammo loot is capped to at most 1 supply grant per authored encounter and comes from finite planned drops, not an infinite respawn.

### 4. Inventory, protection and services

**Binding equipment slots from V5:** two ready ranged weapons, one ready melee weapon; head, body, legs armour; **two relics** and **one field tool**; **four assigned quick-use consumable types**; up to three *registered* Echoform accord records, **one active in any hearing**. A holstered weapon is not lost, but Ninth cannot bring every weapon into a room: excess equipment is parked in the next stable service locker. The large backpack has no weight slider. Quest objects and analogue records occupy a distinct, uncapped **Evidence Docket** and never consume loot capacity or become saleable. Writs cannot be destroyed, pawned, consumed, or sold.

**Carrying limits:** two firearms, one melee in hand/holster; up to 2 reserve weapon items temporarily carried for delivery to a service locker; 8 combined consumable stacks (each stack maximum 3 uses), four pinned to quick keys; 12 salvage units; voucher balance maximum 99; ammunition category caps per table above. A field tool may be swapped from the case at a safe station; a loaner cannot be sold or scrapped. RPG UI tabs: `LOADOUT / STORES / DOCKET / RELATIONSHIPS / SERVICE PLAN / RUN RECORD`. It must be keyboard/controller navigable at 320×200, use original Pressure Docket design rather than copied franchise HUD layouts, display gameplay changes in text, and show exact charge counts. In combat, numbers are limited to ammo, health, Breath and current exposure, with no scrollable inventory overlay.

**Excess/ground pickup rules:** A safe locker may hold at most 6 other weapons and 12 consumable stacks during the attempt; these vanish on death or terminal ending. A dropped weapon retains a unique persistent-in-attempt instance ID until that module unloads and is re-placed on reentry only if not collected; same pickup cannot pay twice. Quest-critical evidence duplicates produce journal copies, never duplicate rewards. If a quest reward exceeds capacity, it is automatically placed in the nearest reachable locker and marked on the map, with a deterministic claim ID.

**Armour:** 3 pieces, freely mixed; per-piece protection is a flat damage reduction *percentage* applied after weapon damage, cap combined physical damage reduction at 35%. The V5 armour sets and individual piece names remain fixed; each head gives 3%, body 8%, legs 4% physical reduction, except Hearthkeeper pieces 2%/5%/3% and Last Office 4%/10%/6%. Set bonus requires all three from same set, does not stack with another set. Armour has **no passive durability decay**—do not add repair busywork. Environmental damage to city infrastructure uses explicit service actions instead.

| Full existing set | Provisional three-piece bonus, in addition to pieces | Complication / limits |
|---|---|---|
| Hearthkeeper Rags | +15% healing from Breath Ampoules | Low base protection, shelter ration mark visible |
| Brass Union Rig | -25% Ember hazard damage; slide stagger +12 | Work machinery recognises union token |
| Broker's Mourning Suit | 10% voucher discount at cooperating legal traders | Rescued debtors' trust -1 on first meeting; never prevents rescue |
| Last Lamp Vestments | -20% Dissonance duration; -20% shallow-water slowdown | Forced-choir staff may mistake Ninth for an enforcer |
| Glass Pruner Coat | -20% glass-hazard damage; +1 Insight for eligible botanical checks | Only when botanical evidence is already present |
| Last Office Plate | weapon recoil ×0.86 with heavy weapons; +5% physical DR (35% global cap) | Unarmed civilians initially fear the insignia |
| Reprint Shroud | -25% Mnemonic status duration; recover Breath +2/s after status ends | -5% physical DR from its base pieces |
| Architect's Burden | traps deal -20%; one extra Tech-specific interaction cue per district | Does not automatically grant Founders' Cipher |

Unique **Recall Plate** uses three slots and gives a nonlethal stand-down command once/Quiet Barracks visit if the applicable Kest testimony is genuinely recorded. **Salt Pilgrim Greaves** prevent shallow-water slowdown, **Salt-Sewn Hood** reveals one whisper clue/area but imposes -1 contextual Speech while worn. These remain branch-exclusive, not generic drops. Relics retain their V5 unique benefits; their compact bonuses must not exceed one +1 situational check or a bounded 10–20% effect, and their drawbacks must be surfaced before equipping. No relic can fabricate evidence or override a character's refusal.

**Injury/recovery:** health does not automatically refill on changing districts. A shelter or friendly clinic offers one 50-HP treatment per district entry for 4 vouchers or an earned favour; no farming by repeated exit/reentry, tracked `service_used[district_id]`. Personal Breath regenerates 2 units/s while not sprinting or under pressure, until 60% maximum; finishers, rare fields and Breath Ampoules fill above that limit. Sprint 6 Breath/s, dash 14 Breath (2 s cooldown), charged melee 8 Breath. If Breath reaches zero, Ninth can still walk, reload and use the starting firearm: no mobility softlock.

#### Every standard consumable — provisional charge, effect, price

| Canonical item | Charge / exact mechanical effect | Vendor price (vouchers) | Limitations |
|---|---|---:|---|
| Breath Ampoule | +35 HP and +24 personal Breath instantly | 6 | Free backup placed at guaranteed combat lockers |
| Printed Flesh Wrap | +52 HP over 6s, one light wound cleared | 8 | Healing pauses for 1s if hit |
| Triage Vapour | +25 HP and sprint bonus +12% for 4s | 7 | Visual distortion 3s |
| Graft Soup | +65 HP outside combat; +15 max Breath for this district | 10 | Adds +5 short-lived Mnemonic strain |
| Sister's Thimble | Clear 1 strong status; Sonic status damage -20% for 10s | 9 | Limited stock per run |
| Last Ration | +18 HP; +1 Resolve on next single eligible check | 4 | Consume bonus on first attempted check |
| Adrenal Bell | Sprint +18%, swap time -0.1s for 8s | 8 | Afterwards sprint -10% for 6s |
| Salt Charge | 26 Blast to Unsaid + clear 1 corrupted surface in 2.5m | 6 | No unrestricted boss stun |
| Glass Flechette | 8 shards × 9 Puncture over 2m, one hit/target maximum 4 shards | 6 | Friendly fire in tight spaces |
| Cinder Bottle | Burning area 4m radius 4s at 8 Ember/s | 7 | Can destroy nearby evidence |
| Screaming Ribbon | Decoy lasts 7s, draws non-deaf hostiles up to 15m | 5 | May attract extra patrol |
| Discharge Canister | Stuns a powered machine 2s, or powers one marked terminal | 8 | Single selection, not both effects |
| Containment Staple | Forcible accord offer after witnessed vulnerability | not routinely sold (regulated) | Refusal and relationship harm apply; never required |
| Echo Feed | Restore +18 hearing stamina between exchanges | 5 | Can't be used after withdrawal until retry registered |
| Gauze Cocoon | Recover one unraveled registered participant to 15 strain margin | 8 | Between hearings only |
| Reset Resin | Clear 1 hearing debuff / temporary command lock | 7 | Does not erase coercion history |
| Truce Wafer | One extra voluntary conversation response at a hearing | 6 | No guaranteed cooperation |
| Imprint Dye | One cosmetic/imprint accent recalibration after participant's assent | 5 | No type evolution, no forced body rewrite |
| Archive Solvent | Exposes one authored sealed record layer | 5 | Tech/alternate evidence route remains |
| False Papers | One attempted false-credential passage | 6 | Check may fail on observed contradictions |
| Transit Chit | One use of an optional scheduled transit link | 3 | Core Writ route not dependent |
| Canal Lamp | Reveals flooded signs and reflected route marks for 1 district | 3 | A normal torch remains available |
| Spare Fuse | Powers one tagged panel or disarms one trap bus | 4 | Does not create Energy from nothing; draws from panel reserve |

**Price scope:** voucher values are *allocation receipts* or legal service credit used in-world, not a new magical currency. One voucher represents a claim against existing supply in an office ledger, and must be backed by that office's stock; a voucher cannot conjure consumables. Black-market barter exchanges tangible salvage, favours or office records with explicit contracts. Voucher stock starts at 12, earned from unique services (4–12 per task), capped at 99. Scrap/salvage starts at 3, capped at 12, and exists as finite tagged physical pickups. All shops have fixed inventory for the duration of an attempt: starter clinic 3 Breath Ampoules (plus guarantee pickups), two district-specific 1–3-charge supplies, one chosen standard weapon offer and one bench. High-rarity consumables require earned access or quest action, never necessary for the critical path.

#### Trades, resources, repairs, fabrication, no infinite exploits

| Service | Cost / requirement | Exact outcome and conservation source |
|---|---|---|
| Purchase starter ammo | Table above + store stock | Moves physical bullets from vendor stock to Ninth's stack; vendor stock decrements |
| Purchase standard firearm | 18–28 vouchers, corresponding office licence or salvage exchange | Moves one world-authored instance; no random stat prefix |
| Major weapon mod | 3 salvage + a staffed bench or found installer | Consumes physical parts; one active mod on weapon |
| Reset standard perk/stat selection | 3 salvage and 90 s, once per run | No resource creation, no refund of spent story choices |
| Emergency cover plate patch | 2 salvage + 1 labour unit, once/encounter site | Restores up to 30 cover integrity (max original), may reroute safety |
| Repair air valve | 2 salvage + 2 labour + 1 energy | +5 local air throughput from previously blocked existing pipe capacity |
| Restore machine protection | 2 salvage + 2 labour + 1 energy | Re-enables one authored defence/door; may change civilian response |
| Staffed clinic treatment | 4 vouchers or earned favour, once/district entry | Consumes one medicine stock; +50 HP |
| Fabricate common spare fuse | 2 salvage + 1 energy and a licensed bench | One Spare Fuse; cannot exceed shop inventory limits |

**Vendor relationship matrix:** Office Trust is a signed score -3..+3 per founding office. **Trust is not moral alignment.** Escaped debtors and registry brokers may respond oppositely to the same action; only witnesses and credible channels learn it. At trust ≥2, that office offers 10% discount on its *existing stock* and a safe service route; at ≤-2, guarded stations add one patrol and require an alternate path, but do not disable Writ registry fallback, guaranteed ammo or public loaner. NPC quest reward packages are grouped as `(immediate power, service access, information, transport/evacuation, long-term trust)`. A better weapon can be paired with lost repair/transport services, but a rescue does not have to yield identical numeric DPS to be viable. UI previews exact consequences before irreversible actions when Ninth can know them.

**Reward parity scenario (provisional):** Brin's release grants Brin's Torque (+1 contextual repair), 1 safe service station with 2 repair uses, +1 Labour trust and one escorted cover lane; betrayal awards Chain of Wages mod and 8 vouchers but Labour trust -2, removes that station, and increases heat leakage in Sootworks. Compare resources and risk across 5–10 encounter scenarios; no moral path is tuned to be strictly superior. **Fraud prevention:** vouchers/salvage are granted once per tagged interaction, selling an object pays at most 40% of its purchase price, vendor stock is never regenerated by re-entering a module, and purchased goods may be sold only after unique-instance validation. No vendor accepts evidence, Writs or rescued civilians as ordinary inventory items.



## 9. Enemies, bosses, AI roles and tactical Echoform hearing

### 8. The V5 Echoform hearing — tactical implementation, not Pokémon combat

The canonical hearing is a civic field-interference test involving **one active participating Echoform** and one external opposition/field. The active participant chooses whether to cooperate; registrations are not property transfers. The twelve biological species and their existing art/behaviour descriptions remain unchanged. Their six historical material labels describe ecology/manufacture, **not a rock-paper-scissors type ring**. Five player commands only: **Press / Attune / Brace / Observe / Withdraw**. No four-move list, evolution level, capture reward, defeated-opponent ownership or permanent species XP.

**Field state:** `integrity=31`, participant `strain_margin=46`, `observed=false`, `turns=0`, `refusals=0`, `accord_type ∈ {voluntary, coerced, loaner}`, `arena_id`, `familiarity=0..2`, `active=true`, `finished`, `passed`, and append-only transcript events. These starting numbers preserve V5 Python's present duel demonstration and serve as **prototype targets**, not verified player-facing balance. `familiarity` increases by +1 on voluntarily completed authored interactions up to 2 for this attempt; it is *not* a permanent creature level or forced imprint. Voluntary participant begins at trust 2; public loaner at trust 1, coerced at trust 0. Trust from -2..+3 is per-NPC/entity, never inherited by every member of a species. Each fresh attempt resets accord, familiarity, strain and trust except player-profile knowledge (out-of-world codex).

| Command | Provisional integrity decrease | Participant strain | Additional rule |
|---|---:|---:|---|
| Press | 8 | 5 | If coercion and every third Press, refusal: decrease 0, record refusal, still takes strain |
| Attune | 8 +4 if field matches learned practice +3 if observed | 4 | Observed flag consumed only for impact bonus on first subsequent Attune |
| Brace | 0 | 2 | Next damaging response reduced by 3 (floor 1), cannot make a zero-cost loop |
| Observe | 3 | 2 | Reveals next field response, enables +3 Attune, records an actual observation |
| Withdraw | 0 | 0 | Ends attempt safely; can retry with same willing creature or free public Rootkin |

A participant may autonomously refuse in a way that is explained by actual trust/compulsion state, never because an invisible random number demands it. If `strain_margin` reaches 0, the hearing ends without mission failure; damage does not kill the creature and the public Rootkin loaner and unlimited hearing retries remain available. Loaner retry is free, never consumes rare ammo, supplies or time that would trigger unavoidable fatal shelter loss. Hearing is only available at the district assigned by WorldPlan; it cannot be completed from Hearth Nine. Successful hearing grants `independent_pressure_hearing_completed`, unlocks field methods and 110 unique XP. No mandatory rare field item is required.

**Compatibility with V5 Python:** Preserve its existing numerical command effects when testing existing scripts; the optional V6 added trust/familiarity and Brace guard behavior must be separately implemented in Godot or a later narrative reference update. The V5 Python code currently keeps `observed` true once set and `Brace` simply incurs 2 pressure without a guard. The V6 rule above clarifies intended gameplay and **must not be described as an already passing V5 test**. `Echo Feed`, `Gauze Cocoon`, `Reset Resin`, `Truce Wafer`, `Imprint Dye`, `Containment Staple` remain in the same item catalogue with V5 non-ownership/consent caveats. Coercion can increase immediate compliance but decreases willingness/long-term trust. No reward may override an entity's right to leave the hearing.

**Provisional success example:** Loaner Rootkin, unfamiliar field: `Observe` reduces integrity 31→28 (strain 46→44); `Attune` observed bonus 11 reduces 28→17 (strain→40); `Attune` 8 reduces 17→9 (strain→36); `Press` 8 reduces 9→1 (strain→31); final `Observe` 3 reduces 1→0 and passes. In the real V5 script the observed flag persists, so this 5-command example applies to the **new V6 intended** guard/consumption rule. A Python reference simulation must implement it if used for verification. The case illustrates that success is possible without ownership or type advantages, not that all patterns are balanced.


### Twelve species — retained full anatomy/lore catalogue

### C1. Twelve original Echoform species — full initial bestiary

| Species / type | Sprite and animation appearance | Lore / battle identity | Archived behaviours (not playable commands) |
|---|---|---|---|
| **Cindermoth** · Ember | Hand-sized black moth enlarged to dog scale, scalloped bronze wings with little eye-like holes, thorax glowing like coal, twelve-frame wingbeat leaving ember pixels | Born from the memory of a child watching the first sunrise; evasive support; found in Orchard ash vents | Ash Wing, Lantern Flicker, Scorch Kiss, Ember Shelter |
| **Boiler Calf** · Ember | Low cattle-like furnace with ivory rib grate, chimney horns exhaling flat grey sprite smoke, piston knees, burning-red eye vents | Printed from the memory of a factory animal that never existed; slow area bruiser; Sootworks boilers | Furnace Kick, Steam Shield, Cinder Charge, Last Whistle |
| **Rootkin** · Growth | Loping deer-shaped cluster of pale roots with a human hand in place of one antler, luminous moss joints and dripping dark soil | Remembers an impossible childhood garden; healing/binding; Glass Orchard nursery | Root Lash, Quiet Bloom, Pollen Veil, Grasping Floor |
| **Cradle Wasp** · Growth | Wasp the size of a terrier, striped abdomen made of nursery blankets, six stiff needle legs and gauze wings | Formed from memories of lost childcare; quick debuff/tactical reposition; orphanage annex | Needle Dance, Swaddling Fog, Memory Sap, Cradle Guard |
| **Mirror Jackal** · Glass | Transparent long-snouted hound with internal silver skeleton and flat triangular facets; its reflection is animated a frame late | Built from a stolen wedding portrait; speed, counterattack and false doubles; Orchard glass tunnels | Shard Bite, Mirror Step, Refraction, Thin Ice |
| **Prism Eel** · Glass | Floating eel in a segmented crystal tube, gold teeth visible through glass, tiny coloured light flashes in the ribs | Once a mirror's memory of the sea; piercing special damage; flooded industrial ducts | Prism Bolt, Splinter Current, Clear Skin, Glass Wake |
| **Spool Hound** · Wire | Three-legged steel terrier with braided copper body, cassette-reel flanks and a sparking antenna tail | Leaks recorded guard-dog commands; anti-Choir disruptor; barracks transmitter rooms | Current Fang, Static Bark, Cable Snare, Overwind |
| **Suture Mite** · Wire | Beetle-bodied surgical stapler, spindly chrome limbs, a row of fine red-lit sutures down its shell | Reprints last words as electrical pulses; utility and defensive debuff; hospital train | Staple Bite, Patch Circuit, Electrode Flare, False Pulse |
| **Bell Wretch** · Choir | Pale frog-like body with swollen bell-shaped throat, tuning forks growing through shoulders, throat inflates before sonic attack | A hymn remembered after the singers died; ranged control; Flood Basilica | Chime Crush, Dissonant Note, Choir Shield, Toll of Three |
| **Hush Heron** · Choir | Tall, skinless bird with porcelain mask-face, tubular throat, black lace flight feathers and tiny red foot-bells | Recalls moments of silence before executions; precise disabling attacks; drowned crypt | Silence Spear, Unsaid Verse, Wing of Mercy, Requiem |
| **Name Leech** · Husk | Fleshy grey slug with human handwriting across translucent skin, short grasping teeth, a little receipt dangling from its jaw | Consumes titles and labels; durable attrition; Ashmarket archive drains | Unname, Memory Siphon, Husk Coil, Borrowed Skin |
| **Grief Stag** · Husk | Broad-shouldered skeletal elk clad in moth-eaten overcoat cloth, candles in antlers, jaw opens sideways in three frames | A family's collective memory of someone nobody can identify; terminal boss-capable tank; abandoned rail | Grief Horn, Funeral Step, Borrowed Cry, Mercy Break |

**Retired visual-concept note (not V5/V6 gameplay):** no fixed three-stage evolution tree. Each Echoform has two seeded **Imprint Paths**, one based on voluntary trust and one on coercive control. Cindermoth, for example, can become **Hearthwing** (wide protective wings, healing) or **Ash-Marshal** (spiked iron wings, heavier damage and lower loyalty). Both are variant sprites of the same species, not additional mandatory collection entries. The story bible tracks the original form, chosen imprint and whether it joined freely.

**Precedence on species table:** the last column of four named moves is **visual/behaviour lore only**, not four selectable battle actions. The ecological material label is never a type advantage multiplier. The old “Imprint Paths” paragraph is a historical visual possibility only; there are no creature XP/evolution trees in the scoped tactical hearing. No creature is awarded to Ninth merely for winning a hearing.


### Original ecological field roles from V5

### Existing species, original physical logic and field role

| Species | Retained anatomy | Practical interpretation of material category | Expected field niche (design target) |
|---|---|---|---|
| Cindermoth | Vent-born, scalloped metal wings, ember thorax | Ember: warmth and microdrafts | Sootworks furnace pulses, Ashmarket heat-sensitive seals |
| Boiler Calf | Low furnace cattle-shape, piston knees | Ember: sustained heat | Dampen machinery oscillation |
| Rootkin | Pale living root bundle, moss joints | Growth: living calibration mesh | Orchard lattice, submerged filtration |
| Cradle Wasp | Gauze wings, six needle-like legs | Growth: binding threads | Repair torn physical media |
| Mirror Jackal | Offset reflected body, hard facets | Glass: optical phase shift | Visual discrepancies and false duplicate checks |
| Prism Eel | Glass tube, segmented luminescence | Glass: refracted signal path | Flooded ducts, isolated optical signals |
| Spool Hound | Copper braid, recorder reels, asymmetric legs | Wire: physical recording and induction | Barracks radio orders, Market registries |
| Suture Mite | Stapler abdomen, small probe limbs | Wire: fine circuitry | Surgical panel restoration |
| Bell Wretch | Throat as pressure bell, tuned shoulder forks | Choir: air-resonance | Basilica signal discrimination |
| Hush Heron | Long reed throat, foot-bells | Choir: selective silence | Interrupt false orders without destroying testimony |
| Name Leech | Translucent living inscription | Husk: unstable missing identity | Detect forged naming records |
| Grief Stag | Heavy coat-like membrane and broad sensor horns | Husk: collective missing memories | High-risk search of archival blind spots |

### Enemy and boss implementation matrix — P1 combat specification, not newly approved enemy lore

The bible establishes grunts, enforcers, elites, mini-bosses and three Custodians as combat *tiers*; distinct enemy-species lists, final health pools and completed animations are NOT supplied. The following table defines reusable AI behaviours for established encounter material, with provisional numbers, without asserting new named monsters.

| Encounter category | Source in Vesper | Behavioural contract | Telegraph / weakness | Provisional durability and damage | Failure and rewards |
|---|---|---|---|---|---|
| Unsaid residue | Unbound memory patterns | Approach remembered routes; alternate lunge and involuntary repetition; lose interest when source field cut | 0.65 s sensory cue, interrupted by Sonic and isolation; avoid relying only on tint | Grunt 70 HP, contact 12–16 damage | Non-renewing planned drops; no infinite XP |
| Office enforcer | Civic security and contracted guards | Seek partial cover, advance on flank when ally suppresses, halt on recognised legal order | Exposed reload window ≥0.7 s; physical cover respected | 70–125 HP, burst 8–13 damage | Writ registry fallback remains if keeper dies |
| Infrastructure automaton | Fixed pumps, sentries and defence machinery | Turret sweep and tagged hazard; active while power supplied | Visible rotation/valve cue ≥0.6 s; Arc affects electronics | 125–240 HP as selected | Collateral damage posts to CivicResourceLedger |
| Reprint casualty / coerced worker | Finite biomass and corrupted identity records | Physically forceful but intermittent, may avoid targets after recognised personal memory evidence | Wind-up 0.8 s, breaks stance on physical obstruction | Elite target 240 HP, impact 15–24 | Treatment versus elimination affects local witness state |
| Boss-level encounter | office heavy elite or relevant Custodian mechanism | 2–3 distinct state phases; bounded adds; genuine alternative solution | Key arena machinery visible before attack, ≥0.85 s major signal | Mini-boss 420; Custodian 650 HP target, not tested | Custodian fate and method recorded independently |

**No invented infinite respawns:** every combat arena consumes a finite encounter budget. Attack damage and telegraph numbers are trial defaults only. Each combat encounter must provide attack feedback, stagger/recovery, line-of-sight cover and a means of retreat. AI navigation cannot substitute for collider validation. NPC civilians are never anonymous explosive props: their harm changes a reported consequence.

**Three Custodian encounter contracts:** Edda's ward bellows and patient collateral; Voss's moving gun nests and perimeter breach risk; Latch's omission of unregistered lives in casualty accounting. Each must admit authored nonviolent methods when evidence and NPC states allow, a reliable assault alternative, a real outcome distinction, and no mandatory rare-item dependency. Final AI tuning, arena geometry and sound cues are unimplemented.



## 10. Districts, authored room modules and procedural safety

### 5. Roguelite world construction and route guarantees

**Preserved V5 WorldPlan distribution:** choose 3 featured offices from 5; the other 2 remain optionally reachable. Select 3 major arcs from the existing 8; select **2 distinct local storylets per featured district** from its existing 4; choose 1 Custodian (Edda, Voss, Latch), 1 contested reserve Lung site, a mandatory hearing anchor inside the first 2 featured districts, 1 opponent appropriate to that hearing, and independent reachable locations for Deep Heat Survey, Orchard Root Seed and Founders' / Governor's Maintenance Cipher. The last two names are a *single object*: V5 calls it Governor's Maintenance Cipher in the 14-item catalogue and Founders' Cipher in some gameplay briefs; keep the object ID `cipher` and visible canonical item name **Governor's Maintenance Cipher**, with **Founders' Cipher** as journal shorthand, not a second collectible. The WorldPlan may contain a mix of available interventions; it must never pick Ninth's decisions.

**Possible variation:** order/selection of featured districts, room placement among existing movable modules, weather/pressure condition, patrol shifts, route serviceability, local intervention choices, offered mod installations, three major arcs, six local hooks, 1 Custodian, one Lung allocation claimant, hearing field layout, optional side-travel risk and salvage pickups. **Fixed anchors:** Hearth Nine first, the five district identities and core political roles, Quorum sockets, Engine foundations, protected analogue archive, Freight Lift, mandatory hearing within first two featured regions, Emergency Rail, public Rootkin loaner, critical item existence and all three standard final choices. No generation of architecture/people from infinite matter.

#### Map data and assembly algorithm (Godot-compatible; not implemented yet)

A room module is an authored Godot scene + a **separate metadata Resource** `{id, district_id, footprint_grid, door_sockets:[{local_transform, corridor_class, pressure_class, width}], tags, safe_spawn_volumes, hazard_volumes, NPC_anchor_ids, quest_anchor_ids, air_connection_ids, static_navmesh_resource, variant_count, art_palette_id}`. Every module must have a believable original engineering role, stable module ID and bounded connector class. Map grid is used only for placement; interiors can be 3D sprite-compatible rooms with `StaticBody3D` collision. Use 8m/16m service blocks and controlled vertical connector types rather than arbitrary tile soup.

**Topological/physical construction pipeline:**

1. From the seed, create *independent* RNG streams for `story`, `layout`, `enemies`, `loot`, `cosmetic` using a stable custom integer mixer; never consume story RNG from visual particle effects. Save world seed, stream states and generator algorithm version.
2. Create a mandatory DAG: `Hearth Nine → contested Lung site → each chosen featured district's public Writ registry → Freight Lift → Custodian → finale`, and a cross-linked branch for the hearing on one first/second featured district. Attach the 2 optional districts and all three reachable restoration dossier leads as separate branches; a fallback physically accessible paper-record route always exists.
3. Place authored anchors first at validated fixed-coordinate transforms: arrival, Cinder Lung clinic service, district Writ registry, hearing, evidence lockbox + analogue duplicate, side quest sites, exit, rail/Engine anchors. Reject a layout that depends on an optional gear upgrade to connect any mandatory anchor.
4. Fill between anchors with 2–4 compatible authored corridor/room modules per district, each with matching pressure/door/socket class and zero 3D intersection against installed modules (test inflated AABBs, not only texture surfaces). Allow maintenance passages and optional loops, but no free-form teleportation. All sectors have actual power/vent connectors to an anchored infrastructure network.
5. Assign encounter curves by place function: safe intro corridor → low-threat encounter → tension/rest → one risky alternative → Writ arena/negotiation → exit. A safe route and a combat route must not both become blocked by a randomly selected hazard.
6. Attach offered NPC and storylet scenes to matched tagged anchors; quest anchors whose actors die still have deterministic registry fallback. Spawn actual documentary clues before any check that could consume them. Plan shops/safe rooms from finite tagged stock, including guaranteed Ledger ammo and Breath Ampoules on required assault routes.
7. Validate in two independent passes: (a) connector graph reachability via BFS/DFS for a walking actor **and** a fallback action-state graph for doors, lifts, pressure hazards, Writs and routes; (b) instantiated collision and 3D navigation traversal at Ninth's hull dimensions. A route must have clearance for avatar radius 0.35 m and height 1.65 m; unpowered doors need an alternate access state or a valid action. Validate exit-to-entrance reverse path for backtracking when relevant.
8. Retry a failed sector layout with a deterministic layout-subseed at most **8 times**. On failure load the district's hand-authored fallback layout and log `fallback_used=true`. A fallback may change cosmetics/encounters, never critical facts or the eventual ending availability. Do not skip validation for the fallback.
9. Save an immutable `MapPlan` (module IDs, transforms, door states, loot IDs, NPC slots, nav validation stamp) before player entry. The live game changes door and hazard states through recorded actions only; it does not reseed after player failure or move rooms under the player's feet.

**Godot note:** Navigation meshes consider navigable surfaces independent of physics/collisions; validation must test both (Godot official docs: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationmeshes.html). Use pre-baked navmesh resources for most authored room modules, stitch region edges at known door sockets or bake composed low-poly collision geometry. Avoid runtime full-world mesh parsing spikes. Godot `RandomNumberGenerator.seed` creates repeatable streams, and stored `.state` resumes them; version the layout algorithm so a later game patch does not silently reinterpret saved seeds (https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html).

**Physical feasibility and limits:** The Engine's dusk shift repositions existing modules along built rails, schedules personnel transfers and makes recorded reprints at a resource cost. No instant buildings, underground extensions that were never surveyed or limitless air/biomass. A generation's *layout plan* is a bounded selection of module placements. A player's `WorldPlan` might differ between attempts; that reflects a new post-failure reconstruction, not a miracle after a final ending.

#### Three full example run configurations

| Field | Attempt A — Breaker | Attempt B — Witness | Attempt C — Mechanist |
|---|---|---|---|
| Featured offices | Sootworks → Ashmarket → Quiet Barracks | Flood Basilica → Glass Orchard → Ashmarket | Glass Orchard → Sootworks → Flood Basilica |
| Optional offices | Glass Orchard, Flood Basilica | Sootworks, Quiet Barracks | Ashmarket, Quiet Barracks |
| Custodian | Voss | Edda | Latch |
| Lung action | Fight contested escort | Negotiate stamped claim | Technical diversion with recorded cost |
| Writs | Assault, registry after keeper death, evidence stand-down | Lay council, Orchard experiment, buyer coalition | Lab test, safe-strike sabotage, choir-signal bypass |
| Hearing | Public loaner Rootkin, Brace/Attune | Voluntary Cindermoth, Observe/Attune | Loaner Rootkin after failed voluntary offer; retry |
| NPC arcs offered | Kest, Brin, Perrin | Ossa, Iona, Venn | Sela, Brin, Pale Ledger |
| Mods | Crowd Brake, Chain of Wages only if earned | Witness Seal | Mercy Brake, Saint's Wick |
| Featured room hazards | Industrial hot exhaust, machine-gun lane | Flooding, fragile glass, debtor stanchions | Unstable seed bed, furnace steam, signal interferer |
| Ending | Crown: Voss contained, no false kill | Liberation: rails open, ration cost tallied | True Dawn: survey + seed + cipher, public mandate and limited transition |

These configurations are **design illustrations**, not claims that these exact runs have been executed in Godot. Each core Writ route is independent; any failed civic check returns a named assault/registry route. The three restoration item clues are reachable even when a corresponding district is optional.



## 11. Art direction, material grammar and asset criteria

### Original visual grammar — the Pressure Docket style

- **Render budget:** native 320×200 virtual image, crisp nearest-neighbour pixel edges. Directional sprites use eight facing directions as applicable, aligned foot baselines and 4–8 purposeful animation frames for each locomotion cycle. Don't rescale bodies from frame to frame.
- **Visual hierarchy:** silhouette → role → interaction marker → light → material → ornament. The object must identify itself with its texture temporarily removed.
- **Core materials:** carbon steel, ceramic pressure plates, maintenance linen, pressed paperwork, layered safety glass and enamel. Copper occurs where conductors or analogue records justify it; brass occurs where precise bearings and fittings justify it. Wax, bone, blood and exposed tubing are *rare accents*, never the universal style.
- **Civic ornament:** rectangular file-card recesses, corner-punched records, height and pressure marks, service-window slots, stamped consent fields. This is not a borrowed American mid-century advertising world or an underwater Art Deco utopia.
- **HUD:** left pressure bellows with a breathable-air indicator; centre-left gear strain; lower inventory docket; right civic credentials and current evidence tabs. No central male face portrait, copied shotgun status digits, elemental badge set or four-cell Pokémon command frame.

### Sixteen weapons — revised readable first-person silhouettes

| Name | Updated silhouette and close-up appearance | Operational history and animation | Forbidden visual shortcut |
|---|---|---|---|
| Covenant Pistol | Flat-sided short service pistol with a squared witness counter in front of the grip, pearl-grey maintenance key and matte charcoal slide; a narrow white tab advances with each shot | Office enforcement pistol; low-offset muzzle and a visible mechanical counter reset | Do not copy familiar video-game revolver cylinder and heroic centre-screen hand pose |
| Coil Shotgun | Compressed rectangular shutter-breaching tool, twin parallel conductor bars above an inset ceramic block, gunwale-shaped lower handgrip, no exposed ribs | Started as a remote pressure-door opener; two-part recoil, ceramic cooling plate flashes | No copied DOOM shotgun barrel proportions or reload frames |
| Nail Storm | Asymmetric industrial riveter, feed-box to the right, three square service apertures in a stepped profile, hinged recoil cage | Housing assembler adapted for suppression; piston travels visibly, spent belt drops into collection pan | No generic rotary minigun barrel crown |
| Saw Lance | Telescoping iron miner's pole carrying **two alternating reciprocating shear jaws**, visible tooth plates and a black pressure clutch; wide, flattened blade face | Sever foundation bolts; charged chop closes opposite jaw halves in two deliberate phases | **No exposed chainsaw chain** and no DOOM chainsaw grip or sound |
| Volt Rifle | Offset tripod-like insulator spine and two capped electrodes around a sealed glass vacuum module; navy enamel | Stop faulty memory pumps without destroying pumps; visible capacitor needle and staged discharge | No lightning-gun ornament copying |
| Bone Mortar | Short ceramic waste-reclamation drum on a back-braced loading cradle; front is a simple pressure-sealed rectangular muzzle, with bone material visible **inside sealed pods only** | Waste recycler's compressed-pod breaker | No vertebral cannon shell or gaping jaw silhouette |
| Censer Flamer | Squat treatment fogger with accordion fuel bellows below an oval grille, intact service label and replaceable mesh cartridge | Basilica disinfectant machine used for crowd clearing; fuel pulses show without fantasy flames | No torch-like demon-headed nozzle |
| Harpoon Injector | Long narrow medical extraction frame, side-mounted rounded pressure cylinder and forked padded catch plate | Redirect biological machinery; sliding extraction rod visibly retracts after each use | No skeleton harpoon or generic spear-gun pirate motifs |
| Hush Carbine | Quiet square-body archival signal projector with slotted paper tape track and low conical mouth | Former crowd-control transmitter; cassette wheel turns one measured increment per attack | No copied space-marine rifle housing |
| Cinder Launcher | Industrial hot-ash ejector: oblong hopper beneath a shielded pressure tube, angled heat guard, white numbered canister sockets | Prevent uncontrolled furnace slag; vent purge before charged shot | No shoulder rocket tube silhouette matching DOOM |
| Widow's Toll | Compact split-bell transducer worn on a side brace, dark perforated acoustic dish, porcelain child's shoe tied as a private keepsake | Iona's mourning signal turned into a precise focused shock | No generic oversized revolver or gratuitous children-in-danger icon |
| Surgeon's Mercy | Flat white auto-suture handle, needle-guided nose, restrained teal metering strip and one spare vial under the thumb | Sela's independent surgical controller; careful two-step priming | No fantasy healer gun syringe forest |
| Penance Fang | Reversible dented trench shears with a blunt-back rescue jaw, strapped to a folded military service rail | Kest's confiscated workplace tool; snapping shear and recoil, not chainsaw spin | No heavy demon-sword visual or blood-soaked hero blade |
| Debt Collector's Smile | Narrow thermal-paper accountability device with offset projector muzzle, internal receipt strip and one black ceramic punch key | Penal debt register made into a weapon; ejects a narrow paper ledger after finishing a quota | No obvious grinning face/logo as entire silhouette |
| Choirbreaker | Boxy acoustic cancellation frame using staggered rectangular waveguide ducts and one heavy fabric-wrapped handle | Ossa removes coercive hymn control; waveform shutters sweep left to right | No organ-pipe shotgun or BioShock-style ornate antique firearm |
| Ferryman's Hook | Offset short tow-hook projector with wound linen line drum and a forward catch plate, nickel water seals | Perrin's salvage/rail attachment unit; line spools back with visible friction | No ghostly hook chains or harpoon-pirate visual |

### Eight armour sets — clear silhouettes by labour rather than generic “armour level”

| Set | At-screen identifying shape | Materials and institutional source |
|---|---|---|
| Hearthkeeper Rags | Folded linen collar, large filter apron front, plain gaiters | Cooperative ward upholstery and replaced breathing masks |
| Brass Union Rig | Angled shoulder splash guards, low welding visor, two asymmetrical tool hooks | Factory protective welding gear with privately repaired seams |
| Broker's Mourning Suit | Tall narrow black coat with stiff inverted ledger pockets | Durable, clean commercial cloth, restrained silver buttons |
| Last Lamp Vestments | Broad cylindrical acoustic collar and hanging sound-damping strips | Textured civic signal fabric, enamel fittings, no saintly halo repetition |
| Glass Pruner Coat | Wide horticultural sleeves, reinforced triangular glass-front shroud | Oil-resistant coated linen and intact pale greenhouse film |
| Last Office Plate | Dense square chest plate, high casualty-card compartment, plain shock helmet | Ceramic-and-steel public-defence standard, not space-marine armour |
| Reprint Shroud | Slightly mismatched joined panels and numbered seam tabs | Salvaged fabric and inspection markers making successive repair visible |
| Architect's Burden | Broad back brace with calibrated ruler slots, weighted hip stays | A walking measuring frame, not a heroic exosuit |

**NPC-only gear:** Recall Plate carries Kest's contested casualty register, Salt-Sewn Hood is made of acoustic wet-proof cloth not human skin, Salt Pilgrim Greaves are railway ballast protection. Use legible differences in silhouette before ornate markings.

### Consumable and quest-item visual changes

- **Cinder Lung:** twin sealed bellows and translucent correction cassette with a permanent competing-ward claim tag. It requires **electricity plus independently sourced correction patterns**; it does not burn memories as chemical energy.
- **Containment Staple:** industrial override pin with visible consent-warning tab and a removable cut-wire release. Do not make it a spherical capture device or imply ownership is obtained by winning.
- **Truce Wafer:** flat folded service agreement with a pressed edible nutrient layer; offered to a creature by a visible hand; never an auto-capture item.
- **Echo Feed:** coarse grey nutrient sachet with water instructions and a municipal imprint; ordinary agricultural consumable rather than fantasy candy.
- **Archive Solvent:** flat green reagent bottle, graded nozzle and safety text. Its purpose is physical document restoration, not a magical key.
- **Spare Fuse / Transit Chit / Deep Heat Survey:** everyday industrial silhouettes—ceramic plug, punched travel permit and folded field map. These are vital world-identity anchors; don't make every pickup grotesque.
- **Writs:** five differently notched heavy office records with embossed roles, not shield-shaped gym badges. Their placement is in public registries, safes and archives, not ceremonial arenas.
- **Namesake Locket / Fare Token / Unwritten Page:** each should retain the wear of its owner rather than become a glowing generic rarity token.


### Area palettes, citizen silhouettes and creature read at 320×200

### 1. Non-negotiable visual hierarchy

1. **Silhouette** readable at in-game scale.
2. **Functional action** readable in three frames or fewer for simple attacks; more frames for major tells.
3. **High-contrast value separation** for targets and interactables.
4. **Material identity** for each district.
5. **Reserved accent colour** to mark faction, hazard, loot and tactical state.
6. **Texture and ornament** only after the above pass.

Base design target: integer-scaled **320×200 virtual canvas**, approximately 320×150 action view plus optional 50-pixel HUD. Rendering should support correct aspect adjustment and modern screen sizes without blurring sprites. These dimensions are an internal style target, not a claim about a chosen engine or hardware. Never use a modern soft-focus filter as a substitute for drawn pixels. Use nearest-neighbour for authored sprites and inspect at both 1× and typical display scale.

A curated index of **no more than 256 on-screen colours** is the production target. A shared master palette reserves black/grey, cream, olive, oxidised copper and warning red, with regional ramps. A project may keep richer source files for editing but must test palettised exports. Do **not** use any commercial game's palette or sprite imagery as distributable game assets; author the palette and graphics independently.

#### Suggested master swatches (original target values)

| Role | Hex | Use |
|---|---|---|
| Deep black | `#171918` | Shadow, enemy outline; not pure universal black |
| Cold iron | `#424A48` | Structural equipment, public doors |
| Service grey | `#68706C` | Workspaces, machine housings |
| Bone chalk | `#C8C7AE` | Inscriptions and institutional enamel |
| Stale paper | `#E1D1A6` | Journals, cards, wood and canvas highlights |
| Copper shadow | `#6F4A36` | Electrical joints, rivets |
| Amber maintenance | `#C28A43` | Service lamps, heat and alerts |
| Chartreuse lamp | `#86956A` | Cultivation and signal fluorescence |
| Oxide teal | `#407D7F` | Unstable systems and evidence spots |
| Warning vermilion | `#A94D3B` | Hazard, hot machinery, legal refusal |
| Bruised mauve | `#716076` | Memory residue, Echoform cognition |
| Hospital blue | `#718D9A` | Filter controls and care infrastructure |

These are starting palette roles; final exact indexed ramps require sprite tests. Text must maintain adequate contrast independent of fictional lighting. Local palettes should not apply a single muddy filter to every object.

### 2. Space-specific visual hierarchy

| Space | Structural shapes | Main materials / palette | Lighting and signage | Life in the space | Density |
|---|---|---|---|---|---|
| **Hearth Nine** | Low arches, repair flanges, compact niches | Washed canvas, white-painted pipe, pale blue enamel, grey-green filters | Warm clinical lamps with sickly amber backup; hand-written ward cards | Soup tins, stitched spare masks, repaired children's toys | Low; a trustworthy base between runs |
| **Ashmarket** | Narrow counters, interlocking shutters, suspended tally boards | Charcoal shop iron, faded wine cloth, dirty ivory paper | Hard overhead spotlights; stamped numeric auction signage | Cooking pots, unrelated gossip, customers comparing old furniture | Medium, locally crowded |
| **Sootworks** | Tall rectangular furnace bays and moving horizontal conveyors | Ash-black iron, refractory brick, burnt orange, olive workcloth | Pulsing furnace light; stencil safety numbers and worn warning stripes | Tools, meal benches, makeshift herb planters | High motion, disciplined details |
| **Glass Orchard** | Ribbed glasshouses and trellis triangles | Condensation glass, chalk white root trays, green-grey organic fibres | Diffuse sunlight and small coloured grow-lamps; hand-lettered specimen tags | Pruning tables, seed tins, clean well-kept plots | Moderate with quiet pauses |
| **Flood Basilica** | Narrow vertical bells, long aisles, lower waterlines | Porous limestone, dark green copper, wet oak, pale votive ceramics | Blue-green reflected light; engraved liturgical texts with repaired machine labels | Book-drying racks, benches, tiny recipes among offerings | Low-to-medium, monumental only in main nave |
| **Quiet Barracks** | Square firing slots, right-angle grids, barracks quadrangles | Olive ceramic, dull pewter, dark blue uniforms | Directed white security beams; service numbers and replaced nameplates | Half-played games, photographs tucked into gloves | Medium, rigid alignment |
| **Engine Infrastructure** | Repeated pressure rings, axial conduits, thick service ladders | Aged enamel, heat-scored copper, red-brown insulation | Nine diagnostic pulses and practical access labels | Inscribed repairs and successive overrides | Sparse in key revelation chambers |
| **Emergency Railway** | Long parallel vanishing lines, narrow enclosed platforms | Peeling yellow paint, black rail steel, pale timetable tiles | Low independent battery lamps, crossed-out capacity numbers | Luggage scales, blankets, carriage seating charts | Open longitudinal sightlines |
| **Custodian Chamber — Edda** | Heating manifolds, triage cubicles, weighted chart stands | Blue-white enamel with warm amber ward panels | Life-monitor glow, audible valve strikes | Patient blankets and maintenance notes | Clinical geometry over ornament |
| **Custodian Chamber — Voss** | Trenchlike defensive layers, map tables, transverse barricades | Slate military steel, olive ceramic, worn chalk | Focused sightline lighting and route arrows | Filled ration tins, casualty map | Strong tactical lines |
| **Custodian Chamber — Latch** | Concentric counting platforms, modular numerals, transparent columns | Silver-grey machine metal, cream paper strips, violet memory-circuit recesses | Literal data panels; danger marked by missing values | Printed error corrections, rejected appeals | Visual order with one conspicuous omission |

**Rule:** Not all ornament is evidence of wickedness. Use Art Deco-inspired geometries in selected civic spaces, but keep public utility rooms efficient and built to a coherent local era. Avoid direct resemblance to Rapture or Vault-Tec, familiar occult runes or established franchise symbols.

### 3. Character silhouettes, costumes and materials

A character should be recognisable in a tiny thumbnail as a **job first, faction second, individual third**. Set a reference height ladder: civilian 100%, soldier 110%, heavy reprint 135%, Echoform 40–180% by species. When a character is meant to be the same person across views, maintain neck height, shoulders, costume seam and footwear consistently. Facial asymmetry and a prop are not substitutes for body identity.

| Character | Thumbnail identity | Main materials | Prohibited drift |
|---|---|---|---|
| Nix | No wandering hologram body: single copper receiver and protected analogue spool | Wire, paper index, black bakelite | Glowing digital ghost girl |
| Oren | One shoulder slightly higher, substantial repaired forearm | Olive work jacket, iron door key ring | Generic heavily-armoured supersoldier |
| Sela Vale | Loose clinic sleeves, thin surgical apron, one hand faintly tethered | Blue-grey cloth, removable surgical filaments | Full-body robotic surgeon |
| Iona Pell | Narrow bowed silhouette, single oversized vermilion rain cloak, porcelain shoe | Paper-backed cloth, ceramic, plain brass clip | Red gory robe and skull jewellery |
| Brin Harker | Short, broad, smoked goggles and asymmetric six-finger prosthesis | Canvas quilting, grease, brass mechanics | Giant steampunk gear accessories |
| Kest-07 | Tall rectangular service mask with one damaged chin edge | Olive ceramic armour, riveted ID layers | Identical space marine silhouette |
| Sister Ossa | Long neck silhouette defined by the detachable voice-box | Water-worn dark cloth, copper voice hardware | Floating saint halo at all times |
| Venn-of-Glass | Slim carrier frame and inward-opening cage held low | Glass worker gloves, pale padded coat | Anime creature trainer outfit |
| Old Perrin | Broad oilskin hood, ferryman's counting tray held horizontally | Salt-stiffened canvas, wet timber, iron fare tokens | Spectral skeleton ferryman |
| Pale Ledger | Tall paper-face mask and narrow carried account spine | Black accounting cloth, stacked paper ceramic | Faceless hooded generic reaper |
| Edda | Triage chart permanently in hand, no crown | Clinical vestments, enamel service clips | Religious demon queen |
| Voss | Rectangular command coat and small field-map board | Military weave, ceramic repairs | Generic power armour warlord |
| Latch | Static calculator-console face with unequal columns | Enamel panels, indicator lamps | Giant floating skull computer |

### 4. Creature production — one ecology, twelve species

The **Unsaid** are unstable loops of discarded memory bound to contaminated material. They repeat phrases and actions. The **Echoforms** are coherent imprinted organisms manufactured with biomass, power and a stable lattice. They may learn and refuse; do not depict them as cute elemental pets or make every creature a tooth-covered lump.

| Echoform | Silhouette and motion | Functional trait / visual cue |
|---|---|---|
| Cindermoth | Square, furnace-shield wings; small hunched core | Vent shutters flick to discharge heat; amber emission only in action frames |
| Boiler Calf | Low quadruped with an unmistakable boiler back | Pressure piston legs; steam audible before impact |
| Rootkin | Rounded shoot-body with wide root braces | Anchors to the floor to guard, not anthropomorphic leafy child |
| Cradle Wasp | Narrow segmented abdomen and cradling forelimbs | Egg-case shell as armour; approach from above visibly telegraphed |
| Mirror Jackal | Long triangular muzzle with offset glass plates | Reflects environmental glints before evasive move |
| Prism Eel | Ribbon body with three distinct refractive fins | Electrical flare travels along body direction |
| Spool Hound | Low canine outline with reel-backed chest | Filament tail carries tension lines between joints |
| Suture Mite | Compact oval frame, two oversized forward tools | Deliberate stitching motion rather than random scuttling |
| Bell Wretch | Bell-shaped upper shell, two uneven load-bearing legs | Sound emission originates from open bell cavity |
| Hush Heron | High thin legs, folded fanlike throat | Pauses before silent disruption; distinct noncomedic silhouette |
| Name Leech | Flat C-shaped body with paper tags along underside | Tags detach as attack telegraph; no human face required |
| Grief Stag | Upright broad-shouldered cervid with tuning-frame antlers | Antlers store a pulse visibly, not arbitrary skull ornament |

Every species needs an exact sketch of plausible joints, balance and movement, an idle state, a telegraphed attack and a readable injured/recover state. Do not add eight-direction motion to a species until its single-view combat readability passes. The contained duel can use two large combat portraits with 2–6 tactical frames; FPS creatures need proper directional views if flanking is supported.


### Sprite production, original asset prompts and acceptance tests

### 6. Sprite specifications and mechanical animation budgets

**NPC/enemy full-body source:** consistent camera height at 2.5D eye level. As a planning target, use character render canvases around 96×128 pixels for average humans; taller monsters may use 128×160 pixels. Actual on-screen size depends on distance, so do not claim these as universal engine dimensions. Preserve alpha transparency, a common ground baseline, consistent pose alignment and the same body proportions in every direction.

**Directional standard:** 8 angles in 45° steps for enemies whose facing is visible; use artistically approved mirroring only for truly symmetrical designs (asymmetric gear must not reverse!). Key states: idle (minimum 2 frames), full walking cycle (at least 4 purposeful alternating footfalls, ideally 6–8 for humans), attack windup, impact, recovery, damage reaction and collapse. **Do not scale or shift the character between adjacent frames.** Export aligned bounding boxes with recorded foot anchors.

**FPS weapon sprites:** 320×200 virtual screen, 128×128 or 160×128 working area with fixed lower baseline; muzzle, hands and stock cannot jitter across frames. Prepare separate idle, equip, ready, shoot, recoil, reload, melee/secondary, muzzle flash and empty/blocked states. Compare silhouettes at real screen size. Recoil is a controlled movement with a return to the identical idle anchor.

**Tactical Echoform sprites:** Large left/right portraits or opposed sprites within the same palette. The four moves are 'strike', 'resonate', 'guard', 'listen'. Each requires a distinguishable visual cue. Never imply turn counts are a supernatural time-stop: the ring uses mechanical shutters and the world keeps moving.

**Textures:** Author 64×64 core tiles, with 128×128 for selected feature panels if supported by engine; tile seamlessly on all intended axes. Variations should break repetition without randomized blur. Common 2.5D sector features: consistent wall height, door insets, stair-step platforms, signage overlays, clean sightlines and nearest-neighbour sampling where configured. Use original artwork only.

**HUD:** Reserve clear HP, ammunition, current Writ progress, Echoform condition, one contextual button and compact quest indicator. A paper receipt/diagnostic panel language is more original than copying DOOM's face bar or Fallout's Pip-Boy. Small text should have at least two values of contrast and avoid tiny decorative distress.

### 7. Reusable AI art-generation prompt library

#### A. NPC portrait
> Original pixel portrait of [named Vesper character], early-1990s industrial RPG production painting reduced to a hand-edited 256-colour sprite aesthetic, shoulder-up at three-quarter angle, [profession materials and two personal costume features], even readable shadow, transparent or flat neutral background, one stable light direction, candid expression suitable for conversation. Prioritise face construction and recognisable silhouette. Do not reproduce existing game characters, branding, faction symbols or UI.

#### B. Full-body turnaround
> One original [character] from Vesper, consistent costume and proportions, front/back/left/right on separate equal cells, no cropping, same height and foot baseline, work-related silhouette, 8-bit-style indexed colour ramps, balanced neutral light, authentic cloth/metal/ceramic construction. No extra props outside costume, no alternate clothing or age between views, no modern shooter model sheets.

#### C. FPS enemy sprite
> A [Echoform species] built from [identified functioning anatomy] with [specified joints], one strong readable attack silhouette, front-facing pixel sprite, 96×128 source, transparent background, level lighting, controlled noise, original 1990s sprite-game sensibility. Include idle, windup and impact references as separate clear frames. Avoid generic demons, teeth everywhere, neon glows and copied monster body plans.

#### D. Eight-way creature sheet
> Same original [species] model, eight exact viewpoints 45° apart, unchanged proportions/colour/pattern/props, neutral steady illumination, isolated consistent ground anchor, every cell equal, side views with clear readable limbs and no flipped asymmetry, render with colour control for conversion to a bespoke 256-colour palette. No cropped wings or duplicated front views.

#### E. First-person weapon
> Original Vesper [weapon] with visible [manufactured mechanism], 320×200 game presentation, weapon held in same lower-screen position, front-quarter first-person perspective, authoritative industrial weight, usable grip and reload access, authentic blocky indexed pixel finish, transparent background, design supports idle/firing/reload alignment. Avoid modern military attachments and unrelated bio-ornament.

#### F. Tileable wall texture
> Seamless 64×64 pixel-game wall texture for [district] made of [specified material], straight photographed-looking surface translated into deliberate pixel clusters, aligned grime at joints, no shadows cast by fictional objects, tile edges match, restricted project colour ramps, no lettering or strong repeating emblems.

#### G. Architecture keyframe
> Original Vesper [district] interior, 2.5D corridor scale, [district shapes, material palette, safety signage], functional lighting and explicit sightlines, a lived-in ordinary detail adjacent to one troubling institutionally justified detail, blocky pixel art with restrained grand geometry, no filmic bokeh, no famous game room layout.

#### H. Consumable pickup and inventory icon
> Original functional [item], manufactured [context] and [materials], one identifiable use mechanism, isolated pickup sprite plus simplified 32×32 inventory glyph in the same indexed-palette pixel language, no text embedded in the graphic, silhouette clear against light and dark HUD panels, no copied logos.

#### I. HUD panel
> Original industrial civic record-keeping HUD, narrow 320×50 lower strip, clear HP/ammunition/Writs/Echoform readouts with readable hierarchies, enamel and paper composite with minimal ornament, pixel UI, distinct action affordances, no imitation of DOOM face/status bar or Pip-Boy screen.

#### J. In-world illustration
> One institutional image for Vesper: [safety handbook / missing passenger poster / corrected ledger], made by a specific government office with known purpose and limited knowledge, physically plausible printing and wear, restrained original geometric motifs, accurate invented terminology. No existing trademarks, slogan copying or decorative nonsense glyphs.

#### Negative constraints applicable to all

No character, monster, prop, logo, texture, gun silhouette or map layout copied from an established game. No oversmoothed pixel effect, AI paint-smearing, indecipherable tiny lettering, inconsistent perspective, accessory mutation across frames, off-grid feet, clipped outlines, random gore, universal brass coating, excessive biological tentacles, stock photorealism, modern tactical cosmetics or uniform green-brown colour grading.

### 8. Asset review and acceptance checklist

- [ ] Original silhouette compared against franchise references for excessive resemblance.
- [ ] Recognisable at intended actual gameplay scale, not only in 2048-pixel render.
- [ ] Pixel clusters deliberately cleaned; indexed ramps do not create stray colours.
- [ ] Feet/weapon baseline stable across all animation frames.
- [ ] Human walk cycle moves alternating legs and returns to standing, without shuffle frames.
- [ ] Camera, facing and lighting agree across directional views.
- [ ] Necessary functional mechanism visible on weapons and equipment.
- [ ] High-value interactive object visually distinguishable from set dressing.
- [ ] Creature origin and biological construction traceable to canon.
- [ ] Each district's palette and shapes distinguish it from other districts.
- [ ] Signage text uses Vesper's original terminology and is legible.
- [ ] Tested alongside active HUD, projectiles, pickups and enemy overlap.
- [ ] Original source frames and palette retained for corrections; never ship existing IP assets.

### 9. Visual implementation roadmap

**P0:** Hearth Nine architecture, three standard NPCs, Covenant Pistol/Coil Shotgun, one Unsaid, one Echoform and complete HUD prototype. Establish size, frame and colour conventions.

**P1:** Sootworks and Flood Basilica with physically different geometry/lighting; Ossa/Brin full-turnaround and complete walk cycles; four arms and two armour families.

**P2:** One fully animated contained Echoform battle and a second enemy; evaluate animation budgets and UI readability before all twelve species.

**P3:** Full regional art kit, additional weapons/armour, environmental narrative panels and differentiated Custodian arenas after actual playtesting.

**Visual precedence:** V5 Pressure Docket overrides any conflicting earlier “legacy” weapon pose, creature battle UI or catalogue description. Art prompts specify source requirements; no sprites or animation files have actually been produced. All visual outputs require separate original-art and licensing review.



## 12. Audio and music direction — new implementable proposal, not approved canon

**Goal:** an independently composed industrial sound identity communicating the physical systems and the people running them, without copying commercial soundtrack, samples or signature effects. Sound establishes whether a pressure valve, correction bank, human plea or Echoform trial is active.

| Environment | Ambient beds | Foreground events and mixing priority | Music intention |
|---|---|---|---|
| Hearth Nine | Cloth movement, filter motor, shallow breaths, pots and distant conversation | Low-air alarm has highest local attention; no continuous alarm when stable | Sparse reed, low pulse, nearly silent during clinic decisions |
| Ashmarket | Paper shutters, tally clicks, footsteps, transaction calls | Counter stamps and whispered names audible near offices | Uneven repetitive mechanical rhythm |
| Sootworks | Press cycles, conveyor friction, furnace draft | Turret spin and shear tell must cut through machinery | Percussive alternating work strokes |
| Glass Orchard | Wet glass taps, root pumps, garden tools | Growth-lattice failures chirp with distinctive nonhuman register | Thin sustained partial tones |
| Flood Basilica | Water echo, page handling, pipe/organ mechanics | Coercive signal must be detectable apart from real congregational song | Acoustic interval clusters, not copied liturgy |
| Quiet Barracks | Boot scuffs, radio clicks, ventilation hum | Sentry charge and perimeter gate cue localised to direction | Restrained clocked pulses |
| Engine / rail | Repetitive nine-cycle valves, independent battery hiss | Charter lock, rail gates and ending-specific machine action unmistakeable | Motifs resolve or interrupt based on selected ending |

**Implementation:** separate music, dialogue, weapons, enemy, ambient, UI and accessibility buses; dynamic-range modes; subtitles for every speech and narratively important sound, speaker identification and nonaudio cues for positional threats. Each weapon requires distinct shot, cycling/reload, empty, impact and recovery recordings (original or licensed); each enemy attack telegraph needs audio cue unique enough to distinguish it at 320×200. Hearing commands produce non-musical short cues, including visible equivalent indicators.

**Provisional acceptance:** no peak clipping, no important speech masked by effects at defaults, no unlabelled audio-only mandatory puzzle, subtitle tests with sound muted, stereo/mono compatibility and listener positional coverage. Final LUFS, latency and voice-cast budgets are OPEN until the audio implementation and hardware target exist. No actual audio asset has been created here.



## 13. UX, interfaces, tutorials and accessibility — build contract

The in-world identity is the **Pressure Docket**: staggered filing cards, pressure gauges, signed paper decisions, square service-window layouts and a narrow asymmetric combat status bar. Do not emulate DOOM's face HUD or a Pokémon four-cell command screen.

| Screen | Must expose | Must never hide | Proposed input/readability |
|---|---|---|---|
| Combat HUD | HP, personal Breath, two ready weapon slots, ammo, status, interaction cue | Lethal hazard tell and remaining ammo | Minimal 320×200 footprint; 1 action to swap |
| Docket journal | Main goals, three unique Writs, Echoform trial, rail/evidence and known final prerequisites | Objective that is optional vs mandatory; discovered vs rumoured | Accessible from Tab, mouse and controller; clear completed/blocked labels |
| Dialogue | Exact deterministic stat/evidence threshold, optional costs, allowed cancellation | Named consequences Ninth knows; witnessed facts vs speculation | Keyboard focus and scroll; no real-time interruption except marked crisis |
| Inventory | Slot occupancy, ammunition caps, source/origin, consumable charges, comparison | Non-tradable evidence; drop/pickup safety | Visual+text comparison; safe-station swaps |
| Creature hearing | One active participant, trust/willingness, field condition, integrity/strain, all five commands | Withdraw and public-loaner retry | Docket strip, icon+label, no ownership trophy |
| Relationships | Office trust -3..+3, witnessed evidence, character stage and fate | Unknown NPC information | Avoid a universal morality meter |
| Run record | Actual failed attempts, factual Nix recordings, meta blueprint *offers* | Terminal ending seals and campaign independence | Distinguish New Game, retry, abandon, completed |
| Ending vote | Charter quorum, proof requirements, public mandate, rail seats, civic consequences | Hidden random roll changing story ending | Explicit player choice and confirmation |

**Onboarding proposal (first 6–10 minutes):** a safe walk/aim and basic pistol target in Hearth Nine; contested air unit introduces interaction and journal evidence; an authored micro-conversation demonstrates visibly disabled skill checks with a safe fallback; a Writ chart and rail notice foreshadow the campaign. The trial must provide a public Rootkin with no account/ownership requirement. Give a single overlay cue the first time Breath reaches zero, and never suppress basic walking and fire.

**Accessibility:** remappable controls; readable scalings with pixel-accurate gameplay and separately scalable text; high-contrast interactables, colourblind-safe patterns; reduced flashing and screen shake; motion/aim assistance optional; subtitles and sound indicators; readable default 4:3 and widescreen modes; difficulty modes Steady, Severe, Witness preserving story access. Test with actual devices: no claim of verified accessibility until playtest.

**Save/reload feedback:** show last committed timestamp, active attempt status and selected seed; only resume a valid atomic snapshot; never resurrect completed campaigns as an active attempt; failed writes retain the last intact save. UI promises must correspond to the real transaction status.



## 14. Technical architecture, data contracts, city resources and endings

### 7. City resources, combat consequences and the political simulation

**The five capacities are not player stats.** Use normalized integer planning units 0..100 for **Energy (E), Correction integrity (C), Biomass (B), Clean-air throughput (A), Labour/time (L)** as readable *city reserve/capacity indicators*, not physics joules or persons. Initial **provisional** state `E=72, C=62, B=64, A=54, L=58`, plus physically finite service stocks by office, named ward air-allocation shares and a list of damaged components. The separate channels remain canonical; changing E does not directly increase C. High C allows functional correction; low C increases local anomaly risk but cannot produce a scripted instant-loss of required story progress.

**Transaction form:** `{id, event_id, source, target, resource, amount, authored_reason, visible_warning, witness_scope}`; `apply_resource_action()` validates source exists, unique event ID, nonnegative remaining stock and permissible target capacity. A **repair may increase a capacity** by removing a physical bottleneck while consuming E/L/salvage; it does not create clean air from no source. Maintenance, food generation and geothermal energy require tracked sources and rates; no passive infinite regeneration. Unrecorded reductions are bugs. Values at 0 may harm support/evacuation and create hostile states but cannot delete the core, all Writ records or the public Rootkin.

| Event, unique and visible | Resource/accounting consequence | Story consequence and fallback |
|---|---|---|
| Hearth Nine wins withheld reserve Lung | move +8 air capacity/allocation to Hearth Nine, -5 to the claimant ward; -1 E and -1 C to install | named ward debt, new negotiation/repair opportunity; no miraculous created Lung |
| Pump repaired with 2 salvage, 2 L, 1 E | +5 effective A capacity (existing unused pipe headroom, capped by filter) | optional safer path and more clinic appointments |
| Destroy high-voltage distribution unit | -8 E, -2 A until repaired | opposing guard network weakens; civilians lose part of same service, warning shown |
| Preserve isolation bus during sabotage | -3 E (temporary outage) and 2 L to isolate; no correction contamination | disables one elite machine, preserves evidence and air |
| Launch coercive memory sweep | -6 C stored safe patterns and +3 Unsaid risk in local threat meter; +5 immediate administrative compliance | oppressive short-term ease and explicit later contamination |
| Conduct voluntary pattern trial | -2 C setup, +3 integrity after verified pattern lattice calibration, costs 3 L and documented willing participants | useful experimental result, never substitute for all Dawn prerequisites |
| Rescue worker cohort | -4 L during evacuation work; +4 later skilled L at a staffed rail depot, from a recorded transfer | human agency and repair access, not free printed labour |
| Burn Orchard storage | -9 B, -2 C (lost stable lattice samples) | aggressive route opens, civic research becomes slower; cipher archive copy survives |
| Maintain ward filter during Act II | -2 E, -1 C, +3 useful A throughput through normal service | makes shelter stable, no infinite harvesting allowed |
| Repair emergency rail seals | -2 E, -3 L, 2 salvage | +2 usable seats to evacuation planning, capped by existing physical rail fleet |

**Event conservation rule:** `C` refers to a measured pool of safe correction patterns/integrity, not souls or conventional electricity. Restored C must name a verified pattern source, calibration result or salvaged reserve. `B` can rise only from tagged agriculture/recycling feedstock at a counted E/L cost; `E` only from fuel/geothermal or redistribution; `A` from filtered air/pipe capacity subject to `E,C` and filter inventory; `L` from existing workers freed/transferred or scheduling, never infinite clones. All capacity changes must expose `cause` in debug log and, when directly attributable to player action, preview it in player-facing language.

**Evacuation capacity:** starts at a **provisional 24 seats** (this is an abstraction of physical places reserved for Hearth Nine, not Vesper's total population). May change through repairs ±2/4, support +/- 2, shelter losses -2 per recorded loss, and specific Perrin carriage +4. Clamp 12–40 seats per attempt; a `seats_used` ledger prevents duplicate rescues, and routes cannot report a person boarded if `rail_state` is `closed`. When the rail is a limited transition under Dawn, boarding is capped by the trial's physical safety limit and approved committee schedules. Narrative language must not describe universal evacuation when only an initial cohort survived.

**Combat collateral feedback:** major destructive actions hit tagged service objects, not random nearby furniture. Each destructible has `functional_role`, `safe_destroy_warning`, `resource_ledger_impact`, `alternate_evidence_ids`, `repair_requirements` and `NPC_witness_targets`. A destroyed recording machine removes *one* route to evidence, while the authored archive duplicate survives; a missing Witness is not conjured from a different seed. Player actions determine effects, not an abstract good/evil score. A grave action can lose trust even if it provides powerful loot. Patrol knowledge travels only via surviving radios/runners, with a distance and deadline; a guard who saw nothing cannot accuse Ninth omnisciently.

### 9. Ending logic is an explicit state machine

After `lung_installed && unique_writ_count >= 3 && hearing_passed && core_records_found && custodian_resolved`, offer **Liberation, Dominion, Crown** unconditionally. No XP, level, weapon, key NPC survival, rare loot, quest completion, optional district selection or positive moral-reputation minimum applies. For **True Dawn**, also require `survey && seed && cipher && assembly_mandate`; both energy-supply retrofit and alternative nonhuman boundary-correction lattice must exist, and public deliberation must expose risks. The public assembly cannot be bypassed using high Speech alone or forged evidence; low Speech can succeed through real coalition support or repair milestones, keeping it accessible but neither inevitable nor a guaranteed morally superior outcome.

| Ending | Infrastructure and physical change | NPC / narrative resolver constraints |
|---|---|---|
| Liberation | Active human pattern extraction stopped; correction wound allowed to collapse into withdrawal zone; emergency rails open subject to available seats | Only witnessed, alive, reachable NPCs may board; local contract outcomes persist |
| Dominion | Power and correction remain running under institutional harvest; rails closed | Short-term security/air materially improves; coercive policy persists; no train-departure epilogue |
| Crown | Custodian replaced by Ninth; Engine remains running; rails closed unless explicitly civic-authorised postscript in later approved canon | Nonviolent removal is not narrated as murder; danger is personalised authority, not merely Dominion with a new name |
| True Dawn | Deep Heat Survey powers conventional pumps, Orchard Root Seed supplies tested alternative correction patterns, Maintenance Cipher calibrates; limited **revocable trial** | Requires real mandate and physical operating cost; limited rail capacity; no perfect cure claim |

**Player choices recorded separately from seeds:** ending selection itself is an action, not a randomly drawn consequence. A saved campaign whose ending is non-null is immutable; later input raises a domain error. Ending epilogues are generated from actual `rail_state`, `npcs_alive`, `knowledge_sources`, `seats_allocated`, `resource_ledger`, `custodian_fate`, `local_quest_decisions` and credible testimony. Dead/unseen NPCs cannot give interviews or appear as helpers; an unmoved civilian is not automatically on a train. Random prose cannot invent a missing clue. The full current V5 Python asserts much of this at the narrative-state layer; the Godot port must independently validate it against physical scene and quest state.

### 10. Time, difficulty and encounter balance targets

| Segment | Normal planned time | Mechanically enforced content budget |
|---|---|---|
| Hearth Nine / Lung | 12–15 min | 1 contested allocation, 1 safe station, 1 nearby resource lane |
| Three districts | 36–48 min | 3 Writ outcomes, 6 optional short hooks, up to 3 long arcs offered |
| Engine lift and archive | 10–15 min | 2 actual independent records; one guaranteed charter copy |
| Custodian | 10–20 min | 1 three-phase confrontation OR alternate removal path |
| Final civic decision | 5–10 min | 1 policy decision, coherent epilogues |
| **Total** | **73–108 min** | No mandatory optional quest or level-grind gate |

**Difficulty modes:** `Steady` 100% enemy HP/damage; `Severe` enemy HP ×1.12, damage ×1.15, pickups identical, AI telegraph times ≥0.6s; `Witness` story access mode 80% enemy damage, +20% ammo pickup, all endings unchanged. Modes are not diegetic moral states and do not alter evidence or resource conservation. Do not gate achievements or Dawn to higher difficulty. Vertical slice targets 20–35 minutes with **Hearth Nine, Sootworks, Flood Basilica, two-Writ *slice-only* lift, Brin/Ossa, four V5-named weapons, two sets, eight supplies, one real hearing and two end cards**. The full game must still require three unique Writs. Never confuse a playable prototype with a production-complete campaign.

**Balance worked examples:** (1) Breaker Force 6, Resolve 4: HP=100+6×2+3×3=121; Reflex 3 speed 5.6 m/s. (2) Witness Force 2, Resolve 3: HP=100+6−3=103; 100+4×1=104 Breath. (3) Coil Shotgun point-blank base=8×8=64 kinetic; versus plated enforcer ×.80 ≈51, with head/weak-point ×1.35 =69 before range falloff. (4) A standard NPC contract challenge is Speech threshold 6 + documented original contract; Witness Speech 5 + an explicitly applicable approved evidence bonus +1 can qualify, while Breaker has a separate hatch/assault fallback. (5) Mod install: 3 salvage from tagged crate and two pickups → spend 3 at a staffed bench; cannot regain the same scrap by uninstalling the mod. (6) City air-valve repair: E 72→71, L 58→56, available pipe throughput A 54→59; report existing blocked line, not conjured air.

### 11. Stable data schemas and Godot ownership boundaries

**Data is authoritative; visual scenes do not invent state.** Prefer versioned Resource definitions for static recipes and scene metadata; use plain validated Dictionaries or typed serialisable records for run state. Proposed folder boundary:

```
res://data/defs/{weapons,mods,armour,consumables,perks,rooms,quests,creatures}/
res://systems/{run_manager,world_planner,map_assembler,character,inventory,combat,
               civic_resources,quest_state,dialogue,evidence,hearing,ending,save_codec}.gd
res://scenes/{hearth_nine,ashmarket,sootworks,glass_orchard,flood_basilica,
               quiet_barracks,engine_core}/
res://ui/{pressure_docket,loadout,dialogue,hearing,run_record}/
user://profiles/profile_v6.json
user://profiles/active_attempt_v6.json
```

| System | Authoritative inputs | Owned run-state fields | Outputs/events | Save, failure and required acceptance |
|---|---|---|---|---|
| CharacterProgression | build, chosen stats, unique challenge IDs | 6 attrs, XP, level, perk IDs, respec count | `level_changed`, `perk_chosen`, check context | Valid 18 creation total, level cap 7, every XP ID once |
| InventoryEquipment | item definitions, pickups, vendors, action ID | unique instances, slots, ammo, vouchers, salvage, vendor stocks | `equipped`, `consumed`, `sold` | No duplicate rewards, overcap to safe locker, no Writ sales |
| CombatDirector | stats, weapons, enemy components | HP/Breath, animations, alert, spent ammo, enemy IDs | `damage_dealt`, `staggered`, `machine_damaged` | Exact once ammo deduction and tagged collateral |
| QuestState | WorldPlan, evidence, actor life, actual choices | arcs' 0–4 stage and fate, short-quest state, Writ registry | `quest_changed`, `writ_recorded` | Actor death fallback, no unseen testimony, no duplicate quest completion |
| CivicResourceLedger | service stock, E/C/B/A/L capacities, event ID | five resources + source ledger + ward air allotments | `resource_transferred`, `service_lost` | No unexplained gain; source paid, no negative stock |
| WorldPlanner | seed, fixed V5 fact tables, unlock-filtered offers | featured 3, optional 2, three arcs, six local hooks, Custodian, hearing, dossier slots | immutable `WorldPlan` | Critical path and all endings' prerequisites placed |
| MapAssembler | WorldPlan, module metadata, layout RNG | MapPlan placements, validated sockets/doors/nav | `map_validated`, `map_fallback` | No intersections, forward/backward reachability; retry 8 then authored fallback |
| RunManager | profile record, create/fail/finish action | attempt ID, death provenance, status, event log | `attempt_failed`, `attempt_completed`, `new_campaign` | Death resets exact attempt state, completed endings immutable |
| MetaProfile | committed failure or terminal record | blueprint set, codex, cosmetics, challenge settings, true death archive | `blueprint_discovered`, `codex_updated` | No permanent combat multipliers, no fake Nix memory |
| EchoformHearing | field ID, cooperation, commands | one active, trust, 31 integrity/46 strain, transcript | `command_resolved`, `withdrawn`, `hearing_passed` | Unlimited public loaner retry, five commands only |
| EndingResolver | confirmed canonical events | eligible endings, rail state, civic mandate and passengers | `ending_chosen`, `epilogue_created` | All three unconditional endings; Dawn conditional and physical constraints |
| SaveCodec | all systems' snapshot APIs | schema/seed/RNG/version and committed event count | `saved`, `loaded`, `migrated` | Atomic save, reload equality, no reward replay |

**Recommended event schema (JSON-style pseudodata):**

```json
{
  "schema": 6,
  "attempt_id": "attempt-000124",
  "world_plan": {"seed": 142, "generation_version": 6, "featured": ["Sootworks","Ashmarket","Quiet Barracks"], "custodian": "voss"},
  "rng_states": {"story": 123, "layout": 456, "loot": 789, "combat": 1011},
  "event": {"id": "ev-0017", "kind": "writ_transfer", "district_id": "Sootworks", "method": "registry", "witness_ids": ["public_registry"], "resource_cost": [{"resource":"L", "from":"sootworks_maintenance", "amount":2}]},
  "character": {"build":"Breaker", "attributes":{"Force":6,"Reflex":3,"Insight":2,"Speech":1,"Tech":2,"Resolve":4}, "xp": 470, "level":4, "perks":["F1","R1"]},
  "inventory": {"ready_ranged": ["wp_covenant_01", "wp_coil_01"], "melee":"wp_saw_01", "unique_instances": ["wp_covenant_01","wp_coil_01","wp_saw_01"]},
  "arc_state": {"Brin Harker": {"stage":2,"alive":true,"evidence_ids":["payroll_cylinder"],"decision":null}},
  "hearing": {"active":"Rootkin", "accord":"loaner", "passed":true},
  "ending": null
}
```

**Godot implementation notes:** Use signals for events, not for separate sources of truth. `RunManager` owns the attempt transaction queue; `QuestState` consumes recorded evidence events; `NarrativeRenderer` is read-only. Use deterministic `RandomNumberGenerator` streams with saved seed+state; do not count on a specified PRNG implementation staying unchanged across engine versions. For saves, define a validated schema plus migration tests; `FileAccess` serialises explicit `Vector3`/`Transform3D` fields as plain arrays. `WorldPlan` is stable after generation, while `Campaign` is mutable through player input. Keep V5 Python in a separate reference folder; compare the same preconditions against a subset of manually mirrored Godot state transitions, then validate the actual scene implementation separately.

**Engine source verification:** Seeded Godot `RandomNumberGenerator` supports reproducible streams but must save both seed and current state for suspended runs; save systems must serialise arbitrary gameplay objects with explicit schema; pathfinding on a NavigationMesh does not by itself verify the physical collision geometry. Engine integration should independently test actual Ninth-sized hull clearance, even after logical graph validation.

Official references: https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html ; https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html ; https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationmeshes.html .



## 15. Production milestones, scope and handover

# THE NINTH EXHALE — V6 GODOT ENGINE IMPLEMENTATION HANDOVER

**For the next implementation agent.** Read `ninth_exhale_game_bible_v6.md` first (all V5 history, story, NPC arcs, visual standards, weapons, armour, consumables and V6 mechanics are consolidated), then `ninth_exhale_v6_rpg_roguelite_systems.md` for exact numbers/data contracts, `ninth_exhale_v6_gap_resolution_report.md` for traceability and `ninth_exhale_v6_test_plan.md` for mandatory tests. Keep `historical_v5/` untouched. **There is no playable Godot game in this V6 package.** Do not claim one has been built.

### Immutable core rules

Ninth is the playable protagonist; the White Quiet happened 91 years earlier. The Engine uses separate **mechanical Energy** and **mnemonic Correction** channels. Five physical resources (E/C/B/A/L) are finite and cannot regenerate without source/cost. The city may rearrange only existing infrastructure. Nix knows what she actually witnessed in her analogue archive, not every event or any invented prior death. One successful run gives a final ending: later New Game campaigns are counterfactual, not canon rewinds.

The full game is Hearth Nine Lung allocation → **three distinct founding Writs** from any five offices → a **mandatory V5 Echoform field hearing** with a free, unlimited-retry Rootkin loaner → Engine archive/Custodian → Liberation/Dominion/Crown, plus True Dawn iff three separate discoveries and a genuinely approved public mandate. No high stat, rare weapon or side quest is required for the first three endings. Three featured districts, two optional still reachable, three major NPC arcs, two side hooks per featured district, one Custodian. Do not reintroduce elemental type-ring, capture-prize, creature evolution/level grind or four-command battles. The five actual commands are **Press, Attune, Brace, Observe, Withdraw**; one active participant at a time. Preserve all V5 equipment names and original sprite-era art direction.

### Read this change carefully

V5 Python `BUILDS` has only four prototype stats. The gameplay uses six, with **18 starting points** and four V6 presets. The prototype's scene/story generator is still authoritative about existing *narrative state transitions* where V6 has not explicitly changed them, but its numbers are not the playable Godot character build model. V6 numerical weapon, economy and perk stats are provisional and need playtesting. V5 appendix lists three Echoforms in a portable case; that is three registered accords, **not a three-creature hearing**. Saw Lance is an opposed reciprocating shear, not a chain saw; **Grinder Crown** is an abrasive collar retaining the mod and benefit.

### Recommended engineering order — stop at verified gates

1. **G0 Data foundation:** Godot project import, typed Resource definitions and stable IDs for all 16 weapons, 20 standard mods, 8 armour sets, 23 consumables, 12 Echoforms, 20 quest hooks, 8 NPC arcs; load V5 story reference data without changing it. Implement six-attribute `CharacterProgression`, `RunManager`, source-backed `CivicResourceLedger`, unique-event XP and versioned save snapshot. Run the Python reference suite.
2. **G1 Movement and gunplay:** one Hearth Nine room and one short Sootworks lane; first-person camera, 320×200-compatible render, authored walls/collision, baseline pistol firing, movement/dash, Breath/health and a simple enemy; save/load exact state.
3. **G2 Meaningful quest:** install contested Cinder Lung with real fight, bargain, steal or technical approach; witness and evidence state distinguish outcomes. Add Sootworks Writ with assault + evidence-backed registry fallback, including keeper-death fallback. One safe service station and simple voucher/salvage stock.
4. **G3 Dialogue/NPC and hearing:** Brin four-beat state and Ossa at least introduction/decision; NPC death must produce no impossible later speech; build real one-active Echoform field hearing with loaner Rootkin and all five commands, withdrawal, retry, transcript, explicit consent.
5. **G4 Controlled vertical slice:** add Flood Basilica, two-Writ **slice-only** lift, Edda confrontation, two different state-dependent ending cards, original sprites and four weapons: Covenant Pistol, Coil Shotgun, Nail Storm, Choirbreaker. Include two armour sets and eight representative consumables. Target **20–35 minutes**. This slice is not the full canonical three-Writ campaign.
6. **G5 Full framework:** expand to all five districts, Quorum three-of-five, restoration dossier, all three Custodians, three optional arcs per run, procedural modular maps with collision/nav validation, persistent blueprint *offers*, actual death reconstruction, all four endings. No item/quest softlocks.
7. **G6 Balance and originality:** human 73–108-minute campaign tests, combat/economy tuning, readability, voice/style/quest inspection, legal visual/branding reviews.

### Required minimum data APIs

`WorldPlanner.create(seed,profile_unlocks) -> WorldPlan` (pure), `MapAssembler.validate(plan,modules) -> MapPlan|Failure`, `CharacterProgression.award_once(challenge_id,kind)`, `Inventory.claim(instance_id)`, `Inventory.buy(stock_id,price)`, `CivicResourceLedger.apply(event_id,typed_costs,typed_gains,source)`, `QuestState.record_witnessed(action,actor,evidence)`, `EchoformHearing.command(name)`, `EndingResolver.available(campaign)`, `RunManager.fail_with_record(death_event)`, `RunManager.finish_terminal(ending)`, `SaveCodec.commit_atomic(snapshot)`. Every call returns a validated transition or a reasoned domain error; no random choice should be made inside ending selection, inventory duplication or witness assignment.

**Serialization:** persist `version`, `WorldPlan`, `MapPlan`, per-system RNG seed/state, difficulty, player position, six attributes/XP/perks, item instance IDs and vendor stocks, NPC witness/life/arc states, quest and Writ IDs, echo hearing transcript/trust/strain, E/C/B/A/L source ledger, rail seats, actual death provenance, ending status. For JSON arrays, explicitly encode transforms/vectors. Loading after an irreversible choice must not duplicate reward; completed campaigns are immutable. Godot documents these requirements through its standard save and RNG APIs (see V6 systems references).

**First acceptance demonstration to deliver:** playable 20–35 minute Linux desktop build, offline, with a reliable launch file and README; demonstrate two different routes for Cinder Lung, two Writs in slice (while full design remains three), at least one nonviolent Writ method, at least one optional fatal NPC branch that changes a later end card, actual Rootkin loaner hearing with Withdraw and retry, and a death that genuinely creates a new WorldPlan while Nix truthfully remembers only recorded prior failures. Screenshot and real play log, not merely copied narrative output. If a feature is missing, mark it unimplemented.

**Do not invent:** new canon factions, alternate endings, protected lore dates, free biomass/correction energy, Pokémon-type rings, missing optional NPC evidence, unlimited shop restocks or permanent stat progression. Do not copy DOOM/Fallout/BioShock assets or UI. Respect the V5 Protected Originality Register and keep the human IP review open.



## 16. Validation, provisional values and unresolved decisions

### 12. Core negative tests and measurable quality gates

**Narrative and canon:** no erased terminal ending, no false death memory, no dead or unseen NPC acting in a credits scene, every Dawn prerequisite independently placed, optional quest abandonment does not block first three endings, V5 named entities remain unchanged, five hearing commands exactly, one active participant, two independent Lumen channels, no unlimited biomass.

**RPG:** 18 creation points, max 6 at start, stat cap 10, no negative derived health; valid four presets and Custom; missing dialogue evidence cannot be substituted by a bonus stat; failed check never blocks all fallback Writ methods; unique XP awards once; level never exceeds seven; perk prerequisites maintained through respec.

**Inventory/economy:** purchased/quest item instance cannot duplicate on reload, ammo cannot exceed caps, 23 consumable IDs all have finite prices/effects or explicit non-sale restriction, 16 weapons and 20 mods mapped uniquely, rare rewards respect actual NPC branch, equipped slots correct, sales cannot yield arbitrage profit, no unlimited bench repair loops.

**Procedural:** graph and physical navigation connectivity for Hearth Nine → Lung, all featured Writ records → core, hearing, all restoration sources; every traversable socket respects hull dimensions and class; no overlapping modules; failure falls back to authored, validated map; no impossible item behind optional lock; random cosmetic RNG does not change story results.

**Echoform:** unlimited loaner retries, legal withdrawal, coercion refusal and transcript, five actual commands, correct strain/integrity, genuine cooperation, opposing participant never becomes loot, old type-ring absent.

**Save/ending:** save/reload identical public state (including RNG states, scene placements, stock, action IDs); death reset and eligible blueprint persistence; empty prior-death history before actual failure; terminal end-state immutable; capacity-aware epilogue and unique boarding entries; no unresolved NPC assigned train role.

**Stage gates:** (G0) data schema + V5 baseline tests; (G1) walkable Hearth Nine with gunfire; (G2) first Writ plus one meaningful noncombat method; (G3) real hearing and Brin/Ossa quest state; (G4) two-Writ slice finale with different state-driven cards; (G5) five-district full Quorum + multi-run procedure + Dawn; (G6) balance 73–108 min on human playtests. G0 can be checked in Python; G1–G6 require Godot and people. A failed gate blocks the claim of playable completion, not the continued existence of authored canon.

### 13. Explicit open questions and test-only values

1. The exact 320×200 viewport scaling and controller tuning require real hardware testing; do not rely on screenshots alone.
2. Weapon reload sprites, enemy stagger durations, health damage and all prices are **new provisional balance targets**. Confirm with trace data from a playable build.
3. Godot collision/nav baking, area connectivity, floor modules and streaming need execution in Godot. The Python graph tests cannot substitute for an instantiated level.
4. V5 narrative `BUILDS` and numerical hearing prototype remain historical reference until a separate bridge maps the new six attributes and turn rules into Python; do not silently change tested V5 outcomes.
5. Public mandate thresholds need a final council scene and witness/repair action list in engine data; the V5 Python checks an existing mandate flag but does not simulate municipal deliberation at Godot depth.
6. The exact charter document name (Governor's Maintenance Cipher / Founders' Cipher) is retained by stable ID `cipher` without creating a fifteenth quest object; check UI language with a manual editorial pass.
7. Before publication, human review remains required for trademark searches, assets, licensed samples and sound/music originality. This specification does not claim IP clearance.

**Research and engine references used for implementation design:** Godot official documentation on deterministic RNG streams and state restoration (https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html), Godot saving-state and JSON limitations (https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html), and Godot navigation-mesh creation and the distinction between navigation and collision (https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationmeshes.html). These support engine implementation advice, not the game's original lore.

**Current validation status:** Baseline V6 rules reference and V5 narrative reference tests are executable Python demonstrations; no playable Godot scene, physical procedural layout, final enemy AI, finished sprite sheets, audio cues or human pacing/balance test is established by these files. Test logs record *what ran*, not proof of game completion. See `VALIDATION_REPORT.md`.

**Additional editorial correction for level pacing:** V6 describes 945 XP as the “typical mandatory” total but includes three 20-XP evidence clusters that may be missed on valid assault routes. The true guaranteed main-objective subtotal is **885 XP** (`140+3×165+110+140`), enough to reach level 6 (800 XP). If three evidence clusters are also found, the route earns 945 XP. The level-7 threshold (1050 XP) remains optional. This is a documentation clarification, not a rules change.

**Source language conflict to avoid:** the historical V2 creature catalogue’s four named signature moves, fixed imprint/evolution language and “type” labels do not grant player actions or damage multipliers. The current V5/V6 playable hearing has only the five shared commands and one active organism. Historical art/lore data in Appendix A is allowed only under that stated precedence.


---

# APPENDICES — CANONICAL CONTENT REFERENCE

These catalogues are part of the master bible. Where historical wording described an obsolete rule, that wording is retained only as art/lore evidence and must be interpreted under Section 9's active hearing contract and Section 11's V5 Pressure Docket visual standards. The latest quantitative mechanics remain in Sections 7–10 and 14.

## Appendix A — Eight NPC identities, four-stage quests, conditions and unique rewards



## B1. Iona Pell — THE WOMAN WHO RENTED HER DAUGHTER
**Theme:** ownership, grief and the temptation to remember a comforting lie. **Starting anchors:** Ashmarket or refugee rail platform; later Flood Basilica and Engine access concourse. **Appearance:** elderly, narrow-shouldered woman in a vermilion rain cloak stitched from legal documents; one eyelid held open by a small brass clip; carries a porcelain child's shoe tied with red thread.

1. **The receipt.** Iona asks Ninth to retrieve a deed proving her daughter's memories are being rented to five buyers. The deed is in a locked broker's box. Acquire it by `[Tech 5]` unlocking, `[Speech 5]` impersonating an auditor, or fighting the guard. She says, *'They've sold her first word to a man with no children.'*
2. **The wrong voice.** At a confession booth she finds five recordings of the same daughter. `[Insight 5]` establishes that one is an original memory, two are edits, and two are commercial forgeries. Recover the originals or accept the Collector's offer to replace them with a happy fabricated childhood.
3. **The meeting.** Iona confronts the living adult who was once her daughter. She does not recognise Iona and is frightened of her. Choose to tell them the evidence, give them time apart, force the recognition with a Resonance Bell, or sell the daughter back to the market.
4. **Aftermath.** If allowed to decide freely, the daughter may choose a cautious reunion or leave alone; Iona accepts her autonomy. If forced, the daughter becomes a hostile Memory Husk in the next section. If sold, Iona vanishes and her bell is heard in Ashmarket during future cycles. If ignored after the meeting, she departs on an uncertain journey.

**Outcomes and rewards:** patient truth → **Namesake Locket** (relic: lost-identity clues glow nearby), and Iona can escort refugees; coercion → **Widow's Toll** (sonic pistol: high stagger, inflicts Resolve strain on allied Echoforms); exploitation → **Broker's Chit** (discounted black-market services, fewer free NPC recruits); abandonment → Iona's bell can be recovered from an empty carriage, with a brief lore-only epilogue. **Narrative price:** obtaining a happy ending does not imply the daughter must consent to reunion.

## B2. Brin Harker — THE NINETY-FIRST SHIFT
**Theme:** solidarity versus personal survival. **Starting anchors:** Sootworks or Hearth Nine repair bay; later a union lockhouse and barracks freight junction. **Appearance:** short, heavily built mechanic wearing smoked goggles and a quilted canvas coat, six brass prosthetic fingers on one hand, with a pocket watch whose hands are rivets.

1. **The clock card.** Brin shows a time card with ninety-one consecutive years of attendance. `[Insight 4]` reveals the union has been charging time across reprinted bodies. Brin asks for the original payroll cylinder.
2. **The switch.** The payroll cylinder is chained to a foundry mainframe. Recover it with `[Tech 5]` or breach the furnace control room in first-person combat. Reveal that the debt was paid forty-three years earlier.
3. **The strike.** Brin proposes stopping the furnace long enough to free the workers. Choose to arm the strikers, negotiate evacuation, secretly inform the Millwright or walk away. If the player chooses to arm them but fails to disable the turret grid, many workers die; this is telegraphed by the exposed turrets before committing.
4. **The second whistle.** Brin appears at an evacuation gate, a merchant workbench, or chained to a furnace depending on the choice. Resolve a final dialogue or combat event. Brin says, *'I don't want to be the hero. I want a day that doesn't belong to anybody.'*

**Outcomes and rewards:** free the workers → **Brin's Torque** (relic: faster repairs and temporary cover panels) plus Brin's weapon-upgrade service; negotiate partial freedom → **Union Rivet Kit** (two deterministic weapon mod rerolls); betray the strike → **Chain of Wages** (Nail Storm mod: extra ammunition from marked enemies, lower Hearthkeeper approval); ignore → Brin may become **Boiler Penitent**, a tragic optional elite whose death drops **Black Shift Badge** (fire resistance, worse merchant prices).

## B3. Kest-07 — THE MAN YOU KILLED YESTERDAY
**Theme:** institutional obedience, guilt and whether a victim is entitled to vengeance. **Starting anchors:** Quiet Barracks or checkpoint convoy; later Sootworks tribunal and Engine rail. **Appearance:** tall infantryman in chipped olive ceramic plates; white enamel service mask with a cracked mouth slit; one nameplate riveted over another. His right boot leaves a red footprint, even on clean ground.

1. **The list.** Kest arrests Ninth with a warrant bearing the player's signature from a previous reconstruction. A recovered radio log proves Ninth killed Kest in an earlier run; if this is the first run, the Engine fabricated the historical signature as a coercion technique, and Nix clarifies the difference.
2. **The barracks ledger.** Find Kest's personnel record showing he was printed forty times, each iteration ordered to execute another version of himself. `[Resolve 5]` can persuade him to read the record; otherwise evade a duel and send evidence through the barracks terminal.
3. **The confession.** Kest offers to testify against the Last Office if you agree not to erase his memory of wrongdoing. Alternatively, you can delete his guilt, command him as a weapon, or fight him.
4. **The final march.** Kest returns at the Engine gates. He may protect civilians, turn against the army, assist the Custodian or challenge Ninth to a duel. He says, *'My last order was to stop being a person. I haven't obeyed it yet.'*

**Outcomes and rewards:** testify with full memory → **Recall Plate** armour set and a veteran escort; wipe memory/enslave → **Penance Fang** (motor-blade, huge bleed versus disarmed targets), but Kest loses independent agency; kill → **Reliquary Tag** (relic: see old military access points) and a hostile veterans' end card; leave → a reconstruction after an actual failed attempt may print a successor with an inexplicable scar; a completed campaign does not revert.

## B4. Sister Ossa — THE CHOIR WITH NO MOUTHS
**Theme:** faith, consent and the violence of a necessary lie. **Starting anchors:** Flood Basilica or hospital train; later Ashmarket vox dealer and submerged crypt. **Appearance:** barefoot alto in funeral-green robes, throat encircled by an external copper voice-box, face covered by a slit silk hood; a bellows moves beneath her collar when she is silent.

1. **The missing note.** Ossa asks you to recover a note omitted from the sacred hymn. Listen at three resonant locations, fight acoustic predators, and copy the missing frequency onto an analogue wafer.
2. **The audience.** She admits her choir is made of living captives. `[Speech 6]` can persuade a lay council that the hymn has been used without consent; the parishioners may retain their faith and reject the coercive apparatus. `[Insight 5]` can discover the apparatus can be muted without killing its prisoners.
3. **The last performance.** Choose to silence the choir, publicly expose it, amplify it to repel the Unsaid while sacrificing singers' memories, or seize its control panel for yourself. This decision changes the Basilica's ambient audio and combat waves.
4. **The silence.** If saved, Ossa speaks unaided for the first time; if exploited, she becomes an enormous bell-backed boss in a subsequent arena; if she dies, she leaves a hymn with one bar missing.

**Outcomes and rewards:** rescue choir → **Choirbreaker** (rare sonic rifle, can stun certain Echoforms nonlethally) and an optional safe route; maintain the machine → **Drowned Canticle** (relic: acoustic ward, increased enemy suspicion); kill/abandon → **Salt-Sewn Hood** (relic: ghost-voice clues audible, lower Speech while worn). She says, *'Silence is not an absence. Sometimes it is the first honest thing.'*

## B5. Dr Sela Vale — THE HANDS THAT HEALED EVERYONE
**Theme:** medicine, triage and the cost of good intentions. **Starting anchors:** Hearth Nine; later Glass Orchard surgical annex and Lumen clinic. **Appearance:** dark-blue surgical apron above a yellowing boiler suit, magnifying spectacles, left forearm encased in an enamel instrument brace. Her hands sometimes move a heartbeat before she decides to move them.

1. **The trembling hands.** Sela asks you to fetch a calibration spindle from the Orchard. `[Insight 5]` or a diagnostic table reveals her hands contain remote control fibres installed by the Engine.
2. **The patient list.** Her treatment records show that each cured patient has unknowingly surrendered a childhood memory. Find the records and confront her: she knew the treatment was suspect but not that the consent forms were forged.
3. **The operation.** Use `[Tech 6]` and medical supplies to sever the control fibres, accept the Engine's offer to turn Sela into an automated miracle surgeon, or publicly blame her and destroy the clinic. Combat defence protects her during surgery.
4. **The last patient.** Sela can heal refugees in the evacuation, run a compulsory-treatment facility for Dominion, or become a boss-like operating theatre under Engine control.

**Outcomes and rewards:** free her hands → **Surgeon's Mercy** (precision sidearm; weak-point hits heal an allied Echoform or nearby companion) and limited healing service; enthrone as automatic surgeon → **White Ledger** (relic: stronger healing with a memory-cost drawback); destroy the clinic → **Clean Scalpels** (crafting component and no refuge medic); leave unresolved → she survives with a visible tremor and tells Ninth she is afraid of touching anyone.

## B6. Venn-of-Glass — THE KEEPER OF SMALL MONSTERS
**Theme:** kinship, control and whether created beings count as people. **Starting anchors:** Glass Orchard or mobile Echoform caravan; later fighting pit and creature nursery. **Appearance:** wiry teenager in a cracked yellow hazmat coat, carrying a cage lined with violet felt; one side of their head shows a transparent graft containing a tiny drifting moth-shaped Echoform.

1. **The cage that opens inward.** Venn demonstrates a memory-born creature that refuses an obedience staple. Help retrieve it using a Resonance Bell, or force it into submission with a Containment Staple.
2. **The duel.** Venn challenges Ninth to a three-round tactical Echoform match, teaching four-move command selection, type advantage and status control. This arc is optional; the game's first mandatory duel has a separate guaranteed tutorial.
3. **The nursery.** Find a nursery where the Last Office converts unclaimed Echoforms into ammunition. Choose rescue, sabotage without rescue, or take the profitable conversion contract. `[Speech 5]` can persuade one of the wardens to quit.
4. **The departure.** Venn becomes a travelling creature-care vendor if trusted, a frightened prisoner if exploited, or a hostile tamer if betrayed.

**Outcomes and rewards:** rescue → **Consent Bell** (field tool: voluntary recruitment, higher loyalty and one extra negotiation prompt) plus **Cindermoth** recruitment; exploit → **Cage Clamp** (field tool: immediate capture at loyalty penalty and greater escape risk); abandon → **Broken Cocoon** (relic: detects rare creatures but reduces starting morale). Venn says, *'It comes when I call. That is different from being unable to leave.'*

## B7. Old Perrin — THE FERRYMAN WITHOUT A SHORE
**Theme:** survival arithmetic and who gets the last seat. **Starting anchors:** Flood Basilica evacuation channel, Ashmarket waterway or Sootworks slag canal. **Appearance:** skeletal old ferryman in stitched grey oilskins, face hidden beneath a waterlogged campaign hat; carries a metal oar with children's height marks engraved along the shaft.

1. **Fare for one.** Perrin operates a little boat that always returns with one fewer passenger. He asks for a brass transit token and refuses to say why.
2. **The empty seat.** Investigate the passenger manifests. The boat's pump consumes one person's final memory per crossing; Perrin has been selecting himself but his memory is almost spent.
3. **A cheaper crossing.** Find replacement pressure seals, pay the fare with your own run-specific memory (lose one temporary dialogue perk), allow a volunteer to choose knowingly, or secretly divert the cost to a stranger.
4. **The last ferry.** Perrin can attach an extra carriage to the emergency rail, vanish on his boat, or fight as the Drowned Helmsman if betrayed.

**Outcomes and rewards:** repair the boat → **Fare Token** (relic: free travel between one pair of district waypoints, +1 evacuation car); sell passengers → **Ferryman's Hook** (harpoon variant: pulls stunned enemies, costs Resolve when used against civilians); sacrifice own memory → **Salt Pilgrim Greaves** (leg armour: immune to water slowdown) and a lost piece of Ninth's remembered history; do nothing → only a drifting oar remains. Perrin says, *'The river isn't hungry. We just trained it to expect payment.'*

## B8. The Pale Ledger — A RECEIPT FROM TOMORROW
**Theme:** predestination and the corrupting comfort of knowing the future. **Starting anchors:** roaming administrative kiosk in any featured district; later archive, optional duel annex and engine approach. **Appearance:** angular figure wearing a paper-white coat, with a rolled receipt printer embedded in the jaw and carbon-copy fingers. Its hat brim contains a row of tiny clock faces each showing a different hour.

1. **A bill not yet owed.** The Ledger hands Ninth a receipt for an action they have not taken. Some details are accurate predictions drawn from the Engine, others are traps. `[Insight 6]` reveals the most improbable line is handwritten.
2. **The signature.** Obtain the ledger's carbon master through combat, `[Tech 6]` access or bargaining away a *temporary* skill point for the run. Never charge permanent progression or user account data.
3. **The prophecy.** The Ledger offers a weapon in exchange for guaranteeing one civilian's future suffering. Refuse and destroy the contract; take the bargain; or reassign the debt to the Ledger itself using `[Speech 7]` plus evidence.
4. **Tomorrow's corridor.** The same scene reappears later with visible differences caused by the player's choice. A recruited ally, modified boss phase or mercenary ambush validates what happened.

**Outcomes and rewards:** void the contract → **Unwritten Page** (relic: reveals one false objective or hostile deception per run); accept the bargain → **Debt Collector's Smile** (high-damage revolver, every fifth lethal hit adds social corruption); trick the Ledger → **Carbon Key** (consumable-free opening of one optional archive lock); abandon → the Ledger sells the prediction to the Custodian and an encounter changes. It says, *'The future is quite affordable, provided you never read the small print.'*

## B9. Dialogue example: the reward is not guaranteed to be the kindest outcome

**Iona, at the living daughter's door**

> **Iona:** 'Open it. She has my eyes, even if she doesn't remember.'  
> **Ninth:** `[Speech 6]` 'You can tell her the truth. You cannot command her to love you.'  
> **Iona:** 'Then I will have to survive hearing no.'  
> **Ninth:** `[Tech 5]` 'I can make the memories recognise each other.'  
> **Nix (radio):** 'A forced memory feels like a fact. It doesn't feel like a choice.'  
> **Ninth:** `'She's not property. I'll destroy the contract.'`  
> **Ninth:** `[Greed] 'The market still pays for an intact identity.'`

The `Speech` route supports a consensual but ambiguous reunion and grants the Namesake Locket. The `Tech` coercion wins immediate access to a stronger early Echoform but risks a late hostile reunion. The anti-slavery route destroys the contract regardless of Iona's feelings, earns faction respect and potentially costs the player's chance at the locket. The greed route supplies money and an increased bounty. Choices change *who* benefits, not merely an abstract morality value.
## Appendix B — Full authored equipment, appearance, origin and utility catalogues

# E. COMPLETE INITIAL WEAPON CATALOGUE — 16 named weapons

The first ten are the standard arsenal. The final six are uniquely tied to character and faction outcomes. The V5 appearance column supersedes incompatible original-DOOM-like sketches; original item identities, names, sources and mechanical roles are retained. Each entry specifies the sprite, gameplay identity, material history and source. Values below represent *relative* roles rather than balanced DPS numbers.

| Weapon · slot / ammunition | Detailed on-screen appearance | Mechanical identity | Lore and acquisition |
|---|---|---|---|
| **1. Covenant Pistol** · sidearm / Ledger Slugs | Flat-sided short service pistol with a squared witness counter in front of the grip, pearl-grey maintenance key and matte charcoal slide; a narrow white tab advances with each shot | Accurate reliable opening weapon; alt-fire marks an enemy's weak point, increasing follow-up ammo recovery | Issued to Last Office clerks so that an execution could be described as contract enforcement; guaranteed initial firearm |
| **2. Coil Shotgun** · heavy / Coil Shells | Compressed rectangular shutter-breaching tool, twin parallel conductor bars above an inset ceramic block, gunwale-shaped lower handgrip, no exposed ribs | Devastating close cone; perfect-timing pump fires a narrow penetrator blast; high stagger, slow reload | Salvaged from storm shutters after the White Quiet; first found in checkpoints or Sootworks |
| **3. Nail Storm** · heavy / Rivet Belts | Asymmetric industrial riveter, feed-box to the right, three square service apertures in a stepped profile, hinged recoil cage | Sustained automatic suppression; builds heat; can pin small enemies to walls and recover ammo from shattered armour | The Brass Union designed it to build housing, then used it to dismantle its masters; Sootworks stock |
| **4. Saw Lance** · melee / pressure charge | Telescoping iron miner's pole carrying **two alternating reciprocating shear jaws**, visible tooth plates and a black pressure clutch; wide, flattened blade face | Reach-melee combo, grapple-hook finisher, overheat and bleeding; recovers Breath on staggered targets | The first miners cut the Engine's foundation with these; common foundry find |
| **5. Volt Rifle** · rifle / Voltaic Cells | Offset tripod-like insulator spine and two capped electrodes around a sealed glass vacuum module; navy enamel | Mid-range precision burst; alt-fire chains through electrical enemies; interrupts machinery | Developed to restrain malfunctioning memory pumps without destroying expensive labour; barracks technicians |
| **6. Bone Mortar** · launcher / Ossuary Pods | Short ceramic waste-reclamation drum on a back-braced loading cradle; front is a simple pressure-sealed rectangular muzzle, with bone material visible **inside sealed pods only** | Slow explosive arcing shots; leaves fragments that deny territory; strong vs clustered hordes | Crafted from biomaterial reclaimed by the city's corpse recyclers; black-market dealer or rare boss |
| **7. Censer Flamer** · heavy / Censer Fuel | Squat treatment fogger with accordion fuel bellows below an oval grille, intact service label and replaceable mesh cartridge | Short-range cone, persistent Ember floor hazards; exposes stealth Echoforms, but risks burning evidence | Priests once used cleansing smoke to conceal the smell of memory harvesting; Basilica cache |
| **8. Harpoon Injector** · rifle / Harpoon Spurs | Long narrow medical extraction frame, side-mounted rounded pressure cylinder and forked padded catch plate | Pierces armour, pins mobile targets; alternate shot pulls loose objects or extracts an enemy's temporary buff | Designed for tranquilising and relocating dangerous printed organisms; Orchard surgical annex |
| **9. Hush Carbine** · rifle / Waking Tape | Quiet square-body archival signal projector with slotted paper tape track and low conical mouth | Fast low-flash sonic projectiles; disrupts Choir shields and Echoform commands; relatively low raw damage | Secret Last Office crowd-control weapon using stolen lullabies as ammunition; restricted kiosk |
| **10. Cinder Launcher** · launcher / Cinder Casks | Industrial hot-ash ejector: oblong hopper beneath a shielded pressure tube, angled heat guard, white numbered canister sockets | Area firebomb, chargeable cluster shot; destroys organic growth but damages neutral objects if careless | Emergency burn-off device converted into riot artillery; Sootworks and fallen siege crews |
| **11. Widow's Toll** · rare sidearm / Waking Tape | Compact split-bell transducer worn on a side brace, dark perforated acoustic dish, porcelain child's shoe tied as a private keepsake | High sonic stagger and grief-mark debuff; forced captures suffer loyalty strain nearby | Iona's altered mourning bell, obtained by coercive reunion or exploitation; the ringing sounds briefly like a child calling home |
| **12. Surgeon's Mercy** · rare sidearm / Ledger Slugs | Flat white auto-suture handle, needle-guided nose, restrained teal metering strip and one spare vial under the thumb | Weak-point precision shots convert a fraction of damage into healing for one nearby ally/Echoform; modest damage | Sela's surgically freed hand fitted its trigger; earned by ending her forced treatments |
| **13. Penance Fang** · rare melee / pressure charge | Reversible dented trench shears with a blunt-back rescue jaw, strapped to a folded military service rail | Heavy bleed and an armour-splitting execute; increases faction fear and reduces some nonlethal dialogue modifiers | Built from Kest-07's imposed obedience; gained by wiping his identity or forcing him into servitude |
| **14. Debt Collector's Smile** · rare sidearm / Ledger Slugs | Narrow thermal-paper accountability device with offset projector muzzle, internal receipt strip and one black ceramic punch key | Enormous close critical damage; every fifth lethal hit adds corruption that complicates civilian dealings | The Pale Ledger's predatory investment in Ninth's future; gained by signing the cruel prophecy |
| **15. Choirbreaker** · rare rifle / Waking Tape | Boxy acoustic cancellation frame using staggered rectangular waveguide ducts and one heavy fabric-wrapped handle | Focused Sonic line shot; interrupts sonic bosses and can subdue a distressed Echoform without killing it | Ossa made it by dismantling the forced choir's control bell, obtained through rescue and public exposure |
| **16. Ferryman's Hook** · rare rifle / Harpoon Spurs | Offset short tow-hook projector with wound linen line drum and a forward catch plate, nickel water seals | Hooks stunned foes across cover and pulls Ninth towards anchor points; coercive use damages Resolve in dialogue | Perrin's tool converted to an instrument of abduction, gained by selling passengers to the ferry system |

## E1. Ammunition — ten physical pickup types

| Ammunition | Appearance, origin, use |
|---|---|
| **Ledger Slugs** | Stubby black brass cartridges with a white signature strip around each base; pre-war clerks stamped legal approvals onto bullet casings; sidearms use them. |
| **Coil Shells** | Fat ivory ceramic shells with twin copper contact rails; storm-worker charges now power shotgun bursts. |
| **Rivet Belts** | Heavy linked strips of rust-red industrial nails with the old Brass Union crest stamped on the links; automatic Nail Storm feed. |
| **Pressure Cartridges** | Pale brass aerosol cylinders with a red pressure needle; used to recharge Saw Lance/Penance Fang motor assistance; basic slashes still work at zero charge. |
| **Voltaic Cells** | Blue-green translucent batteries inside black steel finger cages, warm to the touch and faintly singing; Volt Rifle power source. |
| **Ossuary Pods** | White egg-shaped bone capsules, wax-sealed and numbered on black labels; the city's recycled remains now become Bone Mortar projectiles. |
| **Censer Fuel** | Narrow copper flasks with a burning orange wick on their label; formerly sanctified disinfectant, now flamer ammunition. |
| **Harpoon Spurs** | Silver darts in a three-tine hinged rack, with long green thread trailing from each tip; supplied to the Injector and Ferryman's Hook. |
| **Waking Tape** | Tiny black cassette coils with cream paper labels listing unknown children's names; recorded memory patterns become Sonic projectiles. |
| **Cinder Casks** | Miniature thick-walled red cylinders capped with a conical steel fuse; furnace residue burns fiercely when shattered by the launcher. |

Weapon-specific rare payloads are implemented as modifiers to these ten pickup types, not extra base inventory objects.

## E2. Twenty weapon mods — two for each standard weapon

| Base weapon | Mod A — appearance / function / history | Mod B — appearance / function / history |
|---|---|---|
| Covenant Pistol | **Witness Seal:** turquoise evidence-tab on cylinder; targets marked through dialogue evidence stay revealed briefly; forged by public defenders | **Exaction Spring:** red double-coil behind hammer; higher fire cadence but harsher recoil; Last Office collections issue |
| Coil Shotgun | **Crowd Brake:** blunt square iron mouthpiece; wider stagger cone and lower range; riot-unit surplus | **Glass Choke:** translucent serrated choke; tight slug with long penetration; fabricated from Orchard mirrors |
| Nail Storm | **Chain of Wages:** black numbered feed chain; more ammunition from debt-marked enemies, harms Brass Union standing; Brin's betrayal reward | **Cradle Clamp:** pale spring-loaded bipod; reduced spread while sliding but slower swap; originally a sewing machine holder |
| Saw Lance | **Mercy Brake:** bright silver snap-off gear; nonlethal finisher against staggered humanoids, earns less Breath; Sela's innovation | **Grinder Crown:** red segmented circular saw collar; greater damage vs heavy armour, higher heat; Millwright patent |
| Volt Rifle | **Blue Testament:** glass capacitor etched with names; chain attack heals a nearby allied machine a little; memorial guild item | **Fulgur Fork:** forked yellow ceramic muzzle; wider chain and higher battery usage; barracks suppressor design |
| Bone Mortar | **Mother's Casket:** slim violet bone shell rail; smaller area but restores a sliver of Breath to protected ally; illegal grieving rite | **Grave Splitter:** black iron fragmentation ring; extra splinters on explosion; charnel recycler tool |
| Censer Flamer | **Saint's Wick:** braided white cloth burning blue; cleanses certain corruption fields while consuming fuel; Basilica heresy | **Penance Vent:** rust-red fan housing; longer reach and extra self-heat risk; church punishment gear |
| Harpoon Injector | **Mercy Needle:** green enamel medical head; heals rescued Echoforms when fired at allies, expensive payload; rescue caravan design | **Trawl Barbs:** three hooked steel fingers; stronger enemy pull but visible scars on restrained targets; Perrin's work |
| Hush Carbine | **Quiet Hours:** cork-lined black silencer drum; stealth kills delay alerts, lowers stagger; banned nursery stock | **Choir Throat:** gold fluted resonance nozzle; stronger Dissonance, noisier and draws sound hunters; Cantor's laboratory |
| Cinder Launcher | **Heat Bloom:** six-petal copper diffuser; cluster embers ignite growth tiles, risk collateral fire; Orchard clearance system | **Salvage Cage:** bolted rectangular shrapnel basket; heavier fragments and shorter blast radius; workers' improvised riot defence |

**Mod rules:** the player selects one of the two major mods per weapon at a time; small run affixes may vary recoil or drop rates but may not replace authored lore and silhouette. Quest-exclusive Chain of Wages cannot appear as an anonymous random drop on an unbetrayed Brin run.

# F. COMPLETE INITIAL ARMOUR CATALOGUE — eight 3-piece sets, plus unique pieces

Three slots: **head, body, legs**. Partial mixing is permitted. Each piece grants a little resistance matching its material; wearing all three grants the listed set perk. Armour sprite silhouettes are visible on Ninth in mirrors, the paper-doll screen and death/reprint cutaways. The centred FPS weapon sprite remains legible regardless of armour.

| Set / origin | Head piece — distinctive appearance | Body piece — distinctive appearance | Legs piece — distinctive appearance | Full-set gameplay identity |
|---|---|---|---|---|
| **1. Hearthkeeper Rags** · shelter volunteers | **Filter Hood:** oatmeal canvas cowl with two yellowed breathing discs and blue stitched initials | **Refuge Smock:** thick off-white quilted torso with red stitch repairs, small copper air gauge and rib straps | **Shelter Boots:** black rubber industrial boots with extra patched knees and a dangling air hose | More Breath from medical pickups; low armour; the first piece of clothing Ninth remembers wearing |
| **2. Brass Union Rig** · foundry workers | **Welder Brow:** square soot-dark iron brow guard with green observation slit and a melted crest | **Rivet Harness:** wide yellow-brown leather suspenders over copper-reinforced breastplate, a hammer loop at the hip | **Furnace Chaps:** overlapping black heat plates on knees and shins, red canvas tied around ankles | Heat resistance; bonus stagger while sliding; every patch was sewn after a strike or strikebreaking raid |
| **3. Broker's Mourning Suit** · Ashmarket enforcers | **Receipt Visor:** narrow black silk veil pinned across a silver counting-eye | **Mourner's Coat:** tailored charcoal coat with pale contract slips sewn like scales inside the lapels | **Auction Gaiters:** tall burgundy leather boots with little price tags attached at the rear heel | Discounts from compliant traders, reduced tolerance from rescued citizens; designed to make collection look ceremonial |
| **4. Last Lamp Vestments** · Basilica guards | **Censer Halo:** bent copper ring above a padded white skull cap, ash-black holes from earlier bolts | **Reliquary Cuirass:** tarnished gold chest plates over bottle-green choir cloth, a pair of open speaker grilles at ribs | **Drowned Slacks:** dark sea-green leggings wrapped in silver pipe insulation, rust stains at cuffs | Resistance to Sonic status and shallow-water slowdown; built from decommissioned hymn machinery |
| **5. Glass Pruner Coat** · Orchard researchers | **Lens Wreath:** interlocking triangular glass lenses in a rubber cap, one lens opaque violet | **Pruner Mantle:** faded olive surgeon's coat over a translucent ribbed resin vest, blue resin spills at seams | **Glass Treads:** broad rubber boots lined with pearl scales, triangular cleats inset into soles | Less Puncture from glass shards and higher Insight when examining plant evidence; designed to survive living conservatories |
| **6. Last Office Plate** · military police | **White Enamel Helm:** large bucket-shaped ivory helmet with black rectangular mouth slot and asymmetrical red tally marks | **Order Breastplate:** green ceramic slabs riveted to dark ballistic cloth, shoulder badge stamped with a scratched-out name | **Checkpoint Greaves:** high matte-black shin braces with deep red boot straps, worn square toes | Better heavy-weapon stability and Impact defence; reduces citizen trust when entering settlements armed |
| **7. Reprint Shroud** · failed printed bodies | **Null Mask:** smooth smoke-grey faceplate with one round lens and a vertical white seam down the centre | **Seam Mantle:** long torn grey drape threaded with violet surgical sutures, sections of internal framework exposed | **Blank Feet:** pale brace-legged walking apparatus with black stitch marks and mismatched heel heights | Faster recovery from Mnemonic status, lower max physical armour; recovered from bodies the machine discarded |
| **8. Architect's Burden** · Engine core engineers | **Measure Crown:** brass caliper-shaped frame arching above the head, six small numbered lenses, black cloth veil behind | **Charter Carapace:** heavy brown leather and white enamel breastpiece, filled with brass rulers, legal seals and thin cables | **Foundation Boots:** squat iron-toed shoes with carved centimetre markings and grease-black gaiters | Adds a Tech contextual dialogue option and reduces damage from traps; its seams conceal the architect's original confession |

### Unique quest armour pieces

| Piece · slot | Appearance, function and history |
|---|---|
| **Recall Plate** · full set overlay / Kest's good ending | Olive-and-ivory armour visibly engraved with the names of recovered soldiers across helmet, chest and greaves; moderate protection and one nonlethal stand-down command per barracks visit; Kest refuses to have the names polished away. Occupies three armour slots. |
| **Salt Pilgrim Greaves** · legs / Perrin's self-sacrifice route | White-salt-crusted thigh-high oilskin waders, cracked black boots and seven little ferry tickets folded into the seams; remove water slowdown and cause the boots to leave bright wet footprints in dark corridors. |
| **Salt-Sewn Hood** · head / Ossa's ruined outcome | Dark grey funeral hood with sea-salt crystals along the face opening and a brass bell clapper instead of a throat clasp; reveals distant ghost-whisper hints but imposes -1 Speech while worn because the living recoil from it. |

# G. Relics, field tools and utility equipment

Relics are small personal artifacts, usually worn at the waist, neck or wrist. Equip two. Most give a compact passive modifier plus one interaction with the world, instead of flat damage boosts. Field tools occupy a separate slot and typically act in exploration or Echoform recruitment.

## G1. Twelve common relics

| Relic | Appearance / origin | Function |
|---|---|---|
| **Copper Witness** | Coin-sized oval mirror under brown tarnish, in which a person's reflection arrives half a second late; made for inspectors of memory loss | Reveals forged witness statements and fake door signs in some areas |
| **Red Thread Spool** | Tiny pewter spool wound with crimson thread and one black knot; burial seamstress tradition | Slightly improves companion rescue speed and reveals a trail left by missing NPCs |
| **Cinder Rosary** | Seven coarse charcoal beads on copper wire, one bead always smouldering; worn by air-filter workers | Minor Ember resistance and better salvage chance from furnace kills |
| **Blank Signet** | Thin silver ring with an empty square seal and a sharp interior edge; an administrator's attempt to erase rank | Better anonymity at Last Office checks; mild merchant suspicion in Ashmarket |
| **Glass Psalm** | Triangular blue glass flake suspended in a wire cage; piece of the first false sun | Amplifies Echoform Glass attacks slightly, increases Sonic vulnerability |
| **Rivet Psalm** | Steel union token shaped like three interlocking nails, punched through the centre | Small Force boost on heavy equipment interactions; miners recognise it |
| **Dead Battery** | Obsolete square cell with red and yellow poles bound by cloth; known to work only when nobody watches | One automatic temporary ward after lethal Arc damage, then recharges between districts |
| **Hearth Photo** | Small sepia picture under cloudy celluloid showing a family with the faces rubbed away | Reduces NPC fear if Ninth arrives unarmed; provides no combat bonus |
| **Moth Glass** | Curved bronze lens containing a preserved translucent moth wing | Briefly reveals hidden Echoforms and secret nursery passages |
| **Bone Tally** | Five ivory counters on a black loop, each with a different death date | Increases recovery after a close-range finisher, small susceptibility to Mnemonic attacks |
| **Chorus Plug** | Copper ear insert with a cross-cut black rubber seal and blue identification bead | Resists Dissonance but reduces distance of sound-based secret clues |
| **Train Nail** | A bent nickel-steel rail spike wrapped in salt-white twine | Shows the nearest unlocked route toward a rail station, not a main quest shortcut |

## G2. Named quest relics and tools — each with explicit origin

| Name · category | Physical appearance | Effect / source |
|---|---|---|
| **Namesake Locket** · relic | Oval dirty-gold locket that opens onto two tiny uneven photographs, joined by a single red hair | Nearby lost-identity evidence glows faint amber; obtained by respecting Iona and her daughter's choices |
| **Broker's Chit** · relic | Rectangular bone voucher with clipped corners, black ink signature and a still-wet red price stamp | Improves black-market trades but reduces recruitment trust; Iona exploit path |
| **Brin's Torque** · relic | Thick iron neck-ring split at the hinge, stamped with payroll numbers and repaired by six brass finger-shaped rivets | Improves repairs, unlocks cover-plate crafting if Brin survives; union liberation reward |
| **Union Rivet Kit** · utility consumable | Red folded canvas roll containing eight brass rivets and a stubby yellow punch | Reroll two offered gun-mod choices once; negotiated strike outcome |
| **Black Shift Badge** · relic | Coal-black enamel clock disc, hands welded at 03:17, hanging from a broken chain | Ember resistance, worse lawful merchant prices; recovered from Boiler Penitent Brin |
| **Reliquary Tag** · relic | Two white enamel soldier ID tags joined back-to-back so neither name can be read | Reveals sealed military maintenance doors; Kest killed path |
| **Drowned Canticle** · relic | Silver tongue from an enormous bell in a transparent water vial; hums when held near a mouth | Grants an acoustic ward, makes silent faction enforcers suspicious; Ossa exploit path |
| **White Ledger** · relic | Bright white pocket accounts book with transparent pages and blood-red ruled margins | Stronger direct healing, but healing consumes a small temporary memory reserve; Sela automation path |
| **Consent Bell** · field tool | Small bronze handbell lined with violet felt and a silk knot around the handle | Enables voluntary Echoform recruitment dialogue and higher initial loyalty; Venn rescue path |
| **Cage Clamp** · field tool | Heavy black three-prong wrist trap with yellow caution stripes and purple sparking contacts | Immediate forced Echoform binding; lower loyalty and higher chance of refusal; Venn exploit path |
| **Broken Cocoon** · relic | Dry grey cocoon under green glass, torn open from the inside | Reveals rare Echoform spawn marks, starts recruited creatures with lower morale; Venn abandon path |
| **Fare Token** · relic | Green oxidised ferry coin, one face showing a boat, the other a child's scratched height mark | Adds one free district travel link and supports evacuation capacity; Perrin repair route |
| **Unwritten Page** · relic | Blank yellowed paper pinned between two pieces of glass, handwriting briefly appears only while turning it | Detects one false objective or deceptive prediction per run; Pale Ledger refused route |
| **Carbon Key** · field tool | Flat graphite-black key with duplicating-paper teeth and a small pale receipt spool | Opens one optional archive lock without ammunition or Tech requirement; Pale Ledger tricked route |
| **Resonance Bell** · default field tool | Rusty palm-size brass bell with concentric red enamel rings, pale cotton handle and visible hairline cracks | Guaranteed recruit/negotiation interface for Echoforms, regardless of Venn's presence; slower than Consent Bell but never blocks progression |
| **Censer Probe** · common field tool | Blunt steel screwdriver with incense holes along its shaft and a tiny emerald indicator lamp | Tests air filters and disarms one class of pressure traps; available from Hearth Nine |

**Special rule:** rare relics are trade-offs, not universally superior. Some impose social or tactical drawbacks that make the equipment's fiction matter mechanically.

# H. COMPLETE CONSUMABLE CATALOGUE — 23 initial consumables

Consumables are not health potions with arbitrary fantasy names. Their manufacture, physical wear and consequences reveal how a city dependent on stolen memories keeps its people functioning. Quantities are scarce enough to encourage choosing when to use them, but guaranteed basic healing/ammunition replenishment prevents unwinnable attrition. Most consumables reset at each new run; discovered recipes persist as blueprint options.

## H1. Six survival consumables

| Consumable | Appearance and history | Gameplay use |
|---|---|---|
| **Breath Ampoule** | Pear-shaped cobalt glass vial wrapped in coarse white gauze, containing blue effervescent liquid; condensed fresh air manufactured in Hearth Nine from a failing filter | Restores a moderate amount of Ninth's Breath/health; common, reliably stocked in shelter |
| **Printed Flesh Wrap** | Rectangular salmon-coloured biopaper in a folded medical tin, with fine blue blood-vessel lines; grown from discarded reprint material | Heal over several seconds and remove a light wound; disabled briefly when hit |
| **Triage Vapour** | Small rusty inhaler fitted with ivory double nozzles and a green warning stencil; once administered to workers during furnace accidents | Immediate modest healing and brief movement recovery, but increases visual distortion |
| **Graft Soup** | Sealed dented metal ration can, grey handwritten label and a spoon taped to its side; laboratory leftovers from nutrient-grown replacement organs | Large out-of-combat healing plus temporary increased maximum Breath; mild Mnemonic strain |
| **Sister's Thimble** | Little silver thimble full of dark red resin, lid stamped with a candle; covert medicine shared by Basilica lay sisters | Removes one serious status and grants short Sonic defence; uncommon |
| **Last Ration** | Dry tan biscuit wrapped in an old timetable, tied with red thread, smells of copper and burnt sugar | Small healing and one Resolve boost during the next NPC dialogue; found with refugees |

## H2. Six combat consumables

| Consumable | Appearance and history | Gameplay use |
|---|---|---|
| **Adrenal Bell** | Thumb-sized copper ampoule with ringing ceramic pellet trapped in its neck; illegal Last Office combat stimulant | Faster sprint and weapon swap for a few seconds, then a temporary stamina deficit |
| **Salt Charge** | Rough white cylinder bound in black tar paper with a blue wax fuse; engineers used salt explosions to suppress unstable memory fog | Area anti-Husk damage and clears cursed surfaces; low direct damage to humans |
| **Glass Flechette** | Cracked crystal orb packed with bright triangular fragments, held by crossed copper wire; harvested from Orchard machinery | Explodes into short-range Puncture shards, effective against lightly armoured clusters |
| **Cinder Bottle** | Thick brown medicine bottle containing orange sludge and a cloth wick, dripped wax sealing the neck; improvised picket weapon | Creates persistent Ember floor hazard; can burn NPC evidence and supplies if careless |
| **Screaming Ribbon** | Long strip of yellow tape wound round a serrated bone spool, faint black handwritten names along its edge; broadcast waste from the Basilica | Throws a sonic decoy that draws sound-hunting enemies and disrupts weak Choir shields |
| **Discharge Canister** | Ribbed cyan-black grenade with two brass screw terminals and a flashing red bead; decommissioned battery failsafe | Short Arc stun against machines, can power an emergency terminal once if thrown carefully |

## H3. Six Echoform-use consumables

| Consumable | Appearance and history | Gameplay use |
|---|---|---|
| **Containment Staple** | Palm-length black spring-loaded staple gun strip, violet pins tied in three bundles; designed by Last Office creature handlers | One forced capture attempt against a weakened recruitable Echoform, with loyalty penalty and risk of eventual revolt |
| **Echo Feed** | Sachet of grey granular powder with childlike doodles printed in pale blue; engineered nutrition for memory organisms | Restores a moderate amount of Echoform endurance between duels |
| **Gauze Cocoon** | Folded cream-coloured fibrous mesh ball with little copper pins around the edges; adopted from surgical emergency shelters | Revives one unravelled Echoform with low endurance after a battle, not during a boss's decisive turn |
| **Reset Resin** | Teal dropper bottle containing thick translucent fluid, suspended silver particles moving uphill; accidental by-product of reprint chemistry | Clears one Echoform debuff or one temporary move-lock |
| **Truce Wafer** | Thin blue square biscuit sealed in transparent film with a hand-shaped sigil; used by early ethical tamers | During a duel offers a single extra non-coercive negotiation attempt, not a guaranteed catch |
| **Imprint Dye** | Two tiny conjoined ampoules, one ember-orange, one violet, tied by grey string; illicit Orchard horticulture experiment | Changes one Echoform's cosmetic imprint route within its unlocked legal variants, never overrides consent history |

## H4. Five exploration and dialogue consumables

| Consumable | Appearance and history | Gameplay use |
|---|---|---|
| **Archive Solvent** | Flat green bottle with black-paper-wrapped stopper and red measurement lines; used by clerks to dissolve paper locks | Exposes one hidden archive layer or removes a document seal; alternative Tech check remains possible |
| **False Papers** | Creased buff identity folio with faded photograph window, two competing signatures and a fresh crimson stamp | Supports one disguise/deception check; can be detected by high-ranking Last Office staff |
| **Transit Chit** | Small punched blue card with zigzag silver stripe and oily finger marks; workers' rationed permission to travel | Opens an optional fast-travel gate, does not replace the three Writs |
| **Canal Lamp** | Squat yellow paraffin lamp with caged green glass chimney, dripping black handle insulation; found on submerged ferry docks | Reveals reflected signs and submerged path markings for one region; burns out after use |
| **Spare Fuse** | White ceramic plug capped with heavy copper tips and handwritten repair date; found in every maintenance shed | Restarts one local power board or trap circuit; allows a resource-driven alternate route |

## H5. Additional NPC-only one-use rewards

These do not enlarge the standard 23-consumable shop pool. They are specifically authored branch rewards: **Union Rivet Kit** (two mod rerolls); **Clean Scalpels** (silver surgical blades in teal cloth, grant one medical crafting recipe and are spent on use); **Carbon Key** (one archive opening, described in the field-tool list); **Broker's Chit** is reusable and therefore a relic, not a consumable.

# I. KEY ITEMS, QUEST OBJECTS AND LORE DOCUMENTS — 14 core objects

Quest objects do not take inventory capacity and cannot be discarded if needed for a live critical objective. Their sprites and descriptions should be as distinctive as primary weapons. Descriptions may gain an extra line when evidence changes the player's understanding.

| Object | Detailed appearance and associated lore | Practical role |
|---|---|---|
| **1. Cinder Lung** | Two braced pressure bellows around a sealed translucent blue **correction cassette**, stamped with the competing ward’s allocation claim; its pumps use electricity, while its mnemonic patterns independently stabilise the local boundary | Guaranteed Act I target, installed in Hearth Nine, opens Writ hunt |
| **2. Writ of Trade** | Black-gold metal certificate the size of a hand, notched like a coin, one ruby accounting seal and microscopic price columns; authorises memory commerce | One of five possible final access tokens |
| **3. Writ of Labour** | Crooked six-sided iron plate with soot-worn tally marks and a chain-link handle; founded by a workers' coalition later stripped of authority | One of five possible final access tokens |
| **4. Writ of Growth** | Palm-sized milky glass tile with a green shoot alive inside the material and a carved human thumbprint; authorises biological reconstruction | One of five possible final access tokens |
| **5. Writ of Faith** | Long tapering silver noteplate with nine deep sound grooves and a green patina, used as a tuning instrument in sacred rites | One of five possible final access tokens |
| **6. Writ of Defence** | Thick white enamel cartridge of sealed military dispatches, red wax bearing a crossed-out general's name; gave the first army emergency powers | One of five possible final access tokens |
| **7. Emergency Rail Charter** | Folded black linen blueprint with thin luminous white rails and an attached brass switch key; proof that evacuation was planned before the Engine's cruelty became routine | Automatically discovered in final chamber in every run; ensures the Liberation route is always legible |
| **8. The Architect's Confession** | One-inch copper wire spool threaded through a square wooden card, the first three turns stained black; the original architect knowingly approved forced harvesting | Mandatory endgame reveal; unlocks unique Custodian arguments |
| **9. Pressure Seal Diagram** | Crinkled yellow engineering drawing with triangular repair stamps and Perrin's handwritten depth measurements; fixes the ferry's memory-consuming pump | Optional Perrin ending and evacuation bonus |
| **10. Payroll Cylinder** | Thick striped brass cylinder engraved with decades of workers' names; no date ever advances past the city's first reconstruction | Brin's quest evidence, enables legal testimony or mutiny |
| **11. Original Hymn Wafer** | Octagonal green wax recording disc in a broken bell-shaped sleeve; the sacred hymn is an operating instruction misremembered as scripture | Ossa evidence; can change Basilica Writ method if acquired |
| **12. Orchard Root Seed** | Walnut-size transparent seed containing a curled blue shoot and a faint human silhouette; survives without harvested memories | Optional True Dawn ingredient; guaranteed discoverable if the player elects to search restoration clues |
| **13. Deep Heat Survey** | Military field map printed on dark linen, geothermal vents marked with pale blue circles and three tiny evacuation passages | Optional True Dawn ingredient and extra rail safety information |
| **14. Governor's Maintenance Cipher** | Brass punch card with blue notches and an unsealed handwritten consent field; documents how to use geothermal current for the pumps while the living seed supplies slowly calibrated nonhuman boundary-correction patterns | Optional True Dawn ingredient, revealed by optional restoration lead chain |

The three True Dawn ingredients (Seed, Survey, Cipher) are seeded into reachable **optional** mission sites in every run, regardless of which three Writ districts are featured. Obtaining them is a deliberate side objective; they are not random rare drops and never prerequisites for the unconditional good ending (Liberation).


---

# Appendix B — Asset-production specification
## Appendix C — Asset checklist and production acceptance

# K. Art asset checklist and implementation handover

**Original content counts for a first full release:** five district themes; eight major branching NPC arcs; twenty existing short local quest kernels; 16 weapons; ten ammunition types; 20 authored weapon modifications; eight complete three-piece armour sets plus three named armour rewards; 12 common relics plus 16 named quest relics/tools; 23 base consumables; 14 central quest objects; 12 Echoform species with preserved four named behaviour motifs and at least two planned imprint variants, plus five shared V5 hearing commands; five core enemy families; three variable Custodians; four ending modes.

For each weapon, make: world pickup sprite, inventory icon, 4–8 frame first-person idle/fire/reload sequence as appropriate, muzzle flash, dropped item sprite and palette test against each district. For each NPC, make: eight-angle body turnaround; four or more walking frames; talk/idle variations; a distinct death/corpse state; outcome transformations where specified; portrait-free dialogue stance readable at 320×200. For each Echoform: eight-angle views for first-person arenas; five field-command cue animations; hurt, unravel and recruitment states; two imprint variants that retain silhouette identity. For key objects: 64×64 icon, in-world 32–64-pixel sprite and at least one lore inspection paragraph.

**V5-authorised vertical slice:** Hearth Nine; Sootworks and Flood Basilica; two of the long arcs (Brin and Ossa); four weapons (Covenant Pistol, Coil Shotgun, Nail Storm, Choirbreaker); eight consumables; two armour sets; three eligible Accord participants (Cindermoth, Rootkin, Spool Hound) with one public loaner; one mandatory field hearing; two Writs for the slice; end-of-run moral choice; and one NPC ending card that varies by a genuine player decision. The full version restores the three-of-five requirement.

**Scope warning:** This is a detailed game-content specification, not evidence of created artwork, rendered sprites, implemented combat or finished AI. The story prototype can test narrative selection, but true reachability, combat feel, tactical balance, NPC timing, and artwork fidelity require a playable build.
## Appendix D — Protected originality register (20 preserved invariants)

# Protected Originality Register — The Ninth Exhale V5

> **Status:** Production originality assessment, not legal clearance. Source baseline: `ninth_exhale_game_bible_v4.md`, `ninth_exhale_v4_art_direction.md`, `ninth_exhale_v4_literary_style_guide.md`, `ninth_exhale_storygen_v4.py` and V4 example stories. Sources are cited by original headings, not invented page numbers.


**Scope:** 20 protected or carefully refined elements. “Distinctive” is a creative editorial judgement, not a conclusion of legal novelty. This register is the preservation baseline for all V5 revisions.

## POR-01 — Lumen Engine: independent power and mnemonic correction

- **Exact element:** Lumen Engine: independent power and mnemonic correction
- **V4 source:** V4 §2.1
- **Distinctive quality:** Heat operates machinery; independent adaptive patterns maintain a damaged boundary.
- **Narrative function:** Explains survival without supernatural memory-as-fuel.
- **Gameplay function:** Gates air, repairs, final decisions and Engine loads.
- **Thematic role:** Forces technical costs into moral arguments.
- **Dependencies:** Cinder Lung, five finite resources, endings
- **Similarity concern:** General dystopian central machine; individual two-channel logic is stronger
- **Protection level:** Preserve
- **Permitted changes:** Refine operational descriptions; never merge channels.

## POR-02 — Finite resources and the negative-feedback loop

- **Exact element:** Finite resources and the negative-feedback loop
- **V4 source:** V4 §§2.2–2.3
- **Distinctive quality:** Energy, patterns, biomass, breathable air and labour cannot be conjured; harvesting creates Unsaid waste that drives further harvesting.
- **Narrative function:** Makes policies causally credible.
- **Gameplay function:** Links enemy volume to societal cost.
- **Thematic role:** Exploitation appears profitable and self-defeating.
- **Dependencies:** All districts, enemy ecology, relief choices
- **Similarity concern:** Generic scarcity theme only
- **Protection level:** Preserve
- **Permitted changes:** Give every resource change a ledger consequence.

## POR-03 — Compulsory consent as a legal fiction

- **Exact element:** Compulsory consent as a legal fiction
- **V4 source:** V4 §§1, 2.3, 5
- **Distinctive quality:** An institution can prove a signature without demonstrating a free decision.
- **Narrative function:** Creates the setting’s ordinary horror.
- **Gameplay function:** Controls dialogue evidence, recruitment and medical checks.
- **Thematic role:** Asks who controls the definition of agreement.
- **Dependencies:** Iona, Sela, Venn, Edda, council vote
- **Similarity concern:** Broad authoritarian trope, but specific paperwork logic is strong
- **Protection level:** Preserve
- **Permitted changes:** More mundane forms and contested signatures; never trivialise real consent.

## POR-04 — The nine-count motif

- **Exact element:** The nine-count motif
- **V4 source:** V4 §§2.6, 12, 13
- **Distinctive quality:** A production number and medical count become a motif through unremarked physical repetition.
- **Narrative function:** Connects personal and civic history.
- **Gameplay function:** Can signal an approaching state transition.
- **Thematic role:** Identity does not determine moral fate.
- **Dependencies:** Ninth, Engine reprinting, final act
- **Similarity concern:** Numerology is common, execution is specific
- **Protection level:** Refine carefully
- **Permitted changes:** Restrict recurrence; avoid the narrator explaining the symbol.

## POR-05 — Bounded nightly reconstruction

- **Exact element:** Bounded nightly reconstruction
- **V4 source:** V4 §2.4
- **Distinctive quality:** Physical modular corridors, staff assignments and limited reprints rearrange the city; fixed anchors persist.
- **Narrative function:** Explains run variation and civic instability.
- **Gameplay function:** Determines seeded locations, travel and risk.
- **Thematic role:** A person cannot simply be restored as an accounting entry.
- **Dependencies:** WorldPlan, rail anchors, costs, analogue sites
- **Similarity concern:** Roguelite resets are general genre structure
- **Protection level:** Preserve
- **Permitted changes:** Maintain material cost and stable anchors.

## POR-06 — Final endings remain terminal

- **Exact element:** Final endings remain terminal
- **V4 source:** V4 §2.4 and Act V
- **Distinctive quality:** A completed city’s ending persists; new runs are counterfactual campaigns, not its undoing.
- **Narrative function:** Allows meaningful finality despite replayability.
- **Gameplay function:** Prevents post-ending state mutations.
- **Thematic role:** Gives choices consequence.
- **Dependencies:** Campaign.ending, four routes, Nix records
- **Similarity concern:** Structural convention only
- **Protection level:** Preserve
- **Permitted changes:** No hidden rewind or post-credits undo.

## POR-07 — Nix: imperfect analogue testimony

- **Exact element:** Nix: imperfect analogue testimony
- **V4 source:** V4 §2.5 and §5
- **Distinctive quality:** A physical spool keeps partial, falsifiable evidence while digital records are editable.
- **Narrative function:** Makes narration a disputable witness.
- **Gameplay function:** Supports investigation and run-specific clues.
- **Thematic role:** Witness versus authority.
- **Dependencies:** Archive scenes, previous deaths, technical limitations
- **Similarity concern:** Radio guide resembles BioShock at surface; bounded knowledge distinguishes
- **Protection level:** Refine carefully
- **Permitted changes:** Avoid command catchphrases and omniscient direction.

## POR-08 — Ninth as independent ninth print

- **Exact element:** Ninth as independent ninth print
- **V4 source:** V4 §2.6 and Act III
- **Distinctive quality:** The architect’s guilty conscience is a source template, not Ninth’s inherited personality.
- **Narrative function:** Keeps revelation from assigning morality.
- **Gameplay function:** Allows all endings for any player.
- **Thematic role:** Responsibility versus predetermined identity.
- **Dependencies:** Architect archive, reprint, nine-count
- **Similarity concern:** Identity twist resembles several speculative thrillers
- **Protection level:** Refine carefully
- **Permitted changes:** Foreshadow through labour and record practice; never mind-control twist.

## POR-09 — Five-office civic political economy

- **Exact element:** Five-office civic political economy
- **V4 source:** V4 §§2.3, 3, 4
- **Distinctive quality:** Trade, Labour, Growth, Faith and Defence each manage one scarce social function.
- **Narrative function:** Institutions behave as interacting dependencies.
- **Gameplay function:** Five Writ routes and cross-district effects.
- **Thematic role:** Public power is distributed and contested.
- **Dependencies:** District maps, Writs, Custodians
- **Similarity concern:** Five milestones could resemble badge hunting if presented as tokens
- **Protection level:** Preserve
- **Permitted changes:** Use physical jurisdiction, not trophy-collection ceremony.

## POR-10 — Emergency Quorum Charter and recoverable Writs

- **Exact element:** Emergency Quorum Charter and recoverable Writs
- **V4 source:** V4 §§3, 7–8
- **Distinctive quality:** Three distinct office credentials allow emergency review; records outlast their keepers.
- **Narrative function:** Defeats arbitrary single-villain locks.
- **Gameplay function:** Always permits completion after violence or diplomacy.
- **Thematic role:** The difference between legitimacy and virtue.
- **Dependencies:** Quorum logic, civil registry, all endings
- **Similarity concern:** Milestone count is a general convention
- **Protection level:** Preserve
- **Permitted changes:** Strengthen procedural speech and visible office functions.

## POR-11 — Unsaid as industrial discarded patterns

- **Exact element:** Unsaid as industrial discarded patterns
- **V4 source:** V4 §2.2
- **Distinctive quality:** Hazardous incomplete loops arise from improperly disposed boundary patterns.
- **Narrative function:** Supplies horror ecology linked to work.
- **Gameplay function:** Shows consequences of harvested waste; informs fights.
- **Thematic role:** Society fights symptoms of its own production.
- **Dependencies:** Monster production, furnace quotas
- **Similarity concern:** Risk of DOOM-like humanoid demon silhouettes in assets
- **Protection level:** Refine carefully
- **Permitted changes:** Require function-derived anatomies, avoid horned demons and familiar poses.

## POR-12 — Echoforms as morally contested printed organisms

- **Exact element:** Echoforms as morally contested printed organisms
- **V4 source:** V4 §§2.2, 7, Appendix C
- **Distinctive quality:** Stable patterned beings may show preference and fear; personhood is disputed.
- **Narrative function:** Challenges people’s ownership assumptions.
- **Gameplay function:** Tactical encounter, cooperation and logistics.
- **Thematic role:** Agency versus ownership.
- **Dependencies:** Venn, creature catalogue, mandatory hearing
- **Similarity concern:** Three starters, type ring and four-move package resembled Pokémon
- **Protection level:** Refine carefully
- **Permitted changes:** Retain 12 species and trial; replace type ring with field interference and accord-based participation.

## POR-13 — Cinder Lung as rationed and contested medical module

- **Exact element:** Cinder Lung as rationed and contested medical module
- **V4 source:** V4 Act I, item I.1
- **Distinctive quality:** A known component is withheld by an allocation policy even as wards lack breathable air.
- **Narrative function:** Introduces the state in an intimate setting.
- **Gameplay function:** Objective has four approaches and delay costs.
- **Thematic role:** Whose emergency receives priority?
- **Dependencies:** Sela, Oren, Hearth Nine, air quota
- **Similarity concern:** Initial fetch-the-part objective resembled Fallout 1 water chip
- **Protection level:** Refine carefully
- **Permitted changes:** Frame as disputed requisition with a cost to another ward.

## POR-14 — Hearth Nine as a functioning community

- **Exact element:** Hearth Nine as a functioning community
- **V4 source:** V4 §§3–4
- **Distinctive quality:** Clinicians, guards, children and maintenance staff have normal work routines.
- **Narrative function:** Gives central stakes actual people.
- **Gameplay function:** Delays affect survival and evacuation.
- **Thematic role:** Ordinary care versus administrative harm.
- **Dependencies:** Lung, Sela, Oren, endings
- **Similarity concern:** Generic shelter setting unless culturally specific
- **Protection level:** Refine carefully
- **Permitted changes:** Make it a ward cooperative, not a sealed survival vault.

## POR-15 — Eight four-stage optional NPC arcs

- **Exact element:** Eight four-stage optional NPC arcs
- **V4 source:** V4 §13 and Appendix B
- **Distinctive quality:** Characters make independent decisions; effects persist when unselected.
- **Narrative function:** Produces intimate stories against the institutions.
- **Gameplay function:** Stages permit evidence, choice, rewards, death states.
- **Thematic role:** Ethics emerges through lived consequences.
- **Dependencies:** Arc data, epilogues and equipment rewards
- **Similarity concern:** Dark-Souls-like rediscovery is generic; actual beats should be unique
- **Protection level:** Preserve
- **Permitted changes:** Keep names, agency and distinct outcomes; avoid exact Souls-style teleport/event triggers.

## POR-16 — Five named district working cultures

- **Exact element:** Five named district working cultures
- **V4 source:** V4 §§3–4, §12
- **Distinctive quality:** Market, foundry, orchard, basilica and barracks have jobs, architecture, paperwork and technical duties.
- **Narrative function:** Provides independent societies with interlocking survival needs.
- **Gameplay function:** Different fields, hazards and resolutions.
- **Thematic role:** No one institution owns the truth.
- **Dependencies:** Writ routes, environmental assets
- **Similarity concern:** Risk of BioShock-like grand ideological halls
- **Protection level:** Refine carefully
- **Permitted changes:** Use municipal service architecture instead of general Art Deco luxury.

## POR-17 — Analogues of public civic oversight

- **Exact element:** Analogues of public civic oversight
- **V4 source:** V4 Act V, §§7–8
- **Distinctive quality:** The risky alternative needs public disclosure, independent monitoring and a revocable mandate.
- **Narrative function:** Makes True Dawn contestable rather than perfect.
- **Gameplay function:** Three optional parts plus support vote.
- **Thematic role:** Collective consent as genuine process.
- **Dependencies:** True Dawn, all NPC epilogues
- **Similarity concern:** General democracy concept, distinctive in mechanical story use
- **Protection level:** Preserve
- **Permitted changes:** Provide dissent, maintenance debts and uneven benefits.

## POR-18 — Finite evacuation rail and civic cost

- **Exact element:** Finite evacuation rail and civic cost
- **V4 source:** V4 §§4, 8, Item I.7
- **Distinctive quality:** Limited seats and a preexisting rail charter create a costly choice.
- **Narrative function:** Prevents easy universal rescue.
- **Gameplay function:** Capacity changes after delays and Perrin choices.
- **Thematic role:** Not everyone is saved by one lever.
- **Dependencies:** Liberation, crew, Perrin, shelter losses
- **Similarity concern:** Generic escape train could echo other shooters
- **Protection level:** Refine carefully
- **Permitted changes:** Show railway as service infrastructure, not a miraculous secret vehicle.

## POR-19 — Functional equipment and occupational origin

- **Exact element:** Functional equipment and occupational origin
- **V4 source:** V4 Appendices D–I
- **Distinctive quality:** Weapons, equipment and consumables derive from repair, audit, medicine and industrial work.
- **Narrative function:** Gives objects and companies a history.
- **Gameplay function:** Equipment mods and quest rewards.
- **Thematic role:** Tools can become instruments of both care and abuse.
- **Dependencies:** 16 weapons, 20 mods, 8 sets, 23 consumables
- **Similarity concern:** Some centred-gun silhouettes, chainsaw-like melee and fetishised gore resemble shooters
- **Protection level:** Refine carefully
- **Permitted changes:** Retain IDs, revise high-risk shapes and first-person poses.

## POR-20 — Separated world plan and human action log

- **Exact element:** Separated world plan and human action log
- **V4 source:** V4 §8, V4 story generator
- **Distinctive quality:** Seeds select circumstances; authored decisions determine outcomes and endings.
- **Narrative function:** Keeps randomness from inventing moral agency.
- **Gameplay function:** Provides reproducible story-state tests.
- **Thematic role:** The player’s conduct is theirs, not a roll.
- **Dependencies:** WorldPlan, Campaign, 4 endings
- **Similarity concern:** General procedural practice
- **Protection level:** Preserve
- **Permitted changes:** Maintain event provenance and reporting separation.

## Revision safeguard

No protected element has been removed from the V5 bible. There are two material refinements rather than replacements: (a) the air crisis is explicitly treated as a ration dispute and (b) the Echoform duel is now a consent-aware civic interference hearing using five field commands, environmental response and recorded withdrawal. The complete twelve-species catalogue is retained.

## External methodological sources

- Australian Attorney-General’s Department, [copyright basics](https://www.ag.gov.au/rights-and-protections/copyright/copyright-basics).
- U.S. Copyright Office, [games guidance](https://www.copyright.gov/register/tx-games.html).

## Appendix E — Stable authoring ID bridge (proposed Godot IDs; names unchanged)

All identifiers below are **new technical keys**, not renamed lore. The V5 Python script can continue to use its names until a tested adapter translates those names. Save migrations must preserve old IDs and item instances. **Exception:** the Founders' Cipher must retain existing canonical story ID `cipher` (the longer `qobj_governor_s_maintenance_cipher` is a *catalogue alias*). Writs are keyed by their existing `qobj_writ_of_*` records, not duplicated as new items.

| Catalogue | Proposed stable ID | Existing display name |
|---|---|---|
| weapons | wp_covenant_pistol | Covenant Pistol |
| weapons | wp_coil_shotgun | Coil Shotgun |
| weapons | wp_nail_storm | Nail Storm |
| weapons | wp_saw_lance | Saw Lance |
| weapons | wp_volt_rifle | Volt Rifle |
| weapons | wp_bone_mortar | Bone Mortar |
| weapons | wp_censer_flamer | Censer Flamer |
| weapons | wp_harpoon_injector | Harpoon Injector |
| weapons | wp_hush_carbine | Hush Carbine |
| weapons | wp_cinder_launcher | Cinder Launcher |
| weapons | wp_widow_s_toll | Widow's Toll |
| weapons | wp_surgeon_s_mercy | Surgeon's Mercy |
| weapons | wp_penance_fang | Penance Fang |
| weapons | wp_debt_collector_s_smile | Debt Collector's Smile |
| weapons | wp_choirbreaker | Choirbreaker |
| weapons | wp_ferryman_s_hook | Ferryman's Hook |
| weapon_mods | mod_witness_seal | Witness Seal |
| weapon_mods | mod_exaction_spring | Exaction Spring |
| weapon_mods | mod_crowd_brake | Crowd Brake |
| weapon_mods | mod_glass_choke | Glass Choke |
| weapon_mods | mod_chain_of_wages | Chain of Wages |
| weapon_mods | mod_cradle_clamp | Cradle Clamp |
| weapon_mods | mod_mercy_brake | Mercy Brake |
| weapon_mods | mod_grinder_crown | Grinder Crown |
| weapon_mods | mod_blue_testament | Blue Testament |
| weapon_mods | mod_fulgur_fork | Fulgur Fork |
| weapon_mods | mod_mother_s_casket | Mother's Casket |
| weapon_mods | mod_grave_splitter | Grave Splitter |
| weapon_mods | mod_saint_s_wick | Saint's Wick |
| weapon_mods | mod_penance_vent | Penance Vent |
| weapon_mods | mod_mercy_needle | Mercy Needle |
| weapon_mods | mod_trawl_barbs | Trawl Barbs |
| weapon_mods | mod_quiet_hours | Quiet Hours |
| weapon_mods | mod_choir_throat | Choir Throat |
| weapon_mods | mod_heat_bloom | Heat Bloom |
| weapon_mods | mod_salvage_cage | Salvage Cage |
| ammunition | ammo_ledger_slugs | Ledger Slugs |
| ammunition | ammo_coil_shells | Coil Shells |
| ammunition | ammo_rivet_belts | Rivet Belts |
| ammunition | ammo_pressure_cartridges | Pressure Cartridges |
| ammunition | ammo_voltaic_cells | Voltaic Cells |
| ammunition | ammo_ossuary_pods | Ossuary Pods |
| ammunition | ammo_censer_fuel | Censer Fuel |
| ammunition | ammo_harpoon_spurs | Harpoon Spurs |
| ammunition | ammo_waking_tape | Waking Tape |
| ammunition | ammo_cinder_casks | Cinder Casks |
| armour_sets | armor_hearthkeeper_rags | Hearthkeeper Rags |
| armour_sets | armor_brass_union_rig | Brass Union Rig |
| armour_sets | armor_broker_s_mourning_suit | Broker's Mourning Suit |
| armour_sets | armor_last_lamp_vestments | Last Lamp Vestments |
| armour_sets | armor_glass_pruner_coat | Glass Pruner Coat |
| armour_sets | armor_last_office_plate | Last Office Plate |
| armour_sets | armor_reprint_shroud | Reprint Shroud |
| armour_sets | armor_architect_s_burden | Architect's Burden |
| unique_armour | armor_unique_recall_plate | Recall Plate |
| unique_armour | armor_unique_salt_pilgrim_greaves | Salt Pilgrim Greaves |
| unique_armour | armor_unique_salt_sewn_hood | Salt-Sewn Hood |
| common_relics | relic_copper_witness | Copper Witness |
| common_relics | relic_red_thread_spool | Red Thread Spool |
| common_relics | relic_cinder_rosary | Cinder Rosary |
| common_relics | relic_blank_signet | Blank Signet |
| common_relics | relic_glass_psalm | Glass Psalm |
| common_relics | relic_rivet_psalm | Rivet Psalm |
| common_relics | relic_dead_battery | Dead Battery |
| common_relics | relic_hearth_photo | Hearth Photo |
| common_relics | relic_moth_glass | Moth Glass |
| common_relics | relic_bone_tally | Bone Tally |
| common_relics | relic_chorus_plug | Chorus Plug |
| common_relics | relic_train_nail | Train Nail |
| named_relics_tools | tool_unique_namesake_locket | Namesake Locket |
| named_relics_tools | tool_unique_broker_s_chit | Broker's Chit |
| named_relics_tools | tool_unique_brin_s_torque | Brin's Torque |
| named_relics_tools | tool_unique_union_rivet_kit | Union Rivet Kit |
| named_relics_tools | tool_unique_black_shift_badge | Black Shift Badge |
| named_relics_tools | tool_unique_reliquary_tag | Reliquary Tag |
| named_relics_tools | tool_unique_drowned_canticle | Drowned Canticle |
| named_relics_tools | tool_unique_white_ledger | White Ledger |
| named_relics_tools | tool_unique_consent_bell | Consent Bell |
| named_relics_tools | tool_unique_cage_clamp | Cage Clamp |
| named_relics_tools | tool_unique_broken_cocoon | Broken Cocoon |
| named_relics_tools | tool_unique_fare_token | Fare Token |
| named_relics_tools | tool_unique_unwritten_page | Unwritten Page |
| named_relics_tools | tool_unique_carbon_key | Carbon Key |
| named_relics_tools | tool_unique_resonance_bell | Resonance Bell |
| named_relics_tools | tool_unique_censer_probe | Censer Probe |
| consumables | cons_breath_ampoule | Breath Ampoule |
| consumables | cons_printed_flesh_wrap | Printed Flesh Wrap |
| consumables | cons_triage_vapour | Triage Vapour |
| consumables | cons_graft_soup | Graft Soup |
| consumables | cons_sister_s_thimble | Sister's Thimble |
| consumables | cons_last_ration | Last Ration |
| consumables | cons_adrenal_bell | Adrenal Bell |
| consumables | cons_salt_charge | Salt Charge |
| consumables | cons_glass_flechette | Glass Flechette |
| consumables | cons_cinder_bottle | Cinder Bottle |
| consumables | cons_screaming_ribbon | Screaming Ribbon |
| consumables | cons_discharge_canister | Discharge Canister |
| consumables | cons_containment_staple | Containment Staple |
| consumables | cons_echo_feed | Echo Feed |
| consumables | cons_gauze_cocoon | Gauze Cocoon |
| consumables | cons_reset_resin | Reset Resin |
| consumables | cons_truce_wafer | Truce Wafer |
| consumables | cons_imprint_dye | Imprint Dye |
| consumables | cons_archive_solvent | Archive Solvent |
| consumables | cons_false_papers | False Papers |
| consumables | cons_transit_chit | Transit Chit |
| consumables | cons_canal_lamp | Canal Lamp |
| consumables | cons_spare_fuse | Spare Fuse |
| echoforms | echo_cindermoth | Cindermoth |
| echoforms | echo_boiler_calf | Boiler Calf |
| echoforms | echo_rootkin | Rootkin |
| echoforms | echo_cradle_wasp | Cradle Wasp |
| echoforms | echo_mirror_jackal | Mirror Jackal |
| echoforms | echo_prism_eel | Prism Eel |
| echoforms | echo_spool_hound | Spool Hound |
| echoforms | echo_suture_mite | Suture Mite |
| echoforms | echo_bell_wretch | Bell Wretch |
| echoforms | echo_hush_heron | Hush Heron |
| echoforms | echo_name_leech | Name Leech |
| echoforms | echo_grief_stag | Grief Stag |
| quest_objects | qobj_cinder_lung | Cinder Lung |
| quest_objects | qobj_writ_of_trade | Writ of Trade |
| quest_objects | qobj_writ_of_labour | Writ of Labour |
| quest_objects | qobj_writ_of_growth | Writ of Growth |
| quest_objects | qobj_writ_of_faith | Writ of Faith |
| quest_objects | qobj_writ_of_defence | Writ of Defence |
| quest_objects | qobj_emergency_rail_charter | Emergency Rail Charter |
| quest_objects | qobj_the_architect_s_confession | The Architect's Confession |
| quest_objects | qobj_pressure_seal_diagram | Pressure Seal Diagram |
| quest_objects | qobj_payroll_cylinder | Payroll Cylinder |
| quest_objects | qobj_original_hymn_wafer | Original Hymn Wafer |
| quest_objects | qobj_orchard_root_seed | Orchard Root Seed |
| quest_objects | qobj_deep_heat_survey | Deep Heat Survey |
| quest_objects | qobj_governor_s_maintenance_cipher | Governor's Maintenance Cipher |
| local_storylets | qshort_the_borrowed_verdict | The Borrowed Verdict |
| local_storylets | qshort_the_price_of_rain | The Price of Rain |
| local_storylets | qshort_the_fifth_customer | The Fifth Customer |
| local_storylets | qshort_the_honest_thief | The Honest Thief |
| local_storylets | qshort_a_strike_of_hands | A Strike of Hands |
| local_storylets | qshort_the_last_shift | The Last Shift |
| local_storylets | qshort_warm_iron | Warm Iron |
| local_storylets | qshort_boiler_saint | Boiler Saint |
| local_storylets | qshort_the_tree_that_calls_mother | The Tree That Calls Mother |
| local_storylets | qshort_green_in_the_dark | Green in the Dark |
| local_storylets | qshort_the_missing_harvest | The Missing Harvest |
| local_storylets | qshort_a_beautiful_lie | A Beautiful Lie |
| local_storylets | qshort_the_drowned_choir | The Drowned Choir |
| local_storylets | qshort_a_confession_for_sale | A Confession for Sale |
| local_storylets | qshort_saint_without_a_face | Saint Without a Face |
| local_storylets | qshort_the_last_funeral | The Last Funeral |
| local_storylets | qshort_the_unfired_gun | The Unfired Gun |
| local_storylets | qshort_deserter_at_the_gate | Deserter at the Gate |
| local_storylets | qshort_the_nameless_platoon | The Nameless Platoon |
| local_storylets | qshort_signal_zero | Signal Zero |
| major_npcs | npc_iona_pell | Iona Pell |
| major_npcs | npc_brin_harker | Brin Harker |
| major_npcs | npc_kest_07 | Kest-07 |
| major_npcs | npc_sister_ossa | Sister Ossa |
| major_npcs | npc_dr_sela_vale | Dr Sela Vale |
| major_npcs | npc_venn_of_glass | Venn-of-Glass |
| major_npcs | npc_old_perrin | Old Perrin |
| major_npcs | npc_the_pale_ledger | The Pale Ledger |
| districts | dist_ashmarket | Ashmarket |
| districts | dist_sootworks | Sootworks |
| districts | dist_glass_orchard | Glass Orchard |
| districts | dist_flood_basilica | Flood Basilica |
| districts | dist_quiet_barracks | Quiet Barracks |
| hearing_commands | cmd_press | Press |
| hearing_commands | cmd_attune | Attune |
| hearing_commands | cmd_brace | Brace |
| hearing_commands | cmd_observe | Observe |
| hearing_commands | cmd_withdraw | Withdraw |
