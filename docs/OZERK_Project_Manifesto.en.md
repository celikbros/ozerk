# OZERK Project Manifesto

> This is the English translation of the founding document. The Turkish original (OZERK_Proje_Manifestosu.md) is normative in case of discrepancy.

**Founding Document — Version 1.1**  
**17 August 2026** (first published: 16 August 2026)

> **Change log.** Version 1.1: two items on browser-engine dependency were added to Chapter 24. The amendment was proposed in [RFC-0004](../rfc/0004-tarayici-motoru.md) and accepted with the founder's approval under the procedure in [GOVERNANCE.md](../GOVERNANCE.md).

> **Your phone. Your data. Your decision.**

**Brand spelling:** OZERK  
**Turkish pronunciation:** Özerk  
**International definition:** Open, independent and user-sovereign mobile platform

---

## 1. Founding Declaration

The smartphone is the most personal computer in a person's life. It knows our location, our conversations, our photographs, our health data, our financial transactions, our relationships, our habits, and our daily decisions.

Despite this, today's smartphones often do not truly belong to the user.

The user pays for the device; yet:

- they are tied to a company account in order to use the device,
- others decide which applications they may install and from where,
- they cannot see which servers their applications communicate with,
- they cannot easily move their data,
- they cannot fully control the telemetry the operating system sends,
- they leave the software lifespan of their device to the manufacturer's commercial decisions,
- they face technical or contractual obstacles when they want to run their own software.

OZERK holds that this order is not inevitable.

OZERK does not aim to imitate Android or iOS. It does not attempt to copy millions of applications. It does not build another closed store, another mandatory account system, or another data monopoly.

OZERK's purpose is to build an independent mobile ecosystem that meets people's everyday mobile needs with open standards, free software, web technologies, and user control.

OZERK shall not depend on a single company, a single application store, a single cloud provider, or a single hardware manufacturer.

OZERK's core belief is this:

> **Technology must not force people to conform to its order; it must adapt to people's choices, freedom, and lives.**

---

## 2. What Is OZERK?

OZERK is a mobile platform composed of open, mutually complementary components:

- **OZERK OS:** A Linux-based mobile operating system.
- **OZERK Shell:** The phone and convergent desktop user interface.
- **OZERK Guard:** The permission, network, privacy, and application control system.
- **OZERK App:** The open application packaging and capability declaration standard.
- **OZERK Store:** The user-facing application discovery and installation interface.
- **OZERK Repo:** Federated and cryptographically verified software repositories.
- **OZERK Push:** Provider-independent notification infrastructure.
- **OZERK Bridge:** An isolated Android compatibility environment, used when needed.
- **OZERK SDK:** Developer tools for native, web, and WebAssembly applications.
- **OZERK Foundation:** The independent body that safeguards the platform's principles and open standards.

OZERK is not merely an operating system.

OZERK shall be designed as:

- a model of user rights,
- an application security standard,
- a developer ecosystem,
- an open distribution system,
- an approach to hardware freedom,
- a governance model.

---

## 3. What OZERK Is Not

OZERK's boundaries are defined explicitly.

OZERK:

- Is not an Android distribution with Google services removed.
- Is not a system built around running Android applications.
- Is not a Linux experiment aimed only at technical users.
- Is not a closed application store controlled by another company.
- Is not a service that tries to bind the user to its own cloud.
- Is not "free" in the sense of a no-cost application distribution platform.
- Does not falsely claim that every hardware component is open source.
- Does not promise flawless security or absolute anonymity.
- Does not technically ban commercial software on ideological grounds.
- Is not a paternalistic system that makes decisions on the user's behalf.
- Does not accept the count of millions of applications as a measure of success.

OZERK's purpose is not to reproduce the existing mobile world as it is, but to build a more rightful mobile world.

---

## 4. Mission

OZERK's mission is:

> **To create a secure, open, and usable mobile ecosystem in which people can meet their everyday mobile needs without a mandatory account, a mandatory store, hidden telemetry, advertising tracking, or dependence on closed platforms.**

This mission rests on four fundamental goals:

1. To give the user real control over their device and their data.
2. To give the developer the ability to build and distribute software without depending on a single company's permission.
3. To reduce app dependence on services through open standards and web technologies.
4. To create long-lived, repairable, and updatable mobile devices.

---

## 5. Vision

OZERK's long-term vision is this:

- A phone must not require opening an account with any company in order to be usable.
- An application must not be able to send data to other companies without the user's knowledge.
- The user must be able to see not only which sensors an application accesses, but also which servers.
- The application store must not establish a monopoly over software distribution.
- Web services must not be condemned to exist only as Android or iOS applications.
- The developer must be able to run the same application on a phone, a tablet, and a Linux desktop.
- The user must be able to export their data in open formats and move it to another system.
- The software lifespan of a phone must not depend solely on the manufacturer's desire to sell new devices.
- Android must be usable when needed, but must not become the owner of the system.
- The mobile computer must once again be the user's personal computer.

---

## 6. OZERK's Fundamental Principles

### 6.1. User sovereignty

The owner of the device is the user.

The manufacturer, the operating system developer, the application store, or the cloud provider may not act as the owner of the device on the user's behalf.

The user must be able to:

- install their own software,
- add alternative repositories,
- replace the operating system,
- use their own verification keys,
- move their data,
- disable system services they do not want,
- use their device without deleting their account.

Security shall not be used as a justification for taking the right of ownership away from the user.

### 6.2. The right to use without an account

An OZERK device shall not ask for an online account at first boot.

The user shall be able to start using the phone by setting only a local password, PIN, or biometric protection.

None of the following shall be mandatory:

- an OZERK account,
- a manufacturer account,
- an e-mail address,
- phone number registration,
- a cloud subscription,
- an application store account,
- consent to personalized advertising.

Account use shall come into play only for optional services that require an account.

### 6.3. Privacy is not a default setting, but the base state

In OZERK, privacy shall not be a setting that is turned on afterwards.

The default system shall:

- not generate an advertising identifier,
- not build a user profile,
- not send usage history to a central server,
- not keep a location history,
- not analyze contacts,
- not automatically upload photographs to the cloud,
- not provide a cross-application tracking identifier,
- not send crash reports without explicit consent.

If the user wishes to share data, they must:

- see which data will be sent,
- know the recipient,
- be able to choose between one-time and continuous sharing,
- be able to revoke their decision later.

### 6.4. Open source and verifiable software

OZERK OS, the core system components, and the official base applications shall be open source.

However, publishing the source code alone is not sufficient.

The official distribution system shall, as far as possible, provide:

- building from source code,
- independent build verification,
- reproducible packages,
- a software bill of materials,
- signed update metadata,
- transparent release records.

The user must not be forced to trust that a published application was produced from the disclosed source code solely on the developer's word.

### 6.5. Openness against application store monopoly

OZERK Store shall not be the only source of software on OZERK.

The user shall be able to add:

- the official free software repository,
- a community repository,
- a university or institutional repository,
- a developer's own repository,
- a private repository they manage themselves.

An application developer shall be able to distribute their own software without obtaining permission from the OZERK Foundation or from the company developing OZERK.

OZERK shall make secure installation easy; it shall not prohibit independent distribution.

### 6.6. The web is a first-class application platform

OZERK shall not treat web applications as incomplete or second-class applications.

A web application shall be able to:

- be installed to the home screen,
- run in an independent application window,
- have its own storage area,
- work offline,
- receive notifications,
- participate in the system share interface,
- access the camera, microphone, and location with user permissions.

Each web application shall have its own separate:

- cookie space,
- permission set,
- network history,
- cache area,
- process group.

Removing a web application shall mean removing its local data and background privileges as well.

### 6.7. Native applications should be used where needed

Web technologies shall not be forced upon every need.

A native application may be preferred in the following cases:

- intensive hardware access,
- real-time audio or video processing,
- extended offline operation,
- low latency,
- advanced accessibility,
- local file management,
- professional productivity,
- system integration.

OZERK shall not wage an ideological war between web and native. The right technology shall be used for the right need.

### 6.8. Android is a guest

OZERK's foundation shall not be Android.

Android applications may be run inside OZERK Bridge when needed. However, this environment shall:

- not be installed by default,
- run in a separate data area,
- not have direct access to the user's contacts,
- not see the main file system,
- be subject to separate network rules,
- not continue living in the background when closed.

Android compatibility is a transition tool; it is not OZERK's permanent identity.

OZERK shall not promise to imitate other platforms' security attestations or to run every banking and DRM application.

### 6.9. Open protocols come before closed networks

OZERK shall not lock its users into a new closed communication network that can only talk to other OZERK users.

The default communication infrastructure shall, as far as possible, rest on interoperable standards such as:

- e-mail,
- Matrix,
- XMPP,
- SIP,
- WebRTC,
- WebDAV,
- CalDAV,
- CardDAV,
- open file sharing protocols.

If OZERK services shut down tomorrow, users' data and ability to communicate must not be lost.

### 6.10. Security is provided together with user control

OZERK does not define security as taking control away from the user.

The security model shall be built on:

- verified boot,
- encrypted user data,
- application sandboxing,
- the principle of least privilege,
- per-application network control,
- secure A/B updates,
- automatic rollback,
- cryptographic package verification,
- up-to-date security patches.

The user shall be able to enable developer mode, install their own operating system, and, on hardware where this is possible, re-lock their device with their own verification keys.

### 6.11. Data must be portable

OZERK shall not aim to store any user data in proprietary formats that lock it into its own ecosystem.

The user must be able to export the following:

- contacts,
- calendars,
- message backups,
- photographs,
- videos,
- notes,
- browser data,
- password and passkey backups,
- application settings,
- health and sensor data.

Open and documented formats shall be used wherever possible.

When a user wishes to leave OZERK, they must not lose their data.

### 6.12. The cloud is optional

OZERK may offer cloud features; but it may not make the cloud a mandatory part of the operating system.

The user may:

- use no cloud at all,
- take only local backups,
- back up to their own computer,
- use their own NAS device,
- run their own server,
- choose whichever service provider they wish,
- use the encrypted service offered by OZERK.

A cloud account is not the ownership key of the device.

### 6.13. Artificial intelligence shall not be a mandatory data collection channel

Artificial intelligence features on OZERK shall operate:

- optionally,
- clearly visibly,
- on-device where possible,
- with the data to be sent shown to the user,
- allowing choice of provider.

An AI feature may not silently send the microphone, photographs, messages, or documents to a remote server.

Local models, self-hosted models, and external provider options shall be clearly distinguished from one another.

### 6.14. Hardware realities shall not be hidden

A phone running Linux does not mean all of its hardware is free.

OZERK shall publish an explicit freedom inventory for every device:

- kernel status,
- GPU driver,
- Wi-Fi driver and firmware,
- baseband firmware,
- camera drivers,
- ISP components,
- bootloader status,
- verified boot options,
- user key support.

A device containing closed firmware shall not be marketed as "one hundred percent free."

Transparency is worth more than a claim of perfection.

### 6.15. Longevity and repairability

OZERK devices should not be designed for short product cycles.

Before a commercial OZERK device reaches the market, the following must be declared explicitly:

- the minimum update period,
- the security support period,
- the spare parts policy,
- the battery service method,
- the bootloader policy,
- the repair documentation.

The goal is to establish a hardware and software model capable of offering seven years or more of security support on commercial devices.

If this period cannot be supported by the hardware supply chain, the situation must not be hidden from the user.

### 6.16. Accessibility must be a core feature

Accessibility is not a module to be added later.

From the beginning, OZERK shall treat needs such as:

- a screen reader,
- high contrast,
- adjustable text size,
- hearing aid compatibility,
- captions,
- vibration and visual alerts,
- physical keyboards,
- switch-controlled use,
- voice control,
- color blindness accommodation

as part of the design system.

### 6.17. Localization and cultural openness

OZERK shall not be designed only for English-speaking technical users.

The translation system shall be:

- open to community contribution,
- consistent in terminology,
- supportive of right-to-left languages,
- compatible with local date, number, and measurement formats.

A language pack shall not bind the user to a particular country's service or to a central account.

---

## 7. OZERK Declaration of User Rights

Every OZERK user has the following rights:

1. The right to use the device without opening an account.
2. The right to install their own software.
3. The right to use alternative repositories.
4. The right to know the source code status of applications.
5. The right to see in advance which permissions an application requests.
6. The right to see which servers an application communicates with.
7. The right to review the usage history of the camera, microphone, and location.
8. The right to refuse telemetry.
9. The right to export their data in open formats.
10. The right to choose their own backup provider.
11. The right to unlock the device's bootloader and re-lock it on supported hardware.
12. The right not to automatically lose all warranty rights for using unofficial software.
13. The right to learn which changes updates make.
14. The right to refuse an update that expands the scope of permissions.
15. The right to completely remove an application and all of its local data.
16. The right to receive accurate information about vulnerabilities and support periods.
17. The right to leave OZERK services.
18. The right to be the administrator of their own device.

These rights are not marketing promises; they are acceptance criteria of product design.

---

## 8. Application Ecosystem

OZERK acknowledges that the number of applications is not the same thing as quality and practical value.

The success of a mobile ecosystem should not be measured by:

- how many millions of applications it has,
- how many games are in the store,
- how many similar photo filters it offers.

Success should be measured by this question:

> Can the user carry out the essential tasks of their daily life securely, comfortably, and independently?

### 8.1. Core system applications

OZERK's first mature release must fully provide at least the following functions:

- phone,
- SMS and, where needed, MMS,
- contacts,
- camera,
- gallery,
- file manager,
- web browser,
- e-mail,
- calendar,
- notes,
- clock and alarm,
- calculator,
- maps and navigation,
- music,
- video,
- PDF and document viewing,
- QR code and document scanning,
- audio recording,
- password and passkey management,
- TOTP authenticator,
- VPN,
- backup,
- application store,
- update manager,
- privacy center.

These applications shall be few in number, fast, consistent, and of high quality.

### 8.2. Four application classes

#### A. System applications

These are high-privilege components such as the phone, settings, updates, the permission manager, and the system interface.

They:

- are distributed with the operating system image,
- undergo dedicated security review,
- hold higher privileges than normal applications,
- are kept limited in number.

#### B. Native OZERK applications

These are applications that run on Linux and are distributed inside a sandbox.

GTK, Qt, Rust, C, C++, Go, Python, Flutter, and other suitable technologies may be used.

Through standard portals, the application:

- picks files,
- takes photographs,
- selects contacts,
- sends notifications,
- shares content,
- uses location.

Direct access to all user data shall not be the default.

#### C. Packaged web applications

These are applications produced, versioned, and signed from HTML, CSS, JavaScript, and WebAssembly sources.

They:

- can be built from source code by the store,
- can work offline,
- can be independently verified,
- can be updated like a normal application,
- can be developed without learning a native toolkit.

#### D. Hosted web applications

These run a remote web service like an independent application.

Each hosted web application has its own separate:

- storage,
- permissions,
- network history,
- cookies,
- cache.

The user is clearly informed that the application's code can be changed by the remote server.

### 8.3. Approach to closed-source applications

The official OZERK free software repository shall host only open source applications.

However, in the name of user freedom, the system shall not technically prohibit closed-source software.

For a closed-source application, the user shall be shown an explicit label:

- source code closed,
- build cannot be independently verified,
- known tracking services,
- the permissions it requests,
- the services it connects to,
- the update source.

Freedom is not imposing bans without informing the user; it is the user's ability to make an informed decision.

---

## 9. OZERK Guard: The Permission and Network Model

OZERK Guard is one of the platform's fundamental differentiating components.

In existing mobile systems, permissions mostly focus on sensor access:

- camera,
- microphone,
- location,
- contacts.

OZERK adds a second dimension to this:

> **Who may the application talk to on the internet?**

### 9.1. Permission options

Sensitive permissions shall, where possible, support the following options:

- deny,
- allow once,
- allow only while the application is open,
- allow for a limited time,
- always allow,
- allow only selected items.

For example, a messaging application should be able to receive the contacts the user selects instead of seeing all contacts.

A photo application should reach the photographs selected by the user instead of seeing the whole gallery.

### 9.2. Network access levels

Every application shall have one of the following network profiles:

1. **No network access**
2. **Only allowed domains**
3. **Ask the user for new domains**
4. **General internet access**
5. **Raw network access — a special high-risk privilege**

On the application screen, the user must be able to see:

- the domains connected to,
- the time of connection,
- the amount of data sent and received,
- blocked requests,
- newly added destinations.

OZERK shall not place fake certificates on the user's device in order to read network content. Covertly decrypting HTTPS content for security purposes shall not be a default method.

### 9.3. Privacy Center

The Privacy Center shall not show the user a single fancy but meaningless score.

Instead, it shall present verifiable information:

- connections blocked in the last 24 hours,
- applications using location,
- microphone and camera usage times,
- applications running in the background,
- the applications sending the most data,
- updates requesting new permissions,
- connections made to known tracking services.

The statement "No known trackers found" shall not mean "this application definitely does not track."

OZERK shall state only what it can observe and verify.

---

## 10. Security Approach

OZERK regards security not as an absolute promise but as a continuous process.

### 10.1. Threats the platform aims to protect against

OZERK aims to protect in particular against the following risks:

- malicious or over-privileged applications,
- advertising and tracking SDKs,
- device loss or theft,
- attacks on the network,
- compromised update servers,
- counterfeit packages,
- data leakage between applications,
- unauthorized sensor use,
- covert data transfer in the background.

### 10.2. Openly acknowledged limits

OZERK shall not claim absolute security in the following situations:

- devices physically seized and subjected to advanced laboratory attacks,
- unknown vulnerabilities inside closed baseband or firmware,
- broad privileges knowingly granted by the user,
- direct access performed while the device is unlocked,
- targeted state-level attacks,
- upstream kernel or hardware vulnerabilities,
- social engineering attacks that deceive the user.

Privacy is not anonymity. Nor does open source automatically mean secure.

### 10.3. Update security

OZERK OS shall use:

- signed full-system updates,
- A/B system partitions,
- automatic rollback on failed updates,
- a read-only base system,
- verified system integrity.

Application and system updates shall be manageable through separate channels.

If an application update requests broader permissions, the update shall not be applied automatically; the permission difference shall be shown to the user.

---

## 11. Android Transition Strategy

Android dependence shall not be ignored; but it shall not be enlarged either.

OZERK follows this order:

1. If an open and well-functioning web service exists, the web application is used.
2. If an open source native Linux application exists, it is preferred.
3. If an alternative service with an open protocol exists, it is offered to the user.
4. If the service works only through an Android application, OZERK Bridge may be used.

The purpose of OZERK Bridge is not to bind the user back to Android, but to isolate the few unavoidable applications during the transition period.

Full compatibility shall not be guaranteed for applications that demand banking, government identity, car control, DRM, or hardware attestation.

These limitations shall not be concealed at the time of product sale.

---

## 12. Developer Declaration

The OZERK developer is not a customer dependent on a platform owner's permission, but an equal partner in the ecosystem.

The developer's rights:

- to distribute their application independently,
- to set up their own repository,
- to choose their own payment provider,
- to access open and stable APIs,
- not to be forced into the store's own payment system,
- to run their application on the Linux desktop as well,
- not to be confined to a single programming language,
- to build paid products while keeping the source code open,
- to receive a clear and technical justification when an application is rejected,
- to learn about changes to platform rules in advance.

The OZERK SDK shall pursue the following aims:

- a low learning cost,
- good documentation,
- example applications,
- an emulator,
- automatic permission auditing,
- reproducible builds,
- security analysis,
- easy packaging,
- easy independent distribution.

An example developer flow:

```bash
ozerk init
ozerk run
ozerk test
ozerk permissions
ozerk build
ozerk verify
ozerk publish
```

---

## 13. Application Manifest

Every application shall declare its privileges explicitly before installation.

The manifest shall contain at least the following information:

- application identity,
- version,
- source code address,
- license,
- execution type,
- file access,
- camera access,
- microphone access,
- contact and calendar access,
- location precision,
- network access model,
- allowed domains,
- background execution conditions,
- notification privilege,
- telemetry declaration,
- advertising declaration,
- build verification status.

An application shall not be able to silently use a privilege it has not declared in the manifest.

If there is a difference between the declaration and the observed behavior, the user and the repository administrators shall be warned.

---

## 14. Repositories and Software Distribution

### 14.1. OZERK Free

This is the official free software repository.

Criteria:

- an open source license,
- buildability from source code,
- absence of tracking and advertising SDKs,
- explicit declaration of permissions,
- reproducible builds where possible,
- continued security updates.

### 14.2. OZERK Community

These are open source applications maintained by the community.

Points where verification as strong as the official repository's cannot be provided are shown explicitly.

### 14.3. External repositories

Companies, universities, developers, and users may run their own repositories.

OZERK verifies repository signatures and the chain of trust; but it does not claim that all external sources are safe.

### 14.4. Distribution security

The official process shall, as far as possible, include:

- an isolated build environment,
- an independent second build,
- output comparison,
- a software bill of materials,
- malware analysis,
- cryptographic signing,
- a transparency log.

---

## 15. Economic Freedom

Free software does not have to be free of charge.

OZERK developers may:

- sell applications,
- offer subscriptions,
- receive donations,
- sell support services,
- offer enterprise editions,
- provide hosting services.

OZERK Store:

- does not force the developer into a single payment system,
- does not impose mandatory high commissions,
- states its fee openly if it provides a payment service,
- does not turn the publication of free and open source applications into an instrument of commercial pressure.

OZERK itself may have the following revenue sources:

- device sales,
- accessories,
- long-term support,
- enterprise device management,
- optional encrypted cloud,
- technical support,
- secure hosting,
- hardware partnerships,
- low-cost payment infrastructure,
- public sector and institutional projects.

Selling user data shall not be a revenue model.

---

## 16. Hardware Principles

OZERK's long-term goal is not to remain merely a system ported to existing phones.

The principles targeted for a commercial OZERK device:

- a user-unlockable bootloader,
- re-locking with a user key where possible,
- upstream Linux support,
- documented modem interfaces,
- hardware virtualization,
- IOMMU,
- USB-C display output,
- easy battery replacement or serviceability,
- long-term parts supply,
- repair manuals,
- strong isolation between the modem and the main system,
- the option of hardware kill switches for the microphone, camera, and radios.

OZERK shall not ignore the dependencies created by hardware manufacturers' closed drivers.

---

## 17. The Convergent Computer Vision

OZERK is not only a mobile phone interface.

When the phone is connected to a monitor, keyboard, and mouse, it should be able to offer:

- a full desktop workspace,
- window management,
- a terminal,
- development tools,
- a file system,
- office applications,
- remote desktop,
- SSH,
- database clients.

The same device should be usable as:

- a phone,
- a tablet,
- a personal computer,
- a secure identity device,
- a development terminal.

This capability may not be a mandatory criterion for the first release; but the OZERK architecture shall be built from the outset so as not to preclude convergent use.

---

## 18. Notifications, Identity, and Synchronization

### 18.1. Notifications

The OZERK notification infrastructure shall not depend on a single company.

The user shall be able to choose:

- the OZERK provider,
- another provider,
- their own server.

An application must not be forced to use a particular commercial push service.

### 18.2. Identity

A central OZERK identity is not mandatory.

The system shall support open and portable identity methods such as:

- passkeys,
- WebAuthn,
- TOTP,
- SSH keys,
- client certificates,
- password managers.

### 18.3. Synchronization

Contacts, calendars, files, and notes must be synchronizable over:

- the local network,
- the user's computer,
- a NAS,
- WebDAV,
- CalDAV,
- CardDAV,
- a chosen cloud provider.

---

## 19. Governance

OZERK's technical and ethical principles cannot be left to the short-term commercial decisions of a single company.

For this reason, a two-layer structure is targeted.

### 19.1. OZERK Foundation

The duties of the foundation, or of an equivalent non-profit body:

- to protect the fundamental principles of the OZERK brand,
- to publish open standards,
- to manage the RFC process,
- to oversee the official free software repository,
- to manage security policies,
- to ensure community representation,
- to grant technical conformity certification.

### 19.2. Commercial companies

One or more companies may:

- manufacture devices,
- sell support,
- offer hosting services,
- develop enterprise solutions,
- release OZERK-compatible products.

No company may be the sole owner of the platform or its sole distribution gate.

### 19.3. Open decision process

Significant technical decisions shall be made through open RFC documents.

The first foundational RFCs:

- Platform Principles
- Application Sandbox Model
- Repository Trust Model
- Web Application Profile
- Notification Protocol
- Hardware Freedom Requirements
- Android Compatibility Boundary
- Governance and Brand Use
- Data Portability Standard
- Security Response Process

---

## 20. Brand Use Principle

The OZERK name may not be used to present users with claims of freedom or security that are not real.

For a device to be described as "OZERK compatible," at least the following conditions shall be required:

- no account requirement,
- no hidden telemetry,
- the ability for the user to install alternative software,
- disclosure of the official support period,
- implementation of the application sandbox model,
- preservation of repository freedom,
- support for data export,
- publication of the hardware freedom inventory.

The OZERK brand shall not be licensed to products that merely imitate the appearance while violating the principles.

---

## 21. Project Implementation Phases

### Phase 0 — Founding standards

- The manifesto and governance document
- The OZERK App manifest standard
- The security and permission model
- The repository standard
- The web application profile
- The hardware requirements

### Phase 1 — Emulator and developer system

- A bootable Linux-based system
- An OZERK Shell prototype
- Running native applications
- Installing web applications
- A basic permission manager
- The developer CLI and SDK

### Phase 2 — Reference phone

- Calls and SMS
- Mobile data
- Wi-Fi
- Bluetooth
- Camera
- GNSS
- Audio routing
- Suspend and power management
- Encrypted user data
- Secure updates

### Phase 3 — OZERK Guard

- Per-application network isolation
- Domain rules
- Selective file and contact portals
- Background budgets
- Sensor history
- The Privacy Center

### Phase 4 — Application ecosystem

- The official free repository
- Build infrastructure
- Reproducible packages
- Approximately 25 core applications
- A web application catalog
- Provider-independent push

### Phase 5 — User pilot

- Real everyday use
- Carrier testing
- Battery optimization
- Camera quality
- Bluetooth car and headset testing
- Update and rollback testing
- Accessibility testing

### Phase 6 — Commercial device

- Hardware manufacturer partnership
- Long-term support
- Repair and spare parts infrastructure
- Regulatory and carrier certifications
- User-controlled verified boot
- Warranty and service system

---

## 22. Measures of Success

OZERK's success shall not be measured by the number of applications.

The first real success shall be measured by a user being able to:

- set up the phone without opening an account,
- make calls reliably,
- exchange messages,
- use web services,
- take photographs and videos,
- use maps and navigation,
- manage e-mail and calendars,
- move their files,
- reach banking services at least through the secure web,
- audit the connections of their applications,
- back up their data to a destination of their own choosing,
- not lose their device when a system update fails.

Technical acceptance criteria:

- reliable incoming and outgoing calls,
- emergency call support,
- true screen-off suspend,
- an encrypted user area,
- verified OTA updates,
- automatic rollback,
- camera and video calls,
- Bluetooth audio,
- PWA installation and notifications,
- a denied permission being genuinely blocked,
- a blocked network destination being unreachable,
- package signatures being verified on the device,
- data being exportable in open formats.

---

## 23. OZERK's Red Lines

OZERK shall never:

1. Require an account in order to use the device.
2. Create an advertising identifier.
3. Make user data a revenue model.
4. Run hidden or mandatory telemetry.
5. Make a single application store mandatory.
6. Force the developer into its own payment system.
7. Make Android the mandatory foundation of the system.
8. Present closed firmware as if it were open.
9. Claim that software is automatically secure because its source code is open.
10. Promise the user absolute privacy or absolute anonymity.
11. Silently install an update that expands the scope of permissions.
12. Lock user data in a non-exportable form.
13. Prevent the user from running their own software for commercial reasons.
14. Abandon old devices in software solely in order to sell new devices.
15. Turn the user into a tenant of their own device in the name of security.

When one of these lines is crossed, the product is considered to have departed from the spirit of OZERK.

---

## 24. Commitment to Honesty

OZERK accepts the following facts from the outset:

- Hardware support for mobile Linux is hard.
- VoLTE, VoWiFi, and carrier compatibility are critical obstacles.
- Camera quality is not solved merely by the sensor working.
- Closed modem and firmware dependencies may not be entirely eliminated.
- Some banking and identity applications may not work.
- Some services may deliberately restrict web access.
- Android application compatibility may not be complete.
- Battery life and suspend support require serious per-device engineering.
- An open source community alone is not a guarantee of consumer-grade product quality.
- Security requires continuous updates and professional process.
- A good idea alone does not create an ecosystem.
- The promise that the web is a first-class application platform depends permanently on a browser engine that OZERK does not write and could not write; there are three engines under active maintenance in the world, and all three are funded by organisations vastly larger than OZERK. OZERK does not set the technical direction of the web platform.
- In a web-first system the browser engine is the largest attack surface, and every web application shares it; OZERK depends on upstream's cadence for patching that surface, and shall publish the measured patch delay.

OZERK shall not hide these difficulties, shall not downplay them, and shall not market unrealized features as if they existed.

Success is achieved not by denying reality, but by defining problems openly and solving them systematically.

---

## 25. Final Declaration

OZERK is not against technology.

OZERK is not against companies, commerce, application stores, cloud services, or paid software.

OZERK is against forced dependence.

The world OZERK stands for is this:

- Companies provide services; they do not take ownership of the user.
- Developers earn money; they are not condemned to a distribution monopoly.
- Applications provide functionality; they do not collect needless data.
- The cloud provides convenience; it does not become the key to the device.
- Security protects the user; it does not take authority away from the user.
- The hardware manufacturer sells a product; it does not limit the user's ownership of the device.
- The operating system works for the user instead of watching the user.

OZERK's purpose is not to build another ecosystem prison.

OZERK's purpose is to leave the exit door open.

> **OZERK is the project of a mobile world in which the user governs the applications, not one in which the applications govern the user.**

> **OZERK is the phone becoming a personal computer again.**

> **OZERK puts compatibility in the place of dependence; transparency in the place of tracking; user sovereignty in the place of asking permission.**

## OZERK

**Your phone. Your data. Your decision.**
