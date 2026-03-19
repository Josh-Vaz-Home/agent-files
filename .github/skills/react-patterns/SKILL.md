---
name: react-patterns
description: "React and TypeScript implementation examples for Vite SPAs. Use for component structure, route modules, loader/action flows, hook extraction, prop typing, React Hook Form + Zod patterns, accessibility-minded UI patterns, and client-side auth/session boundaries."
---

# React Patterns

## When to use

- Designing or refactoring React components
- Designing route modules and loader/action flows
- Extracting hooks or clarifying prop contracts
- Making UI behavior more accessible, maintainable, and type-safe

## CLI references

- `npm run dev`
- `npm run build`
- `npm run typecheck`

## Guidance

- Assume a Vite SPA with React 19, Node.js 22+, React Router, and the latest stable TypeScript.
- Use typed props and narrow unions.
- Use semantic markup before extra ARIA.
- Use route loaders/actions when the route owns the data or mutation; use component hooks for local or isolated behavior.
- Use React Hook Form + Zod when forms involve server validation, conditional fields or steps, async side effects, or advanced inputs.
- Keep auth/session logic in a thin hook/context layer backed by session endpoints.
- If Browser or DevTools MCP tools are available in the adopted workspace, use them for DOM, console, network, and storage inspection while validating UI behavior.
- If HTTP or OpenAPI MCP tools are available, use them to inspect response shape and schema contracts before assuming a backend change is required.
- Use headless, accessible primitives when abstraction is needed.
- Tailwind CSS plus design tokens/CSS variables is the default greenfield styling path.
- Build mobile-first, make loading/empty/error states explicit, and keep motion intentional.

## Compact patterns

### Route module pattern

- Let `src/routes/**` own loaders/actions, redirects, and route-level auth decisions.
- Keep page components focused on rendering `useLoaderData()` results and user interaction.

```tsx
import { redirect } from "react-router-dom";
import type { LoaderFunctionArgs } from "react-router-dom";

export async function loader({ request }: LoaderFunctionArgs) {
  const session = await requireSession(request);
  if (!session.roles.includes("owner")) throw redirect("/forbidden");
  return billingService.getSummary(session.accountId);
}
```

### Form pattern

- Start with a Zod schema, wire it into React Hook Form, and map server validation failures back into field or form state.
- Keep labels, descriptions, and error announcements explicit instead of hiding them in custom magic.

```tsx
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

const inviteMemberSchema = z.object({
  email: z.string().email("Enter a valid email address."),
  role: z.enum(["admin", "member"]),
});

type InviteMemberValues = z.infer<typeof inviteMemberSchema>;

export function InviteMemberForm(): JSX.Element {
  const form = useForm<InviteMemberValues>({
    resolver: zodResolver(inviteMemberSchema),
    defaultValues: { email: "", role: "member" },
  });

  const emailError = form.formState.errors.email?.message;

  const onSubmit = form.handleSubmit(async (values) => {
    const result = await inviteMember(values);

    if (!result.ok && result.fieldErrors.email) {
      form.setError("email", {
        type: "server",
        message: result.fieldErrors.email,
      });
    }
  });

  return (
    <form onSubmit={onSubmit} noValidate>
      <label htmlFor="invite-email">Email</label>
      <p id="invite-email-hint">Use the teammate's work email.</p>
      <input
        id="invite-email"
        type="email"
        aria-describedby={
          emailError
            ? "invite-email-hint invite-email-error"
            : "invite-email-hint"
        }
        aria-invalid={emailError ? true : undefined}
        {...form.register("email")}
      />
      {emailError ? (
        <p id="invite-email-error" role="alert">
          {emailError}
        </p>
      ) : null}

      <label htmlFor="invite-role">Role</label>
      <select id="invite-role" {...form.register("role")}>
        <option value="member">Member</option>
        <option value="admin">Admin</option>
      </select>

      <button type="submit" disabled={form.formState.isSubmitting}>
        Send invite
      </button>
    </form>
  );
}
```

### Auth/session pattern

- Prefer `useAuth()` or equivalent thin context wrappers that read backend/BFF session state.
- Keep role checks simple, reviewable, and close to route or layout boundaries.
- Redirect at the route boundary when the user should not reach the page at all. Use section-level gating only for controls inside an otherwise valid screen.

```tsx
import type { ReactNode } from "react";

type AuthState = {
  user: User | null;
  roles: string[];
  isLoading: boolean;
  login(): Promise<void>;
  logout(): Promise<void>;
  refreshSession(): Promise<void>;
};

export function useAuth(): AuthState {
  return useAuthContext();
}

export function OwnerOnly({
  children,
}: {
  children: ReactNode;
}): JSX.Element | null {
  const { roles, isLoading } = useAuth();
  if (isLoading) return null;
  return roles.includes("owner") ? <>{children}</> : null;
}
```

### React state and render cues

- Derive display values during render instead of mirroring them through `useEffect`.

```tsx
const fullName = `${firstName} ${lastName}`;
```

- Put click- or submit-triggered side effects in the handler that caused them. Use `useEffect` for subscriptions, timers, and external synchronization.

```tsx
async function handleSave() {
  await saveProfile(values);
  toast.success("Profile saved.");
}
```

- Use functional `setState` updates when the next value depends on the current value. This keeps callbacks stable and avoids stale closures.

```tsx
const addTag = useCallback((tag: string) => {
  setTags((current) => [...current, tag]);
}, []);
```

- Use lazy `useState` initialization for storage-backed or expensive initial values.

```tsx
const [draft, setDraft] = useState(() => loadDraftFromStorage());
```

- Do not define child components inside parent components. Extract them and pass the data they need as props.

```tsx
function MemberRow({ member }: { member: Member }) {
  return <li>{member.name}</li>;
}
```

- Prefer immutable transforms like `toSorted()` when reshaping props or state for render, and keep effect dependencies narrow when only a primitive or derived boolean matters.

### UI polish cues

- Keep spacing and typography rhythm consistent across screens.
- Build mobile-first and make breakpoint changes explicit at `sm`, `md`, and `lg`.
- Make empty/loading/error states intentional, not placeholders.
- Use light transitions only when they clarify state change and still respect reduced-motion preferences.

## Decision cues

- Use a route loader/action when multiple route-level components consume the data, the route owns the redirect or mutation, or auth must be decided before render.
- Use a component hook when the behavior is reusable, local to one subtree, or too small to deserve route ownership.
- Extract a shared primitive on first clear reuse or when logic exceeds roughly 30 lines and the contract is stable.
