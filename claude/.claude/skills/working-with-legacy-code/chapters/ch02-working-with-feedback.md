# Chapter 2: Working with Feedback

## Two Ways to Make Changes

| Approach | Description | Risk |
|----------|-------------|------|
| **Edit and Pray** | Plan carefully, make changes, manually verify | High — no safety net |
| **Cover and Modify** | Write tests first, make changes, get instant feedback | Low — tests catch errors |

## The Software Vise

Tests act as a **vise** — they clamp behavior in place so you change only what you intend.

## Unit Test Qualities

1. **They run fast** — a slow unit test is 1/10th of a second
2. **They help localize problems** — failures point to the cause

A test is NOT a unit test if it: talks to a database, communicates across a network, touches the file system, or requires special environment setup.

## The Legacy Code Dilemma

> When we change code, we should have tests in place. To put tests in place, we often have to change code.

## The Legacy Code Change Algorithm

1. **Identify change points** — where you need to modify code
2. **Find test points** — where you can observe effects
3. **Break dependencies** — remove obstacles to testing
4. **Write tests** — characterize existing behavior
5. **Make changes and refactor** — with confidence

This is the master algorithm of the entire book. Every chapter supports one or more of these steps.
