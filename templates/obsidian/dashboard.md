# Wiki Dashboard

> [!tip] This page uses **Dataview** plugin queries. Make sure Dataview is enabled in Settings → Community plugins.

## Recently Updated

```dataview
TABLE type, domain, updated, length(sources) AS "Sources"
FROM "wiki"
WHERE type
SORT updated DESC
LIMIT 15
```

## All Entities

```dataview
TABLE domain, updated, tags
FROM "wiki/entities"
SORT file.name ASC
```

## All Concepts

```dataview
TABLE domain, updated, tags
FROM "wiki/concepts"
SORT file.name ASC
```

## All Topics

```dataview
TABLE domain, updated, tags
FROM "wiki/topics"
SORT file.name ASC
```

## All Syntheses

```dataview
TABLE domain, created, tags
FROM "wiki/syntheses"
SORT created DESC
```

## Pages by Domain

```dataview
TABLE length(rows) AS "Pages"
FROM "wiki"
WHERE type
GROUP BY domain
```

## Pages by Type

```dataview
TABLE length(rows) AS "Count"
FROM "wiki"
WHERE type
GROUP BY type
```

## Stale Pages (not updated in 90+ days)

```dataview
TABLE type, domain, updated
FROM "wiki"
WHERE type AND date(now) - updated > dur(90 days)
SORT updated ASC
```

## Pages Without Sources

```dataview
TABLE type, domain
FROM "wiki"
WHERE type AND (!sources OR length(sources) = 0)
SORT file.name ASC
```
