---
type: entity
domain: research
created: 2026-01-15
updated: 2026-03-20
sources:
  - "[[raw/research/papers/2026-01-15-react-hooks-deep-dive.md]]"
tags: [tool, frontend]
aliases: [React.js, ReactJS]
---
# React

## Overview

React is a JavaScript library for building user interfaces, maintained by Meta. It introduced the component-based architecture and virtual DOM concepts that revolutionized frontend development.

## Key Facts

- **Maintainer**: Meta (Facebook)
- **First release**: 2013
- **Current version**: 19.x (as of 2026)
- **Key concepts**: Components, Hooks, Virtual DOM, JSX
- **Ecosystem**: Next.js, Remix, React Native

## Notes

- Prefer functional components with hooks over class components
- `useEffect` cleanup is critical for avoiding memory leaks
- Server Components (React 19) change the mental model significantly — components can run on the server without shipping JS to the client
- [[TypeScript]] integration is essentially mandatory for any serious project

## Related

- [[TypeScript]]
- [[Next.js]]
- [[Frontend-Best-Practices]]
