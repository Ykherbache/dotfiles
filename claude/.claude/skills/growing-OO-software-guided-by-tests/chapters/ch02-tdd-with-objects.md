# Ch 2: Test-Driven Development with Objects

## Core Argument

OO design is about communication between objects, not data and procedures. TDD with mock objects drives this communication-focused design.

## Key Frameworks

### Object Communication over Data Structure
An OO system is a web of collaborating objects. Each object has clearly defined responsibilities and communicates via messages. Focus on the protocols between objects, not their internal state.

### Tell, Don't Ask
Objects should send commands ("tell") rather than query state and make decisions for other objects ("ask"). Asking breaks encapsulation by pulling logic to the caller. Telling keeps behavior where the data is.

### Roles, Responsibilities, Collaborators
Design objects by thinking about:
1. **Roles** — what part does this object play?
2. **Responsibilities** — what does it own?
3. **Collaborators** — who does it talk to?

### Mock Objects as Design Tool
Mocks are not primarily for test isolation. They are a **design tool** that lets you:
- Discover interfaces between objects (what messages get sent)
- Specify communication protocols before implementing
- Drive outside-in development

### Object Peer Stereotypes
An object's peers fall into three categories:
- **Dependencies**: services the object needs to do its job (injected via constructor)
- **Notifications**: objects that need to know about changes (fire-and-forget)
- **Adjustments**: peers that tune behavior (policies, strategies)

## Design Heuristic
If you can't describe an object's role without "and," it has too many responsibilities. If mocking setup is complex, the object has too many collaborators.
